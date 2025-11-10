import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Use Case: Actualizar cantidad de inventario
///
/// OWASP A09: Incluye updatedBy para auditoría
class UpdateInventoryQuantity {
  final InventoryRepository repository;

  UpdateInventoryQuantity(this.repository);

  Future<Either<Failure, InventoryItem>> call({
    required String id,
    required int newQuantity,
    required String updatedBy,
  }) async {
    return await repository.updateInventoryQuantity(
      id: id,
      newQuantity: newQuantity,
      updatedBy: updatedBy,
    );
  }
}

































