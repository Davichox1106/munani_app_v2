import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para obtener todas las transferencias
class GetAllTransfers {
  final TransferRepository repository;

  GetAllTransfers({required this.repository});

  /// Ejecuta la obtención de todas las transferencias
  Future<Either<Failure, List<TransferRequest>>> call() async {
    return await repository.getAllTransfers();
  }
}






















