import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para obtener transferencias por ubicación
class GetTransfersByLocation {
  final TransferRepository repository;

  GetTransfersByLocation({required this.repository});

  /// Ejecuta la obtención de transferencias por ubicación
  Future<Either<Failure, List<TransferRequest>>> call({
    required String locationId,
    required String locationType,
  }) async {
    return await repository.getTransfersByLocation(locationId, locationType);
  }
}






















