import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart' as user_management;
import '../repositories/user_repository.dart';

/// Use case para crear un nuevo usuario
///
/// Solo accesible por Administradores
/// Permite crear usuarios con cualquier rol:
/// - admin
/// - store_manager
/// - warehouse_manager
/// - customer
class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<Either<Failure, user_management.User>> call({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedLocationId,
    String? assignedLocationType,
  }) async {
    // Validaciones básicas
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return Left(ValidationFailure('Todos los campos son requeridos'));
    }

    if (!['admin', 'store_manager', 'warehouse_manager', 'customer']
        .contains(role)) {
      return Left(ValidationFailure('Rol inválido'));
    }

    // Managers deben tener ubicación asignada
    if ((role == 'store_manager' || role == 'warehouse_manager') &&
        (assignedLocationId == null || assignedLocationType == null)) {
      return Left(ValidationFailure('Managers deben tener ubicación asignada'));
    }

    // Password debe tener al menos 8 caracteres
    if (password.length < 8) {
      return Left(ValidationFailure('La contraseña debe tener al menos 8 caracteres'));
    }

    return await repository.createUser(
      email: email,
      password: password,
      name: name,
      role: role,
      assignedLocationId: assignedLocationId,
      assignedLocationType: assignedLocationType,
    );
  }
}

