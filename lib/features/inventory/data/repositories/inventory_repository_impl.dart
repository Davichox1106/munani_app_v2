import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../sync/domain/entities/sync_queue_item.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../../../core/database/isar_database.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../models/inventory_local_model.dart';
import '../models/inventory_remote_model.dart';
import '../../../products/data/models/product_local_model.dart';
import '../../../products/data/models/product_variant_local_model.dart';
import '../../../locations/data/models/store_local_model.dart';
import '../../../locations/data/models/warehouse_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de Inventory con patrón Offline-First
///
/// OWASP A04: Arquitectura Offline-First
/// 1. Todas las operaciones se guardan primero en Isar (local)
/// 2. Se agregan a cola de sincronización
/// 3. Se sincronizan con Supabase cuando hay conexión
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final InventoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final IsarDatabase isarDatabase;
  final SyncRepository syncRepository;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.isarDatabase,
    required this.syncRepository,
  });

  @override
  Stream<Either<Failure, List<InventoryItem>>> getAllInventory() async* {
    try {
      await for (final items in localDataSource.watchAllInventory()) {
        // Enriquecer con nombres de productos y ubicaciones
        final enrichedItems = await _enrichInventoryItems(items);
        yield Right(enrichedItems.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<InventoryItem>>> getInventoryByLocation({
    required String locationId,
    required String locationType,
  }) async* {
    try {
      await for (final items in localDataSource.watchInventoryByLocation(
        locationId,
        locationType,
      )) {
        // Enriquecer con nombres de productos y ubicaciones
        final enrichedItems = await _enrichInventoryItems(items);
        yield Right(enrichedItems.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<InventoryItem>>> getLowStockInventory() async* {
    try {
      await for (final items in localDataSource.watchLowStockInventory()) {
        // Enriquecer con nombres de productos y ubicaciones
        final enrichedItems = await _enrichInventoryItems(items);
        yield Right(enrichedItems.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> getInventoryItem(String id) async {
    try {
      final item = await localDataSource.getInventoryItem(id);
      if (item == null) {
        return Left(CacheFailure('Inventory item not found'));
      }
      return Right(item.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryByVariant(
    String productVariantId,
  ) async {
    try {
      final items = await localDataSource.getInventoryByVariant(
        productVariantId,
      );
      return Right(items.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryByLocationType(
    String locationType,
  ) async {
    try {
      final items = await localDataSource.getInventoryByLocationType(
        locationType,
      );
      return Right(items.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> createInventoryItem({
    required String productVariantId,
    required String locationId,
    required String locationType,
    required int quantity,
    required int minStock,
    required int maxStock,
    required String updatedBy,
    String? productName,
    String? variantName,
    String? locationName,
  }) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      double? unitCost;
      double? lastCost;
      double? totalCost;
      String? resolvedProductName = productName;
      String? resolvedVariantName = variantName;
      List<String> imageUrls = const [];

      try {
        final isar = await isarDatabase.database;
        final variant = await isar.productVariantLocalModels
            .filter()
            .uuidEqualTo(productVariantId)
            .findFirst();

        if (variant != null) {
          unitCost = variant.priceSell;
          lastCost = variant.priceSell;
          totalCost = variant.priceSell * quantity;
          resolvedVariantName ??= variant.variantName;

          final product = await isar.productLocalModels
              .filter()
              .uuidEqualTo(variant.productId)
              .findFirst();
          resolvedProductName ??= product?.name;
          imageUrls = product?.imageUrls.toList() ?? const [];
        }
      } catch (e) {
        AppLogger.warning('⚠️ No se pudo obtener datos de variante/producto $productVariantId: $e');
      }

      // 1. Crear modelo local
      final localModel = InventoryLocalModel()
        ..uuid = uuid
        ..productVariantId = productVariantId
        ..locationId = locationId
        ..locationType = locationType
        ..quantity = quantity
        ..minStock = minStock
        ..maxStock = maxStock
        ..lastUpdated = now
        ..updatedBy = updatedBy
        ..productName = resolvedProductName
        ..variantName = resolvedVariantName
        ..locationName = locationName
        ..unitCost = unitCost
        ..lastCost = lastCost
        ..totalCost = totalCost
        ..imageUrls = imageUrls
        ..costUpdatedAt = unitCost != null ? now : null
        ..needsSync = true;

      // 2. Guardar en Isar (Offline-First)
      final savedModel = await localDataSource.saveInventoryItem(localModel);

      // 3. Agregar a cola de sincronización
      await _addToSyncQueue(
        entityType: SyncEntityType.inventory,
        entityId: uuid,
        operation: SyncOperation.create,
        data: savedModel.toJson(),
      );

      return Right(savedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error creating inventory: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> updateInventoryQuantity({
    required String id,
    required int newQuantity,
    required String updatedBy,
  }) async {
    try {
      // 1. Obtener item actual
      final existingItem = await localDataSource.getInventoryItem(id);
      if (existingItem == null) {
        return Left(CacheFailure('Inventory item not found'));
      }

      // 2. CREAR NUEVO OBJETO copiando el ID de Isar
      final updatedItem = InventoryLocalModel()
        ..id = existingItem.id  // ← IMPORTANTE: Copiar ID de Isar
        ..uuid = existingItem.uuid
        ..productVariantId = existingItem.productVariantId
        ..locationId = existingItem.locationId
        ..locationType = existingItem.locationType
        ..quantity = newQuantity
        ..minStock = existingItem.minStock
        ..maxStock = existingItem.maxStock
        ..lastUpdated = DateTime.now()
        ..updatedBy = updatedBy
        ..productName = existingItem.productName
        ..variantName = existingItem.variantName
        ..locationName = existingItem.locationName
        ..unitCost = existingItem.unitCost
        ..totalCost = (existingItem.unitCost ?? 0) * newQuantity
        ..lastCost = existingItem.lastCost
        ..costUpdatedAt = existingItem.costUpdatedAt
        ..imageUrls = List<String>.from(existingItem.imageUrls)
        ..needsSync = true;

      // 3. Guardar en Isar
      final updatedModel = await localDataSource.saveInventoryItem(
        updatedItem,
      );

      // 4. Agregar a cola de sincronización
      await _addToSyncQueue(
        entityType: SyncEntityType.inventory,
        entityId: id,
        operation: SyncOperation.update,
        data: updatedModel.toJson(),
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error updating inventory: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> updateStockLevels({
    required String id,
    required int minStock,
    required int maxStock,
    required String updatedBy,
  }) async {
    try {
      final existingItem = await localDataSource.getInventoryItem(id);
      if (existingItem == null) {
        return Left(CacheFailure('Inventory item not found'));
      }

      // CREAR NUEVO OBJETO copiando el ID de Isar
      final updatedItem = InventoryLocalModel()
        ..id = existingItem.id  // ← IMPORTANTE: Copiar ID de Isar
        ..uuid = existingItem.uuid
        ..productVariantId = existingItem.productVariantId
        ..locationId = existingItem.locationId
        ..locationType = existingItem.locationType
        ..quantity = existingItem.quantity
        ..minStock = minStock
        ..maxStock = maxStock
        ..lastUpdated = DateTime.now()
        ..updatedBy = updatedBy
        ..productName = existingItem.productName
        ..variantName = existingItem.variantName
        ..locationName = existingItem.locationName
        // Preservar costos existentes y recalcular totalCost por consistencia
        ..unitCost = existingItem.unitCost
        ..lastCost = existingItem.lastCost
        ..totalCost = (existingItem.unitCost ?? 0) * existingItem.quantity
        ..costUpdatedAt = existingItem.costUpdatedAt
        ..imageUrls = List<String>.from(existingItem.imageUrls);

      final updatedModel = await localDataSource.saveInventoryItem(
        updatedItem,
      );

      await _addToSyncQueue(
        entityType: SyncEntityType.inventory,
        entityId: id,
        operation: SyncOperation.update,
        data: updatedModel.toJson(),
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error updating stock levels: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInventoryItem(String id) async {
    try {
      await localDataSource.deleteInventoryItem(id);

      await _addToSyncQueue(
        entityType: SyncEntityType.inventory,
        entityId: id,
        operation: SyncOperation.delete,
        data: {'id': id},
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error deleting inventory: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryItem>> adjustInventory({
    required String id,
    required int delta,
    required String updatedBy,
  }) async {
    try {
      final existingItem = await localDataSource.getInventoryItem(id);
      if (existingItem == null) {
        return Left(CacheFailure('Inventory item not found'));
      }

      // Calcular nueva cantidad (no permitir negativa)
      final newQuantity = (existingItem.quantity + delta).clamp(0, double.infinity).toInt();

      // CREAR NUEVO OBJETO copiando el ID de Isar
      final updatedItem = InventoryLocalModel()
        ..id = existingItem.id  // ← IMPORTANTE: Copiar ID de Isar
        ..uuid = existingItem.uuid
        ..productVariantId = existingItem.productVariantId
        ..locationId = existingItem.locationId
        ..locationType = existingItem.locationType
        ..quantity = newQuantity
        ..minStock = existingItem.minStock
        ..maxStock = existingItem.maxStock
        ..lastUpdated = DateTime.now()
        ..updatedBy = updatedBy
        ..productName = existingItem.productName
        ..variantName = existingItem.variantName
        ..locationName = existingItem.locationName
        // Preservar costos y recalcular total
        ..unitCost = existingItem.unitCost
        ..lastCost = existingItem.lastCost
        ..totalCost = (existingItem.unitCost ?? 0) * newQuantity
        ..costUpdatedAt = existingItem.costUpdatedAt
        ..imageUrls = List<String>.from(existingItem.imageUrls);

      final updatedModel = await localDataSource.saveInventoryItem(
        updatedItem,
      );

      await _addToSyncQueue(
        entityType: SyncEntityType.inventory,
        entityId: id,
        operation: SyncOperation.update,
        data: updatedModel.toJson(),
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error adjusting inventory: $e'));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItem>>> searchInventory(String query) async {
    try {
      // 1. Obtener TODOS los items de inventario
      final allItems = await localDataSource.getAllInventoryList();
      AppLogger.debug('🔍 searchInventory: Obtenidos ${allItems.length} items de la base de datos');
      
      // 2. Enriquecer TODOS los items con nombres de productos y ubicaciones
      final enrichedItems = await _enrichInventoryItems(allItems);
      AppLogger.debug('🔍 searchInventory: Enriquecidos ${enrichedItems.length} items');
      
      // 3. Filtrar en memoria por la query
      final queryLower = query.toLowerCase().trim();
      if (queryLower.isEmpty) {
        return Right(enrichedItems.map((model) => model.toEntity()).toList());
      }
      
      final filteredItems = enrichedItems.where((item) {
        // Buscar en nombre del producto
        if (item.productName != null && item.productName!.toLowerCase().contains(queryLower)) {
          return true;
        }
        
        // Buscar en nombre de la variante
        if (item.variantName != null && item.variantName!.toLowerCase().contains(queryLower)) {
          return true;
        }
        
        // Buscar en nombre de la ubicación
        if (item.locationName != null && item.locationName!.toLowerCase().contains(queryLower)) {
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
        
        // Buscar en cantidad
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
        
        // Buscar en fecha de última actualización
        final dateStr = item.lastUpdated.toIso8601String().substring(0, 10);
        if (dateStr.contains(queryLower)) {
          return true;
        }
        
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
      
      AppLogger.debug('🔍 searchInventory: Filtrados ${filteredItems.length} resultados para "$query"');
      return Right(filteredItems.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Error searching inventory: $e'));
    }
  }

  // ============================================================================
  // HELPERS - Enriquecimiento de datos
  // ============================================================================

  /// Enriquece los items de inventario con nombres de productos y ubicaciones
  Future<List<InventoryLocalModel>> _enrichInventoryItems(
    List<InventoryLocalModel> items,
  ) async {
    try {
      final isar = await isarDatabase.database;
      final enrichedItems = <InventoryLocalModel>[];

      AppLogger.debug('🔄 _enrichInventoryItems: Procesando ${items.length} items');

      for (final item in items) {
        // Crear copia del item (siempre)
        final enrichedItem = InventoryLocalModel()
          ..id = item.id
          ..uuid = item.uuid
          ..productVariantId = item.productVariantId
          ..locationId = item.locationId
          ..locationType = item.locationType
          ..quantity = item.quantity
          ..minStock = item.minStock
          ..maxStock = item.maxStock
          ..lastUpdated = item.lastUpdated
          ..updatedBy = item.updatedBy
          ..productName = item.productName
          ..variantName = item.variantName
          ..locationName = item.locationName
          // Costos: preservar valores ya almacenados en Isar
          ..unitCost = item.unitCost
          ..totalCost = item.totalCost
          ..lastCost = item.lastCost
          ..costUpdatedAt = item.costUpdatedAt
          ..imageUrls = List<String>.from(item.imageUrls);

        // Solo enriquecer si los nombres no están ya cargados
        if (item.productName == null || item.locationName == null) {
          AppLogger.debug('🔄 Enriqueciendo item: productName="${item.productName}", locationName="${item.locationName}"');

          // Cargar nombre del producto si no está disponible
          if (enrichedItem.productName == null || enrichedItem.variantName == null) {
            try {
              // Buscar la variante del producto
              final variant = await isar.productVariantLocalModels
                  .getByUuid(item.productVariantId);
              
              if (variant != null) {
                enrichedItem.variantName = variant.variantName;
                
                // Buscar el producto padre
                final product = await isar.productLocalModels
                    .getByUuid(variant.productId);
                
                if (product != null) {
                  enrichedItem.productName = product.name;
                  if (enrichedItem.imageUrls.isEmpty) {
                    enrichedItem.imageUrls = product.imageUrls.toList();
                  }
                  AppLogger.info('✅ Cargado productName: "${product.name}"');
                }
              }
            } catch (e) {
              AppLogger.error('Error cargando datos del producto: $e');
            }
          }

          // Cargar nombre de la ubicación si no está disponible
          if (enrichedItem.locationName == null) {
            try {
              if (item.locationType == 'store') {
                final store = await isar.storeLocalModels
                    .getByUuid(item.locationId);
                if (store != null) {
                  enrichedItem.locationName = store.name;
                  AppLogger.info('✅ Cargado locationName (store): "${store.name}"');
                }
              } else if (item.locationType == 'warehouse') {
                final warehouse = await isar.warehouseLocalModels
                    .getByUuid(item.locationId);
                if (warehouse != null) {
                  enrichedItem.locationName = warehouse.name;
                  AppLogger.info('✅ Cargado locationName (warehouse): "${warehouse.name}"');
                }
              }
            } catch (e) {
              AppLogger.error('Error cargando datos de la ubicación: $e');
            }
          }

          AppLogger.info('✅ Item enriquecido: productName="${enrichedItem.productName}", locationName="${enrichedItem.locationName}"');
        } else {
          AppLogger.info('✅ Item ya enriquecido: productName="${enrichedItem.productName}", locationName="${enrichedItem.locationName}"');
        }

        // Siempre agregar el item (enriquecido o no)
        enrichedItems.add(enrichedItem);
      }

      AppLogger.debug('🔄 _enrichInventoryItems: Procesados ${enrichedItems.length} items');
      return enrichedItems;
    } catch (e) {
      AppLogger.error('Error enriqueciendo items de inventario: $e');
      return items; // Retornar items originales si hay error
    }
  }

  // ============================================================================
  // HELPERS - Sincronización
  // ============================================================================

  Future<void> _addToSyncQueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        attempts: 0,
        createdAt: DateTime.now(),
        priority: SyncPriority.normal,
      );

      // Usar syncRepository.addToQueue() para notificar al stream
      await syncRepository.addToQueue(syncItem);

      AppLogger.info('📋 Item agregado a cola: ${entityType.value} - ${operation.value}');
    } catch (e) {
      AppLogger.error('❌ Error agregando a cola de sincronización: $e');
    }
  }

  @override
  Future<Either<Failure, void>> syncFromRemote() async {
    try {
      AppLogger.info('📋 Sincronizando inventarios bidireccional...');

      // 1. SUBIR cambios locales no sincronizados
      final unsyncedItems = await localDataSource.getUnsyncedInventory();
      AppLogger.info('📤 Subiendo ${unsyncedItems.length} inventarios no sincronizados...');

      for (final localItem in unsyncedItems) {
        try {
          // Intentar actualizar en Supabase
          try {
            final remoteModel = InventoryRemoteModel.fromJson(localItem.toJson());
            await remoteDataSource.updateInventoryItem(
              localItem.uuid,
              remoteModel.toJson(),
            );
            AppLogger.info('✅ Inventario ${localItem.uuid} actualizado en Supabase');
          } catch (e) {
            // Si falla el update, intentar crear
            final errorText = e.toString();
            if (errorText.contains('no encontrado') ||
                errorText.contains('not found') ||
                errorText.contains('does not exist')) {
              final remoteModel = InventoryRemoteModel.fromJson(localItem.toJson());
              await remoteDataSource.createInventoryItem(remoteModel.toJson());
              AppLogger.info('✅ Inventario ${localItem.uuid} creado en Supabase');
            } else {
              // Re-lanzar otros errores
              rethrow;
            }
          }

          // Marcar como sincronizado
          localItem.needsSync = false;
          localItem.lastSyncedAt = DateTime.now();
          await localDataSource.saveInventoryItem(localItem);
        } catch (e) {
          AppLogger.error('❌ Error sincronizando inventario ${localItem.uuid}: $e');
          // Continuar con el siguiente item
        }
      }

      // 2. DESCARGAR desde Supabase
      final remoteInventories = await remoteDataSource.getAllInventory();
      AppLogger.info('📥 Descargados ${remoteInventories.length} inventarios de Supabase');

      // 3. Guardar en Isar (convertir de Remote a Local)
      for (final remoteInventory in remoteInventories) {
        final localModel = InventoryLocalModel.fromRemote(remoteInventory.toJson());
        localModel.needsSync = false;
        localModel.lastSyncedAt = DateTime.now();
        await localDataSource.saveInventoryItem(localModel);
      }

      AppLogger.info('✅ Sincronización bidireccional completada');
      return const Right(null);
    } catch (e) {
      AppLogger.error('❌ Error sincronizando inventarios: $e');
      return Left(ServerFailure('Error sincronizando inventarios: $e'));
    }
  }

}
