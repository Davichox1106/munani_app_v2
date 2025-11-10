import '../../domain/entities/customer.dart';

class CustomerRemoteModel {
  final String id;
  final String ci;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? assignedLocationId;
  final String? assignedLocationType;
  final String? assignedLocationName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerRemoteModel({
    required this.id,
    required this.ci,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.assignedLocationId,
    this.assignedLocationType,
    this.assignedLocationName,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerRemoteModel.fromJson(Map<String, dynamic> json) => CustomerRemoteModel(
        id: json['id'] as String,
        ci: json['ci'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        assignedLocationId: json['assigned_location_id'] as String?,
        assignedLocationType: json['assigned_location_type'] as String?,
        assignedLocationName: json['assigned_location_name'] as String?,
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ci': ci,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'assigned_location_id': assignedLocationId,
        'assigned_location_type': assignedLocationType,
        'assigned_location_name': assignedLocationName,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Customer toEntity() => Customer(
        id: id,
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

  static CustomerRemoteModel fromEntity(Customer e) => CustomerRemoteModel(
        id: e.id,
        ci: e.ci,
        name: e.name,
        phone: e.phone,
        email: e.email,
        address: e.address,
        assignedLocationId: e.assignedLocationId,
        assignedLocationType: e.assignedLocationType,
        assignedLocationName: e.assignedLocationName,
        createdBy: e.createdBy,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}
