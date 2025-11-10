import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

/// Use case: Eliminar almacén
class DeleteWarehouse {
  final LocationRepository repository;

  DeleteWarehouse(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteWarehouse(id);
  }
}






























