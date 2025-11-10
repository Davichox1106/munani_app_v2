import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../sync/domain/entities/sync_queue_item.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/store_local_datasource.dart';
import '../datasources/store_remote_datasource.dart';
import '../datasources/warehouse_local_datasource.dart';
import '../datasources/warehouse_remote_datasource.dart';
import '../models/store_local_model.dart';
import '../models/warehouse_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de ubicaciones
///
/// Gestiona stores y warehouses con patrón Offline-First
/// OWASP A04:2021 - Insecure Design: Arquitectura robusta offline-first
class LocationRepositoryImpl implements LocationRepository {
  final StoreLocalDataSource storeLocalDataSource;
  final StoreRemoteDataSource storeRemoteDataSource;
  final WarehouseLocalDataSource warehouseLocalDataSource;
  final WarehouseRemoteDataSource warehouseRemoteDataSource;
  final NetworkInfo networkInfo;
  final SyncRepository syncRepository;

  LocationRepositoryImpl({
    required this.storeLocalDataSource,
    required this.storeRemoteDataSource,
    required this.warehouseLocalDataSource,
    required this.warehouseRemoteDataSource,
    required this.networkInfo,
    required this.syncRepository,
  });

  // ========== STORES ==========

  @override
  Future<Either<Failure, List<Store>>> getAllStores() async {
    try {
      final localStores = await storeLocalDataSource.getAllStores();
      final stores = localStores.map((m) => m.toEntity()).toList();

      // Sincronizar en background
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(stores);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener tiendas: $e'));
    }
  }

  @override
  Future<Either<Failure, Store>> getStoreById(String id) async {
    try {
      final localStore = await storeLocalDataSource.getStoreByUuid(id);

      if (localStore != null) {
        return Right(localStore.toEntity());
      }

      AppLogger.debug('📡 Tienda $id no encontrada en cache, intentando remoto');

      if (await networkInfo.isConnected) {
        try {
          final remoteStore = await storeRemoteDataSource.getStoreById(id);
          final localModel = StoreLocalModel.fromRemote(
            id: remoteStore.id,
            name: remoteStore.name,
            address: remoteStore.address,
            phone: remoteStore.phone,
            managerId: remoteStore.managerId,
            isActive: remoteStore.isActive,
            paymentQrUrl: remoteStore.paymentQrUrl,
            paymentQrDescription: remoteStore.paymentQrDescription,
            createdAt: remoteStore.createdAt,
            updatedAt: remoteStore.updatedAt,
          )..markAsSynced();

          await storeLocalDataSource.saveStore(localModel);
          return Right(localModel.toEntity());
        } catch (e) {
          final message = _mapRemoteError(e, entityLabel: 'tienda');
          return Left(ServerFailure(message));
        }
      }

      return const Left(CacheFailure('Tienda no encontrada'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener tienda: $e'));
    }
  }

  @override
  Future<Either<Failure, Store>> createStore({
    required String name,
    required String address,
    String? phone,
    String? managerId,
    String? paymentQrUrl,
    String? paymentQrDescription,
  }) async {
    try {
      // Validación
      if (name.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre es requerido'));
      }

      if (address.trim().isEmpty) {
        return const Left(ValidationFailure('La dirección es requerida'));
      }

      if (paymentQrUrl == null || paymentQrUrl.trim().isEmpty) {
        return const Left(ValidationFailure('La URL del QR es obligatoria'));
      }

      if (paymentQrDescription == null || paymentQrDescription.trim().isEmpty) {
        return const Left(ValidationFailure('La descripción del QR es obligatoria'));
      }

      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final store = Store(
        id: uuid,
        name: name.trim(),
        address: address.trim(),
        phone: phone?.trim(),
        managerId: managerId,
        isActive: true,
        paymentQrUrl: paymentQrUrl.trim(),
        paymentQrDescription: paymentQrDescription.trim(),
        createdAt: now,
        updatedAt: now,
      );

      // Guardar local
      final localModel = StoreLocalModel.fromEntity(store);
      localModel.markForSync();
      await storeLocalDataSource.saveStore(localModel);

      // Encolar para sync
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.store,
        entityId: store.id,
        operation: SyncOperation.create,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(store);
    } catch (e) {
      return Left(CacheFailure('Error al crear tienda: $e'));
    }
  }

  @override
  Future<Either<Failure, Store>> updateStore(Store store) async {
    try {
      if (store.name.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre es requerido'));
      }

      if (store.paymentQrUrl == null || store.paymentQrUrl!.trim().isEmpty) {
        return const Left(ValidationFailure('La URL del QR es obligatoria'));
      }

      if (store.paymentQrDescription == null ||
          store.paymentQrDescription!.trim().isEmpty) {
        return const Left(ValidationFailure('La descripción del QR es obligatoria'));
      }

      final updatedStore = store.copyWith(updatedAt: DateTime.now());

      final localModel = StoreLocalModel.fromEntity(updatedStore);
      localModel.markForSync();
      await storeLocalDataSource.saveStore(localModel);

      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.store,
        entityId: store.id,
        operation: SyncOperation.update,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(updatedStore);
    } catch (e) {
      return Left(CacheFailure('Error al actualizar tienda: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStore(String id) async {
    try {
      await storeLocalDataSource.deleteStore(id);

      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.store,
        entityId: id,
        operation: SyncOperation.delete,
        data: {'id': id},
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al eliminar tienda: $e'));
    }
  }

  @override
  Stream<List<Store>> watchAllStores() {
    return storeLocalDataSource.watchAllStores().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, List<Store>>> searchStores(String query) async {
    try {
      final localStores = await storeLocalDataSource.searchStores(query);
      final stores = localStores.map((m) => m.toEntity()).toList();
      return Right(stores);
    } catch (e) {
      return Left(CacheFailure('Error al buscar tiendas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncStoresFromRemote() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No hay conexión'));
      }

      AppLogger.debug('🔄 Sincronizando tiendas desde servidor...');
      final remoteStores = await storeRemoteDataSource.getAllStores();
      AppLogger.debug('📦 Obtenidas ${remoteStores.length} tiendas del servidor');

      // Obtener tiendas locales actuales
      final localStores = await storeLocalDataSource.getAllStores();
      AppLogger.debug('💾 Tiendas locales actuales: ${localStores.length}');

      // Crear mapa de tiendas remotas por UUID
      final remoteStoresMap = <String, dynamic>{};
      for (final remote in remoteStores) {
        remoteStoresMap[remote.id] = remote;
      }

      // Crear lista de tiendas a actualizar/crear
      final storesToSave = <StoreLocalModel>[];

      // 1. Actualizar tiendas existentes y agregar nuevas
      for (final remote in remoteStores) {
        final localModel = StoreLocalModel.fromRemote(
          id: remote.id,
          name: remote.name,
          address: remote.address,
          phone: remote.phone,
          managerId: remote.managerId,
          isActive: remote.isActive,
        paymentQrUrl: remote.paymentQrUrl,
        paymentQrDescription: remote.paymentQrDescription,
          createdAt: remote.createdAt,
          updatedAt: remote.updatedAt,
        );
        
        // Marcar como sincronizado
        localModel.markAsSynced();
        storesToSave.add(localModel);
      }

      // 2. Identificar tiendas locales que ya no existen en el servidor
      // (solo si no están pendientes de sincronización)
      final pendingStores = await storeLocalDataSource.getPendingSync();
      final pendingUuids = pendingStores.map((s) => s.uuid).toSet();

      for (final local in localStores) {
        if (!remoteStoresMap.containsKey(local.uuid) && 
            !pendingUuids.contains(local.uuid)) {
          // Esta tienda ya no existe en el servidor y no está pendiente de sync
          // La eliminamos localmente (soft delete)
          AppLogger.debug('🗑️ Eliminando tienda local que ya no existe en servidor: ${local.name}');
          await storeLocalDataSource.deleteStore(local.uuid);
        }
      }

      // 3. Guardar todas las tiendas actualizadas
      if (storesToSave.isNotEmpty) {
        await storeLocalDataSource.saveStores(storesToSave);
        AppLogger.info('✅ Sincronizadas ${storesToSave.length} tiendas');
      }

      return const Right(null);
    } catch (e) {
      AppLogger.error('❌ Error al sincronizar tiendas: $e');
      return Left(ServerFailure('Error al sincronizar tiendas: $e'));
    }
  }

  // ========== WAREHOUSES ==========

  @override
  Future<Either<Failure, List<Warehouse>>> getAllWarehouses() async {
    try {
      final localWarehouses = await warehouseLocalDataSource.getAllWarehouses();
      final warehouses = localWarehouses.map((m) => m.toEntity()).toList();

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(warehouses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener almacenes: $e'));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> getWarehouseById(String id) async {
    try {
      final localWarehouse = await warehouseLocalDataSource.getWarehouseByUuid(id);

      if (localWarehouse != null) {
        return Right(localWarehouse.toEntity());
      }

      AppLogger.debug('📡 Almacén $id no encontrado en cache, intentando remoto');

      if (await networkInfo.isConnected) {
        try {
          final remoteWarehouse = await warehouseRemoteDataSource.getWarehouseById(id);
          final localModel = WarehouseLocalModel.fromRemote(
            id: remoteWarehouse.id,
            name: remoteWarehouse.name,
            address: remoteWarehouse.address,
            phone: remoteWarehouse.phone,
            managerId: remoteWarehouse.managerId,
            isActive: remoteWarehouse.isActive,
            paymentQrUrl: remoteWarehouse.paymentQrUrl,
            paymentQrDescription: remoteWarehouse.paymentQrDescription,
            createdAt: remoteWarehouse.createdAt,
            updatedAt: remoteWarehouse.updatedAt,
          )..markAsSynced();

          await warehouseLocalDataSource.saveWarehouse(localModel);
          return Right(localModel.toEntity());
        } catch (e) {
          final message = _mapRemoteError(e, entityLabel: 'almacén');
          return Left(ServerFailure(message));
        }
      }

      return const Left(CacheFailure('Almacén no encontrado'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener almacén: $e'));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> createWarehouse({
    required String name,
    required String address,
    String? phone,
    String? managerId,
    String? paymentQrUrl,
    String? paymentQrDescription,
  }) async {
    try {
      if (name.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre es requerido'));
      }

      if (address.trim().isEmpty) {
        return const Left(ValidationFailure('La dirección es requerida'));
      }

      if (paymentQrUrl == null || paymentQrUrl.trim().isEmpty) {
        return const Left(ValidationFailure('La URL del QR es obligatoria'));
      }

      if (paymentQrDescription == null || paymentQrDescription.trim().isEmpty) {
        return const Left(ValidationFailure('La descripción del QR es obligatoria'));
      }

      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final warehouse = Warehouse(
        id: uuid,
        name: name.trim(),
        address: address.trim(),
        phone: phone?.trim(),
        managerId: managerId,
        isActive: true,
        paymentQrUrl: paymentQrUrl.trim(),
        paymentQrDescription: paymentQrDescription.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final localModel = WarehouseLocalModel.fromEntity(warehouse);
      localModel.markForSync();
      await warehouseLocalDataSource.saveWarehouse(localModel);

      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.warehouse,
        entityId: warehouse.id,
        operation: SyncOperation.create,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(warehouse);
    } catch (e) {
      return Left(CacheFailure('Error al crear almacén: $e'));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> updateWarehouse(Warehouse warehouse) async {
    try {
      if (warehouse.name.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre es requerido'));
      }

       if (warehouse.paymentQrUrl == null || warehouse.paymentQrUrl!.trim().isEmpty) {
        return const Left(ValidationFailure('La URL del QR es obligatoria'));
      }

      if (warehouse.paymentQrDescription == null ||
          warehouse.paymentQrDescription!.trim().isEmpty) {
        return const Left(ValidationFailure('La descripción del QR es obligatoria'));
      }

      final updatedWarehouse = warehouse.copyWith(updatedAt: DateTime.now());

      final localModel = WarehouseLocalModel.fromEntity(updatedWarehouse);
      localModel.markForSync();
      await warehouseLocalDataSource.saveWarehouse(localModel);

      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.warehouse,
        entityId: warehouse.id,
        operation: SyncOperation.update,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(updatedWarehouse);
    } catch (e) {
      return Left(CacheFailure('Error al actualizar almacén: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWarehouse(String id) async {
    try {
      await warehouseLocalDataSource.deleteWarehouse(id);

      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.warehouse,
        entityId: id,
        operation: SyncOperation.delete,
        data: {'id': id},
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al eliminar almacén: $e'));
    }
  }

  @override
  Stream<List<Warehouse>> watchAllWarehouses() {
    return warehouseLocalDataSource.watchAllWarehouses().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, List<Warehouse>>> searchWarehouses(String query) async {
    try {
      final localWarehouses = await warehouseLocalDataSource.searchWarehouses(query);
      final warehouses = localWarehouses.map((m) => m.toEntity()).toList();
      return Right(warehouses);
    } catch (e) {
      return Left(CacheFailure('Error al buscar almacenes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncWarehousesFromRemote() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No hay conexión'));
      }

      AppLogger.debug('🔄 Sincronizando almacenes desde servidor...');
      final remoteWarehouses = await warehouseRemoteDataSource.getAllWarehouses();
      AppLogger.debug('📦 Obtenidos ${remoteWarehouses.length} almacenes del servidor');

      // Obtener almacenes locales actuales
      final localWarehouses = await warehouseLocalDataSource.getAllWarehouses();
      AppLogger.debug('💾 Almacenes locales actuales: ${localWarehouses.length}');

      // Crear mapa de almacenes remotos por UUID
      final remoteWarehousesMap = <String, dynamic>{};
      for (final remote in remoteWarehouses) {
        remoteWarehousesMap[remote.id] = remote;
      }

      // Crear lista de almacenes a actualizar/crear
      final warehousesToSave = <WarehouseLocalModel>[];

      // 1. Actualizar almacenes existentes y agregar nuevos
      for (final remote in remoteWarehouses) {
        final localModel = WarehouseLocalModel.fromRemote(
          id: remote.id,
          name: remote.name,
          address: remote.address,
          phone: remote.phone,
          managerId: remote.managerId,
          isActive: remote.isActive,
        paymentQrUrl: remote.paymentQrUrl,
        paymentQrDescription: remote.paymentQrDescription,
          createdAt: remote.createdAt,
          updatedAt: remote.updatedAt,
        );
        
        // Marcar como sincronizado
        localModel.markAsSynced();
        warehousesToSave.add(localModel);
      }

      // 2. Identificar almacenes locales que ya no existen en el servidor
      // (solo si no están pendientes de sincronización)
      final pendingWarehouses = await warehouseLocalDataSource.getPendingSync();
      final pendingUuids = pendingWarehouses.map((w) => w.uuid).toSet();

      for (final local in localWarehouses) {
        if (!remoteWarehousesMap.containsKey(local.uuid) && 
            !pendingUuids.contains(local.uuid)) {
          // Este almacén ya no existe en el servidor y no está pendiente de sync
          // Lo eliminamos localmente (soft delete)
          AppLogger.debug('🗑️ Eliminando almacén local que ya no existe en servidor: ${local.name}');
          await warehouseLocalDataSource.deleteWarehouse(local.uuid);
        }
      }

      // 3. Guardar todos los almacenes actualizados
      if (warehousesToSave.isNotEmpty) {
        await warehouseLocalDataSource.saveWarehouses(warehousesToSave);
        AppLogger.info('✅ Sincronizados ${warehousesToSave.length} almacenes');
      }

      return const Right(null);
    } catch (e) {
      AppLogger.error('❌ Error al sincronizar almacenes: $e');
      return Left(ServerFailure('Error al sincronizar almacenes: $e'));
    }
  }

  void _syncInBackground() {
    syncRepository.syncAll();
  }

  String _mapRemoteError(
    Object error, {
    required String entityLabel,
  }) {
    final text = error.toString();
    if (text.contains('PGRST116') || text.contains('rows, hint: null')) {
      final name = entityLabel[0].toUpperCase() + entityLabel.substring(1);
      return '$name no encontrada en Supabase. Verifica que la ubicación exista y se haya sincronizado.';
    }
    return 'No se pudo obtener $entityLabel remota: $error';
  }
}
