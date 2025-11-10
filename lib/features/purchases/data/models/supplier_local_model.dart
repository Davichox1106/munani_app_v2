import 'package:isar/isar.dart';
import '../../domain/entities/supplier.dart';

part 'supplier_local_model.g.dart';

@collection
class SupplierLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  String? contactName;
  String? phone;
  String? email;
  String? address;

  @Index()
  String? rucNit;

  String? notes;
  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  // Campos de sincronización
  late bool isSynced;
  late DateTime lastSyncedAt;

  SupplierLocalModel();

  /// Convierte de entidad a modelo local
  factory SupplierLocalModel.fromEntity(Supplier entity) {
    return SupplierLocalModel()
      ..uuid = entity.id
      ..name = entity.name
      ..contactName = entity.contactName
      ..phone = entity.phone
      ..email = entity.email
      ..address = entity.address
      ..rucNit = entity.rucNit
      ..notes = entity.notes
      ..isActive = entity.isActive
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..createdBy = entity.createdBy
      ..updatedBy = entity.updatedBy
      ..isSynced = true
      ..lastSyncedAt = DateTime.now();
  }

  /// Convierte de modelo local a entidad
  Supplier toEntity() {
    return Supplier(
      id: uuid,
      name: name,
      contactName: contactName,
      phone: phone,
      email: email,
      address: address,
      rucNit: rucNit,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
