import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/store_local_model.dart';

/// Local datasource for stores (Isar)
abstract class StoreLocalDataSource {
  Future<List<StoreLocalModel>> getAllStores();
  Future<StoreLocalModel?> getStoreByUuid(String uuid);
  Future<StoreLocalModel> saveStore(StoreLocalModel store);
  Future<void> saveStores(List<StoreLocalModel> stores);
  Future<void> deleteStore(String uuid);
  Future<List<StoreLocalModel>> getPendingSync();
  Future<void> markForSync(String uuid);
  Future<void> markAsSynced(String uuid);
  Stream<List<StoreLocalModel>> watchAllStores();
  Future<List<StoreLocalModel>> searchStores(String query);
}

class StoreLocalDataSourceImpl implements StoreLocalDataSource {
  final IsarDatabase isarDatabase;

  StoreLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<List<StoreLocalModel>> getAllStores() async {
    final isar = await isarDatabase.database;
    return await isar.storeLocalModels
        .where()
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  @override
  Future<StoreLocalModel?> getStoreByUuid(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.storeLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<StoreLocalModel> saveStore(StoreLocalModel store) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final existing = await isar.storeLocalModels
          .filter()
          .uuidEqualTo(store.uuid)
          .findFirst();

      if (existing != null) {
        store.id = existing.id;
      }

      await isar.storeLocalModels.put(store);
    });

    return store;
  }

  @override
  Future<void> saveStores(List<StoreLocalModel> stores) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      for (final store in stores) {
        final existing = await isar.storeLocalModels
            .filter()
            .uuidEqualTo(store.uuid)
            .findFirst();

        if (existing != null) {
          store.id = existing.id;
        }
      }

      await isar.storeLocalModels.putAll(stores);
    });
  }

  @override
  Future<void> deleteStore(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final store = await isar.storeLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (store != null) {
        await isar.storeLocalModels.delete(store.id);
      }
    });
  }

  @override
  Future<List<StoreLocalModel>> getPendingSync() async {
    final isar = await isarDatabase.database;
    return await isar.storeLocalModels
        .filter()
        .pendingSyncEqualTo(true)
        .findAll();
  }

  @override
  Future<void> markForSync(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final store = await isar.storeLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (store != null) {
        store.markForSync();
        await isar.storeLocalModels.put(store);
      }
    });
  }

  @override
  Future<void> markAsSynced(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final store = await isar.storeLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (store != null) {
        store.markAsSynced();
        await isar.storeLocalModels.put(store);
      }
    });
  }

  @override
  Stream<List<StoreLocalModel>> watchAllStores() async* {
    final isar = await isarDatabase.database;
    yield* isar.storeLocalModels
        .where()
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<StoreLocalModel>> searchStores(String query) async {
    final isar = await isarDatabase.database;
    
    // Obtener todas las tiendas activas
    final allStores = await isar.storeLocalModels
        .where()
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
    
    // Filtrar en memoria por nombre o dirección
    final queryLower = query.toLowerCase().trim();
    
    if (queryLower.isEmpty) {
      return allStores;
    }
    
    final filteredStores = allStores.where((store) {
      // Buscar en nombre
      if (store.name.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en dirección
      if (store.address.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en teléfono
      if (store.phone?.toLowerCase().contains(queryLower) == true) {
        return true;
      }
      
      return false;
    }).toList();
    
    return filteredStores;
  }
}
