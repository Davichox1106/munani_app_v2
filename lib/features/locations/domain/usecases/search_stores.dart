import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/location_repository.dart';

/// UseCase: Buscar tiendas por nombre, dirección o teléfono
class SearchStores {
  final LocationRepository repository;

  SearchStores(this.repository);

  Future<Either<Failure, List<Store>>> call(String query) async {
    // Validar query
    if (query.trim().isEmpty) {
      // Si está vacío, retornar todas
      return await repository.getAllStores();
    }

    return await repository.searchStores(query.trim());
  }
}























