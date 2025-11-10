import 'package:equatable/equatable.dart';

/// Clase base para todos los errores de la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error de servidor (500)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Error de caché/base de datos local
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder a los datos locales']);
}

/// Error de red/conexión
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión']);
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Credenciales inválidas
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(
      [super.message = 'Credenciales inválidas']);
}

/// Contraseña débil
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure(
      [super.message = 'La contraseña es muy débil']);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

/// No encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Error de permisos
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Sin permisos suficientes']);
}

/// Error de sincronización
class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Error al sincronizar']);
}

/// Error de conflicto (409)
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflicto de datos']);
}
