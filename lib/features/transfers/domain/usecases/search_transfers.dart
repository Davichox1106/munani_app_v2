import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';
import '../repositories/transfer_repository.dart';

/// Use case para buscar transferencias
class SearchTransfers {
  final TransferRepository repository;

  SearchTransfers({required this.repository});

  /// Ejecuta la búsqueda de transferencias
  Future<Either<Failure, List<TransferRequest>>> call(String query) async {
    return await repository.searchTransfers(query);
  }
}






















