import '../entities/purchase_item.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Actualizar item de compra
class UpdatePurchaseItem {
  final PurchaseRepository repository;

  UpdatePurchaseItem(this.repository);

  Future<PurchaseItem> call({
    required PurchaseItem item,
    int? quantity,
    double? unitCost,
  }) {
    final newQuantity = quantity ?? item.quantity;
    final newUnitCost = unitCost ?? item.unitCost;
    final newSubtotal = PurchaseItem.calculateSubtotal(newQuantity, newUnitCost);

    final updatedItem = item.copyWith(
      quantity: newQuantity,
      unitCost: newUnitCost,
      subtotal: newSubtotal,
    );

    return repository.updatePurchaseItem(updatedItem);
  }
}
