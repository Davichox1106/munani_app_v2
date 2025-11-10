import 'package:uuid/uuid.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/administrator.dart';
import '../../domain/repositories/administrator_repository.dart';
import '../datasources/administrator_local_datasource.dart';
import '../datasources/administrator_remote_datasource.dart';
import '../models/administrator_local_model.dart';

/// Implementación del repositorio de Administrators con patrón Offline-First
///
/// OWASP A04: Arquitectura Offline-First
/// 1. Todas las operaciones se guardan primero en Isar (local)
/// 2. Se sincronizan con Supabase cuando hay conexión
class AdministratorRepositoryImpl implements AdministratorRepository {
  final AdministratorLocalDataSource localDataSource;
  final AdministratorRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  AdministratorRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Stream<List<Administrator>> getAll() async* {
    try {
      // Sincronizar en background si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      // Retornar stream de local
      await for (final models in localDataSource.watchAllAdministrators()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching administrators: $e');
    }
  }

  @override
  Stream<List<Administrator>> getAllIncludingInactive() async* {
    try {
      // Sincronizar en background si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      // Retornar stream de local
      await for (final models in localDataSource.watchAllAdministrators()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching administrators: $e');
    }
  }

  @override
  Future<List<Administrator>> search(String query) async {
    try {
      final models = await localDataSource.searchAdministrators(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error searching administrators: $e');
    }
  }

  @override
  Future<Administrator?> getByEmail(String email) async {
    try {
      final local = await localDataSource.getAdministratorByEmail(email);
      if (local != null) {
        return local.toEntity();
      }

      // Si no está en local y hay conexión, obtener de remoto
      if (await networkInfo.isConnected) {
        final remote = await remoteDatasource.getByEmail(email);
        if (remote != null) {
          final localModel = AdministratorLocalModel.fromEntity(remote);
          await localDataSource.saveAdministrator(localModel);
          return remote;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error getting administrator by email: $e');
    }
  }

  @override
  Future<Administrator> create({
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? notes,
    required String createdBy,
  }) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final newAdministrator = Administrator(
        id: uuid,
        name: name,
        contactName: contactName,
        phone: phone,
        email: email,
        ci: ci,
        address: address,
        notes: notes,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        createdBy: createdBy,
        updatedBy: createdBy,
      );

      // Guardar en local primero
      final localModel = AdministratorLocalModel.fromEntity(newAdministrator)
        ..isSynced = false;
      await localDataSource.saveAdministrator(localModel);

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.create(
            name: name,
            contactName: contactName,
            phone: phone,
            email: email,
            ci: ci,
            address: address,
            notes: notes,
            createdBy: createdBy,
          );

          // Marcar como sincronizado
          localModel.markAsSynced();
          await localDataSource.saveAdministrator(localModel);
        } catch (e) {
          AppLogger.error('Error syncing administrator: $e');
        }
      }

      return newAdministrator;
    } catch (e) {
      throw Exception('Error creating administrator: $e');
    }
  }

  @override
  Future<Administrator> update(Administrator administrator, String updatedBy) async {
    try {
      final updatedAdministrator = administrator.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      // Guardar en local primero
      final localModel = AdministratorLocalModel.fromEntity(updatedAdministrator)
        ..isSynced = false;
      await localDataSource.saveAdministrator(localModel);

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.update(
            id: administrator.id,
            name: updatedAdministrator.name,
            contactName: updatedAdministrator.contactName,
            phone: updatedAdministrator.phone,
            email: updatedAdministrator.email,
            ci: updatedAdministrator.ci,
            address: updatedAdministrator.address,
            notes: updatedAdministrator.notes,
            updatedBy: updatedBy,
          );

          // Marcar como sincronizado
          localModel.markAsSynced();
          await localDataSource.saveAdministrator(localModel);
        } catch (e) {
          AppLogger.error('Error syncing administrator update: $e');
        }
      }

      return updatedAdministrator;
    } catch (e) {
      throw Exception('Error updating administrator: $e');
    }
  }

  @override
  Future<void> deactivate(String administratorId) async {
    try {
      final local = await localDataSource.getAdministratorById(administratorId);
      if (local != null) {
        local.isActive = false;
        local.markAsUnsynced();
        await localDataSource.saveAdministrator(local);

        // Intentar sincronizar si hay conexión
        if (await networkInfo.isConnected) {
          try {
            await remoteDatasource.deactivate(administratorId);
            local.markAsSynced();
            await localDataSource.saveAdministrator(local);
          } catch (e) {
            AppLogger.error('Error syncing administrator deactivation: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Error deactivating administrator: $e');
    }
  }

  @override
  Future<void> activate(String administratorId) async {
    try {
      final local = await localDataSource.getAdministratorById(administratorId);
      if (local != null) {
        local.isActive = true;
        local.markAsUnsynced();
        await localDataSource.saveAdministrator(local);

        // Intentar sincronizar si hay conexión
        if (await networkInfo.isConnected) {
          try {
            await remoteDatasource.activate(administratorId);
            local.markAsSynced();
            await localDataSource.saveAdministrator(local);
          } catch (e) {
            AppLogger.error('Error syncing administrator activation: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Error activating administrator: $e');
    }
  }

  @override
  Future<bool> existsCi(String ci, {String? excludeId}) async {
    try {
      // Primero buscar en local
      final local = await localDataSource.getAdministratorByCi(ci);
      if (local != null && local.uuid != excludeId) {
        return true;
      }

      // Si hay conexión, verificar también en remoto
      if (await networkInfo.isConnected) {
        return await remoteDatasource.existsCi(ci, excludeId: excludeId);
      }

      return false;
    } catch (e) {
      throw Exception('Error checking CI existence: $e');
    }
  }

  /// Sincronización completa de administradores
  @override
  Future<void> syncAdministrators() async {
    if (!await networkInfo.isConnected) return;

    try {
      // 1. Sincronizar cambios locales no sincronizados hacia Supabase
      final unsynced = await localDataSource.getUnsyncedAdministrators();
      for (final localModel in unsynced) {
        try {
          final entity = localModel.toEntity();

          // Verificar si existe en remoto
          final remoteExists = await remoteDatasource.getByEmail(entity.email);

          if (remoteExists == null) {
            // Crear en remoto
            await remoteDatasource.create(
              name: entity.name,
              contactName: entity.contactName,
              phone: entity.phone,
              email: entity.email,
              ci: entity.ci,
              address: entity.address,
              notes: entity.notes,
              createdBy: entity.createdBy ?? '',
            );
          } else {
            // Actualizar en remoto
            await remoteDatasource.update(
              id: entity.id,
              name: entity.name,
              contactName: entity.contactName,
              phone: entity.phone,
              email: entity.email,
              ci: entity.ci,
              address: entity.address,
              notes: entity.notes,
              updatedBy: entity.updatedBy ?? '',
            );
          }

          // Marcar como sincronizado
          localModel.markAsSynced();
          await localDataSource.saveAdministrator(localModel);
        } catch (e) {
          AppLogger.error('Error syncing administrator ${localModel.uuid}: $e');
        }
      }

      // 2. Sincronizar desde Supabase hacia local (importante!)
      // Obtener todos los administradores desde Supabase
      try {
        final remoteList = await remoteDatasource.getAllIncludingInactive().first;
        
        for (final remoteModel in remoteList) {
          try {
            // AdministratorModel extiende Administrator, convertir directamente a modelo local
            final localModel = AdministratorLocalModel.fromEntity(remoteModel);

            // Guardar o actualizar en local
            await localDataSource.saveAdministrator(localModel);
          } catch (e) {
            AppLogger.error('Error saving remote administrator ${remoteModel.id}: $e');
          }
        }

        AppLogger.info('✅ Administradores sincronizados desde Supabase: ${remoteList.length}');
      } catch (e) {
        AppLogger.error('Error fetching administrators from Supabase: $e');
      }
    } catch (e) {
      AppLogger.error('Error in full sync: $e');
    }
  }

  /// Sincroniza en background sin bloquear la UI
  void _syncInBackground() {
    syncAdministrators().catchError((error) {
      AppLogger.error('Background sync error: $error');
    });
  }
}
