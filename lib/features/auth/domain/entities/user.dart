import 'package:equatable/equatable.dart';

/// Entidad User - Representa un usuario del sistema
///
/// Esta entidad es parte de la capa de dominio y no depende de ninguna
/// implementación específica de base de datos o API.
class User extends Equatable {
  /// ID único del usuario (UUID de Supabase)
  final String id;

  /// Email del usuario (único)
  final String email;

  /// Nombre completo del usuario
  final String name;

  /// Rol del usuario: 'admin', 'store_manager', 'warehouse_manager'
  final String role;

  /// ID de la ubicación asignada (tienda o bodega)
  final String? assignedLocationId;

  /// Tipo de ubicación asignada: 'store' o 'warehouse'
  final String? assignedLocationType;

  /// Nombre de la ubicación asignada (tienda o almacén)
  final String? assignedLocationName;

  /// Indica si el usuario está activo
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
    this.assignedLocationName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si el usuario es administrador
  bool get isAdmin => role == 'admin';

  /// Verifica si el usuario es gerente de tienda
  bool get isStoreManager => role == 'store_manager';

  /// Verifica si el usuario es gerente de bodega
  bool get isWarehouseManager => role == 'warehouse_manager';

  /// Verifica si el usuario tiene una ubicación asignada
  bool get hasAssignedLocation =>
      assignedLocationId != null && assignedLocationType != null;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        assignedLocationId,
        assignedLocationType,
        assignedLocationName,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, isActive: $isActive)';
  }
}
