import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart' as user_management;
import '../repositories/user_repository.dart';

/// Use case para actualizar un usuario existente
///
/// Solo accesible por Administradores
class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<Either<Failure, user_management.User>> call({
    required String userId,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure('ID de usuario requerido'));
    }

    return await repository.updateUser(
      userId: userId,
      name: name,
      role: role,
      assignedLocationId: assignedLocationId,
      assignedLocationType: assignedLocationType,
      isActive: isActive,
    );
  }
}

