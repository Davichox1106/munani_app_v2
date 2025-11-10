import '../../domain/entities/warehouse.dart';

/// Remote model for Warehouse (Supabase)
/// Maps to/from JSON for API communication
class WarehouseRemoteModel {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? managerId;
  final bool isActive;
  final String? paymentQrUrl;
  final String? paymentQrDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarehouseRemoteModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.managerId,
    required this.isActive,
    this.paymentQrUrl,
    this.paymentQrDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from Supabase JSON to remote model
  factory WarehouseRemoteModel.fromJson(Map<String, dynamic> json) {
    return WarehouseRemoteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      managerId: json['manager_id'] as String?,
      isActive: json['is_active'] as bool,
      paymentQrUrl: json['payment_qr_url'] as String?,
      paymentQrDescription: json['payment_qr_description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'manager_id': managerId,
      'is_active': isActive,
      'payment_qr_url': paymentQrUrl,
      'payment_qr_description': paymentQrDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert remote model to domain entity
  Warehouse toEntity() {
    return Warehouse(
      id: id,
      name: name,
      address: address,
      phone: phone,
      managerId: managerId,
      isActive: isActive,
      paymentQrUrl: paymentQrUrl,
      paymentQrDescription: paymentQrDescription,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create remote model from domain entity
  factory WarehouseRemoteModel.fromEntity(Warehouse warehouse) {
    return WarehouseRemoteModel(
      id: warehouse.id,
      name: warehouse.name,
      address: warehouse.address,
      phone: warehouse.phone,
      managerId: warehouse.managerId,
      isActive: warehouse.isActive,
      paymentQrUrl: warehouse.paymentQrUrl,
      paymentQrDescription: warehouse.paymentQrDescription,
      createdAt: warehouse.createdAt,
      updatedAt: warehouse.updatedAt,
    );
  }
}
