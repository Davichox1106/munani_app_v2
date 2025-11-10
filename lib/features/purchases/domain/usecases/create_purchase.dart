import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Crear nueva compra
class CreatePurchase {
  final PurchaseRepository repository;

  CreatePurchase(this.repository);

  Future<Purchase> call({
    required String supplierId,
    required String supplierName,
    required String locationId,
    required String locationType,
    required String locationName,
    String? invoiceNumber,
    DateTime? purchaseDate,
    String? notes,
    required String createdBy,
  }) {
    final purchase = Purchase(
      id: '', // El repositorio generará el UUID
      supplierId: supplierId,
      supplierName: supplierName,
      locationId: locationId,
      locationType: locationType,
      locationName: locationName,
      invoiceNumber: invoiceNumber,
      purchaseDate: purchaseDate ?? DateTime.now(),
      subtotal: 0.00,
      tax: 0.00,
      total: 0.00,
      status: PurchaseStatus.pending,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: createdBy,
      needsSync: true,
    );

    return repository.createPurchase(purchase);
  }
}
