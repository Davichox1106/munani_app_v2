import 'package:equatable/equatable.dart';

/// Entidad de reporte de ventas
class SalesReport extends Equatable {
  final String locationId;
  final String locationName;
  final String locationType; // 'store' o 'warehouse'
  final DateTime startDate;
  final DateTime endDate;
  final int totalSales;
  final double totalAmount;
  final double totalTax;
  final double grandTotal;
  final List<SalesReportItem> items;

  const SalesReport({
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalAmount,
    required this.totalTax,
    required this.grandTotal,
    required this.items,
  });

  @override
  List<Object?> get props => [
        locationId,
        locationName,
        locationType,
        startDate,
        endDate,
        totalSales,
        totalAmount,
        totalTax,
        grandTotal,
        items,
      ];
}

/// Item individual de venta en el reporte
class SalesReportItem extends Equatable {
  final String saleId;
  final String saleNumber;
  final DateTime saleDate;
  final String? customerName;
  final double subtotal;
  final double tax;
  final double total;
  final String status;

  const SalesReportItem({
    required this.saleId,
    required this.saleNumber,
    required this.saleDate,
    this.customerName,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
  });

  @override
  List<Object?> get props => [
        saleId,
        saleNumber,
        saleDate,
        customerName,
        subtotal,
        tax,
        total,
        status,
      ];
}
