import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Use Case: Ajustar inventario (incrementar/decrementar)
///
/// Usado en compras (+), ventas (-), y transferencias
/// OWASP A09: Incluye updatedBy para auditoría
class AdjustInventory {
  final InventoryRepository repository;

  AdjustInventory(this.repository);

  /// Ajustar inventario
  /// 
  /// [delta] puede ser:
  /// - Positivo: incrementar (compras, recepciones)
  /// - Negativo: decrementar (ventas, envíos)
  Future<Either<Failure, InventoryItem>> call({
    required String id,
    required int delta,
    required String updatedBy,
  }) async {
    return await repository.adjustInventory(
      id: id,
      delta: delta,
      updatedBy: updatedBy,
    );
  }
}

































