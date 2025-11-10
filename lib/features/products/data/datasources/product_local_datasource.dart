import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/product_local_model.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/app_logger.dart';

/// Local datasource for products (Isar)
/// Handles all local database operations for products
abstract class ProductLocalDataSource {
  /// Get all products from local database
  Future<List<ProductLocalModel>> getAllProducts();

  /// Get product by UUID
  Future<ProductLocalModel?> getProductByUuid(String uuid);

  /// Get products by category
  Future<List<ProductLocalModel>> getProductsByCategory(ProductCategory category);

  /// Search products by name (case insensitive)
  Future<List<ProductLocalModel>> searchProducts(String query);

  /// Save product to local database (insert or update)
  Future<ProductLocalModel> saveProduct(ProductLocalModel product);

  /// Save multiple products (bulk insert/update)
  Future<void> saveProducts(List<ProductLocalModel> products);

  /// Delete product by UUID
  Future<void> deleteProduct(String uuid);

  /// Get products pending synchronization
  Future<List<ProductLocalModel>> getPendingSync();

  /// Mark product as pending sync
  Future<void> markForSync(String uuid);

  /// Mark product as synced
  Future<void> markAsSynced(String uuid);

  /// Watch all products (stream)
  Stream<List<ProductLocalModel>> watchAllProducts();

  /// Watch products by category (stream)
  Stream<List<ProductLocalModel>> watchProductsByCategory(ProductCategory category);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final IsarDatabase isarDatabase;

  ProductLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<List<ProductLocalModel>> getAllProducts() async {
    final isar = await isarDatabase.database;
    return await isar.productLocalModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<ProductLocalModel?> getProductByUuid(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.productLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<ProductLocalModel>> getProductsByCategory(ProductCategory category) async {
    final isar = await isarDatabase.database;
    return await isar.productLocalModels
        .filter()
        .categoryEqualTo(category)
        .sortByName()
        .findAll();
  }

  @override
  Future<List<ProductLocalModel>> searchProducts(String query) async {
    final isar = await isarDatabase.database;
    final lowerQuery = query.toLowerCase();
    return await isar.productLocalModels
        .filter()
        .nameContains(lowerQuery, caseSensitive: false)
        .or()
        .descriptionContains(lowerQuery, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  @override
  Future<ProductLocalModel> saveProduct(ProductLocalModel product) async {
    AppLogger.debug('🔄 ProductLocalDataSource: Guardando producto en Isar: ${product.name}');
    
    try {
      final isar = await isarDatabase.database;
      await isar.writeTxn(() async {
        // Check if product exists by uuid
        final existing = await isar.productLocalModels
            .filter()
            .uuidEqualTo(product.uuid)
            .findFirst();

        if (existing != null) {
          // Update: preserve the Isar ID
          product.id = existing.id;
          AppLogger.debug('📝 ProductLocalDataSource: Actualizando producto existente');
        } else {
          AppLogger.debug('➕ ProductLocalDataSource: Creando nuevo producto');
        }

        await isar.productLocalModels.put(product);
      });

      AppLogger.info('✅ ProductLocalDataSource: Producto guardado exitosamente en Isar');
      return product;
    } catch (e) {
      AppLogger.error('❌ ProductLocalDataSource: Error guardando en Isar: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveProducts(List<ProductLocalModel> products) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      for (final product in products) {
        // Check if product exists by uuid
        final existing = await isar.productLocalModels
            .filter()
            .uuidEqualTo(product.uuid)
            .findFirst();

        if (existing != null) {
          // Update: preserve the Isar ID
          product.id = existing.id;
        }
      }

      await isar.productLocalModels.putAll(products);
    });
  }

  @override
  Future<void> deleteProduct(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final product = await isar.productLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (product != null) {
        await isar.productLocalModels.delete(product.id);
      }
    });
  }

  @override
  Future<List<ProductLocalModel>> getPendingSync() async {
    final isar = await isarDatabase.database;
    return await isar.productLocalModels
        .filter()
        .pendingSyncEqualTo(true)
        .findAll();
  }

  @override
  Future<void> markForSync(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final product = await isar.productLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (product != null) {
        product.markForSync();
        await isar.productLocalModels.put(product);
      }
    });
  }

  @override
  Future<void> markAsSynced(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final product = await isar.productLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (product != null) {
        product.markAsSynced();
        await isar.productLocalModels.put(product);
      }
    });
  }

  @override
  Stream<List<ProductLocalModel>> watchAllProducts() async* {
    final isar = await isarDatabase.database;
    yield* isar.productLocalModels
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ProductLocalModel>> watchProductsByCategory(ProductCategory category) async* {
    final isar = await isarDatabase.database;
    yield* isar.productLocalModels
        .filter()
        .categoryEqualTo(category)
        .sortByName()
        .watch(fireImmediately: true);
  }
}
