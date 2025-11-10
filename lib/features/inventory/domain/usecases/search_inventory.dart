import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// UseCase: Buscar inventario por nombre de producto, variante o ubicación
class SearchInventory {
  final InventoryRepository repository;

  SearchInventory(this.repository);

  Future<Either<Failure, List<InventoryItem>>> call(String query) async {
    // Validar query
    if (query.trim().isEmpty) {
      // Si está vacío, retornar todos
      return await repository.getAllInventory().first;
    }

    return await repository.searchInventory(query.trim());
  }
}























