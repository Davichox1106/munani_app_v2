import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Recibir compra (aplica al inventario)
///
/// ⭐ IMPORTANTE: Este es el UseCase más crítico
/// Al marcar una compra como "received", el trigger SQL automáticamente
/// aplicará los cambios al inventario de la ubicación destino
class ReceivePurchase {
  final PurchaseRepository repository;

  ReceivePurchase(this.repository);

  Future<Purchase> call({
    required String purchaseId,
    required String receivedBy,
  }) {
    return repository.receivePurchase(purchaseId, receivedBy);
  }
}
