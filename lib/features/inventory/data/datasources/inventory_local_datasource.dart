import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/inventory_local_model.dart';

/// DataSource local para Inventory usando Isar
///
/// OWASP A04: Arquitectura Offline-First
abstract class InventoryLocalDataSource {
  Stream<List<InventoryLocalModel>> watchAllInventory();
  Stream<List<InventoryLocalModel>> watchInventoryByLocation(
    String locationId,
    String locationType,
  );
  Stream<List<InventoryLocalModel>> watchLowStockInventory();
  Future<InventoryLocalModel?> getInventoryItem(String uuid);
  Future<List<InventoryLocalModel>> getInventoryByVariant(
    String productVariantId,
  );
  Future<List<InventoryLocalModel>> getInventoryByLocationType(
    String locationType,
  );
  Future<InventoryLocalModel> saveInventoryItem(InventoryLocalModel item);
  Future<void> deleteInventoryItem(String uuid);
  Future<List<InventoryLocalModel>> getAllInventoryList();
  Future<List<InventoryLocalModel>> searchInventory(String query);
  Future<List<InventoryLocalModel>> getUnsyncedInventory();
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final IsarDatabase isarDatabase;

  InventoryLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<InventoryLocalModel>> watchAllInventory() async* {
    final isar = await isarDatabase.database;
    // Por defecto Isar ordena por ID (orden de creación)
    yield* isar.inventoryLocalModels
        .where()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<InventoryLocalModel>> watchInventoryByLocation(
    String locationId,
    String locationType,
  ) async* {
    final isar = await isarDatabase.database;
    // Por defecto Isar ordena por ID (orden de creación)
    yield* isar.inventoryLocalModels
        .filter()
        .locationIdEqualTo(locationId)
        .and()
        .locationTypeEqualTo(locationType)
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<InventoryLocalModel>> watchLowStockInventory() async* {
    final isar = await isarDatabase.database;
    
    // Obtener todos los items y filtrar en memoria (Isar no soporta quantity <= minStock directo)
    await for (final allItems in isar.inventoryLocalModels.where().watch(fireImmediately: true)) {
      final lowStockItems = allItems.where((item) => item.quantity <= item.minStock).toList();
      yield lowStockItems;
    }
  }

  @override
  Future<InventoryLocalModel?> getInventoryItem(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.inventoryLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<InventoryLocalModel>> getInventoryByVariant(
    String productVariantId,
  ) async {
    final isar = await isarDatabase.database;
    return await isar.inventoryLocalModels
        .filter()
        .productVariantIdEqualTo(productVariantId)
        .findAll();
  }

  @override
  Future<List<InventoryLocalModel>> getInventoryByLocationType(
    String locationType,
  ) async {
    final isar = await isarDatabase.database;
    // Por defecto Isar ordena por ID (orden de creación)
    return await isar.inventoryLocalModels
        .filter()
        .locationTypeEqualTo(locationType)
        .findAll();
  }

  @override
  Future<InventoryLocalModel> saveInventoryItem(
    InventoryLocalModel item,
  ) async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      // Buscar si ya existe por UUID
      final existing = await isar.inventoryLocalModels
          .filter()
          .uuidEqualTo(item.uuid)
          .findFirst();

      if (existing != null) {
        // Actualizar: preservar el ID de Isar para la actualización
        item.id = existing.id;
      }
      // Si no existe, Isar asignará un nuevo ID automáticamente

      await isar.inventoryLocalModels.put(item);
    });

    // Retornar el item guardado con su ID asignado
    return item;
  }

  @override
  Future<void> deleteInventoryItem(String uuid) async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      final item = await isar.inventoryLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (item != null) {
        await isar.inventoryLocalModels.delete(item.id);
      }
    });
  }

  @override
  Future<List<InventoryLocalModel>> getAllInventoryList() async {
    final isar = await isarDatabase.database;
    return await isar.inventoryLocalModels.where().findAll();
  }

  @override
  Future<List<InventoryLocalModel>> searchInventory(String query) async {
    final isar = await isarDatabase.database;
    
    // Obtener todos los items de inventario
    final allItems = await isar.inventoryLocalModels.where().findAll();

    AppLogger.debug('🔍 InventoryLocalDataSource: Buscando "$query" en ${allItems.length} items');
    
    // Filtrar en memoria por nombre de producto, variante o ubicación
    final queryLower = query.toLowerCase().trim();
    
    if (queryLower.isEmpty) {
      return allItems;
    }
    
    final filteredItems = allItems.where((item) {
      // Debug: Mostrar información del item
      AppLogger.debug('🔍 Item: productName="${item.productName}", variantName="${item.variantName}", locationName="${item.locationName}"');
      
      // ========== BÚSQUEDA EN PROPIEDADES DE TEXTO ==========
      
      // Buscar en nombre del producto
      if (item.productName != null && item.productName!.toLowerCase().contains(queryLower)) {
        AppLogger.debug('✅ Match en productName: "${item.productName}"');
        return true;
      }

      // Buscar en nombre de la variante
      if (item.variantName != null && item.variantName!.toLowerCase().contains(queryLower)) {
        AppLogger.debug('✅ Match en variantName: "${item.variantName}"');
        return true;
      }

      // Buscar en nombre de la ubicación
      if (item.locationName != null && item.locationName!.toLowerCase().contains(queryLower)) {
        AppLogger.debug('✅ Match en locationName: "${item.locationName}"');
        return true;
      }
      
      // Buscar en tipo de ubicación
      if (item.locationType.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en usuario que actualizó
      if (item.updatedBy.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // ========== BÚSQUEDA EN PROPIEDADES NUMÉRICAS ==========
      
      // Buscar en cantidad (stock actual)
      if (item.quantity.toString().contains(queryLower)) {
        return true;
      }
      
      // Buscar en stock mínimo
      if (item.minStock.toString().contains(queryLower)) {
        return true;
      }
      
      // Buscar en stock máximo
      if (item.maxStock.toString().contains(queryLower)) {
        return true;
      }
      
      // ========== BÚSQUEDA EN IDs ==========
      
      // Buscar en UUID del item
      if (item.uuid.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en ID de la variante del producto
      if (item.productVariantId.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Buscar en ID de la ubicación
      if (item.locationId.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // ========== BÚSQUEDA EN FECHAS ==========
      
      // Buscar en fecha de última actualización (formato: YYYY-MM-DD)
      final dateStr = item.lastUpdated.toIso8601String().substring(0, 10);
      if (dateStr.contains(queryLower)) {
        return true;
      }
      
      // Buscar en fecha completa (formato: YYYY-MM-DD HH:MM:SS)
      final fullDateStr = item.lastUpdated.toString();
      if (fullDateStr.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // ========== BÚSQUEDA EN ESTADOS DE STOCK ==========
      
      // Buscar por estado de stock bajo
      if (queryLower.contains('bajo') && item.quantity <= item.minStock) {
        return true;
      }
      
      // Buscar por estado de stock óptimo
      if (queryLower.contains('óptimo') && item.quantity > item.minStock && item.quantity < item.maxStock) {
        return true;
      }
      
      // Buscar por estado de sobrestock
      if (queryLower.contains('sobre') && item.quantity >= item.maxStock) {
        return true;
      }
      
      // Buscar por stock cero
      if (queryLower.contains('cero') && item.quantity == 0) {
        return true;
      }
      
      return false;
    }).toList();

    AppLogger.debug('🔍 InventoryLocalDataSource: Encontrados ${filteredItems.length} resultados para "$query"');
    return filteredItems;
  }

  @override
  Future<List<InventoryLocalModel>> getUnsyncedInventory() async {
    final isar = await isarDatabase.database;
    return await isar.inventoryLocalModels
        .filter()
        .needsSyncEqualTo(true)
        .findAll();
  }
}
