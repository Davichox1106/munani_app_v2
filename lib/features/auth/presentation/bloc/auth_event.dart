import 'package:equatable/equatable.dart';

/// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Verificar estado de autenticación al iniciar app
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento: Login solicitado
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento: Registro solicitado
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

/// Evento: Logout solicitado
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento: Actualización de perfil solicitada
class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? assignedLocationId;
  final String? assignedLocationType;

  const AuthUpdateProfileRequested({
    this.name,
    this.assignedLocationId,
    this.assignedLocationType,
  });

  @override
  List<Object?> get props => [name, assignedLocationId, assignedLocationType];
}

/// Evento: Cambio de contraseña solicitado
class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Evento: Recuperación de contraseña solicitada
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
