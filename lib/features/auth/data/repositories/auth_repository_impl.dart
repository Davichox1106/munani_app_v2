import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de autenticación con Offline-First
///
/// **Patrón Offline-First:**
/// 1. Login: Autentica en Supabase → Guarda en Isar
/// 2. GetCurrentUser: Lee PRIMERO de Isar (offline) → Sincroniza con Supabase si hay conexión
/// 3. Logout: Limpia Isar Y cierra sesión Supabase
///
/// OWASP A04:2021 - Insecure Design:
/// Diseño Offline-First asegura disponibilidad y resiliencia
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    // Login requiere conexión
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      // 1. Autenticar en Supabase
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // 2. Guardar en Isar para acceso offline
      final localModel = UserLocalModel.fromEntity(userModel);
      await localDataSource.cacheUser(localModel);

      return Right(userModel);
    } on AuthException catch (e) {
      // OWASP A07: Mensajes de error genéricos
      if (e.message.contains('Invalid login credentials')) {
        return const Left(
          InvalidCredentialsFailure('Email o contraseña incorrectos'),
        );
      }
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    // Registro requiere conexión
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      // 1. Registrar en Supabase
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      // 2. Guardar en Isar
      final localModel = UserLocalModel.fromEntity(userModel);
      await localDataSource.cacheUser(localModel);

      return Right(userModel);
    } on AuthException catch (e) {
      if (e.message.contains('weak password')) {
        return const Left(
          WeakPasswordFailure('La contraseña no cumple los requisitos mínimos'),
        );
      }
      if (e.message.contains('already registered')) {
        return const Left(
          ConflictFailure('Este email ya está registrado'),
        );
      }
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // 1. Limpiar caché local (SIEMPRE funciona, incluso offline)
      await localDataSource.deleteCachedUser();

      // 2. Cerrar sesión en Supabase (si hay conexión)
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          // Si falla el logout remoto, no es crítico
          // El usuario ya se limpió de Isar
          AppLogger.error('Advertencia: Error al cerrar sesión en Supabase: $e');
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // **OFFLINE-FIRST: Leer PRIMERO de Isar**
      final cachedUser = await localDataSource.getCachedUser();

      if (cachedUser != null) {
        // Usuario en caché encontrado
        final user = cachedUser.toEntity();

        // Sincronizar con Supabase en background si hay conexión
        _syncUserInBackground(cachedUser.uuid);

        return Right(user);
      }

      // No hay usuario en caché, intentar obtener de Supabase
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.getCurrentUser();

        // Guardar en Isar para próximas veces
        final localModel = UserLocalModel.fromEntity(userModel);
        await localDataSource.cacheUser(localModel);

        return Right(userModel);
      }

      // Sin caché y sin conexión
      return const Left(AuthFailure('No hay sesión activa'));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  /// Sincroniza el usuario con Supabase en background
  /// No bloquea la UI si falla
  Future<void> _syncUserInBackground(String uuid) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteUser = await remoteDataSource.getCurrentUser();

        // Actualizar caché con datos más recientes
        final localModel = UserLocalModel.fromEntity(remoteUser);
        await localDataSource.updateCachedUser(localModel);
      }
    } catch (e) {
      // No es crítico si falla la sincronización en background
      AppLogger.debug('Info: No se pudo sincronizar usuario: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? assignedLocationId,
    String? assignedLocationType,
  }) async {
    // Actualización requiere conexión
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      // Obtener usuario actual
      final currentUserResult = await getCurrentUser();

      return await currentUserResult.fold(
        (failure) => Left(failure),
        (currentUser) async {
          // Actualizar en Supabase
          final updatedUserModel = await remoteDataSource.updateProfile(
            userId: currentUser.id,
            name: name,
            assignedLocationId: assignedLocationId,
            assignedLocationType: assignedLocationType,
          );

          // Actualizar en Isar
          final localModel = UserLocalModel.fromEntity(updatedUserModel);
          await localDataSource.updateCachedUser(localModel);

          return Right(updatedUserModel);
        },
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Cambio de contraseña requiere conexión
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final currentUserResult = await getCurrentUser();

      return await currentUserResult.fold(
        (failure) => Left(failure),
        (currentUser) async {
          // Verificar contraseña actual
          final loginResult = await login(
            email: currentUser.email,
            password: currentPassword,
          );

          return await loginResult.fold(
            (failure) => const Left(
              InvalidCredentialsFailure('La contraseña actual es incorrecta'),
            ),
            (_) async {
              await remoteDataSource.changePassword(newPassword: newPassword);
              return const Right(null);
            },
          );
        },
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    // Reset requiere conexión
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
