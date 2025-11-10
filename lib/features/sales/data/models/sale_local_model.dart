import 'package:isar/isar.dart';
import '../../domain/entities/sale.dart';

part 'sale_local_model.g.dart';

@collection
class SaleLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String locationId;
  late String locationType;
  String? saleNumber;
  String? customerName;
  late DateTime saleDate;
  late double subtotal;
  late double tax;
  late double total;

  @enumerated
  late SaleStatus status;

  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String createdBy;

  // Sync flags
  late bool needsSync;
  DateTime? lastSyncedAt;

  SaleLocalModel();

  factory SaleLocalModel.fromEntity(Sale entity) {
    return SaleLocalModel()
      ..uuid = entity.id
      ..locationId = entity.locationId
      ..locationType = entity.locationType
      ..saleNumber = entity.saleNumber
      ..customerName = entity.customerName
      ..saleDate = entity.saleDate
      ..subtotal = entity.subtotal
      ..tax = entity.tax
      ..total = entity.total
      ..status = entity.status
      ..notes = entity.notes
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..createdBy = entity.createdBy
      ..needsSync = false
      ..lastSyncedAt = null;
  }

  Sale toEntity() {
    return Sale(
      id: uuid,
      locationId: locationId,
      locationType: locationType,
      saleNumber: saleNumber,
      customerName: customerName,
      saleDate: saleDate,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }
}
