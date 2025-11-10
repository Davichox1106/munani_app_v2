import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart' as user_management;

/// Repositorio para gestión de usuarios
///
/// Define las operaciones CRUD disponibles para usuarios
/// Solo accesible por Administradores
abstract class UserRepository {
  /// Obtener todos los usuarios del sistema
  Future<Either<Failure, List<user_management.User>>> getAllUsers();

  /// Observar cambios en usuarios en tiempo real
  Stream<List<user_management.User>> watchAllUsers();

  /// Crear un nuevo usuario
  Future<Either<Failure, user_management.User>> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedLocationId,
    String? assignedLocationType,
  });

  /// Actualizar un usuario existente
  Future<Either<Failure, user_management.User>> updateUser({
    required String userId,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
  });

  /// Desactivar un usuario (soft delete)
  Future<Either<Failure, void>> deactivateUser(String userId);

  /// Obtener un usuario por ID
  Future<Either<Failure, user_management.User>> getUserById(String userId);
}

