import 'package:isar/isar.dart';
import '../../domain/entities/user.dart';

part 'user_local_model.g.dart';

/// Modelo de User para Isar (Base de datos local)
///
/// Este modelo se usa SOLO para persistencia local.
/// Para comunicación con Supabase, se usa UserModel.
@collection
class UserLocalModel {
  /// ID local de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  /// UUID de Supabase (único en el sistema)
  @Index(unique: true)
  late String uuid;

  /// Email del usuario
  @Index()
  late String email;

  /// Nombre completo
  late String name;

  /// Rol: 'admin', 'store_manager', 'warehouse_manager'
  late String role;

  /// ID de ubicación asignada
  String? assignedLocationId;

  /// Tipo de ubicación: 'store' o 'warehouse'
  String? assignedLocationType;

  /// Estado activo
  late bool isActive;

  /// Fecha de creación
  late DateTime createdAt;

  /// Fecha de actualización
  late DateTime updatedAt;

  /// Indica si hay cambios pendientes de sincronizar
  late bool pendingSync;

  /// Fecha de última sincronización
  DateTime? syncedAt;

  /// Constructor vacío requerido por Isar
  UserLocalModel();

  /// Crea un UserLocalModel desde la entidad User
  factory UserLocalModel.fromEntity(User user) {
    return UserLocalModel()
      ..uuid = user.id
      ..email = user.email
      ..name = user.name
      ..role = user.role
      ..assignedLocationId = user.assignedLocationId
      ..assignedLocationType = user.assignedLocationType
      ..isActive = user.isActive
      ..createdAt = user.createdAt
      ..updatedAt = user.updatedAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Convierte a entidad User
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

  /// Crea una copia con campos actualizados
  UserLocalModel copyWith({
    String? uuid,
    String? email,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendingSync,
    DateTime? syncedAt,
  }) {
    return UserLocalModel()
      ..id = id
      ..uuid = uuid ?? this.uuid
      ..email = email ?? this.email
      ..name = name ?? this.name
      ..role = role ?? this.role
      ..assignedLocationId = assignedLocationId ?? this.assignedLocationId
      ..assignedLocationType = assignedLocationType ?? this.assignedLocationType
      ..isActive = isActive ?? this.isActive
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..pendingSync = pendingSync ?? this.pendingSync
      ..syncedAt = syncedAt ?? this.syncedAt;
  }
}
