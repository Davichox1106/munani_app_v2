import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/transfer_repository.dart';

/// Use case para eliminar una transferencia
class DeleteTransfer {
  final TransferRepository repository;

  DeleteTransfer({required this.repository});

  /// Ejecuta la eliminación de una transferencia
  Future<Either<Failure, void>> call(String transferId) async {
    return await repository.deleteTransfer(transferId);
  }
}






















