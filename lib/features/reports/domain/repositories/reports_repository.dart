import '../entities/sales_report.dart';
import '../entities/purchases_report.dart';
import '../entities/transfers_report.dart';
import '../entities/daily_sales_report.dart';

/// Repositorio para generación de reportes
abstract class ReportsRepository {
  /// Reporte de ventas filtrado por tienda y fecha
  Future<SalesReport> getSalesReport({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Reporte de compras filtrado por tienda y fecha
  Future<PurchasesReport> getPurchasesReport({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Reporte de transferencias filtrado por fecha
  Future<TransfersReport> getTransfersReport({
    required DateTime startDate,
    required DateTime endDate,
    String? locationId, // Opcional: filtrar por ubicación
  });

  /// Reporte de venta global del día
  Future<DailySalesReport> getDailySalesReport({
    required DateTime date,
  });
}
