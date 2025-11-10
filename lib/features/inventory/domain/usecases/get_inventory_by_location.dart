import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Use Case: Obtener inventario por ubicación
///
/// Filtra inventario de una tienda o almacén específico
class GetInventoryByLocation {
  final InventoryRepository repository;

  GetInventoryByLocation(this.repository);

  Stream<Either<Failure, List<InventoryItem>>> call({
    required String locationId,
    required String locationType,
  }) {
    return repository.getInventoryByLocation(
      locationId: locationId,
      locationType: locationType,
    );
  }
}
