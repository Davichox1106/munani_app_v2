import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse.dart';
import '../repositories/location_repository.dart';

/// UseCase: Obtener todos los almacenes
class GetAllWarehouses {
  final LocationRepository repository;

  GetAllWarehouses(this.repository);

  Future<Either<Failure, List<Warehouse>>> call() async {
    return await repository.getAllWarehouses();
  }

  Stream<List<Warehouse>> watch() {
    return repository.watchAllWarehouses();
  }
}
