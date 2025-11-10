import 'package:uuid/uuid.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/sale_local_datasource.dart';
import '../datasources/sale_remote_datasource.dart';
import '../models/sale_local_model.dart';
import '../models/sale_item_local_model.dart';
import '../models/sale_remote_model.dart';
import '../models/sale_item_remote_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleLocalDataSource localDataSource;
  final SaleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SaleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // Streams reactivas (Isar)
  @override
  Stream<List<Sale>> watchAllSales() async* {
    await for (final models in localDataSource.watchAllSales()) {
      yield models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Stream<List<Sale>> watchSalesByLocation(String locationId) async* {
    await for (final models in localDataSource.watchSalesByLocation(locationId)) {
      yield models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Stream<List<Sale>> watchSalesByStatus(SaleStatus status) async* {
    await for (final models in localDataSource.watchSalesByStatus(status.name)) {
      yield models.map((m) => m.toEntity()).toList();
    }
  }

  // Consultas
  @override
  Future<Sale?> getSaleById(String id) async {
    final model = await localDataSource.getSaleById(id);
    return model?.toEntity();
  }

  @override
  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final items = await localDataSource.getSaleItems(saleId);
    return items.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Sale>> searchSales(String query) async {
    final models = await localDataSource.searchSales(query);
    return models.map((m) => m.toEntity()).toList();
  }

  // Mutaciones Offline-First
  @override
  Future<Sale> createSale(Sale sale) async {
    final entity = sale.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final local = SaleLocalModel.fromEntity(entity)..needsSync = true;
    await localDataSource.saveSale(local);

    if (await networkInfo.isConnected) {
      try {
        final remote = SaleRemoteModel.fromEntity(entity);
        await remoteDataSource.createSale(remote.toJson());
        local.needsSync = false;
        local.lastSyncedAt = DateTime.now();
        await localDataSource.saveSale(local);
      } catch (e) {
        // RLS u otros errores: mantener needsSync para admin; si gerente, se omitirá en sync
      }
    }

    return entity;
  }

  @override
  Future<Sale> updateSale(Sale sale) async {
    final updated = sale.copyWith(updatedAt: DateTime.now());
    final local = SaleLocalModel.fromEntity(updated)..needsSync = true;
    await localDataSource.saveSale(local);

    if (await networkInfo.isConnected) {
      try {
        final remote = SaleRemoteModel.fromEntity(updated);
        await remoteDataSource.updateSale(updated.id, remote.toJson());
        local.needsSync = false;
        local.lastSyncedAt = DateTime.now();
        await localDataSource.saveSale(local);
      } catch (e) {
        // Omitir si RLS
      }
    }

    return updated;
  }

  @override
  Future<void> deleteSale(String id) async {
    await localDataSource.deleteSale(id);
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteSale(id);
      } catch (e) {
        // Omitir si RLS
      }
    }
  }

  // Items
  @override
  Future<SaleItem> addSaleItem(SaleItem item) async {
    final newItem = item.copyWith(id: const Uuid().v4(), createdAt: DateTime.now());
    await localDataSource.saveSaleItem(SaleItemLocalModel.fromEntity(newItem));

    // Marcar venta para sync
    final sale = await localDataSource.getSaleById(item.saleId);
    if (sale != null) {
      sale.needsSync = true;
      await localDataSource.saveSale(sale);
    }

    if (await networkInfo.isConnected) {
      try {
        final remote = SaleItemRemoteModel.fromEntity(newItem);
        await remoteDataSource.createSaleItem(remote.toJson());
        if (sale != null) {
          sale.needsSync = false;
          sale.lastSyncedAt = DateTime.now();
          await localDataSource.saveSale(sale);
        }
      } catch (e) {
        // Omitir si RLS
      }
    }

    return newItem;
  }

  @override
  Future<SaleItem> updateSaleItem(SaleItem item) async {
    await localDataSource.saveSaleItem(SaleItemLocalModel.fromEntity(item));
    final sale = await localDataSource.getSaleById(item.saleId);
    if (sale != null) {
      sale.needsSync = true;
      await localDataSource.saveSale(sale);
    }

    if (await networkInfo.isConnected) {
      try {
        final remote = SaleItemRemoteModel.fromEntity(item);
        await remoteDataSource.updateSaleItem(item.id, remote.toJson());
        if (sale != null) {
          sale.needsSync = false;
          sale.lastSyncedAt = DateTime.now();
          await localDataSource.saveSale(sale);
        }
      } catch (e) {
        // Ignorar errores de sincronización en segundo plano
        AppLogger.debug('Error sincronizando item de venta: $e');
      }
    }

    return item;
  }

  @override
  Future<void> deleteSaleItem(String itemId, String saleId) async {
    await localDataSource.deleteSaleItem(itemId);
    final sale = await localDataSource.getSaleById(saleId);
    if (sale != null) {
      sale.needsSync = true;
      await localDataSource.saveSale(sale);
    }
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteSaleItem(itemId);
        if (sale != null) {
          sale.needsSync = false;
          sale.lastSyncedAt = DateTime.now();
          await localDataSource.saveSale(sale);
        }
      } catch (e) {
        // Ignorar errores de sincronización en segundo plano
        AppLogger.debug('Error sincronizando eliminación de item: $e');
      }
    }
  }

  // Flujo de negocio
  @override
  Future<Sale> completeSale(String id) async {
    final model = await localDataSource.getSaleById(id);
    if (model == null) {
      throw Exception('Venta no encontrada');
    }
    model.status = SaleStatus.completed;
    model.updatedAt = DateTime.now();
    model.needsSync = true;
    await localDataSource.saveSale(model);

    if (await networkInfo.isConnected) {
      try {
        final remote = SaleRemoteModel.fromEntity(model.toEntity());
        await remoteDataSource.updateSale(id, remote.toJson());
        model.needsSync = false;
        model.lastSyncedAt = DateTime.now();
        await localDataSource.saveSale(model);
      } catch (e) {
        // Si RLS, el trigger remoto no aplicará inventario; continuará offline
      }
    }

    return model.toEntity();
  }

  @override
  Future<Sale> cancelSale(String id) async {
    final model = await localDataSource.getSaleById(id);
    if (model == null) {
      throw Exception('Venta no encontrada');
    }
    model.status = SaleStatus.cancelled;
    model.updatedAt = DateTime.now();
    model.needsSync = true;
    await localDataSource.saveSale(model);

    if (await networkInfo.isConnected) {
      try {
        final remote = SaleRemoteModel.fromEntity(model.toEntity());
        await remoteDataSource.updateSale(id, remote.toJson());
        model.needsSync = false;
        model.lastSyncedAt = DateTime.now();
        await localDataSource.saveSale(model);
      } catch (e) {
        // Ignorar errores de sincronización en segundo plano
        AppLogger.debug('Error sincronizando venta: $e');
      }
    }

    return model.toEntity();
  }

  // Sincronización bidireccional
  @override
  Future<void> syncSales() async {
    if (!await networkInfo.isConnected) return;

    // 1) Subir locales pendientes
    final unsynced = await localDataSource.getUnsyncedSales();
    for (final local in unsynced) {
      try {
        final entity = local.toEntity();
        final remote = SaleRemoteModel.fromEntity(entity);
        try {
          await remoteDataSource.updateSale(entity.id, remote.toJson());
        } catch (e) {
          final text = e.toString();
          if (text.contains('row-level security') || text.contains('42501') || text.contains('Forbidden')) {
            // Gerente: se omite subida
          } else if (text.contains('no encontrada') || text.contains('not found')) {
            try {
              await remoteDataSource.createSale(remote.toJson());
            } catch (e2) {
              final t2 = e2.toString();
              if (t2.contains('row-level security') || t2.contains('42501') || t2.contains('Forbidden')) {
                // Omitir para gerente
              } else {
                rethrow;
              }
            }
          } else {
            rethrow;
          }
        }

        // Subir items
        final items = await localDataSource.getSaleItems(entity.id);
        for (final item in items) {
          try {
            final remoteItem = SaleItemRemoteModel.fromEntity(item.toEntity());
            try {
              await remoteDataSource.createSaleItem(remoteItem.toJson());
            } catch (e) {
              final text = e.toString();
              if (text.contains('row-level security') || text.contains('42501') || text.contains('Forbidden')) {
                // Omitir para gerente
              } else {
                rethrow;
              }
            }
          } catch (e) {
            // continuar con otros items
          }
        }

        local.needsSync = false;
        local.lastSyncedAt = DateTime.now();
        await localDataSource.saveSale(local);
      } catch (e) {
        // Loguear y continuar con el siguiente
      }
    }

    // 2) Bajar del servidor y guardar local
    final remoteSales = await remoteDataSource.getAllSales();
    for (final json in remoteSales) {
      final remote = SaleRemoteModel.fromJson(json);
      final entity = remote.toEntity();
      final local = SaleLocalModel.fromEntity(entity)
        ..needsSync = false
        ..lastSyncedAt = DateTime.now();
      await localDataSource.saveSale(local);

      final itemsJson = await remoteDataSource.getSaleItems(entity.id);
      for (final itemJson in itemsJson) {
        final remoteItem = SaleItemRemoteModel.fromJson(itemJson);
        final localItem = SaleItemLocalModel.fromEntity(remoteItem.toEntity());
        await localDataSource.saveSaleItem(localItem);
      }
    }
  }
}
