import '../../../sales/data/datasources/sale_local_datasource.dart';
import '../../../purchases/data/datasources/purchase_local_datasource.dart';
import '../../../transfers/data/datasources/transfer_local_datasource.dart';
import '../../../locations/data/datasources/location_local_datasource.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/purchases_report.dart';
import '../../domain/entities/transfers_report.dart';
import '../../domain/entities/daily_sales_report.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final SaleLocalDataSource saleLocalDataSource;
  final PurchaseLocalDataSource purchaseLocalDataSource;
  final TransferLocalDataSource transferLocalDataSource;
  final LocationLocalDataSource locationLocalDataSource;

  ReportsRepositoryImpl({
    required this.saleLocalDataSource,
    required this.purchaseLocalDataSource,
    required this.transferLocalDataSource,
    required this.locationLocalDataSource,
  });

  @override
  Future<SalesReport> getSalesReport({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Obtener todas las ventas locales usando el stream
    final allSalesStream = saleLocalDataSource.watchAllSales();
    final allSales = await allSalesStream.first;

    // Obtener información de la ubicación
    final storeLocation = await locationLocalDataSource.getStoreById(locationId);
    final warehouseLocation = await locationLocalDataSource.getWarehouseById(locationId);

    final String locationName;
    final String locationType;

    if (storeLocation != null) {
      locationName = storeLocation.name;
      locationType = 'store';
    } else if (warehouseLocation != null) {
      locationName = warehouseLocation.name;
      locationType = 'warehouse';
    } else {
      throw Exception('Ubicación no encontrada');
    }

    // Filtrar ventas por ubicación y rango de fechas
    final filteredSales = allSales.where((sale) {
      final saleDate = sale.saleDate;
      return sale.locationId == locationId &&
          saleDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          saleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Calcular totales
    double totalAmount = 0;
    double totalTax = 0;
    double grandTotal = 0;

    final items = filteredSales.map((sale) {
      totalAmount += sale.subtotal;
      totalTax += sale.tax;
      grandTotal += sale.total;

      return SalesReportItem(
        saleId: sale.uuid,
        saleNumber: sale.saleNumber ?? 'S/N',
        saleDate: sale.saleDate,
        customerName: sale.customerName,
        subtotal: sale.subtotal,
        tax: sale.tax,
        total: sale.total,
        status: sale.status.name,
      );
    }).toList();

    return SalesReport(
      locationId: locationId,
      locationName: locationName,
      locationType: locationType,
      startDate: startDate,
      endDate: endDate,
      totalSales: filteredSales.length,
      totalAmount: totalAmount,
      totalTax: totalTax,
      grandTotal: grandTotal,
      items: items,
    );
  }

  @override
  Future<PurchasesReport> getPurchasesReport({
    required String locationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Obtener todas las compras locales
    final allPurchases = await purchaseLocalDataSource.getAllPurchasesList();

    // Obtener información de la ubicación
    final storeLocation = await locationLocalDataSource.getStoreById(locationId);
    final warehouseLocation = await locationLocalDataSource.getWarehouseById(locationId);

    final String locationName;
    final String locationType;

    if (storeLocation != null) {
      locationName = storeLocation.name;
      locationType = 'store';
    } else if (warehouseLocation != null) {
      locationName = warehouseLocation.name;
      locationType = 'warehouse';
    } else {
      throw Exception('Ubicación no encontrada');
    }

    // Filtrar compras por ubicación y rango de fechas
    final filteredPurchases = allPurchases.where((purchase) {
      final purchaseDate = purchase.purchaseDate;
      return purchase.locationId == locationId &&
          purchaseDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          purchaseDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Calcular totales
    double totalAmount = 0;

    final items = filteredPurchases.map((purchase) {
      totalAmount += purchase.total;

      return PurchasesReportItem(
        purchaseId: purchase.uuid,
        purchaseNumber: purchase.purchaseNumber ?? 'P/N',
        purchaseDate: purchase.purchaseDate,
        supplierName: purchase.supplierName,
        totalAmount: purchase.total,
        status: purchase.status.name,
      );
    }).toList();

    return PurchasesReport(
      locationId: locationId,
      locationName: locationName,
      locationType: locationType,
      startDate: startDate,
      endDate: endDate,
      totalPurchases: filteredPurchases.length,
      totalAmount: totalAmount,
      items: items,
    );
  }

  @override
  Future<TransfersReport> getTransfersReport({
    required DateTime startDate,
    required DateTime endDate,
    String? locationId,
  }) async {
    // Obtener todas las transferencias locales
    final allTransfers = await transferLocalDataSource.getAllTransfers();

    // Filtrar transferencias por rango de fechas y opcionalmente por ubicación
    var filteredTransfers = allTransfers.where((transfer) {
      final requestDate = transfer.requestedAt;
      final dateMatch = requestDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          requestDate.isBefore(endDate.add(const Duration(days: 1)));

      if (locationId != null) {
        return dateMatch &&
            (transfer.fromLocationId == locationId || transfer.toLocationId == locationId);
      }
      return dateMatch;
    }).toList();

    // Contar por estado
    int pendingCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;

    final items = filteredTransfers.map((transfer) {
      switch (transfer.status.name) {
        case 'pending':
          pendingCount++;
          break;
        case 'approved':
          approvedCount++;
          break;
        case 'rejected':
          rejectedCount++;
          break;
        case 'completed':
          completedCount++;
          break;
        case 'cancelled':
          cancelledCount++;
          break;
      }

      return TransfersReportItem(
        transferId: transfer.uuid,
        requestDate: transfer.requestedAt,
        productName: transfer.productName,
        variantName: transfer.variantName,
        quantity: transfer.quantity,
        fromLocationName: transfer.fromLocationName,
        fromLocationType: transfer.fromLocationType,
        toLocationName: transfer.toLocationName,
        toLocationType: transfer.toLocationType,
        status: transfer.status.name,
        requestedBy: transfer.requestedBy,
      );
    }).toList();

    return TransfersReport(
      startDate: startDate,
      endDate: endDate,
      totalTransfers: filteredTransfers.length,
      pendingCount: pendingCount,
      approvedCount: approvedCount,
      rejectedCount: rejectedCount,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      items: items,
    );
  }

  @override
  Future<DailySalesReport> getDailySalesReport({
    required DateTime date,
  }) async {
    // Definir el rango del día (00:00:00 a 23:59:59)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    // Obtener todas las ventas del día usando el stream
    final allSalesStream = saleLocalDataSource.watchAllSales();
    final allSales = await allSalesStream.first;
    final dailySales = allSales.where((sale) {
      return sale.saleDate.isAfter(startOfDay) && sale.saleDate.isBefore(endOfDay);
    }).toList();

    // Calcular totales globales
    double totalSales = 0;
    double totalTax = 0;
    double grandTotal = 0;

    // Agrupar por ubicación
    final Map<String, List<dynamic>> salesByLocation = {};

    for (final sale in dailySales) {
      totalSales += sale.subtotal;
      totalTax += sale.tax;
      grandTotal += sale.total;

      if (!salesByLocation.containsKey(sale.locationId)) {
        salesByLocation[sale.locationId] = [];
      }
      salesByLocation[sale.locationId]!.add(sale);
    }

    // Crear lista de ventas por ubicación
    final List<DailySalesByLocation> byLocation = [];

    for (final entry in salesByLocation.entries) {
      final locationId = entry.key;
      final locationSales = entry.value;

      // Obtener información de la ubicación
      final storeLocation = await locationLocalDataSource.getStoreById(locationId);
      final warehouseLocation = await locationLocalDataSource.getWarehouseById(locationId);

      if (storeLocation == null && warehouseLocation == null) continue;

      final String locationName;
      final String locationType;

      if (storeLocation != null) {
        locationName = storeLocation.name;
        locationType = 'store';
      } else {
        locationName = warehouseLocation!.name;
        locationType = 'warehouse';
      }

      double subtotal = 0;
      double tax = 0;
      double total = 0;

      for (final sale in locationSales) {
        subtotal += sale.subtotal;
        tax += sale.tax;
        total += sale.total;
      }

      byLocation.add(DailySalesByLocation(
        locationId: locationId,
        locationName: locationName,
        locationType: locationType,
        subtotal: subtotal,
        tax: tax,
        total: total,
        salesCount: locationSales.length,
      ));
    }

    return DailySalesReport(
      date: date,
      totalSales: totalSales,
      totalTax: totalTax,
      grandTotal: grandTotal,
      totalTransactions: dailySales.length,
      byLocation: byLocation,
    );
  }
}
