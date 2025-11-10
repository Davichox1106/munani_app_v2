import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse.dart';
import '../repositories/location_repository.dart';

/// Use case: Actualizar almacén
class UpdateWarehouse {
  final LocationRepository repository;

  UpdateWarehouse(this.repository);

  Future<Either<Failure, Warehouse>> call(Warehouse warehouse) async {
    return await repository.updateWarehouse(warehouse);
  }
}






























