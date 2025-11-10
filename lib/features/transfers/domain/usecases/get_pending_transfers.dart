import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para obtener transferencias pendientes por ubicación
class GetPendingTransfers {
  final TransferRepository repository;

  GetPendingTransfers({required this.repository});

  /// Ejecuta la obtención de transferencias pendientes
  Future<Either<Failure, List<TransferRequest>>> call({
    required String locationId,
    required String locationType,
  }) async {
    return await repository.getPendingTransfersByLocation(locationId, locationType);
  }
}






















