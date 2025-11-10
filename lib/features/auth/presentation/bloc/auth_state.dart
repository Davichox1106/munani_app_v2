import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando autenticación
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado: Cargando (procesando login, registro, etc.)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado: Usuario autenticado
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado: Usuario no autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado: Error de autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado: Registro exitoso (muestra mensaje y redirige a login)
class AuthRegistered extends AuthState {
  final String message;

  const AuthRegistered({
    this.message = 'Registro exitoso. Por favor verifica tu email.',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado: Password reset email enviado
class AuthPasswordResetSent extends AuthState {
  final String message;

  const AuthPasswordResetSent({
    this.message = 'Email de recuperación enviado. Revisa tu bandeja de entrada.',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado: Perfil actualizado
class AuthProfileUpdated extends AuthState {
  final User user;
  final String message;

  const AuthProfileUpdated({
    required this.user,
    this.message = 'Perfil actualizado exitosamente',
  });

  @override
  List<Object?> get props => [user, message];
}
