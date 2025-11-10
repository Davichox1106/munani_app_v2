import 'package:isar/isar.dart';
import '../../domain/entities/administrator.dart';

part 'administrator_local_model.g.dart';

@collection
class AdministratorLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  String? contactName;
  String? phone;

  @Index(unique: true)
  late String email;

  @Index(unique: true)
  String? ci;

  String? address;
  String? notes;
  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  // Campos de sincronización
  late bool isSynced;
  late DateTime lastSyncedAt;

  AdministratorLocalModel();

  /// Convierte de entidad a modelo local
  factory AdministratorLocalModel.fromEntity(Administrator entity) {
    return AdministratorLocalModel()
      ..uuid = entity.id
      ..name = entity.name
      ..contactName = entity.contactName
      ..phone = entity.phone
      ..email = entity.email
      ..ci = entity.ci
      ..address = entity.address
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
  Administrator toEntity() {
    return Administrator(
      id: uuid,
      name: name,
      contactName: contactName,
      phone: phone,
      email: email,
      ci: ci,
      address: address,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Marca el modelo como no sincronizado
  void markAsUnsynced() {
    isSynced = false;
    lastSyncedAt = DateTime.now();
  }

  /// Marca el modelo como sincronizado
  void markAsSynced() {
    isSynced = true;
    lastSyncedAt = DateTime.now();
  }
}
