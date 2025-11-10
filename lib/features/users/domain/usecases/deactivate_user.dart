import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

/// Use case para desactivar un usuario
///
/// Solo accesible por Administradores
/// En lugar de eliminar, desactivamos el usuario
class DeactivateUser {
  final UserRepository repository;

  DeactivateUser(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure('ID de usuario requerido'));
    }

    return await repository.deactivateUser(userId);
  }
}



