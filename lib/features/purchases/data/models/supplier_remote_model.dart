import '../../domain/entities/supplier.dart';

/// Modelo remoto de Supplier para Supabase
///
/// Maneja serialización/deserialización con PostgreSQL
class SupplierRemoteModel {
  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? rucNit;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SupplierRemoteModel({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.rucNit,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // ============================================================================
  // CONVERSIONES
  // ============================================================================

  /// Crear desde JSON de Supabase
  factory SupplierRemoteModel.fromJson(Map<String, dynamic> json) {
    return SupplierRemoteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactName: json['contact_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      rucNit: json['ruc_nit'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'address': address,
      'ruc_nit': rucNit,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  /// Convertir a entidad de dominio
  Supplier toEntity() {
    return Supplier(
      id: id,
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

  /// Crear desde entidad de dominio
  factory SupplierRemoteModel.fromEntity(Supplier entity) {
    return SupplierRemoteModel(
      id: entity.id,
      name: entity.name,
      contactName: entity.contactName,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      rucNit: entity.rucNit,
      notes: entity.notes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
}
