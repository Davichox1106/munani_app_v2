import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Obtener usuario actual
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Ejecuta el caso de uso para obtener el usuario actual
  ///
  /// Returns `Either<Failure, User>`
  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}
