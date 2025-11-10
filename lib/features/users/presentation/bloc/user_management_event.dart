import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de gestión de usuarios
abstract class UserManagementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Evento para cargar todos los usuarios
class LoadUsers extends UserManagementEvent {}

/// Evento para crear un nuevo usuario
class CreateUser extends UserManagementEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  final String? assignedLocationId;
  final String? assignedLocationType;

  CreateUser({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.assignedLocationId,
    this.assignedLocationType,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        name,
        role,
        assignedLocationId,
        assignedLocationType,
      ];
}

/// Evento para actualizar un usuario
class UpdateUser extends UserManagementEvent {
  final String userId;
  final String? name;
  final String? role;
  final String? assignedLocationId;
  final String? assignedLocationType;
  final bool? isActive;

  UpdateUser({
    required this.userId,
    this.name,
    this.role,
    this.assignedLocationId,
    this.assignedLocationType,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        role,
        assignedLocationId,
        assignedLocationType,
        isActive,
      ];
}

/// Evento para desactivar un usuario
class DeactivateUser extends UserManagementEvent {
  final String userId;

  DeactivateUser(this.userId);

  @override
  List<Object?> get props => [userId];
}



