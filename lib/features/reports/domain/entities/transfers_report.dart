import 'package:equatable/equatable.dart';

/// Entidad de reporte de transferencias
class TransfersReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransfers;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int completedCount;
  final int cancelledCount;
  final List<TransfersReportItem> items;

  const TransfersReport({
    required this.startDate,
    required this.endDate,
    required this.totalTransfers,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.items,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalTransfers,
        pendingCount,
        approvedCount,
        rejectedCount,
        completedCount,
        cancelledCount,
        items,
      ];
}

/// Item individual de transferencia en el reporte
class TransfersReportItem extends Equatable {
  final String transferId;
  final DateTime requestDate;
  final String productName;
  final String variantName;
  final int quantity;
  final String fromLocationName;
  final String fromLocationType;
  final String toLocationName;
  final String toLocationType;
  final String status;
  final String requestedBy;

  const TransfersReportItem({
    required this.transferId,
    required this.requestDate,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.fromLocationName,
    required this.fromLocationType,
    required this.toLocationName,
    required this.toLocationType,
    required this.status,
    required this.requestedBy,
  });

  @override
  List<Object?> get props => [
        transferId,
        requestDate,
        productName,
        variantName,
        quantity,
        fromLocationName,
        fromLocationType,
        toLocationName,
        toLocationType,
        status,
        requestedBy,
      ];
}
