import 'package:isar/isar.dart';
import '../../domain/entities/purchase.dart';

part 'purchase_local_model.g.dart';

@collection
class PurchaseLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String supplierId;
  late String supplierName;
  late String locationId;
  late String locationType;
  late String locationName;
  String? purchaseNumber;
  String? invoiceNumber;
  late DateTime purchaseDate;
  late double subtotal;
  late double tax;
  late double total;

  @enumerated
  late PurchaseStatus status;

  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String createdBy;
  String? receivedBy;
  DateTime? receivedAt;

  // Campos de sincronización
  late bool needsSync;
  DateTime? lastSyncedAt;

  PurchaseLocalModel();

  /// Convierte de entidad a modelo local
  factory PurchaseLocalModel.fromEntity(Purchase entity) {
    return PurchaseLocalModel()
      ..uuid = entity.id
      ..supplierId = entity.supplierId
      ..supplierName = entity.supplierName
      ..locationId = entity.locationId
      ..locationType = entity.locationType
      ..locationName = entity.locationName
      ..purchaseNumber = entity.purchaseNumber
      ..invoiceNumber = entity.invoiceNumber
      ..purchaseDate = entity.purchaseDate
      ..subtotal = entity.subtotal
      ..tax = entity.tax
      ..total = entity.total
      ..status = entity.status
      ..notes = entity.notes
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..createdBy = entity.createdBy
      ..receivedBy = entity.receivedBy
      ..receivedAt = entity.receivedAt
      ..needsSync = entity.needsSync
      ..lastSyncedAt = entity.lastSyncedAt;
  }

  /// Convierte de modelo local a entidad
  Purchase toEntity() {
    return Purchase(
      id: uuid,
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
      status: status,
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
}
