import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para obtener una transferencia por ID
class GetTransferById {
  final TransferRepository repository;

  GetTransferById({required this.repository});

  /// Ejecuta la obtención de una transferencia por ID
  Future<Either<Failure, TransferRequest?>> call(String transferId) async {
    return await repository.getTransferById(transferId);
  }
}






















