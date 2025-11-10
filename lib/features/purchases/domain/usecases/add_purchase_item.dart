import '../entities/purchase_item.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Agregar item a una compra
class AddPurchaseItem {
  final PurchaseRepository repository;

  AddPurchaseItem(this.repository);

  Future<PurchaseItem> call({
    required String purchaseId,
    required String productVariantId,
    required String productName,
    required String variantName,
    required int quantity,
    required double unitCost,
  }) {
    final subtotal = PurchaseItem.calculateSubtotal(quantity, unitCost);

    final item = PurchaseItem(
      id: '', // El repositorio generará el UUID
      purchaseId: purchaseId,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      quantity: quantity,
      unitCost: unitCost,
      subtotal: subtotal,
      createdAt: DateTime.now(),
    );

    return repository.addPurchaseItem(item);
  }
}
