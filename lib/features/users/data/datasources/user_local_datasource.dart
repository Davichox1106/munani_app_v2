import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/user_local_model.dart';

/// DataSource local para gestión de usuarios (offline-first)
///
/// Maneja todas las operaciones CRUD locales usando Isar
/// Se sincroniza con el servidor cuando hay conexión
abstract class UserLocalDataSource {
  /// Obtener todos los usuarios
  Future<List<UserManagementLocalModel>> getAllUsers();

  /// Observar cambios en todos los usuarios (reactivo)
  Stream<List<UserManagementLocalModel>> watchAllUsers();

  /// Obtener usuario por ID
  Future<UserManagementLocalModel?> getUserById(String userId);

  /// Obtener usuario por email
  Future<UserManagementLocalModel?> getUserByEmail(String email);

  /// Guardar usuario (crear o actualizar)
  Future<UserManagementLocalModel> saveUser(UserManagementLocalModel user);

  /// Eliminar usuario
  Future<void> deleteUser(String userId);

  /// Obtener usuarios que necesitan sincronización
  Future<List<UserManagementLocalModel>> getUsersNeedingSync();

  /// Marcar usuario como sincronizado
  Future<void> markUserAsSynced(String userId);

  /// Obtener usuarios por rol
  Future<List<UserManagementLocalModel>> getUsersByRole(String role);

  /// Obtener usuarios activos
  Future<List<UserManagementLocalModel>> getActiveUsers();

  /// Obtener usuarios inactivos
  Future<List<UserManagementLocalModel>> getInactiveUsers();

  /// Buscar usuarios por nombre o email
  Future<List<UserManagementLocalModel>> searchUsers(String query);

  /// Obtener usuarios asignados a una ubicación
  Future<List<UserManagementLocalModel>> getUsersByLocation(
    String locationId,
    String locationType,
  );

  /// Limpiar datos locales (útil para testing)
  Future<void> clearAllUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final IsarDatabase isarDatabase;

  UserLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<List<UserManagementLocalModel>> getAllUsers() async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels.where().findAll();
  }

  @override
  Stream<List<UserManagementLocalModel>> watchAllUsers() async* {
    final isar = await isarDatabase.database;
    yield* isar.userManagementLocalModels
        .where()
        .watch(fireImmediately: true);
  }

  @override
  Future<UserManagementLocalModel?> getUserById(String userId) async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .uuidEqualTo(userId)
        .findFirst();
  }

  @override
  Future<UserManagementLocalModel?> getUserByEmail(String email) async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .emailEqualTo(email)
        .findFirst();
  }

  @override
  Future<UserManagementLocalModel> saveUser(UserManagementLocalModel user) async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      // Buscar si ya existe por UUID
      final existing = await isar.userManagementLocalModels
          .filter()
          .uuidEqualTo(user.uuid)
          .findFirst();

      if (existing != null) {
        // Actualizar: preservar el ID de Isar
        user.id = existing.id;
      }
      // Si no existe, Isar asignará un nuevo ID automáticamente

      await isar.userManagementLocalModels.put(user);
    });

    return user;
  }

  @override
  Future<void> deleteUser(String userId) async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      final user = await isar.userManagementLocalModels
          .filter()
          .uuidEqualTo(userId)
          .findFirst();

      if (user != null) {
        await isar.userManagementLocalModels.delete(user.id);
      }
    });
  }

  @override
  Future<List<UserManagementLocalModel>> getUsersNeedingSync() async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .needsSyncEqualTo(true)
        .findAll();
  }

  @override
  Future<void> markUserAsSynced(String userId) async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      final user = await isar.userManagementLocalModels
          .filter()
          .uuidEqualTo(userId)
          .findFirst();

      if (user != null) {
        user.markAsSynced();
        await isar.userManagementLocalModels.put(user);
      }
    });
  }

  @override
  Future<List<UserManagementLocalModel>> getUsersByRole(String role) async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .roleEqualTo(role)
        .findAll();
  }

  @override
  Future<List<UserManagementLocalModel>> getActiveUsers() async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .isActiveEqualTo(true)
        .findAll();
  }

  @override
  Future<List<UserManagementLocalModel>> getInactiveUsers() async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .isActiveEqualTo(false)
        .findAll();
  }

  @override
  Future<List<UserManagementLocalModel>> searchUsers(String query) async {
    final isar = await isarDatabase.database;
    
    // Obtener todos los usuarios y filtrar en memoria
    // (Isar no soporta búsquedas complejas con OR directo)
    final allUsers = await isar.userManagementLocalModels.where().findAll();
    
    final queryLower = query.toLowerCase();
    return allUsers.where((user) {
      return user.name.toLowerCase().contains(queryLower) ||
          user.email.toLowerCase().contains(queryLower);
    }).toList();
  }

  @override
  Future<List<UserManagementLocalModel>> getUsersByLocation(
    String locationId,
    String locationType,
  ) async {
    final isar = await isarDatabase.database;
    return await isar.userManagementLocalModels
        .filter()
        .assignedLocationIdEqualTo(locationId)
        .and()
        .assignedLocationTypeEqualTo(locationType)
        .findAll();
  }

  @override
  Future<void> clearAllUsers() async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      await isar.userManagementLocalModels.clear();
    });
  }
}
