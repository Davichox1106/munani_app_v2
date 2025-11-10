import 'package:isar/isar.dart';
import '../../domain/entities/customer.dart';

part 'customer_local_model.g.dart';

@collection
class CustomerLocalModel {
  Id idIsar = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index(unique: true)
  late String ci;

  @Index(type: IndexType.value)
  late String name;

  String? phone;
  String? email;
  String? address;
  String? assignedLocationId;
  String? assignedLocationType;
  String? assignedLocationName;
  late String createdBy;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Sync
  late bool needsSync;
  DateTime? lastSyncedAt;

  CustomerLocalModel();

  factory CustomerLocalModel.fromEntity(Customer e) {
    return CustomerLocalModel()
      ..uuid = e.id
      ..ci = e.ci
      ..name = e.name
      ..phone = e.phone
      ..email = e.email
      ..address = e.address
      ..assignedLocationId = e.assignedLocationId
      ..assignedLocationType = e.assignedLocationType
      ..assignedLocationName = e.assignedLocationName
      ..createdBy = e.createdBy
      ..createdAt = e.createdAt
      ..updatedAt = e.updatedAt
      ..needsSync = false
      ..lastSyncedAt = null;
  }

  Customer toEntity() => Customer(
        id: uuid,
        ci: ci,
        name: name,
        phone: phone,
        email: email,
        address: address,
        assignedLocationId: assignedLocationId,
        assignedLocationType: assignedLocationType,
        assignedLocationName: assignedLocationName,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
