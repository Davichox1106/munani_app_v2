import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Cancelar compra pendiente
class CancelPurchase {
  final PurchaseRepository repository;

  CancelPurchase(this.repository);

  /// Cancela una compra (solo si está en estado 'pending')
  /// No afecta el inventario
  Future<Purchase> call(String purchaseId) {
    return repository.cancelPurchase(purchaseId);
  }
}
