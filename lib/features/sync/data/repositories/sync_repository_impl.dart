import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/sync_queue_item.dart';
import '../../domain/repositories/sync_repository.dart';
import '../models/sync_queue_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de sincronización
///
/// Gestiona la cola de sincronización Offline-First con Isar
/// Resuelve conflictos usando timestamps (last-write-wins)
class SyncRepositoryImpl implements SyncRepository {
  final IsarDatabase isarDatabase;
  final NetworkInfo networkInfo;
  final SupabaseClient supabaseClient;

  final _pendingItemsController = StreamController<int>.broadcast();

  // 🔒 Lock para evitar sincronizaciones concurrentes
  bool _isSyncing = false;

  SyncRepositoryImpl({
    required this.isarDatabase,
    required this.networkInfo,
    required this.supabaseClient,
  });

  @override
  Stream<int> get pendingItemsStream => _pendingItemsController.stream;

  @override
  Future<Either<Failure, void>> addToQueue(SyncQueueItem item) async {
    try {
      final isar = await isarDatabase.database;
      final model = SyncQueueLocalModel.fromEntity(item);

      await isar.writeTxn(() async {
        await isar.syncQueueLocalModels.put(model);
      });

      // Notificar cambio en número de items pendientes
      _notifyPendingCountChanged();

      AppLogger.info('📋 Item agregado a cola: ${item.entityType.value} - ${item.operation.value}');

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al agregar item a cola: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncQueueItem>>> getPendingItems() async {
    try {
      final isar = await isarDatabase.database;

      final models = await isar.syncQueueLocalModels
          .filter()
          .attemptsLessThan(5) // Solo items que no han fallado permanentemente
          .sortByPriority() // Ordenar por prioridad
          .thenByCreatedAt() // Luego por fecha (FIFO)
          .findAll();

      final items = models.map((m) => m.toEntity()).toList();

      return Right(items);
    } catch (e) {
      return Left(CacheFailure('Error al obtener items pendientes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncQueueItem>>> getFailedItems() async {
    try {
      final isar = await isarDatabase.database;

      final models = await isar.syncQueueLocalModels
          .filter()
          .attemptsGreaterThan(4) // Items que excedieron límite de reintentos
          .findAll();

      final items = models.map((m) => m.toEntity()).toList();

      return Right(items);
    } catch (e) {
      return Left(CacheFailure('Error al obtener items fallidos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncItem(SyncQueueItem item) async {
    try {
      // Verificar conexión a internet
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No hay conexión a internet'));
      }

      // ⚠️ NUEVO: Verificar si hay usuario autenticado ANTES de intentar sincronizar
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        AppLogger.warning('⚠️ Sincronización pospuesta: No hay usuario autenticado (item quedará en cola)');
        // NO incrementar intentos, simplemente dejar en cola
        return const Left(NetworkFailure('Sin usuario autenticado'));
      }

      final isar = await isarDatabase.database;

      // Buscar el modelo en Isar
      final model = await isar.syncQueueLocalModels
          .filter()
          .uuidEqualTo(item.id)
          .findFirst();

      if (model == null) {
        return Left(CacheFailure('Item no encontrado en cola'));
      }

      try {
        // Sincronizar con Supabase según el tipo de entidad
        switch (item.entityType) {
          case SyncEntityType.product:
            await _syncProduct(item);
            break;
          case SyncEntityType.productVariant:
            await _syncProductVariant(item);
            break;
          case SyncEntityType.store:
            await _syncStore(item);
            break;
          case SyncEntityType.warehouse:
            await _syncWarehouse(item);
            break;
          case SyncEntityType.inventory:
            await _syncInventory(item);
            break;
          case SyncEntityType.transfer:
            await _syncTransfer(item);
            break;
          default:
            AppLogger.warning('⚠️ Tipo de entidad no implementado: ${item.entityType.value}');
        }

        // Si llegamos aquí, la sincronización fue exitosa
        // Eliminar de la cola
        await isar.writeTxn(() async {
          await isar.syncQueueLocalModels.delete(model.id);
        });

        _notifyPendingCountChanged();

        AppLogger.info('✅ Item sincronizado: ${item.entityType.value}');

        return const Right(null);
      } catch (e) {
        // Incrementar contador de intentos
        await isar.writeTxn(() async {
          model.incrementAttempts(error: e.toString());
          await isar.syncQueueLocalModels.put(model);
        });

        AppLogger.error('❌ Error al sincronizar item: $e');

        return Left(ServerFailure('Error al sincronizar: $e'));
      }
    } catch (e) {
      return Left(CacheFailure('Error en syncItem: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> syncAll() async {
    // 🔒 Evitar sincronizaciones concurrentes
    if (_isSyncing) {
      AppLogger.warning('⚠️ Sincronización ya en progreso, omitiendo...');
      return const Left(NetworkFailure('Sincronización en progreso'));
    }

    _isSyncing = true;
    AppLogger.debug('🔄 Sincronización iniciada - Lock activado');

    try {
      // Verificar conexión
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No hay conexión a internet'));
      }

      // Verificar si hay usuario autenticado
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        AppLogger.warning('⚠️ SyncAll pospuesto: No hay usuario autenticado');
        return const Left(NetworkFailure('Sin usuario autenticado'));
      }

      // Obtener items pendientes
      final itemsResult = await getPendingItems();

      // Manejar resultado con if-else en lugar de fold para evitar race conditions
      if (itemsResult.isLeft()) {
        final failure = itemsResult.fold((l) => l, (r) => null);
        return Left(failure!);
      }

      final items = itemsResult.getOrElse(() => []);

      if (items.isEmpty) {
        AppLogger.info('✅ No hay items pendientes para sincronizar');
        return const Right(0);
      }

      AppLogger.debug('🔄 Sincronización iniciada - ${items.length} items');
      int syncedCount = 0;

      for (final item in items) {
        final result = await syncItem(item);
        result.fold(
          (failure) {
            AppLogger.error('❌ Falló sincronización de ${item.entityType.value}: ${failure.message}');
          },
          (_) {
            syncedCount++;
          },
        );
      }

      AppLogger.info('🔄 Sincronizados $syncedCount de ${items.length} items');
      AppLogger.info('✅ Sincronización completada: $syncedCount items');

      return Right(syncedCount);
    } catch (e) {
      return Left(CacheFailure('Error en syncAll: $e'));
    } finally {
      _isSyncing = false;
      AppLogger.debug('🔓 Lock de sincronización liberado');
    }
  }

  @override
  Future<Either<Failure, int>> retryFailed() async {
    try {
      final failedResult = await getFailedItems();

      return failedResult.fold(
        (failure) => Left(failure),
        (items) async {
          // Resetear contador de intentos
          final isar = await isarDatabase.database;

          for (final item in items) {
            final model = await isar.syncQueueLocalModels
                .filter()
                .uuidEqualTo(item.id)
                .findFirst();

            if (model != null) {
              await isar.writeTxn(() async {
                model.attempts = 0;
                model.errorMessage = null;
                await isar.syncQueueLocalModels.put(model);
              });
            }
          }

          AppLogger.debug('🔄 ${items.length} items marcados para reintento');

          // Intentar sincronizar nuevamente
          return syncAll();
        },
      );
    } catch (e) {
      return Left(CacheFailure('Error en retryFailed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromQueue(String itemId) async {
    try {
      final isar = await isarDatabase.database;

      final model = await isar.syncQueueLocalModels
          .filter()
          .uuidEqualTo(itemId)
          .findFirst();

      if (model != null) {
        await isar.writeTxn(() async {
          await isar.syncQueueLocalModels.delete(model.id);
        });

        _notifyPendingCountChanged();
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al eliminar item: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> clearCompleted() async {
    try {
      final isar = await isarDatabase.database;

      // Obtener items con 0 intentos (ya sincronizados)
      final completed = await isar.syncQueueLocalModels
          .filter()
          .attemptsEqualTo(0)
          .findAll();

      int count = completed.length;

      await isar.writeTxn(() async {
        for (final model in completed) {
          await isar.syncQueueLocalModels.delete(model.id);
        }
      });

      _notifyPendingCountChanged();

      AppLogger.info('🗑️ $count items completados eliminados');

      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Error al limpiar completados: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      final isar = await isarDatabase.database;

      final count = await isar.syncQueueLocalModels
          .filter()
          .attemptsLessThan(5)
          .count();

      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Error al contar pendientes: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPendingItems() async {
    final countResult = await getPendingCount();

    return countResult.fold(
      (failure) => Left(failure),
      (count) => Right(count > 0),
    );
  }

  /// Notificar cambios en el número de items pendientes
  Future<void> _notifyPendingCountChanged() async {
    final countResult = await getPendingCount();
    countResult.fold(
      (failure) => null,
      (count) => _pendingItemsController.add(count),
    );
  }

  /// Sincronizar producto con Supabase
  Future<void> _syncProduct(SyncQueueItem item) async {
    // Verificar y refrescar JWT antes de sincronizar
    final jwtValid = await AuthService.ensureValidJWT();
    if (!jwtValid) {
      throw Exception('JWT inválido, no se puede sincronizar');
    }

    final data = item.data;
    
    switch (item.operation) {
      case SyncOperation.create:
        AppLogger.info('📤 Enviando INSERT a Supabase:');
        AppLogger.debug('   id: ${data['id']}');
        AppLogger.debug('   name: ${data['name']}');
        AppLogger.debug('   category: ${data['category']}');
        AppLogger.debug('   created_by: ${data['created_by']}');
        AppLogger.debug('   Usuario actual: ${supabaseClient.auth.currentUser?.id}');

        await supabaseClient.from('products').insert({
          'id': data['id'],
          'name': data['name'],
          'description': data['description'],
          'category': data['category'],
          'base_price_sell': data['base_price_sell'],
          'base_price_buy': data['base_price_buy'],
          'has_variants': data['has_variants'],
          'image_urls': data['image_urls'],
          'created_by': data['created_by'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        });
        AppLogger.info('🔄 Producto creado en Supabase: ${data['name']}');
        break;
        
      case SyncOperation.update:
        await supabaseClient.from('products').update({
          'name': data['name'],
          'description': data['description'],
          'category': data['category'],
          'base_price_sell': data['base_price_sell'],
          'base_price_buy': data['base_price_buy'],
          'has_variants': data['has_variants'],
          'image_urls': data['image_urls'],
          'updated_at': data['updated_at'],
        }).eq('id', item.entityId);
        AppLogger.info('🔄 Producto actualizado en Supabase: ${data['name']}');
        break;
        
      case SyncOperation.delete:
        AppLogger.debug('🗑️ Intentando eliminar producto de Supabase: ${item.entityId}');
        final deleteResponse = await supabaseClient
            .from('products')
            .delete()
            .eq('id', item.entityId)
            .select(); // select() para confirmar que se eliminó

        AppLogger.info('✅ Producto eliminado en Supabase: ${item.entityId}');
        AppLogger.debug('   Respuesta: $deleteResponse');
        break;
    }
  }

  /// Sincronizar variante de producto con Supabase
  Future<void> _syncProductVariant(SyncQueueItem item) async {
    // Verificar y refrescar JWT antes de sincronizar
    final jwtValid = await AuthService.ensureValidJWT();
    if (!jwtValid) {
      throw Exception('JWT inválido, no se puede sincronizar');
    }

    final data = item.data;
    
    switch (item.operation) {
      case SyncOperation.create:
        await supabaseClient.from('product_variants').insert({
          'id': data['id'],
          'product_id': data['product_id'],
          'variant_name': data['variant_name'],
          'sku': data['sku'],
          'variant_attributes': data['variant_attributes'],
          'price_sell': data['price_sell'],
          'price_buy': data['price_buy'],
          'is_active': data['is_active'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        });
        AppLogger.debug('🔄 Variante creada en Supabase: ${data['variant_name']}');
        break;
        
      case SyncOperation.update:
        await supabaseClient.from('product_variants').update({
          'variant_name': data['variant_name'],
          'sku': data['sku'],
          'variant_attributes': data['variant_attributes'],
          'price_sell': data['price_sell'],
          'price_buy': data['price_buy'],
          'is_active': data['is_active'],
          'updated_at': data['updated_at'],
        }).eq('id', item.entityId);
        AppLogger.debug('🔄 Variante actualizada en Supabase: ${data['variant_name']}');
        break;
        
      case SyncOperation.delete:
        await supabaseClient.from('product_variants').delete().eq('id', item.entityId);
        AppLogger.debug('🔄 Variante eliminada en Supabase: ${item.entityId}');
        break;
    }
  }

  /// Sincronizar tienda con Supabase
  Future<void> _syncStore(SyncQueueItem item) async {
    // Verificar y refrescar JWT antes de sincronizar
    final jwtValid = await AuthService.ensureValidJWT();
    if (!jwtValid) {
      throw Exception('JWT inválido, no se puede sincronizar');
    }

    final data = item.data;
    
    switch (item.operation) {
      case SyncOperation.create:
        await supabaseClient.from('stores').insert({
          'id': data['id'],
          'name': data['name'],
          'address': data['address'],
          'phone': data['phone'],
          'manager_id': data['manager_id'],
          'is_active': data['is_active'],
          'payment_qr_url': data['payment_qr_url'],
          'payment_qr_description': data['payment_qr_description'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        });
        AppLogger.debug('🔄 Tienda creada en Supabase: ${data['name']}');
        break;
        
      case SyncOperation.update:
        await supabaseClient.from('stores').update({
          'name': data['name'],
          'address': data['address'],
          'phone': data['phone'],
          'manager_id': data['manager_id'],
          'is_active': data['is_active'],
          'payment_qr_url': data['payment_qr_url'],
          'payment_qr_description': data['payment_qr_description'],
          'updated_at': data['updated_at'],
        }).eq('id', item.entityId);
        AppLogger.debug('🔄 Tienda actualizada en Supabase: ${data['name']}');
        break;
        
      case SyncOperation.delete:
        await supabaseClient.from('stores').delete().eq('id', item.entityId);
        AppLogger.debug('🔄 Tienda eliminada en Supabase: ${item.entityId}');
        break;
    }
  }

  /// Sincronizar bodega con Supabase
  Future<void> _syncWarehouse(SyncQueueItem item) async {
    // Verificar y refrescar JWT antes de sincronizar
    final jwtValid = await AuthService.ensureValidJWT();
    if (!jwtValid) {
      throw Exception('JWT inválido, no se puede sincronizar');
    }

    final data = item.data;

    switch (item.operation) {
      case SyncOperation.create:
        await supabaseClient.from('warehouses').insert({
          'id': data['id'],
          'name': data['name'],
          'address': data['address'],
          'manager_id': data['manager_id'],
          'is_active': data['is_active'],
          'payment_qr_url': data['payment_qr_url'],
          'payment_qr_description': data['payment_qr_description'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        });
        AppLogger.debug('🔄 Bodega creada en Supabase: ${data['name']}');
        break;

      case SyncOperation.update:
        await supabaseClient.from('warehouses').update({
          'name': data['name'],
          'address': data['address'],
          'manager_id': data['manager_id'],
          'is_active': data['is_active'],
          'payment_qr_url': data['payment_qr_url'],
          'payment_qr_description': data['payment_qr_description'],
          'updated_at': data['updated_at'],
        }).eq('id', item.entityId);
        AppLogger.debug('🔄 Bodega actualizada en Supabase: ${data['name']}');
        break;

      case SyncOperation.delete:
        await supabaseClient.from('warehouses').delete().eq('id', item.entityId);
        AppLogger.debug('🔄 Bodega eliminada en Supabase: ${item.entityId}');
        break;
    }
  }

  /// Sincronizar inventario con Supabase
  Future<void> _syncInventory(SyncQueueItem item) async {
    // Verificar y refrescar JWT antes de sincronizar
    final jwtValid = await AuthService.ensureValidJWT();
    if (!jwtValid) {
      throw Exception('JWT inválido, no se puede sincronizar');
    }

    final data = item.data;

    switch (item.operation) {
      case SyncOperation.create:
        AppLogger.info('📤 Enviando INSERT de inventario a Supabase:');
        AppLogger.debug('   id: ${data['id']}');
        AppLogger.debug('   product_variant_id: ${data['product_variant_id']}');
        AppLogger.debug('   location_id: ${data['location_id']}');
        AppLogger.debug('   location_type: ${data['location_type']}');
        AppLogger.debug('   quantity: ${data['quantity']}');

        await supabaseClient.from('inventory').insert({
          'id': data['id'],
          'product_variant_id': data['product_variant_id'],
          'location_id': data['location_id'],
          'location_type': data['location_type'],
          'quantity': data['quantity'],
          'min_stock': data['min_stock'],
          'max_stock': data['max_stock'],
          'last_updated': data['last_updated'],
          'updated_by': data['updated_by'],
          'location_name': data['location_name'],
          'unit_cost': data['unit_cost'],
          'total_cost': data['total_cost'],
          'last_cost': data['last_cost'],
          'cost_updated_at': data['cost_updated_at'],
          'image_urls': data['image_urls'],
        });
        AppLogger.info('✅ Inventario creado en Supabase');
        break;

      case SyncOperation.update:
        AppLogger.info('📤 Enviando UPDATE de inventario a Supabase: ${item.entityId}');

        await supabaseClient.from('inventory').update({
          'product_variant_id': data['product_variant_id'],
          'location_id': data['location_id'],
          'location_type': data['location_type'],
          'quantity': data['quantity'],
          'min_stock': data['min_stock'],
          'max_stock': data['max_stock'],
          'last_updated': data['last_updated'],
          'updated_by': data['updated_by'],
          'location_name': data['location_name'],
          'unit_cost': data['unit_cost'],
          'total_cost': data['total_cost'],
          'last_cost': data['last_cost'],
          'cost_updated_at': data['cost_updated_at'],
          'image_urls': data['image_urls'],
        }).eq('id', item.entityId);
        AppLogger.info('✅ Inventario actualizado en Supabase');
        break;

      case SyncOperation.delete:
        AppLogger.debug('🗑️ Intentando eliminar inventario de Supabase: ${item.entityId}');

        final deleteResponse = await supabaseClient
            .from('inventory')
            .delete()
            .eq('id', item.entityId)
            .select();

        AppLogger.info('✅ Inventario eliminado en Supabase: ${item.entityId}');
        AppLogger.debug('   Respuesta: $deleteResponse');
        break;
    }
  }

  /// Sincronizar transferencia con Supabase
  Future<void> _syncTransfer(SyncQueueItem item) async {
    // Verificar y refrescar JWT antes de sincronizar
    final jwtValid = await AuthService.ensureValidJWT();
    if (!jwtValid) {
      throw Exception('JWT inválido, no se puede sincronizar');
    }

    final data = item.data;

    switch (item.operation) {
      case SyncOperation.create:
        AppLogger.info('📤 Enviando INSERT de transferencia a Supabase:');
        AppLogger.debug('   id: ${data['uuid']}');
        AppLogger.debug('   product_variant_id: ${data['product_variant_id']}');
        AppLogger.debug('   from_location_id: ${data['from_location_id']}');
        AppLogger.debug('   to_location_id: ${data['to_location_id']}');
        AppLogger.debug('   quantity: ${data['quantity']}');

        AppLogger.debug('🔍 Datos a enviar a Supabase:');
        AppLogger.debug('   updated_by: ${data['updated_by']}');
        AppLogger.debug('   requested_by: ${data['requested_by']}');

        await supabaseClient.from('transfers').insert({
          'id': data['uuid'],
          'product_variant_id': data['product_variant_id'],
          'product_name': data['product_name'],
          'variant_name': data['variant_name'],
          'from_location_id': data['from_location_id'],
          'from_location_name': data['from_location_name'],
          'from_location_type': data['from_location_type'],
          'to_location_id': data['to_location_id'],
          'to_location_name': data['to_location_name'],
          'to_location_type': data['to_location_type'],
          'quantity': data['quantity'],
          'requested_by': data['requested_by'],
          'requested_by_name': data['requested_by_name'],
          'requested_at': data['requested_at'],
          'approved_by': data['approved_by'],
          'approved_by_name': data['approved_by_name'],
          'approved_at': data['approved_at'],
          'rejection_reason': data['rejection_reason'],
          'status': data['status'],
          'notes': data['notes'],
          'last_updated': data['last_updated'],
          'updated_by': data['updated_by'],
        });
        AppLogger.info('✅ Transferencia creada en Supabase');
        break;

      case SyncOperation.update:
        AppLogger.info('📤 Enviando UPDATE de transferencia a Supabase: ${item.entityId}');

        await supabaseClient.from('transfers').update({
          'product_variant_id': data['product_variant_id'],
          'product_name': data['product_name'],
          'variant_name': data['variant_name'],
          'from_location_id': data['from_location_id'],
          'from_location_name': data['from_location_name'],
          'from_location_type': data['from_location_type'],
          'to_location_id': data['to_location_id'],
          'to_location_name': data['to_location_name'],
          'to_location_type': data['to_location_type'],
          'quantity': data['quantity'],
          'requested_by': data['requested_by'],
          'requested_by_name': data['requested_by_name'],
          'requested_at': data['requested_at'],
          'approved_by': data['approved_by'],
          'approved_by_name': data['approved_by_name'],
          'approved_at': data['approved_at'],
          'rejection_reason': data['rejection_reason'],
          'status': data['status'],
          'notes': data['notes'],
          'last_updated': data['last_updated'],
          'updated_by': data['updated_by'],
        }).eq('id', item.entityId);
        AppLogger.info('✅ Transferencia actualizada en Supabase');
        break;

      case SyncOperation.delete:
        AppLogger.debug('🗑️ Intentando eliminar transferencia de Supabase: ${item.entityId}');

        final deleteResponse = await supabaseClient
            .from('transfers')
            .delete()
            .eq('id', item.entityId)
            .select();

        AppLogger.info('✅ Transferencia eliminada en Supabase: ${item.entityId}');
        AppLogger.debug('   Respuesta: $deleteResponse');
        break;
    }
  }

  void dispose() {
    _pendingItemsController.close();
  }
}
