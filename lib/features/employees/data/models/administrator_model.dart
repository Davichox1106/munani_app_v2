import '../../domain/entities/administrator.dart';

/// Modelo de datos para Administrator
class AdministratorModel extends Administrator {
  const AdministratorModel({
    required super.id,
    required super.name,
    super.contactName,
    super.phone,
    required super.email,
    super.ci,
    super.address,
    super.notes,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Crea un modelo desde JSON
  factory AdministratorModel.fromJson(Map<String, dynamic> json) {
    return AdministratorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactName: json['contact_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      ci: json['ci'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'ci': ci,
      'address': address,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  /// Crea un modelo desde una entidad
  factory AdministratorModel.fromEntity(Administrator administrator) {
    return AdministratorModel(
      id: administrator.id,
      name: administrator.name,
      contactName: administrator.contactName,
      phone: administrator.phone,
      email: administrator.email,
      ci: administrator.ci,
      address: administrator.address,
      notes: administrator.notes,
      isActive: administrator.isActive,
      createdAt: administrator.createdAt,
      updatedAt: administrator.updatedAt,
      createdBy: administrator.createdBy,
      updatedBy: administrator.updatedBy,
    );
  }
}
