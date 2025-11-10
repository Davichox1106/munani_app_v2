import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repositorio de autenticación - Interfaz (Contrato)
///
/// Define las operaciones de autenticación que deben ser implementadas
/// por la capa de datos. Sigue el principio de inversión de dependencias (DIP).
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  ///
  /// OWASP A07:2021 - Identification and Authentication Failures:
  /// - Implementa autenticación segura con JWT
  /// - Valida credenciales en el servidor
  /// - No almacena contraseñas en texto plano
  ///
  /// Returns:
  /// - Right(User): Si el login es exitoso
  /// - Left(Failure): Si ocurre un error (InvalidCredentialsFailure, NetworkFailure, etc.)
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  ///
  /// OWASP A07:2021 - Identification and Authentication Failures:
  /// - Valida que la contraseña cumpla requisitos de seguridad
  /// - Verifica que el email no esté duplicado
  ///
  /// Returns:
  /// - Right(User): Si el registro es exitoso
  /// - Left(Failure): Si ocurre un error
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  /// Cierra la sesión del usuario actual
  ///
  /// Returns:
  /// - Right(void): Si el logout es exitoso
  /// - Left(Failure): Si ocurre un error
  Future<Either<Failure, void>> logout();

  /// Obtiene el usuario actual autenticado
  ///
  /// Returns:
  /// - Right(User): Si hay un usuario autenticado
  /// - Left(AuthFailure): Si no hay sesión activa
  /// - Left(NetworkFailure): Si hay error de red
  Future<Either<Failure, User>> getCurrentUser();

  /// Stream que emite el estado de autenticación
  ///
  /// Emite:
  /// - User cuando el usuario está autenticado
  /// - null cuando no hay sesión activa
  Stream<User?> get authStateChanges;

  /// Actualiza el perfil del usuario actual
  ///
  /// Returns:
  /// - Right(User): Usuario actualizado
  /// - Left(Failure): Si ocurre un error
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? assignedLocationId,
    String? assignedLocationType,
  });

  /// Cambia la contraseña del usuario actual
  ///
  /// OWASP A07:2021 - Identification and Authentication Failures:
  /// - Requiere contraseña actual para verificación
  /// - Valida que la nueva contraseña sea segura
  ///
  /// Returns:
  /// - Right(void): Si el cambio es exitoso
  /// - Left(Failure): Si ocurre un error
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Solicita recuperación de contraseña por email
  ///
  /// Returns:
  /// - Right(void): Si el email de recuperación fue enviado
  /// - Left(Failure): Si ocurre un error
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });
}
