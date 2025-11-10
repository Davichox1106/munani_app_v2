import 'package:equatable/equatable.dart';

/// Estado de una solicitud de transferencia
enum TransferStatus {
  pending,    // Pendiente de aprobación
  approved,   // Aprobada
  rejected,   // Rechazada
  completed,  // Completada
  cancelled,  // Cancelada
}

/// Entidad que representa una solicitud de transferencia
class TransferRequest extends Equatable {
  final String id;
  final String productVariantId;
  final String productName;
  final String variantName;
  final String fromLocationId;
  final String fromLocationName;
  final String fromLocationType;
  final String toLocationId;
  final String toLocationName;
  final String toLocationType;
  final int quantity;
  final String requestedBy;
  final String requestedByName;
  final DateTime requestedAt;
  final String? approvedBy;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final String? rejectedByName;
  final DateTime? rejectedAt;
  final String? cancelledBy;
  final String? cancelledByName;
  final DateTime? cancelledAt;
  final String? completedBy;
  final String? completedByName;
  final DateTime? completedAt;
  final String? rejectionReason;
  final TransferStatus status;
  final String? notes;

  const TransferRequest({
    required this.id,
    required this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.fromLocationId,
    required this.fromLocationName,
    required this.fromLocationType,
    required this.toLocationId,
    required this.toLocationName,
    required this.toLocationType,
    required this.quantity,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestedAt,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedByName,
    this.rejectedAt,
    this.cancelledBy,
    this.cancelledByName,
    this.cancelledAt,
    this.completedBy,
    this.completedByName,
    this.completedAt,
    this.rejectionReason,
    required this.status,
    this.notes,
  });

  /// Crea una copia con nuevos valores
  TransferRequest copyWith({
    String? id,
    String? productVariantId,
    String? productName,
    String? variantName,
    String? fromLocationId,
    String? fromLocationName,
    String? fromLocationType,
    String? toLocationId,
    String? toLocationName,
    String? toLocationType,
    int? quantity,
    String? requestedBy,
    String? requestedByName,
    DateTime? requestedAt,
    String? approvedBy,
    String? approvedByName,
    DateTime? approvedAt,
    String? rejectedBy,
    String? rejectedByName,
    DateTime? rejectedAt,
    String? cancelledBy,
    String? cancelledByName,
    DateTime? cancelledAt,
    String? completedBy,
    String? completedByName,
    DateTime? completedAt,
    String? rejectionReason,
    TransferStatus? status,
    String? notes,
  }) {
    return TransferRequest(
      id: id ?? this.id,
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      fromLocationId: fromLocationId ?? this.fromLocationId,
      fromLocationName: fromLocationName ?? this.fromLocationName,
      fromLocationType: fromLocationType ?? this.fromLocationType,
      toLocationId: toLocationId ?? this.toLocationId,
      toLocationName: toLocationName ?? this.toLocationName,
      toLocationType: toLocationType ?? this.toLocationType,
      quantity: quantity ?? this.quantity,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedByName: requestedByName ?? this.requestedByName,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedByName: rejectedByName ?? this.rejectedByName,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledByName: cancelledByName ?? this.cancelledByName,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completedBy: completedBy ?? this.completedBy,
      completedByName: completedByName ?? this.completedByName,
      completedAt: completedAt ?? this.completedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  /// Verifica si la solicitud está pendiente
  bool get isPending => status == TransferStatus.pending;

  /// Verifica si la solicitud fue aprobada
  bool get isApproved => status == TransferStatus.approved;

  /// Verifica si la solicitud fue rechazada
  bool get isRejected => status == TransferStatus.rejected;

  /// Verifica si la solicitud está completada
  bool get isCompleted => status == TransferStatus.completed;

  /// Verifica si la solicitud fue cancelada
  bool get isCancelled => status == TransferStatus.cancelled;

  /// Obtiene el texto del estado
  String get statusText {
    switch (status) {
      case TransferStatus.pending:
        return 'Pendiente';
      case TransferStatus.approved:
        return 'Aprobada';
      case TransferStatus.rejected:
        return 'Rechazada';
      case TransferStatus.completed:
        return 'Completada';
      case TransferStatus.cancelled:
        return 'Cancelada';
    }
  }

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        productName,
        variantName,
        fromLocationId,
        fromLocationName,
        fromLocationType,
        toLocationId,
        toLocationName,
        toLocationType,
        quantity,
        requestedBy,
        requestedByName,
        requestedAt,
        approvedBy,
        approvedByName,
        approvedAt,
        rejectedBy,
        rejectedByName,
        rejectedAt,
        cancelledBy,
        cancelledByName,
        cancelledAt,
        completedBy,
        completedByName,
        completedAt,
        rejectionReason,
        status,
        notes,
      ];
}


