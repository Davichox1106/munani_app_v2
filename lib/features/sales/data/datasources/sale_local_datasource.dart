import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/sale_local_model.dart';
import '../models/sale_item_local_model.dart';

abstract class SaleLocalDataSource {
  // Streams
  Stream<List<SaleLocalModel>> watchAllSales();
  Stream<List<SaleLocalModel>> watchSalesByLocation(String locationId);
  Stream<List<SaleLocalModel>> watchSalesByStatus(String status);

  // Queries
  Future<SaleLocalModel?> getSaleById(String uuid);
  Future<List<SaleLocalModel>> searchSales(String query);

  // Mutations
  Future<SaleLocalModel> saveSale(SaleLocalModel sale);
  Future<void> deleteSale(String uuid);

  // Items
  Future<List<SaleItemLocalModel>> getSaleItems(String saleId);
  Future<SaleItemLocalModel> saveSaleItem(SaleItemLocalModel item);
  Future<void> deleteSaleItem(String uuid);
  Future<void> deleteSaleItemsBySaleId(String saleId);

  // Sync
  Future<List<SaleLocalModel>> getUnsyncedSales();
}

class SaleLocalDataSourceImpl implements SaleLocalDataSource {
  final IsarDatabase isarDatabase;
  SaleLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<SaleLocalModel>> watchAllSales() async* {
    final isar = await isarDatabase.database;
    yield* isar.saleLocalModels.where().sortBySaleDateDesc().watch(fireImmediately: true);
  }

  @override
  Stream<List<SaleLocalModel>> watchSalesByLocation(String locationId) async* {
    final isar = await isarDatabase.database;
    yield* isar.saleLocalModels
        .filter()
        .locationIdEqualTo(locationId)
        .sortBySaleDateDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<SaleLocalModel>> watchSalesByStatus(String status) async* {
    final isar = await isarDatabase.database;
    await for (final all in isar.saleLocalModels.where().sortBySaleDateDesc().watch(fireImmediately: true)) {
      yield all.where((s) => s.status.name == status).toList();
    }
  }

  @override
  Future<SaleLocalModel?> getSaleById(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.saleLocalModels.filter().uuidEqualTo(uuid).findFirst();
  }

  @override
  Future<List<SaleLocalModel>> searchSales(String query) async {
    final isar = await isarDatabase.database;
    return await isar.saleLocalModels
        .filter()
        .customerNameContains(query, caseSensitive: false)
        .or()
        .saleNumberContains(query, caseSensitive: false)
        .sortBySaleDateDesc()
        .findAll();
  }

  @override
  Future<SaleLocalModel> saveSale(SaleLocalModel sale) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final existing = await isar.saleLocalModels.filter().uuidEqualTo(sale.uuid).findFirst();
      if (existing != null) {
        sale.id = existing.id;
      }
      await isar.saleLocalModels.put(sale);
    });
    return sale;
  }

  @override
  Future<void> deleteSale(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final model = await isar.saleLocalModels.filter().uuidEqualTo(uuid).findFirst();
      if (model != null) {
        await deleteSaleItemsBySaleId(uuid);
        await isar.saleLocalModels.delete(model.id);
      }
    });
  }

  @override
  Future<List<SaleItemLocalModel>> getSaleItems(String saleId) async {
    final isar = await isarDatabase.database;
    return await isar.saleItemLocalModels.filter().saleIdEqualTo(saleId).sortByCreatedAt().findAll();
  }

  @override
  Future<SaleItemLocalModel> saveSaleItem(SaleItemLocalModel item) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final existing = await isar.saleItemLocalModels.filter().uuidEqualTo(item.uuid).findFirst();
      if (existing != null) {
        item.id = existing.id;
      }
      await isar.saleItemLocalModels.put(item);
    });
    return item;
  }

  @override
  Future<void> deleteSaleItem(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final model = await isar.saleItemLocalModels.filter().uuidEqualTo(uuid).findFirst();
      if (model != null) {
        await isar.saleItemLocalModels.delete(model.id);
      }
    });
  }

  @override
  Future<void> deleteSaleItemsBySaleId(String saleId) async {
    final isar = await isarDatabase.database;
    await isar.saleItemLocalModels.filter().saleIdEqualTo(saleId).deleteAll();
  }

  @override
  Future<List<SaleLocalModel>> getUnsyncedSales() async {
    final isar = await isarDatabase.database;
    return await isar.saleLocalModels.filter().needsSyncEqualTo(true).findAll();
  }
}
