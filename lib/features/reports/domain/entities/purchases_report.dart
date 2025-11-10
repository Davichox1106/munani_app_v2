import 'package:equatable/equatable.dart';

/// Entidad de reporte de compras
class PurchasesReport extends Equatable {
  final String locationId;
  final String locationName;
  final String locationType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPurchases;
  final double totalAmount;
  final List<PurchasesReportItem> items;

  const PurchasesReport({
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.startDate,
    required this.endDate,
    required this.totalPurchases,
    required this.totalAmount,
    required this.items,
  });

  @override
  List<Object?> get props => [
        locationId,
        locationName,
        locationType,
        startDate,
        endDate,
        totalPurchases,
        totalAmount,
        items,
      ];
}

/// Item individual de compra en el reporte
class PurchasesReportItem extends Equatable {
  final String purchaseId;
  final String purchaseNumber;
  final DateTime purchaseDate;
  final String supplierName;
  final double totalAmount;
  final String status;

  const PurchasesReportItem({
    required this.purchaseId,
    required this.purchaseNumber,
    required this.purchaseDate,
    required this.supplierName,
    required this.totalAmount,
    required this.status,
  });

  @override
  List<Object?> get props => [
        purchaseId,
        purchaseNumber,
        purchaseDate,
        supplierName,
        totalAmount,
        status,
      ];
}
