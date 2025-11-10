import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/purchase_local_model.dart';
import '../models/purchase_item_local_model.dart';

/// DataSource local para Purchases usando Isar
///
/// OWASP A04: Arquitectura Offline-First
abstract class PurchaseLocalDataSource {
  Stream<List<PurchaseLocalModel>> watchAllPurchases();
  Stream<List<PurchaseLocalModel>> watchPurchasesByLocation(String locationId);
  Stream<List<PurchaseLocalModel>> watchPurchasesByStatus(String status);
  Future<PurchaseLocalModel?> getPurchaseById(String uuid);
  Future<List<PurchaseLocalModel>> getAllPurchasesList();
  Future<List<PurchaseLocalModel>> getPurchasesByLocationList(String locationId);
  Future<List<PurchaseLocalModel>> searchPurchases(String query);
  Future<PurchaseLocalModel> savePurchase(PurchaseLocalModel purchase);
  Future<void> deletePurchase(String uuid);
  Future<List<PurchaseLocalModel>> getUnsyncedPurchases();

  // Purchase Items
  Future<List<PurchaseItemLocalModel>> getPurchaseItems(String purchaseId);
  Future<PurchaseItemLocalModel> savePurchaseItem(PurchaseItemLocalModel item);
  Future<void> deletePurchaseItem(String uuid);
  Future<void> deletePurchaseItemsByPurchaseId(String purchaseId);
}

class PurchaseLocalDataSourceImpl implements PurchaseLocalDataSource {
  final IsarDatabase isarDatabase;

  PurchaseLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<PurchaseLocalModel>> watchAllPurchases() async* {
    final isar = await isarDatabase.database;
    yield* isar.purchaseLocalModels
        .where()
        .sortByPurchaseDateDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<PurchaseLocalModel>> watchPurchasesByLocation(
    String locationId,
  ) async* {
    final isar = await isarDatabase.database;
    yield* isar.purchaseLocalModels
        .filter()
        .locationIdEqualTo(locationId)
        .sortByPurchaseDateDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<PurchaseLocalModel>> watchPurchasesByStatus(
    String status,
  ) async* {
    final isar = await isarDatabase.database;
    // Filtrar por status usando .where en memoria
    await for (final allPurchases in isar.purchaseLocalModels
        .where()
        .sortByPurchaseDateDesc()
        .watch(fireImmediately: true)) {
      final filteredPurchases = allPurchases
          .where((p) => p.status.name == status)
          .toList();
      yield filteredPurchases;
    }
  }

  @override
  Future<PurchaseLocalModel?> getPurchaseById(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.purchaseLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<PurchaseLocalModel>> getAllPurchasesList() async {
    final isar = await isarDatabase.database;
    return await isar.purchaseLocalModels
        .where()
        .sortByPurchaseDateDesc()
        .findAll();
  }

  @override
  Future<List<PurchaseLocalModel>> getPurchasesByLocationList(
    String locationId,
  ) async {
    final isar = await isarDatabase.database;
    return await isar.purchaseLocalModels
        .filter()
        .locationIdEqualTo(locationId)
        .sortByPurchaseDateDesc()
        .findAll();
  }

  @override
  Future<List<PurchaseLocalModel>> searchPurchases(String query) async {
    final isar = await isarDatabase.database;
    final lowercaseQuery = query.toLowerCase();

    return await isar.purchaseLocalModels
        .filter()
        .supplierNameContains(lowercaseQuery, caseSensitive: false)
        .or()
        .purchaseNumberContains(lowercaseQuery, caseSensitive: false)
        .or()
        .invoiceNumberContains(lowercaseQuery, caseSensitive: false)
        .sortByPurchaseDateDesc()
        .findAll();
  }

  @override
  Future<PurchaseLocalModel> savePurchase(PurchaseLocalModel purchase) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      // Buscar compra existente por UUID
      final existing = await isar.purchaseLocalModels
          .filter()
          .uuidEqualTo(purchase.uuid)
          .findFirst();

      if (existing != null) {
        // Mantener el ID de Isar existente para actualizar el mismo registro
        purchase.id = existing.id;
      }

      await isar.purchaseLocalModels.put(purchase);
    });
    return purchase;
  }

  @override
  Future<void> deletePurchase(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final purchase = await isar.purchaseLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (purchase != null) {
        // Eliminar items asociados primero
        await deletePurchaseItemsByPurchaseId(uuid);
        // Eliminar la compra
        await isar.purchaseLocalModels.delete(purchase.id);
      }
    });
  }

  @override
  Future<List<PurchaseLocalModel>> getUnsyncedPurchases() async {
    final isar = await isarDatabase.database;
    return await isar.purchaseLocalModels
        .filter()
        .needsSyncEqualTo(true)
        .findAll();
  }

  // ============================================================================
  // PURCHASE ITEMS
  // ============================================================================

  @override
  Future<List<PurchaseItemLocalModel>> getPurchaseItems(
    String purchaseId,
  ) async {
    final isar = await isarDatabase.database;
    return await isar.purchaseItemLocalModels
        .filter()
        .purchaseIdEqualTo(purchaseId)
        .sortByCreatedAt()
        .findAll();
  }

  @override
  Future<PurchaseItemLocalModel> savePurchaseItem(
    PurchaseItemLocalModel item,
  ) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      // Buscar item existente por UUID
      final existing = await isar.purchaseItemLocalModels
          .filter()
          .uuidEqualTo(item.uuid)
          .findFirst();

      if (existing != null) {
        // Mantener el ID de Isar existente para actualizar el mismo registro
        item.id = existing.id;
      }

      await isar.purchaseItemLocalModels.put(item);
    });
    return item;
  }

  @override
  Future<void> deletePurchaseItem(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final item = await isar.purchaseItemLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (item != null) {
        await isar.purchaseItemLocalModels.delete(item.id);
      }
    });
  }

  @override
  Future<void> deletePurchaseItemsByPurchaseId(String purchaseId) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final items = await isar.purchaseItemLocalModels
          .filter()
          .purchaseIdEqualTo(purchaseId)
          .findAll();
      for (final item in items) {
        await isar.purchaseItemLocalModels.delete(item.id);
      }
    });
  }
}
