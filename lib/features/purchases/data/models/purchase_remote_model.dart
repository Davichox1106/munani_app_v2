import '../../domain/entities/purchase.dart';

/// Modelo remoto de Purchase para Supabase
///
/// Maneja serialización/deserialización con PostgreSQL
class PurchaseRemoteModel {
  final String id;
  final String supplierId;
  final String locationId;
  final String locationType;
  final String? purchaseNumber;
  final String? invoiceNumber;
  final DateTime purchaseDate;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? receivedBy;
  final DateTime? receivedAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;

  const PurchaseRemoteModel({
    required this.id,
    required this.supplierId,
    required this.locationId,
    required this.locationType,
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
    required this.needsSync,
    this.lastSyncedAt,
  });

  // ============================================================================
  // CONVERSIONES
  // ============================================================================

  /// Crear desde JSON de Supabase
  factory PurchaseRemoteModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRemoteModel(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      locationId: json['location_id'] as String,
      locationType: json['location_type'] as String,
      purchaseNumber: json['purchase_number'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String,
      receivedBy: json['received_by'] as String?,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'] as String)
          : null,
      needsSync: json['needs_sync'] as bool? ?? false,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'location_id': locationId,
      'location_type': locationType,
      'purchase_number': purchaseNumber,
      'invoice_number': invoiceNumber,
      'purchase_date': purchaseDate.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'received_by': receivedBy,
      'received_at': receivedAt?.toIso8601String(),
      'needs_sync': needsSync,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Convertir a entidad de dominio
  /// Requiere supplierName y locationName del JOIN
  Purchase toEntity({
    required String supplierName,
    required String locationName,
  }) {
    return Purchase(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      locationId: locationId,
      locationType: locationType,
      locationName: locationName,
      purchaseNumber: purchaseNumber,
      invoiceNumber: invoiceNumber,
      purchaseDate: purchaseDate,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: _statusFromString(status),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      receivedBy: receivedBy,
      receivedAt: receivedAt,
      needsSync: needsSync,
      lastSyncedAt: lastSyncedAt,
    );
  }

  /// Crear desde entidad de dominio
  factory PurchaseRemoteModel.fromEntity(Purchase entity) {
    return PurchaseRemoteModel(
      id: entity.id,
      supplierId: entity.supplierId,
      locationId: entity.locationId,
      locationType: entity.locationType,
      purchaseNumber: entity.purchaseNumber,
      invoiceNumber: entity.invoiceNumber,
      purchaseDate: entity.purchaseDate,
      subtotal: entity.subtotal,
      tax: entity.tax,
      total: entity.total,
      status: _statusToString(entity.status),
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      receivedBy: entity.receivedBy,
      receivedAt: entity.receivedAt,
      needsSync: entity.needsSync,
      lastSyncedAt: entity.lastSyncedAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  static PurchaseStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return PurchaseStatus.pending;
      case 'received':
        return PurchaseStatus.received;
      case 'cancelled':
        return PurchaseStatus.cancelled;
      default:
        return PurchaseStatus.pending;
    }
  }

  static String _statusToString(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return 'pending';
      case PurchaseStatus.received:
        return 'received';
      case PurchaseStatus.cancelled:
        return 'cancelled';
    }
  }
}
