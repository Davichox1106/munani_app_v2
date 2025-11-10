import 'package:isar/isar.dart';
import '../../domain/entities/user.dart';

part 'user_local_model.g.dart';

/// Modelo local de Usuario para Isar (offline-first)
///
/// Almacena usuarios localmente para operaciones offline
/// Se sincroniza con Supabase cuando hay conexión
@collection
class UserManagementLocalModel {
  /// ID de Isar (auto-increment)
  Id id = Isar.autoIncrement;

  /// UUID del usuario (clave única)
  @Index(unique: true)
  late String uuid;

  /// Email del usuario
  late String email;

  /// Nombre completo del usuario
  late String name;

  /// Rol del usuario (admin, store_manager, warehouse_manager, customer)
  late String role;

  /// ID de la ubicación asignada (tienda o almacén)
  String? assignedLocationId;

  /// Tipo de ubicación asignada (store, warehouse)
  String? assignedLocationType;

  /// Estado del usuario (activo/inactivo)
  late bool isActive;

  /// Fecha de creación
  late DateTime createdAt;

  /// Fecha de última actualización
  late DateTime updatedAt;

  /// Fecha de última sincronización
  late DateTime lastSync;

  /// Indica si necesita sincronización
  late bool needsSync;

  /// Operación pendiente (create, update, delete)
  String? pendingOperation;

  /// Datos JSON para sincronización
  String? syncData;

  /// Constructor
  UserManagementLocalModel();

  /// Constructor con parámetros
  UserManagementLocalModel.create({
    required this.uuid,
    required this.email,
    required this.name,
    required this.role,
    this.assignedLocationId,
    this.assignedLocationType,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSync,
    this.needsSync = true,
    this.pendingOperation,
    this.syncData,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        lastSync = lastSync ?? DateTime.now();

  /// Convertir desde JSON (Supabase)
  factory UserManagementLocalModel.fromJson(Map<String, dynamic> json) {
    return UserManagementLocalModel.create(
      uuid: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      assignedLocationId: json['assigned_location_id'] as String?,
      assignedLocationType: json['assigned_location_type'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSync: DateTime.now(),
      needsSync: false,
    );
  }

  /// Convertir a JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
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

  /// Convertir a Entity
  User toEntity() {
    return User(
      id: uuid,
      email: email,
      name: name,
      role: role,
      assignedLocationId: assignedLocationId,
      assignedLocationType: assignedLocationType,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crear desde Entity
  factory UserManagementLocalModel.fromEntity(User user) {
    return UserManagementLocalModel.create(
      uuid: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      assignedLocationId: user.assignedLocationId,
      assignedLocationType: user.assignedLocationType,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Marcar como necesita sincronización
  void markForSync(String operation, {Map<String, dynamic>? data}) {
    needsSync = true;
    pendingOperation = operation;
    if (data != null) {
      syncData = data.toString();
    }
    updatedAt = DateTime.now();
  }

  /// Marcar como sincronizado
  void markAsSynced() {
    needsSync = false;
    pendingOperation = null;
    syncData = null;
    lastSync = DateTime.now();
  }

  /// Actualizar datos
  void updateData({
    String? email,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
  }) {
    if (email != null) this.email = email;
    if (name != null) this.name = name;
    if (role != null) this.role = role;
    if (assignedLocationId != null) this.assignedLocationId = assignedLocationId;
    if (assignedLocationType != null) this.assignedLocationType = assignedLocationType;
    if (isActive != null) this.isActive = isActive;
    
    updatedAt = DateTime.now();
    markForSync('update');
  }

  /// Desactivar usuario
  void deactivate() {
    isActive = false;
    updatedAt = DateTime.now();
    markForSync('update');
  }

  @override
  String toString() {
    return 'UserManagementLocalModel(id: $id, uuid: $uuid, email: $email, name: $name, role: $role, isActive: $isActive, needsSync: $needsSync)';
  }
}
