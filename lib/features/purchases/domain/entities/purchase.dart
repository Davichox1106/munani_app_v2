import 'package:equatable/equatable.dart';

/// Estado de una compra
enum PurchaseStatus {
  pending,   // Pendiente (creada pero no recibida)
  received,  // Recibida (aplicada al inventario)
  cancelled, // Cancelada
}

/// Entidad que representa el encabezado de una compra
class Purchase extends Equatable {
  final String id;
  final String supplierId;
  final String supplierName;
  final String locationId;
  final String locationType;
  final String locationName;
  final String? purchaseNumber;
  final String? invoiceNumber;
  final DateTime purchaseDate;
  final double subtotal;
  final double tax;
  final double total;
  final PurchaseStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? receivedBy;
  final DateTime? receivedAt;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool needsSync;
  final DateTime? lastSyncedAt;

  const Purchase({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.locationId,
    required this.locationType,
    required this.locationName,
    this.purchaseNumber,
    this.invoiceNumber,
    required this.purchaseDate,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.receivedBy,
    this.receivedAt,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationReason,
    required this.needsSync,
    this.lastSyncedAt,
  });

  /// Crea una copia con nuevos valores
  Purchase copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? locationId,
    String? locationType,
    String? locationName,
    String? purchaseNumber,
    String? invoiceNumber,
    DateTime? purchaseDate,
    double? subtotal,
    double? tax,
    double? total,
    PurchaseStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? receivedBy,
    DateTime? receivedAt,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? cancellationReason,
    bool? needsSync,
    DateTime? lastSyncedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      locationName: locationName ?? this.locationName,
      purchaseNumber: purchaseNumber ?? this.purchaseNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Verifica si la compra está pendiente
  bool get isPending => status == PurchaseStatus.pending;

  /// Verifica si la compra fue recibida
  bool get isReceived => status == PurchaseStatus.received;

  /// Verifica si la compra está cancelada
  bool get isCancelled => status == PurchaseStatus.cancelled;

  /// Verifica si la compra puede ser editada (solo si está pendiente)
  bool get canBeEdited => status == PurchaseStatus.pending;

  /// Verifica si la compra puede ser recibida (solo si está pendiente)
  bool get canBeReceived => status == PurchaseStatus.pending;

  /// Verifica si la compra puede ser cancelada (solo si está pendiente)
  bool get canBeCancelled => status == PurchaseStatus.pending;

  /// Obtiene el texto del estado
  String get statusText {
    switch (status) {
      case PurchaseStatus.pending:
        return 'Pendiente';
      case PurchaseStatus.received:
        return 'Recibida';
      case PurchaseStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Obtiene el color del estado
  String get statusColor {
    switch (status) {
      case PurchaseStatus.pending:
        return 'orange';
      case PurchaseStatus.received:
        return 'green';
      case PurchaseStatus.cancelled:
        return 'red';
    }
  }

  @override
  List<Object?> get props => [
        id,
        supplierId,
        supplierName,
        locationId,
        locationType,
        locationName,
        purchaseNumber,
        invoiceNumber,
        purchaseDate,
        subtotal,
        tax,
        total,
        status,
        notes,
        createdAt,
        updatedAt,
        createdBy,
        receivedBy,
        receivedAt,
        cancelledBy,
        cancelledAt,
        cancellationReason,
        needsSync,
        lastSyncedAt,
      ];
}
