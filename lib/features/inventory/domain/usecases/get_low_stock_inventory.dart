import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Use Case: Obtener inventario con stock bajo
///
/// Para alertas y notificaciones
class GetLowStockInventory {
  final InventoryRepository repository;

  GetLowStockInventory(this.repository);

  Stream<Either<Failure, List<InventoryItem>>> call() {
    return repository.getLowStockInventory();
  }
}

































