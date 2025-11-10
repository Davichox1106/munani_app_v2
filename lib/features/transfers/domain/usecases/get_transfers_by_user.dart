import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para obtener transferencias por usuario
class GetTransfersByUser {
  final TransferRepository repository;

  GetTransfersByUser({required this.repository});

  /// Ejecuta la obtención de transferencias por usuario
  Future<Either<Failure, List<TransferRequest>>> call(String userId) async {
    return await repository.getTransfersByUser(userId);
  }
}






















