import '../repositories/purchase_repository.dart';

/// UseCase: Eliminar item de compra
class RemovePurchaseItem {
  final PurchaseRepository repository;

  RemovePurchaseItem(this.repository);

  Future<void> call({
    required String itemId,
    required String purchaseId,
  }) {
    return repository.deletePurchaseItem(itemId, purchaseId);
  }
}
