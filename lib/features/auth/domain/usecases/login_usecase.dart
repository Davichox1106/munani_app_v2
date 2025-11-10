import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Iniciar sesión
///
/// OWASP A07:2021 - Identification and Authentication Failures:
/// - Valida credenciales en el servidor
/// - No almacena contraseñas localmente
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Ejecuta el caso de uso de login
  ///
  /// [params] - Parámetros que contienen email y password
  /// Returns `Either<Failure, User>`
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parámetros para el LoginUseCase
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
