import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Contrato para el data source local de autenticación
abstract class AuthLocalDataSource {
  /// Guarda el usuario autenticado en Isar
  Future<void> cacheUser(UserLocalModel user);

  /// Obtiene el usuario autenticado desde Isar
  Future<UserLocalModel?> getCachedUser();

  /// Actualiza el usuario en Isar
  Future<void> updateCachedUser(UserLocalModel user);

  /// Elimina el usuario autenticado (logout)
  Future<void> deleteCachedUser();

  /// Verifica si hay un usuario en caché
  Future<bool> hasUserCached();
}

/// Implementación del data source local usando Isar
///
/// Almacena el usuario autenticado localmente para:
/// 1. Acceso offline a datos del usuario
/// 2. Persistencia de sesión
/// 3. Offline-First: priorizar datos locales
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final IsarDatabase isarDatabase;

  AuthLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<void> cacheUser(UserLocalModel user) async {
    try {
      final isar = await isarDatabase.database;

      await isar.writeTxn(() async {
        // Primero limpiar usuario anterior (solo debe haber uno)
        await isar.userLocalModels.clear();

        // Guardar nuevo usuario
        await isar.userLocalModels.put(user);
      });

      AppLogger.debug('💾 Usuario guardado en Isar: ${user.name} (${user.email})');
    } catch (e) {
      throw CacheException('Error al guardar usuario en caché: $e');
    }
  }

  @override
  Future<UserLocalModel?> getCachedUser() async {
    try {
      final isar = await isarDatabase.database;

      // Obtener el primer usuario (solo debe haber uno)
      final user = await isar.userLocalModels.where().findFirst();

      return user;
    } catch (e) {
      throw CacheException('Error al obtener usuario desde caché: $e');
    }
  }

  @override
  Future<void> updateCachedUser(UserLocalModel user) async {
    try {
      final isar = await isarDatabase.database;

      await isar.writeTxn(() async {
        // Buscar usuario existente por UUID
        final existingUser = await isar.userLocalModels
            .filter()
            .uuidEqualTo(user.uuid)
            .findFirst();

        if (existingUser != null) {
          // Mantener el ID local de Isar
          user.id = existingUser.id;
        }

        // Actualizar o insertar
        await isar.userLocalModels.put(user);
      });
    } catch (e) {
      throw CacheException('Error al actualizar usuario en caché: $e');
    }
  }

  @override
  Future<void> deleteCachedUser() async {
    try {
      final isar = await isarDatabase.database;

      await isar.writeTxn(() async {
        await isar.userLocalModels.clear();
      });
    } catch (e) {
      throw CacheException('Error al eliminar usuario de caché: $e');
    }
  }

  @override
  Future<bool> hasUserCached() async {
    try {
      final isar = await isarDatabase.database;

      final count = await isar.userLocalModels.count();
      return count > 0;
    } catch (e) {
      throw CacheException('Error al verificar usuario en caché: $e');
    }
  }
}
