import 'package:isar/isar.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/transfer_request.dart';

part 'transfer_request_local_model.g.dart';

@collection
class TransferRequestLocalModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String uuid;
  
  late String productVariantId;
  late String productName;
  late String variantName;
  late String fromLocationId;
  late String fromLocationName;
  late String fromLocationType;
  late String toLocationId;
  late String toLocationName;
  late String toLocationType;
  late int quantity;
  late String requestedBy;
  late String requestedByName;
  late DateTime requestedAt;
  String? approvedBy;
  String? approvedByName;
  DateTime? approvedAt;
  String? rejectedBy;
  String? rejectedByName;
  DateTime? rejectedAt;
  String? cancelledBy;
  String? cancelledByName;
  DateTime? cancelledAt;
  String? completedBy;
  String? completedByName;
  DateTime? completedAt;
  String? rejectionReason;
  @enumerated
  late TransferStatus status;
  String? notes;
  
  // Campos de sincronización
  late bool isSynced;
  late DateTime lastUpdated;
  late String updatedBy;

  TransferRequestLocalModel();

  /// Convierte de entidad a modelo local
  factory TransferRequestLocalModel.fromEntity(TransferRequest entity) {
    return TransferRequestLocalModel()
      ..uuid = entity.id
      ..productVariantId = entity.productVariantId
      ..productName = entity.productName
      ..variantName = entity.variantName
      ..fromLocationId = entity.fromLocationId
      ..fromLocationName = entity.fromLocationName
      ..fromLocationType = entity.fromLocationType
      ..toLocationId = entity.toLocationId
      ..toLocationName = entity.toLocationName
      ..toLocationType = entity.toLocationType
      ..quantity = entity.quantity
      ..requestedBy = entity.requestedBy
      ..requestedByName = entity.requestedByName
      ..requestedAt = entity.requestedAt
      ..approvedBy = entity.approvedBy
      ..approvedByName = entity.approvedByName
      ..approvedAt = entity.approvedAt
      ..rejectedBy = entity.rejectedBy
      ..rejectedByName = entity.rejectedByName
      ..rejectedAt = entity.rejectedAt
      ..cancelledBy = entity.cancelledBy
      ..cancelledByName = entity.cancelledByName
      ..cancelledAt = entity.cancelledAt
      ..completedBy = entity.completedBy
      ..completedByName = entity.completedByName
      ..completedAt = entity.completedAt
      ..rejectionReason = entity.rejectionReason
      ..status = entity.status
      ..notes = entity.notes
      ..isSynced = true
      ..lastUpdated = DateTime.now()
      ..updatedBy = entity.requestedBy;
  }

  /// Convierte de modelo local a entidad
  TransferRequest toEntity() {
    return TransferRequest(
      id: uuid,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      fromLocationId: fromLocationId,
      fromLocationName: fromLocationName,
      fromLocationType: fromLocationType,
      toLocationId: toLocationId,
      toLocationName: toLocationName,
      toLocationType: toLocationType,
      quantity: quantity,
      requestedBy: requestedBy,
      requestedByName: requestedByName,
      requestedAt: requestedAt,
      approvedBy: approvedBy,
      approvedByName: approvedByName,
      approvedAt: approvedAt,
      rejectedBy: rejectedBy,
      rejectedByName: rejectedByName,
      rejectedAt: rejectedAt,
      cancelledBy: cancelledBy,
      cancelledByName: cancelledByName,
      cancelledAt: cancelledAt,
      completedBy: completedBy,
      completedByName: completedByName,
      completedAt: completedAt,
      rejectionReason: rejectionReason,
      status: status,
      notes: notes,
    );
  }

  /// Actualiza el estado
  void updateStatus(TransferStatus newStatus) {
    status = newStatus;
    lastUpdated = DateTime.now();
  }

  /// Crea una copia con nuevos valores
  TransferRequestLocalModel copyWith({
    String? uuid,
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
    String? rejectionReason,
    TransferStatus? status,
    String? notes,
    bool? isSynced,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    final copy = TransferRequestLocalModel()
      ..id = id  // Mantener el ID de Isar
      ..uuid = uuid ?? this.uuid
      ..productVariantId = productVariantId ?? this.productVariantId
      ..productName = productName ?? this.productName
      ..variantName = variantName ?? this.variantName
      ..fromLocationId = fromLocationId ?? this.fromLocationId
      ..fromLocationName = fromLocationName ?? this.fromLocationName
      ..fromLocationType = fromLocationType ?? this.fromLocationType
      ..toLocationId = toLocationId ?? this.toLocationId
      ..toLocationName = toLocationName ?? this.toLocationName
      ..toLocationType = toLocationType ?? this.toLocationType
      ..quantity = quantity ?? this.quantity
      ..requestedBy = requestedBy ?? this.requestedBy
      ..requestedByName = requestedByName ?? this.requestedByName
      ..requestedAt = requestedAt ?? this.requestedAt
      ..approvedBy = approvedBy ?? this.approvedBy
      ..approvedByName = approvedByName ?? this.approvedByName
      ..approvedAt = approvedAt ?? this.approvedAt
      ..rejectionReason = rejectionReason ?? this.rejectionReason
      ..status = status ?? this.status
      ..notes = notes ?? this.notes
      ..isSynced = isSynced ?? this.isSynced
      ..lastUpdated = lastUpdated ?? this.lastUpdated
      ..updatedBy = updatedBy ?? this.updatedBy;
    
    return copy;
  }

  /// Convierte de JSON a modelo local
  factory TransferRequestLocalModel.fromJson(Map<String, dynamic> json) {
    return TransferRequestLocalModel()
      ..uuid = (json['id'] ?? json['uuid']) as String
      ..productVariantId = json['product_variant_id'] as String
      ..productName = json['product_name'] as String
      ..variantName = json['variant_name'] as String
      ..fromLocationId = json['from_location_id'] as String
      ..fromLocationName = json['from_location_name'] as String
      ..fromLocationType = json['from_location_type'] as String
      ..toLocationId = json['to_location_id'] as String
      ..toLocationName = json['to_location_name'] as String
      ..toLocationType = json['to_location_type'] as String
      ..quantity = json['quantity'] as int
      ..requestedBy = json['requested_by'] as String
      ..requestedByName = json['requested_by_name'] as String
      ..requestedAt = DateTime.parse(json['requested_at'] as String)
      ..approvedBy = json['approved_by'] as String?
      ..approvedByName = json['approved_by_name'] as String?
      ..approvedAt = json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null
      ..rejectedBy = json['rejected_by'] as String?
      ..rejectedByName = json['rejected_by_name'] as String?
      ..rejectedAt = json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null
      ..cancelledBy = json['cancelled_by'] as String?
      ..cancelledByName = json['cancelled_by_name'] as String?
      ..cancelledAt = json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null
      ..completedBy = json['completed_by'] as String?
      ..completedByName = json['completed_by_name'] as String?
      ..completedAt = json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null
      ..rejectionReason = json['rejection_reason'] as String?
      ..status = _parseStatus(json['status'])
      ..notes = json['notes'] as String?
      ..isSynced = json['is_synced'] as bool? ?? true
      ..lastUpdated = DateTime.parse(json['last_updated'] as String)
      ..updatedBy = json['updated_by'] as String? ?? '';
  }

  /// Convierte de modelo local a JSON
  Map<String, dynamic> toJson() {
    // Asegurar que updated_by siempre tenga un valor válido
    final effectiveUpdatedBy = updatedBy.isNotEmpty ? updatedBy : requestedBy;

    AppLogger.debug('🔍 TransferRequestLocalModel.toJson():');
    AppLogger.debug('   updatedBy: "$updatedBy"');
    AppLogger.debug('   requestedBy: "$requestedBy"');
    AppLogger.debug('   effectiveUpdatedBy: "$effectiveUpdatedBy"');

    if (effectiveUpdatedBy.isEmpty) {
      AppLogger.warning('⚠️ WARNING: updated_by está vacío! Esto causará error en Supabase');
      throw Exception('updated_by no puede estar vacío. requestedBy: "$requestedBy", updatedBy: "$updatedBy"');
    }

    return {
      'uuid': uuid,
      'product_variant_id': productVariantId,
      'product_name': productName,
      'variant_name': variantName,
      'from_location_id': fromLocationId,
      'from_location_name': fromLocationName,
      'from_location_type': fromLocationType,
      'to_location_id': toLocationId,
      'to_location_name': toLocationName,
      'to_location_type': toLocationType,
      'quantity': quantity,
      'requested_by': requestedBy,
      'requested_by_name': requestedByName,
      'requested_at': requestedAt.toIso8601String(),
      'approved_by': approvedBy,
      'approved_by_name': approvedByName,
      'approved_at': approvedAt?.toIso8601String(),
      'rejected_by': rejectedBy,
      'rejected_by_name': rejectedByName,
      'rejected_at': rejectedAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancelled_by_name': cancelledByName,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'completed_by': completedBy,
      'completed_by_name': completedByName,
      'completed_at': completedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'status': status.name,
      'notes': notes,
      'is_synced': isSynced,
      'last_updated': lastUpdated.toIso8601String(),
      'updated_by': effectiveUpdatedBy,
    };
  }

  /// Helper para parsear el status desde JSON (soporta string e int para compatibilidad)
  static TransferStatus _parseStatus(dynamic status) {
    if (status is String) {
      // Parsear desde string (nuevo formato de Supabase)
      return TransferStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => TransferStatus.pending,
      );
    } else if (status is int) {
      // Parsear desde int (formato antiguo de Isar)
      return TransferStatus.values[status];
    }
    return TransferStatus.pending;
  }
}
