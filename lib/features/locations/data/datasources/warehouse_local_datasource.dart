import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/warehouse_local_model.dart';

/// Local datasource for warehouses (Isar)
abstract class WarehouseLocalDataSource {
  Future<List<WarehouseLocalModel>> getAllWarehouses();
  Future<WarehouseLocalModel?> getWarehouseByUuid(String uuid);
  Future<WarehouseLocalModel> saveWarehouse(WarehouseLocalModel warehouse);
  Future<void> saveWarehouses(List<WarehouseLocalModel> warehouses);
  Future<void> deleteWarehouse(String uuid);
  Future<List<WarehouseLocalModel>> getPendingSync();
  Future<void> markForSync(String uuid);
  Future<void> markAsSynced(String uuid);
  Stream<List<WarehouseLocalModel>> watchAllWarehouses();
  Future<List<WarehouseLocalModel>> searchWarehouses(String query);
}

class WarehouseLocalDataSourceImpl implements WarehouseLocalDataSource {
  final IsarDatabase isarDatabase;

  WarehouseLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<List<WarehouseLocalModel>> getAllWarehouses() async {
    final isar = await isarDatabase.database;
    return await isar.warehouseLocalModels
        .where()
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  @override
  Future<WarehouseLocalModel?> getWarehouseByUuid(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.warehouseLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<WarehouseLocalModel> saveWarehouse(WarehouseLocalModel warehouse) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final existing = await isar.warehouseLocalModels
          .filter()
          .uuidEqualTo(warehouse.uuid)
          .findFirst();

      if (existing != null) {
        warehouse.id = existing.id;
      }

      await isar.warehouseLocalModels.put(warehouse);
    });

    return warehouse;
  }

  @override
  Future<void> saveWarehouses(List<WarehouseLocalModel> warehouses) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      for (final warehouse in warehouses) {
        final existing = await isar.warehouseLocalModels
            .filter()
            .uuidEqualTo(warehouse.uuid)
            .findFirst();

        if (existing != null) {
          warehouse.id = existing.id;
        }
      }

      await isar.warehouseLocalModels.putAll(warehouses);
    });
  }

  @override
  Future<void> deleteWarehouse(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final warehouse = await isar.warehouseLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (warehouse != null) {
        await isar.warehouseLocalModels.delete(warehouse.id);
      }
    });
  }

  @override
  Future<List<WarehouseLocalModel>> getPendingSync() async {
    final isar = await isarDatabase.database;
    return await isar.warehouseLocalModels
        .filter()
        .pendingSyncEqualTo(true)
        .findAll();
  }

  @override
  Future<void> markForSync(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final warehouse = await isar.warehouseLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (warehouse != null) {
        warehouse.markForSync();
        await isar.warehouseLocalModels.put(warehouse);
      }
    });
  }

  @override
  Future<void> markAsSynced(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final warehouse = await isar.warehouseLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (warehouse != null) {
        warehouse.markAsSynced();
        await isar.warehouseLocalModels.put(warehouse);
      }
    });
  }

  @override
  Stream<List<WarehouseLocalModel>> watchAllWarehouses() async* {
    final isar = await isarDatabase.database;
    yield* isar.warehouseLocalModels
        .where()
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<WarehouseLocalModel>> searchWarehouses(String query) async {
    final isar = await isarDatabase.database;
    
    // Obtener todos los almacenes activos
    final allWarehouses = await isar.warehouseLocalModels
        .where()
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
    
    // Filtrar en memoria por nombre o dirección
    final queryLower = query.toLowerCase().trim();
    
    if (queryLower.isEmpty) {
      return allWarehouses;
    }
    
    final filteredWarehouses = allWarehouses.where((warehouse) {
      // Buscar en nombre
      if (warehouse.name.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en dirección
      if (warehouse.address.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en teléfono
      if (warehouse.phone?.toLowerCase().contains(queryLower) == true) {
        return true;
      }
      
      return false;
    }).toList();
    
    return filteredWarehouses;
  }
}
