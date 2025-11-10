import '../entities/purchase_with_items.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Obtener compra con sus items
class GetPurchaseWithItems {
  final PurchaseRepository repository;

  GetPurchaseWithItems(this.repository);

  Future<PurchaseWithItems?> call(String purchaseId) {
    return repository.getPurchaseWithItems(purchaseId);
  }
}
