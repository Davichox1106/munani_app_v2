import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para crear una nueva transferencia
class CreateTransfer {
  final TransferRepository repository;

  CreateTransfer({required this.repository});

  /// Ejecuta la creación de una transferencia
  Future<Either<Failure, TransferRequest>> call(TransferRequest transfer) async {
    return await repository.createTransfer(transfer);
  }
}






















