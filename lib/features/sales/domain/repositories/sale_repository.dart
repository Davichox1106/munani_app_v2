import '../entities/sale.dart';
import '../entities/sale_item.dart';

abstract class SaleRepository {
  // Streams
  Stream<List<Sale>> watchAllSales();
  Stream<List<Sale>> watchSalesByLocation(String locationId);
  Stream<List<Sale>> watchSalesByStatus(SaleStatus status);

  // Consultas
  Future<Sale?> getSaleById(String id);
  Future<List<SaleItem>> getSaleItems(String saleId);

  // Búsqueda
  Future<List<Sale>> searchSales(String query);

  // Mutaciones
  Future<Sale> createSale(Sale sale);
  Future<Sale> updateSale(Sale sale);
  Future<void> deleteSale(String id);

  // Items
  Future<SaleItem> addSaleItem(SaleItem item);
  Future<SaleItem> updateSaleItem(SaleItem item);
  Future<void> deleteSaleItem(String itemId, String saleId);

  // Flujo de negocio
  Future<Sale> completeSale(String id); // aplicar inventario
  Future<Sale> cancelSale(String id);

  // Sync
  Future<void> syncSales();
}
