import 'package:equatable/equatable.dart';

/// Entidad de Usuario para el módulo de gestión de usuarios
///
/// Representa un usuario del sistema con sus datos básicos y permisos
class User extends Equatable {
  /// ID único del usuario (UUID)
  final String id;

  /// Email del usuario
  final String email;

  /// Nombre completo del usuario
  final String name;

  /// Rol del usuario (admin, store_manager, warehouse_manager, customer)
  final String role;

  /// ID de la ubicación asignada (tienda o almacén)
  final String? assignedLocationId;

  /// Tipo de ubicación asignada (store, warehouse)
  final String? assignedLocationType;

  /// Estado del usuario (activo/inactivo)
  final bool isActive;

  /// Fecha de creación
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.assignedLocationId,
    this.assignedLocationType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear usuario desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      assignedLocationId: json['assigned_location_id'] as String?,
      assignedLocationType: json['assigned_location_type'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      if (assignedLocationId != null) 'assigned_location_id': assignedLocationId,
      if (assignedLocationType != null) 'assigned_location_type': assignedLocationType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crear copia con cambios
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      assignedLocationType: assignedLocationType ?? this.assignedLocationType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si es administrador
  bool get isAdmin => role == 'admin';

  /// Verificar si es manager de tienda
  bool get isStoreManager => role == 'store_manager';

  /// Verificar si es manager de almacén
  bool get isWarehouseManager => role == 'warehouse_manager';

  /// Verificar si es cliente
  bool get isCustomer => role == 'customer';

  /// Verificar si tiene ubicación asignada
  bool get hasAssignedLocation => assignedLocationId != null && assignedLocationType != null;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        assignedLocationId,
        assignedLocationType,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, isActive: $isActive)';
  }
}


