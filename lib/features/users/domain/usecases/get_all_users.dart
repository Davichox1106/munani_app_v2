import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart' as user_management;
import '../repositories/user_repository.dart';

/// Use case para obtener todos los usuarios del sistema
///
/// Solo accesible por Administradores
class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Future<Either<Failure, List<user_management.User>>> call() async {
    return await repository.getAllUsers();
  }
}

