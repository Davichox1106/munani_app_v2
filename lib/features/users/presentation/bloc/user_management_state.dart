import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart' as user_management;
import '../../domain/entities/enriched_user.dart';

/// Estados para el BLoC de gestión de usuarios
abstract class UserManagementState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UserManagementInitial extends UserManagementState {}

/// Estado de carga
class UserManagementLoading extends UserManagementState {}

/// Estado cuando los usuarios han sido cargados
class UsersLoaded extends UserManagementState {
  final List<user_management.User> users;

  UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

/// Estado cuando los usuarios enriquecidos han sido cargados
class EnrichedUsersLoaded extends UserManagementState {
  final List<EnrichedUser> enrichedUsers;

  EnrichedUsersLoaded(this.enrichedUsers);

  @override
  List<Object?> get props => [enrichedUsers];
}

/// Estado cuando un usuario ha sido creado exitosamente
class UserCreated extends UserManagementState {
  final user_management.User user;
  final String message;

  UserCreated({
    required this.user,
    this.message = 'Usuario creado exitosamente',
  });

  @override
  List<Object?> get props => [user, message];
}

/// Estado cuando un usuario ha sido actualizado exitosamente
class UserUpdated extends UserManagementState {
  final user_management.User user;
  final String message;

  UserUpdated({
    required this.user,
    this.message = 'Usuario actualizado exitosamente',
  });

  @override
  List<Object?> get props => [user, message];
}

/// Estado cuando un usuario ha sido desactivado exitosamente
class UserDeactivated extends UserManagementState {
  final String message;

  UserDeactivated({
    this.message = 'Usuario desactivado exitosamente',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class UserManagementError extends UserManagementState {
  final String message;

  UserManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

