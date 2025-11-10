import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Cerrar sesión
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Ejecuta el caso de uso de logout
  ///
  /// Returns `Either<Failure, void>`
  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
