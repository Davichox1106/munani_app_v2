import 'package:isar/isar.dart';
import '../../domain/entities/employee_store.dart';

part 'employee_store_local_model.g.dart';

@collection
class EmployeeStoreLocalModel {
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
  String? position;
  String? department;
  String? notes;
  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  // Campos de sincronización
  late bool isSynced;
  late DateTime lastSyncedAt;

  EmployeeStoreLocalModel();

  /// Convierte de entidad a modelo local
  factory EmployeeStoreLocalModel.fromEntity(EmployeeStore entity) {
    return EmployeeStoreLocalModel()
      ..uuid = entity.id
      ..name = entity.name
      ..contactName = entity.contactName
      ..phone = entity.phone
      ..email = entity.email
      ..ci = entity.ci
      ..address = entity.address
      ..position = entity.position
      ..department = entity.department
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
  EmployeeStore toEntity() {
    return EmployeeStore(
      id: uuid,
      name: name,
      contactName: contactName,
      phone: phone,
      email: email,
      ci: ci,
      address: address,
      position: position,
      department: department,
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
