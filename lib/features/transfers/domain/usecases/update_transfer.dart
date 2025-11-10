import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para actualizar una transferencia
class UpdateTransfer {
  final TransferRepository repository;

  UpdateTransfer({required this.repository});

  /// Ejecuta la actualización de una transferencia
  Future<Either<Failure, TransferRequest>> call(TransferRequest transfer) async {
    return await repository.updateTransfer(transfer);
  }
}






















