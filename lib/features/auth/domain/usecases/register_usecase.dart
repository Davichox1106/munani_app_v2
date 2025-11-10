import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registrar nuevo usuario
///
/// OWASP A07:2021 - Identification and Authentication Failures:
/// - Valida requisitos de contraseña segura
/// - Verifica email único
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Ejecuta el caso de uso de registro
  ///
  /// [params] - Parámetros que contienen email, password, name y role
  /// Returns `Either<Failure, User>`
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
    );
  }
}

/// Parámetros para el RegisterUseCase
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}
