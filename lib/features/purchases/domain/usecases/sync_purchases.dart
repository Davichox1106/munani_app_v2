import '../repositories/purchase_repository.dart';
import '../repositories/supplier_repository.dart';

/// UseCase: Sincronizar compras y proveedores con backend
class SyncPurchases {
  final PurchaseRepository purchaseRepository;
  final SupplierRepository supplierRepository;

  SyncPurchases({
    required this.purchaseRepository,
    required this.supplierRepository,
  });

  /// Sincroniza todo el módulo de compras
  Future<void> call() async {
    // Sincronizar proveedores primero
    await supplierRepository.syncSuppliers();

    // Luego sincronizar compras
    await purchaseRepository.syncPurchases();
  }

  /// Sincronizar solo proveedores
  Future<void> syncSuppliersOnly() {
    return supplierRepository.syncSuppliers();
  }

  /// Sincronizar solo compras
  Future<void> syncPurchasesOnly() {
    return purchaseRepository.syncPurchases();
  }
}
