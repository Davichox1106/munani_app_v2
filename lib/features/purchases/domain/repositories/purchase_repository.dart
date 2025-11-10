import '../entities/purchase.dart';
import '../entities/purchase_item.dart';
import '../entities/purchase_with_items.dart';

/// Repositorio abstracto para Purchases
///
/// Define el contrato que debe implementar el repositorio de datos
abstract class PurchaseRepository {
  /// Obtener stream de todas las compras
  Stream<List<Purchase>> watchAllPurchases();

  /// Obtener stream de compras por ubicación
  Stream<List<Purchase>> watchPurchasesByLocation(String locationId);

  /// Obtener stream de compras por estado
  Stream<List<Purchase>> watchPurchasesByStatus(PurchaseStatus status);

  /// Obtener compra por ID con sus items
  Future<PurchaseWithItems?> getPurchaseWithItems(String id);

  /// Buscar compras por proveedor, número de compra o factura
  Future<List<Purchase>> searchPurchases(String query);

  /// Crear nueva compra
  Future<Purchase> createPurchase(Purchase purchase);

  /// Actualizar compra existente
  Future<Purchase> updatePurchase(Purchase purchase);

  /// Eliminar compra (soft delete: status = cancelled)
  Future<void> deletePurchase(String id);

  /// Agregar item a una compra pendiente
  Future<PurchaseItem> addPurchaseItem(PurchaseItem item);

  /// Actualizar item de compra
  Future<PurchaseItem> updatePurchaseItem(PurchaseItem item);

  /// Eliminar item de compra
  Future<void> deletePurchaseItem(String itemId, String purchaseId);

  /// Marcar compra como recibida (aplica al inventario)
  Future<Purchase> receivePurchase(String id, String receivedBy);

  /// Cancelar compra pendiente
  Future<Purchase> cancelPurchase(String id);

  /// Sincronizar compras con backend
  Future<void> syncPurchases();
}
