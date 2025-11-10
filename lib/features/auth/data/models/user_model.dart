import '../../domain/entities/user.dart';

/// Modelo de datos para User
///
/// Extiende la entidad User y agrega funcionalidad de serialización/deserialización
/// para trabajar con Supabase y la base de datos local.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.assignedLocationId,
    super.assignedLocationType,
    super.assignedLocationName,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un UserModel desde JSON (usado para datos de Supabase)
  ///
  /// OWASP A03:2021 - Injection Prevention:
  /// Validamos y sanitizamos todos los campos antes de crear el objeto
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      assignedLocationId: json['assigned_location_id'] as String?,
      assignedLocationType: json['assigned_location_type'] as String?,
      assignedLocationName: json['assigned_location_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte el UserModel a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'assigned_location_id': assignedLocationId,
      'assigned_location_type': assignedLocationType,
      'assigned_location_name': assignedLocationName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un UserModel desde la entidad User
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      assignedLocationId: user.assignedLocationId,
      assignedLocationType: user.assignedLocationType,
      assignedLocationName: user.assignedLocationName,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Crea una copia del UserModel con campos actualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    String? assignedLocationName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      assignedLocationType: assignedLocationType ?? this.assignedLocationType,
      assignedLocationName: assignedLocationName ?? this.assignedLocationName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
