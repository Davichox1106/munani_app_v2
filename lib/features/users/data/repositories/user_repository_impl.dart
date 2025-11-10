import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/database/isar_database.dart';
import '../../../auth/domain/entities/user.dart' as auth;
import '../../../sync/domain/entities/sync_queue_item.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../domain/entities/user.dart' as user_management;
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de usuarios (hybrid offline-first)
///
/// Estrategia híbrida por seguridad:
/// - **Lectura**: Offline-first (lee de Isar, sincroniza en background)
/// - **Creación**: Requiere internet (Supabase Auth para seguridad)
/// - **Actualización**: Offline-first (Isar + cola de sincronización)
/// 
/// OWASP A02:2021 - Cryptographic Failures:
/// - Creación de usuarios SOLO con Supabase Auth (hash seguro de passwords)
/// - No almacenamos passwords localmente
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final IsarDatabase isarDatabase;
  final SyncRepository syncRepository;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.isarDatabase,
    required this.syncRepository,
  });

  @override
  Stream<List<user_management.User>> watchAllUsers() {
    return localDataSource.watchAllUsers().map(
      (localUsers) => localUsers.map((u) => u.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, List<user_management.User>>> getAllUsers() async {
    try {
      // 1. Obtener datos locales primero (offline-first)
      final localUsers = await localDataSource.getAllUsers();
      AppLogger.debug('📦 UserRepository: ${localUsers.length} usuarios en caché local');
      
      // 2. Si hay conexión, intentar sincronizar
      if (await networkInfo.isConnected) {
        AppLogger.debug('🌐 UserRepository: Hay conexión, sincronizando usuarios desde servidor...');
        try {
          final remoteUsers = await remoteDataSource.getAllUsers();
          AppLogger.info('✅ UserRepository: ${remoteUsers.length} usuarios descargados del servidor');
          
          // 3. Actualizar datos locales con datos remotos
          for (final remoteUser in remoteUsers) {
            // Convertir de auth.User a user_management.User
            final userManagementUser = _convertAuthUserToUserManagement(remoteUser);
            final localUser = UserManagementLocalModel.fromEntity(userManagementUser);
            await localDataSource.saveUser(localUser);
          }
          AppLogger.debug('💾 UserRepository: Usuarios guardados en caché local');
          
          // 4. Retornar datos actualizados
          final updatedUsers = await localDataSource.getAllUsers();
          AppLogger.info('📤 UserRepository: Retornando ${updatedUsers.length} usuarios actualizados');
          return Right(updatedUsers.map((u) => u.toEntity()).toList());
        } catch (e) {
          // Si falla la sincronización, retornar datos locales
          AppLogger.error('⚠️ Error en sincronización de usuarios: $e');
          AppLogger.info('📤 UserRepository: Retornando ${localUsers.length} usuarios del caché local');
        }
      } else {
        AppLogger.debug('📴 UserRepository: Sin conexión, usando caché local');
      }
      
      // 5. Retornar datos locales (offline)
      AppLogger.info('📤 UserRepository: Retornando ${localUsers.length} usuarios del caché local');
      return Right(localUsers.map((u) => u.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Error al obtener usuarios: $e'));
    }
  }

  @override
  Future<Either<Failure, user_management.User>> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedLocationId,
    String? assignedLocationType,
  }) async {
    try {
      AppLogger.debug('📝 UserRepository: Creando usuario - $name ($role)');
      
      // ⚠️ IMPORTANTE: La creación de usuarios REQUIERE internet
      // porque usa Supabase Auth para seguridad (hash password, etc.)
      final isConnected = await networkInfo.isConnected;
      
      if (!isConnected) {
        AppLogger.error('❌ Sin conexión - no se puede crear usuario (requiere Supabase Auth)');
        return const Left(NetworkFailure(
          'Se requiere conexión a internet para crear usuarios. '
          'Los usuarios deben autenticarse con Supabase Auth por seguridad.'
        ));
      }
      
      AppLogger.debug('🌐 Con conexión - creando usuario en Supabase Auth...');

      // 1. Crear usuario en Supabase Auth (genera UUID seguro y hashea password)
      final remoteUser = await remoteDataSource.createUser(
        email: email,
        password: password,
        name: name,
        role: role,
        assignedLocationId: assignedLocationId,
        assignedLocationType: assignedLocationType,
      );
      
      AppLogger.info('✅ Usuario creado en Supabase Auth: ${remoteUser.email}');

      // 2. Guardar en caché local para acceso offline
      final userManagementUser = _convertAuthUserToUserManagement(remoteUser);
      final localUser = UserManagementLocalModel.fromEntity(userManagementUser);
      localUser.markAsSynced(); // Ya está sincronizado
      
      await localDataSource.saveUser(localUser);
      AppLogger.debug('💾 Usuario guardado en caché local');
      
      return Right(userManagementUser);
    } on ServerException catch (e) {
      AppLogger.error('❌ Error del servidor: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('❌ Error al crear usuario: $e');
      return Left(ServerFailure('Error al crear usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, user_management.User>> updateUser({
    required String userId,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
  }) async {
    try {
      // 1. Obtener usuario local
      final localUser = await localDataSource.getUserById(userId);
      if (localUser == null) {
        return Left(CacheFailure('Usuario no encontrado localmente'));
      }

      // 2. Actualizar datos localmente
      localUser.updateData(
        name: name,
        role: role,
        assignedLocationId: assignedLocationId,
        assignedLocationType: assignedLocationType,
        isActive: isActive,
      );

      // 3. Guardar cambios locales
      final updatedUser = await localDataSource.saveUser(localUser);

      // 4. Si hay conexión, sincronizar inmediatamente
      if (await networkInfo.isConnected) {
        try {
          final remoteUser = await remoteDataSource.updateUser(
            userId: userId,
            name: name,
            role: role,
            assignedLocationId: assignedLocationId,
            assignedLocationType: assignedLocationType,
            isActive: isActive,
          );

          // 5. Actualizar usuario local con datos del servidor
          final userManagementUser = _convertAuthUserToUserManagement(remoteUser);
          final syncedLocalUser = UserManagementLocalModel.fromEntity(userManagementUser);
          syncedLocalUser.id = updatedUser.id; // Preservar ID de Isar
          syncedLocalUser.markAsSynced();
          
          await localDataSource.saveUser(syncedLocalUser);
          
          return Right(userManagementUser);
        } catch (e) {
          // Si falla la sincronización, el usuario queda pendiente
          AppLogger.error('⚠️ Error en sincronización de actualización de usuario: $e');
          return Right(updatedUser.toEntity());
        }
      } else {
        // 5. Sin conexión: agregar a cola de sincronización
        await _addToSyncQueue(
          entityType: SyncEntityType.user,
          entityId: userId,
          operation: SyncOperation.update,
          data: {
            if (name != null) 'name': name,
            if (role != null) 'role': role,
            if (assignedLocationId != null) 'assigned_location_id': assignedLocationId,
            if (assignedLocationType != null) 'assigned_location_type': assignedLocationType,
            if (isActive != null) 'is_active': isActive,
          },
        );
        
        return Right(updatedUser.toEntity());
      }
    } catch (e) {
      return Left(CacheFailure('Error al actualizar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateUser(String userId) async {
    try {
      // 1. Obtener usuario local
      final localUser = await localDataSource.getUserById(userId);
      if (localUser == null) {
        return Left(CacheFailure('Usuario no encontrado localmente'));
      }

      // 2. Desactivar localmente
      localUser.deactivate();
      await localDataSource.saveUser(localUser);

      // 3. Si hay conexión, sincronizar inmediatamente
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deactivateUser(userId);
          
          // 4. Marcar como sincronizado
          localUser.markAsSynced();
          await localDataSource.saveUser(localUser);
          
          return const Right(null);
        } catch (e) {
          // Si falla la sincronización, el usuario queda pendiente
          AppLogger.error('⚠️ Error en sincronización de desactivación de usuario: $e');
          return const Right(null);
        }
      } else {
        // 4. Sin conexión: agregar a cola de sincronización
        await _addToSyncQueue(
          entityType: SyncEntityType.user,
          entityId: userId,
          operation: SyncOperation.update,
          data: {'is_active': false},
        );
        
        return const Right(null);
      }
    } catch (e) {
      return Left(CacheFailure('Error al desactivar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, user_management.User>> getUserById(String userId) async {
    try {
      // 1. Buscar localmente primero
      final localUser = await localDataSource.getUserById(userId);
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // 2. Si no está localmente y hay conexión, buscar en servidor
      if (await networkInfo.isConnected) {
        try {
          final remoteUser = await remoteDataSource.getUserById(userId);
          
          // 3. Guardar localmente para futuras consultas
          final userManagementUser = _convertAuthUserToUserManagement(remoteUser);
          final localUser = UserManagementLocalModel.fromEntity(userManagementUser);
          await localDataSource.saveUser(localUser);
          
          return Right(userManagementUser);
        } catch (e) {
          return Left(ServerFailure('Usuario no encontrado: $e'));
        }
      }

      return Left(CacheFailure('Usuario no encontrado localmente y sin conexión'));
    } catch (e) {
      return Left(CacheFailure('Error al obtener usuario: $e'));
    }
  }

  /// Convertir auth.User a user_management.User
  user_management.User _convertAuthUserToUserManagement(auth.User authUser) {
    return user_management.User(
      id: authUser.id,
      email: authUser.email,
      name: authUser.name,
      role: authUser.role,
      assignedLocationId: authUser.assignedLocationId,
      assignedLocationType: authUser.assignedLocationType,
      isActive: authUser.isActive,
      createdAt: authUser.createdAt,
      updatedAt: authUser.updatedAt,
    );
  }

  /// Agregar operación a la cola de sincronización
  Future<void> _addToSyncQueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        createdAt: DateTime.now(),
        priority: SyncPriority.normal,
      );

      AppLogger.debug('📝 Agregando a cola de sync: ${entityType.name}/$entityId/${operation.name}');
      await syncRepository.addToQueue(syncItem);
      AppLogger.info('✅ Item agregado a cola de sincronización');
    } catch (e) {
      AppLogger.error('⚠️ Error al agregar a cola de sincronización: $e');
    }
  }
}