import 'package:uuid/uuid.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_local_datasource.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_local_model.dart';
import '../models/supplier_remote_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de Suppliers con patrón Offline-First
///
/// OWASP A04: Arquitectura Offline-First
/// 1. Todas las operaciones se guardan primero en Isar (local)
/// 2. Se sincronizan con Supabase cuando hay conexión
class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSource localDataSource;
  final SupplierRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SupplierRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<List<Supplier>> watchAllSuppliers() async* {
    try {
      await for (final models in localDataSource.watchAllSuppliers()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching suppliers: $e');
    }
  }

  @override
  Stream<List<Supplier>> watchActiveSuppliers() async* {
    try {
      await for (final models in localDataSource.watchActiveSuppliers()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching active suppliers: $e');
    }
  }

  @override
  Future<Supplier?> getSupplierById(String id) async {
    try {
      // Intentar obtener de local primero
      final local = await localDataSource.getSupplierById(id);
      if (local != null) {
        return local.toEntity();
      }

      // Si no está en local y hay conexión, obtener de remoto
      if (await networkInfo.isConnected) {
        final remote = await remoteDataSource.getSupplierById(id);
        // Guardar en local
        final localModel = SupplierLocalModel.fromEntity(remote.toEntity());
        await localDataSource.saveSupplier(localModel);
        return remote.toEntity();
      }

      return null;
    } catch (e) {
      throw Exception('Error getting supplier: $e');
    }
  }

  @override
  Future<List<Supplier>> getActiveSuppliers() async {
    try {
      // Sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        await syncSuppliers();
      }

      // Retornar de local
      final models = await localDataSource.getActiveSuppliersList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error getting active suppliers: $e');
    }
  }

  @override
  Future<List<Supplier>> searchSuppliers(String query) async {
    try {
      final models = await localDataSource.searchSuppliers(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error searching suppliers: $e');
    }
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final newSupplier = supplier.copyWith(
        id: uuid,
        createdAt: now,
        updatedAt: now,
      );

      // Guardar en local primero
      final localModel = SupplierLocalModel.fromEntity(newSupplier)
        ..isSynced = false;
      await localDataSource.saveSupplier(localModel);

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          final remoteModel = SupplierRemoteModel.fromEntity(newSupplier);
          await remoteDataSource.createSupplier(remoteModel.toJson());

          // Marcar como sincronizado
          localModel.isSynced = true;
          await localDataSource.saveSupplier(localModel);
        } catch (e) {
          // Si falla la sincronización, quedará pendiente
          AppLogger.error('Error syncing supplier: $e');
        }
      }

      return newSupplier;
    } catch (e) {
      throw Exception('Error creating supplier: $e');
    }
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final updatedSupplier = supplier.copyWith(
        updatedAt: DateTime.now(),
      );

      // Guardar en local primero
      final localModel = SupplierLocalModel.fromEntity(updatedSupplier)
        ..isSynced = false;
      await localDataSource.saveSupplier(localModel);

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          final remoteModel = SupplierRemoteModel.fromEntity(updatedSupplier);
          await remoteDataSource.updateSupplier(
            supplier.id,
            remoteModel.toJson(),
          );

          // Marcar como sincronizado
          localModel.isSynced = true;
          await localDataSource.saveSupplier(localModel);
        } catch (e) {
          AppLogger.error('Error syncing supplier update: $e');
        }
      }

      return updatedSupplier;
    } catch (e) {
      throw Exception('Error updating supplier: $e');
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      // Soft delete en local
      final local = await localDataSource.getSupplierById(id);
      if (local != null) {
        final deactivated = local..isActive = false;
        await localDataSource.saveSupplier(deactivated);

        // Intentar sincronizar si hay conexión
        if (await networkInfo.isConnected) {
          try {
            await remoteDataSource.deleteSupplier(id);
          } catch (e) {
            AppLogger.error('Error syncing supplier deletion: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Error deleting supplier: $e');
    }
  }

  @override
  Future<void> syncSuppliers() async {
    try {
      if (!await networkInfo.isConnected) return;

      // 1. Sincronizar cambios locales no sincronizados
      final unsynced = await localDataSource.getUnsyncedSuppliers();
      for (final localModel in unsynced) {
        try {
          final entity = localModel.toEntity();
          final remoteModel = SupplierRemoteModel.fromEntity(entity);

          // Verificar si existe en remoto
          try {
            await remoteDataSource.getSupplierById(entity.id);
            // Si existe, actualizar
            await remoteDataSource.updateSupplier(
              entity.id,
              remoteModel.toJson(),
            );
          } catch (e) {
            // Si no existe, crear
            await remoteDataSource.createSupplier(remoteModel.toJson());
          }

          // Marcar como sincronizado
          localModel.isSynced = true;
          await localDataSource.saveSupplier(localModel);
        } catch (e) {
          AppLogger.error('Error syncing supplier ${localModel.uuid}: $e');
        }
      }

      // 2. Obtener todos los proveedores remotos y actualizar local
      final remoteSuppliers = await remoteDataSource.getAllSuppliers();
      for (final remoteModel in remoteSuppliers) {
        final entity = remoteModel.toEntity();
        final localModel = SupplierLocalModel.fromEntity(entity)
          ..isSynced = true;
        await localDataSource.saveSupplier(localModel);
      }
    } catch (e) {
      throw Exception('Error syncing suppliers: $e');
    }
  }
}
