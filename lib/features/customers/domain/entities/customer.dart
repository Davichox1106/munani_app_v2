import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String ci; // Documento de identidad (único)
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? assignedLocationId;
  final String? assignedLocationType; // 'store' | 'warehouse'
  final String? assignedLocationName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
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

  Customer copyWith({
    String? id,
    String? ci,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? assignedLocationId,
    String? assignedLocationType,
    String? assignedLocationName,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      ci: ci ?? this.ci,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      assignedLocationType: assignedLocationType ?? this.assignedLocationType,
      assignedLocationName: assignedLocationName ?? this.assignedLocationName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ci,
        name,
        phone,
        email,
        address,
        assignedLocationId,
        assignedLocationType,
        assignedLocationName,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
