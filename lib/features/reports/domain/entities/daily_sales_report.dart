import 'package:equatable/equatable.dart';

/// Entidad de reporte de venta global del día
class DailySalesReport extends Equatable {
  final DateTime date;
  final double totalSales;
  final double totalTax;
  final double grandTotal;
  final int totalTransactions;
  final List<DailySalesByLocation> byLocation;

  const DailySalesReport({
    required this.date,
    required this.totalSales,
    required this.totalTax,
    required this.grandTotal,
    required this.totalTransactions,
    required this.byLocation,
  });

  @override
  List<Object?> get props => [
        date,
        totalSales,
        totalTax,
        grandTotal,
        totalTransactions,
        byLocation,
      ];
}

/// Ventas por ubicación en el reporte diario
class DailySalesByLocation extends Equatable {
  final String locationId;
  final String locationName;
  final String locationType;
  final double subtotal;
  final double tax;
  final double total;
  final int salesCount;

  const DailySalesByLocation({
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.salesCount,
  });

  @override
  List<Object?> get props => [
        locationId,
        locationName,
        locationType,
        subtotal,
        tax,
        total,
        salesCount,
      ];
}
