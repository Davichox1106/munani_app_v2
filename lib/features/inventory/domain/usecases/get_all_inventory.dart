import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Use Case: Obtener todo el inventario
///
/// Retorna un stream para actualizaciones en tiempo real
class GetAllInventory {
  final InventoryRepository repository;

  GetAllInventory(this.repository);

  Stream<Either<Failure, List<InventoryItem>>> call() {
    return repository.getAllInventory();
  }
}

































