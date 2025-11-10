import 'package:uuid/uuid.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/entities/purchase_with_items.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_local_datasource.dart';
import '../datasources/purchase_remote_datasource.dart';
import '../datasources/supplier_local_datasource.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/purchase_local_model.dart';
import '../models/purchase_remote_model.dart';
import '../models/purchase_item_local_model.dart';
import '../models/purchase_item_remote_model.dart';
import '../models/supplier_remote_model.dart';
import '../../../inventory/data/datasources/inventory_local_datasource.dart';
import '../../../inventory/data/models/inventory_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de Purchases con patrón Offline-First
///
/// OWASP A04: Arquitectura Offline-First
/// 1. Todas las operaciones se guardan primero en Isar (local)
/// 2. Se sincronizan con Supabase cuando hay conexión
class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseLocalDataSource localDataSource;
  final PurchaseRemoteDataSource remoteDataSource;
  final SupplierLocalDataSource supplierLocalDataSource;
  final SupplierRemoteDataSource supplierRemoteDataSource;
  final InventoryLocalDataSource inventoryLocalDataSource;
  final NetworkInfo networkInfo;

  PurchaseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.supplierLocalDataSource,
    required this.supplierRemoteDataSource,
    required this.inventoryLocalDataSource,
    required this.networkInfo,
  });

  /// Método helper para asegurar que el proveedor está sincronizado antes de sincronizar la compra
  Future<bool> _ensureSupplierSynced(String supplierId) async {
    try {
      final supplier = await supplierLocalDataSource.getSupplierById(supplierId);
      if (supplier == null) return false;

      // Si ya está sincronizado, retornar true
      if (supplier.isSynced) return true;

      // Intentar sincronizar el proveedor primero
      try {
        final supplierRemoteModel = SupplierRemoteModel.fromEntity(supplier.toEntity());
        await supplierRemoteDataSource.createSupplier(supplierRemoteModel.toJson());

        // Marcar como sincronizado
        supplier.isSynced = true;
        await supplierLocalDataSource.saveSupplier(supplier);
        AppLogger.info('✅ Proveedor sincronizado: ${supplier.name}');
        return true;
      } catch (e) {
        AppLogger.error('❌ Error sincronizando proveedor ${supplier.name}: $e');
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Error verificando proveedor: $e');
      return false;
    }
  }

  @override
  Stream<List<Purchase>> watchAllPurchases() async* {
    try {
      await for (final models in localDataSource.watchAllPurchases()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching purchases: $e');
    }
  }

  @override
  Stream<List<Purchase>> watchPurchasesByLocation(String locationId) async* {
    try {
      await for (final models in localDataSource.watchPurchasesByLocation(locationId)) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching purchases by location: $e');
    }
  }

  @override
  Stream<List<Purchase>> watchPurchasesByStatus(PurchaseStatus status) async* {
    try {
      await for (final models in localDataSource.watchPurchasesByStatus(status.name)) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching purchases by status: $e');
    }
  }

  @override
  Future<PurchaseWithItems?> getPurchaseWithItems(String id) async {
    try {
      final purchaseModel = await localDataSource.getPurchaseById(id);
      if (purchaseModel == null) return null;

      final itemModels = await localDataSource.getPurchaseItems(id);

      return PurchaseWithItems(
        purchase: purchaseModel.toEntity(),
        items: itemModels.map((model) => model.toEntity()).toList(),
      );
    } catch (e) {
      throw Exception('Error getting purchase with items: $e');
    }
  }

  @override
  Future<List<Purchase>> searchPurchases(String query) async {
    try {
      final models = await localDataSource.searchPurchases(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error searching purchases: $e');
    }
  }

  @override
  Future<Purchase> createPurchase(Purchase purchase) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final newPurchase = purchase.copyWith(
        id: uuid,
        createdAt: now,
        updatedAt: now,
        needsSync: true,
      );

      // Guardar en local primero
      final localModel = PurchaseLocalModel.fromEntity(newPurchase);
      await localDataSource.savePurchase(localModel);

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          // Primero asegurar que el proveedor está sincronizado
          final supplierSynced = await _ensureSupplierSynced(newPurchase.supplierId);

          if (supplierSynced) {
            final remoteModel = PurchaseRemoteModel.fromEntity(newPurchase);
            
            // Verificar si la compra ya existe en Supabase
            bool purchaseExists = false;
            try {
              await remoteDataSource.getPurchaseById(newPurchase.id);
              purchaseExists = true;
            } catch (e) {
              purchaseExists = false;
            }

            if (purchaseExists) {
              AppLogger.debug('📝 Compra ya existe en Supabase, actualizando...');
              await remoteDataSource.updatePurchase(newPurchase.id, remoteModel.toJson());
            } else {
              AppLogger.debug('➕ Creando nueva compra en Supabase...');
              await remoteDataSource.createPurchase(remoteModel.toJson());
            }

            // Marcar como sincronizado
            final syncedPurchase = newPurchase.copyWith(
              needsSync: false,
              lastSyncedAt: DateTime.now(),
            );
            final syncedModel = PurchaseLocalModel.fromEntity(syncedPurchase);
            await localDataSource.savePurchase(syncedModel);

            return syncedPurchase;
          } else {
            AppLogger.warning('⚠️ No se pudo sincronizar la compra porque el proveedor no está sincronizado');
          }
        } catch (e) {
          AppLogger.error('Error syncing purchase: $e');
        }
      }

      return newPurchase;
    } catch (e) {
      throw Exception('Error creating purchase: $e');
    }
  }

  @override
  Future<Purchase> updatePurchase(Purchase purchase) async {
    try {
      final updatedPurchase = purchase.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      // Guardar en local primero
      final localModel = PurchaseLocalModel.fromEntity(updatedPurchase);
      await localDataSource.savePurchase(localModel);

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          // Primero asegurar que el proveedor está sincronizado
          final supplierSynced = await _ensureSupplierSynced(updatedPurchase.supplierId);

          if (supplierSynced) {
            final remoteModel = PurchaseRemoteModel.fromEntity(updatedPurchase);
            await remoteDataSource.updatePurchase(
              purchase.id,
              remoteModel.toJson(),
            );

            // Marcar como sincronizado
            final syncedPurchase = updatedPurchase.copyWith(
              needsSync: false,
              lastSyncedAt: DateTime.now(),
            );
            final syncedModel = PurchaseLocalModel.fromEntity(syncedPurchase);
            await localDataSource.savePurchase(syncedModel);

            return syncedPurchase;
          } else {
            AppLogger.warning('⚠️ No se pudo sincronizar la compra porque el proveedor no está sincronizado');
          }
        } catch (e) {
          AppLogger.error('Error syncing purchase update: $e');
        }
      }

      return updatedPurchase;
    } catch (e) {
      throw Exception('Error updating purchase: $e');
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    try {
      await localDataSource.deletePurchase(id);

      // Intentar sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deletePurchase(id);
        } catch (e) {
          AppLogger.error('Error syncing purchase deletion: $e');
        }
      }
    } catch (e) {
      throw Exception('Error deleting purchase: $e');
    }
  }

  @override
  Future<PurchaseItem> addPurchaseItem(PurchaseItem item) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final newItem = item.copyWith(
        id: uuid,
        createdAt: now,
      );

      // Guardar en local primero
      final localModel = PurchaseItemLocalModel.fromEntity(newItem);
      await localDataSource.savePurchaseItem(localModel);

      // Marcar compra como pendiente de sincronización
      final purchase = await localDataSource.getPurchaseById(item.purchaseId);
      if (purchase != null) {
        purchase.needsSync = true;
        await localDataSource.savePurchase(purchase);
      }

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          final remoteModel = PurchaseItemRemoteModel.fromEntity(newItem);
          await remoteDataSource.createPurchaseItem(remoteModel.toJson());

          // Actualizar compra como sincronizada si aplica
          if (purchase != null) {
            purchase.needsSync = false;
            purchase.lastSyncedAt = DateTime.now();
            await localDataSource.savePurchase(purchase);
          }
        } catch (e) {
          AppLogger.error('Error syncing purchase item: $e');
        }
      }

      return newItem;
    } catch (e) {
      throw Exception('Error adding purchase item: $e');
    }
  }

  @override
  Future<PurchaseItem> updatePurchaseItem(PurchaseItem item) async {
    try {
      // Guardar en local primero
      final localModel = PurchaseItemLocalModel.fromEntity(item);
      await localDataSource.savePurchaseItem(localModel);

      // Marcar compra como pendiente de sincronización
      final purchase = await localDataSource.getPurchaseById(item.purchaseId);
      if (purchase != null) {
        purchase.needsSync = true;
        await localDataSource.savePurchase(purchase);
      }

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          final remoteModel = PurchaseItemRemoteModel.fromEntity(item);
          await remoteDataSource.updatePurchaseItem(
            item.id,
            remoteModel.toJson(),
          );

          if (purchase != null) {
            purchase.needsSync = false;
            purchase.lastSyncedAt = DateTime.now();
            await localDataSource.savePurchase(purchase);
          }
        } catch (e) {
          AppLogger.error('Error syncing purchase item update: $e');
        }
      }

      return item;
    } catch (e) {
      throw Exception('Error updating purchase item: $e');
    }
  }

  @override
  Future<void> deletePurchaseItem(String itemId, String purchaseId) async {
    try {
      await localDataSource.deletePurchaseItem(itemId);

      // Marcar compra como pendiente de sincronización
      final purchase = await localDataSource.getPurchaseById(purchaseId);
      if (purchase != null) {
        purchase.needsSync = true;
        await localDataSource.savePurchase(purchase);
      }

      // Intentar sincronizar inmediatamente si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deletePurchaseItem(itemId);

          if (purchase != null) {
            purchase.needsSync = false;
            purchase.lastSyncedAt = DateTime.now();
            await localDataSource.savePurchase(purchase);
          }
        } catch (e) {
          AppLogger.error('Error syncing purchase item deletion: $e');
        }
      }
    } catch (e) {
      throw Exception('Error deleting purchase item: $e');
    }
  }

  @override
  Future<Purchase> receivePurchase(String id, String receivedBy) async {
    try {
      final purchaseModel = await localDataSource.getPurchaseById(id);
      if (purchaseModel == null) {
        throw Exception('Purchase not found');
      }

      if (purchaseModel.status != PurchaseStatus.pending) {
        throw Exception('Only pending purchases can be received');
      }

      final now = DateTime.now();
      final receivedPurchase = purchaseModel.toEntity().copyWith(
        status: PurchaseStatus.received,
        receivedBy: receivedBy,
        receivedAt: now,
        updatedAt: now,
        needsSync: true,
      );

      // Guardar en local
      final localModel = PurchaseLocalModel.fromEntity(receivedPurchase);
      await localDataSource.savePurchase(localModel);

      // Actualizar inventario local
      final items = await localDataSource.getPurchaseItems(id);
      for (final item in items) {
        try {
          // Buscar inventario existente para esta variante y ubicación
          final inventoryList = await inventoryLocalDataSource.getInventoryByVariant(
            item.productVariantId,
          );

          // Filtrar por locationId
          final existingInventory = inventoryList.cast<InventoryLocalModel?>().firstWhere(
            (inv) => inv != null && inv.locationId == receivedPurchase.locationId,
            orElse: () => null,
          );

          if (existingInventory != null) {
            // Actualizar cantidad
            existingInventory.quantity = existingInventory.quantity + item.quantity;
            existingInventory.lastUpdated = DateTime.now();
            existingInventory.updatedBy = receivedBy;

            await inventoryLocalDataSource.saveInventoryItem(existingInventory);
            AppLogger.info('📦 Inventario actualizado: ${item.productVariantId} +${item.quantity}');
          } else {
            // Crear nuevo registro de inventario
            final newInventory = InventoryLocalModel()
              ..uuid = const Uuid().v4()
              ..productVariantId = item.productVariantId
              ..locationId = receivedPurchase.locationId
              ..locationType = 'store' // O 'warehouse' según corresponda
              ..quantity = item.quantity
              ..minStock = 0
              ..maxStock = 1000
              ..lastUpdated = DateTime.now()
              ..updatedBy = receivedBy;

            await inventoryLocalDataSource.saveInventoryItem(newInventory);
            AppLogger.info('📦 Inventario creado: ${item.productVariantId} = ${item.quantity}');
          }
        } catch (e) {
          AppLogger.error('❌ Error actualizando inventario para item ${item.productVariantId}: $e');
        }
      }

      // Sincronizar inmediatamente (IMPORTANTE: el trigger SQL aplicará al inventario en Supabase)
      if (await networkInfo.isConnected) {
        try {
          // Primero asegurar que el proveedor está sincronizado
          final supplierSynced = await _ensureSupplierSynced(receivedPurchase.supplierId);

          if (supplierSynced) {
            final remoteModel = PurchaseRemoteModel.fromEntity(receivedPurchase);

            // Verificar si la compra ya existe en Supabase
            bool purchaseExists = false;
            try {
              await remoteDataSource.getPurchaseById(id);
              purchaseExists = true;
            } catch (e) {
              purchaseExists = false;
            }

            // Sincronizar la compra (crear o actualizar según corresponda)
            if (purchaseExists) {
              AppLogger.debug('📝 Actualizando compra existente en Supabase...');
              await remoteDataSource.updatePurchase(id, remoteModel.toJson());
            } else {
              AppLogger.debug('➕ Creando nueva compra en Supabase...');
              await remoteDataSource.createPurchase(remoteModel.toJson());
            }

            // Sincronizar items de la compra
            final items = await localDataSource.getPurchaseItems(id);
            for (final itemModel in items) {
              try {
                final itemEntity = itemModel.toEntity();
                final itemRemoteModel = PurchaseItemRemoteModel.fromEntity(itemEntity);

                // Intentar crear el item (ignorar si ya existe)
                try {
                  await remoteDataSource.createPurchaseItem(itemRemoteModel.toJson());
                } catch (e) {
                  AppLogger.error('⚠️ Item ya existe o error: $e');
                }
              } catch (e) {
                AppLogger.error('Error syncing item: $e');
              }
            }

            // Ahora actualizar el estado a "received"
            await remoteDataSource.updatePurchase(id, remoteModel.toJson());

            // Marcar como sincronizado
            final syncedPurchase = receivedPurchase.copyWith(
              needsSync: false,
              lastSyncedAt: DateTime.now(),
            );
            final syncedModel = PurchaseLocalModel.fromEntity(syncedPurchase);
            await localDataSource.savePurchase(syncedModel);

            return syncedPurchase;
          } else {
            AppLogger.warning('⚠️ No se pudo sincronizar la compra porque el proveedor no está sincronizado');
          }
        } catch (e) {
          AppLogger.error('Error syncing received purchase: $e');
        }
      }

      return receivedPurchase;
    } catch (e) {
      throw Exception('Error receiving purchase: $e');
    }
  }

  @override
  Future<Purchase> cancelPurchase(String id) async {
    try {
      final purchaseModel = await localDataSource.getPurchaseById(id);
      if (purchaseModel == null) {
        throw Exception('Purchase not found');
      }

      if (purchaseModel.status != PurchaseStatus.pending) {
        throw Exception('Only pending purchases can be cancelled');
      }

      final cancelledPurchase = purchaseModel.toEntity().copyWith(
        status: PurchaseStatus.cancelled,
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      // Guardar en local
      final localModel = PurchaseLocalModel.fromEntity(cancelledPurchase);
      await localDataSource.savePurchase(localModel);

      // Sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        try {
          // Primero asegurar que el proveedor está sincronizado
          final supplierSynced = await _ensureSupplierSynced(cancelledPurchase.supplierId);

          if (supplierSynced) {
            final remoteModel = PurchaseRemoteModel.fromEntity(cancelledPurchase);
            await remoteDataSource.updatePurchase(id, remoteModel.toJson());

            final syncedPurchase = cancelledPurchase.copyWith(
              needsSync: false,
              lastSyncedAt: DateTime.now(),
            );
            final syncedModel = PurchaseLocalModel.fromEntity(syncedPurchase);
            await localDataSource.savePurchase(syncedModel);

            return syncedPurchase;
          } else {
            AppLogger.warning('⚠️ No se pudo sincronizar la compra porque el proveedor no está sincronizado');
          }
        } catch (e) {
          AppLogger.error('Error syncing cancelled purchase: $e');
        }
      }

      return cancelledPurchase;
    } catch (e) {
      throw Exception('Error cancelling purchase: $e');
    }
  }

  @override
  Future<void> syncPurchases() async {
    try {
      if (!await networkInfo.isConnected) return;

      // 1. Sincronizar cambios locales no sincronizados
      final unsynced = await localDataSource.getUnsyncedPurchases();
      for (final localModel in unsynced) {
        try {
          final entity = localModel.toEntity();
          final remoteModel = PurchaseRemoteModel.fromEntity(entity);

          // Intentar actualizar (si existe) o crear (si no existe)
          try {
            await remoteDataSource.updatePurchase(
              entity.id,
              remoteModel.toJson(),
            );
          } catch (e) {
            final errorText = e.toString();
            // Si falla por RLS (no admin), omitir sincronización de subida
            if (errorText.contains('row-level security') ||
                errorText.contains('42501') ||
                errorText.contains('Forbidden')) {
              AppLogger.debug('⛔ Omitiendo sync upstream por RLS (solo admin puede crear/actualizar purchases)');
            } else if (errorText.contains('no encontrada') ||
                errorText.contains('not found')) {
              // Intentar crearlo si el fallo fue por inexistencia
              try {
                await remoteDataSource.createPurchase(remoteModel.toJson());
              } catch (e2) {
                final err2 = e2.toString();
                if (err2.contains('row-level security') ||
                    err2.contains('42501') ||
                    err2.contains('Forbidden')) {
                  AppLogger.debug('⛔ Omitiendo creación por RLS (solo admin).');
                } else {
                  rethrow;
                }
              }
            } else {
              rethrow;
            }
          }

          // Sincronizar items de esta compra
          final items = await localDataSource.getPurchaseItems(entity.id);
          for (final itemModel in items) {
            try {
              final itemEntity = itemModel.toEntity();
              final itemRemoteModel = PurchaseItemRemoteModel.fromEntity(itemEntity);
              try {
                await remoteDataSource.createPurchaseItem(itemRemoteModel.toJson());
              } catch (e) {
                final errorText = e.toString();
                if (errorText.contains('row-level security') ||
                    errorText.contains('42501') ||
                    errorText.contains('Forbidden')) {
                  AppLogger.debug('⛔ Omitiendo sync de items por RLS (solo admin).');
                } else {
                  rethrow;
                }
              }
            } catch (e) {
              AppLogger.error('Error syncing item: $e');
            }
          }

          // Marcar como sincronizado
          localModel.needsSync = false;
          localModel.lastSyncedAt = DateTime.now();
          await localDataSource.savePurchase(localModel);
        } catch (e) {
          AppLogger.error('Error syncing purchase ${localModel.uuid}: $e');
          // En caso de RLS, evitar reintentos infinitos
          final errorText = e.toString();
          if (errorText.contains('row-level security') ||
              errorText.contains('42501') ||
              errorText.contains('Forbidden')) {
            localModel.needsSync = false;
            localModel.lastSyncedAt = DateTime.now();
            await localDataSource.savePurchase(localModel);
          }
        }
      }

      // 2. Obtener compras remotas y actualizar local
      // (Esto se puede optimizar para solo obtener cambios recientes)
      final remotePurchases = await remoteDataSource.getAllPurchases();
      AppLogger.info('📥 Descargadas ${remotePurchases.length} compras desde Supabase');
      for (final purchaseJson in remotePurchases) {
        final remoteModel = PurchaseRemoteModel.fromJson(purchaseJson);
        final entity = remoteModel.toEntity(
          supplierName: purchaseJson['supplier_name'],
          locationName: purchaseJson['location_name'],
        );
        final localModel = PurchaseLocalModel.fromEntity(entity)
          ..needsSync = false
          ..lastSyncedAt = DateTime.now();
        await localDataSource.savePurchase(localModel);

        // Sincronizar items
        final itemsJson = await remoteDataSource.getPurchaseItems(entity.id);
        for (final itemJson in itemsJson) {
          final itemRemoteModel = PurchaseItemRemoteModel.fromJson(itemJson);
          final itemEntity = itemRemoteModel.toEntity(
            productName: itemJson['product_name'],
            variantName: itemJson['variant_name'],
          );
          final itemLocalModel = PurchaseItemLocalModel.fromEntity(itemEntity);
          await localDataSource.savePurchaseItem(itemLocalModel);
        }
      }
    } catch (e) {
      throw Exception('Error syncing purchases: $e');
    }
  }
}
