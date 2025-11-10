import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse.dart';
import '../repositories/location_repository.dart';

/// UseCase: Buscar almacenes por nombre, dirección o teléfono
class SearchWarehouses {
  final LocationRepository repository;

  SearchWarehouses(this.repository);

  Future<Either<Failure, List<Warehouse>>> call(String query) async {
    // Validar query
    if (query.trim().isEmpty) {
      // Si está vacío, retornar todos
      return await repository.getAllWarehouses();
    }

    return await repository.searchWarehouses(query.trim());
  }
}























