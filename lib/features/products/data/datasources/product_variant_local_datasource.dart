import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_variant_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Contrato para el data source local de variantes de productos
abstract class ProductVariantLocalDataSource {
  /// Guardar una variante en Isar
  Future<void> saveVariant(ProductVariantLocalModel variant);

  /// Guardar múltiples variantes en Isar
  Future<void> saveVariants(List<ProductVariantLocalModel> variants);

  /// Obtener todas las variantes
  Future<List<ProductVariantLocalModel>> getAllVariants();

  /// Obtener variantes por producto
  Future<List<ProductVariantLocalModel>> getVariantsByProduct(String productId);

  /// Obtener variante por ID
  Future<ProductVariantLocalModel?> getVariantById(String id);

  /// Actualizar variante
  Future<void> updateVariant(ProductVariantLocalModel variant);

  /// Eliminar variante
  Future<void> deleteVariant(String id);

  /// Limpiar todas las variantes
  Future<void> clearAllVariants();

  /// Obtener variantes pendientes de sincronización
  Future<List<ProductVariantLocalModel>> getPendingSyncVariants();

  /// Watch todas las variantes (stream)
  Stream<List<ProductVariantLocalModel>> watchAllVariants();

  /// Watch variantes por producto (stream)
  Stream<List<ProductVariantLocalModel>> watchVariantsByProduct(String productId);
}

/// Implementación del data source local usando Isar
///
/// Almacena las variantes de productos localmente para:
/// 1. Acceso offline a variantes
/// 2. Sincronización con Supabase
/// 3. Offline-First: priorizar datos locales
class ProductVariantLocalDataSourceImpl implements ProductVariantLocalDataSource {
  final IsarDatabase isarDatabase;

  ProductVariantLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<void> saveVariant(ProductVariantLocalModel variant) async {
    try {
      final isar = await isarDatabase.database;
      await isar.writeTxn(() async {
        // Buscar variante existente por UUID
        final existing = await isar.productVariantLocalModels
            .filter()
            .uuidEqualTo(variant.uuid)
            .findFirst();

        if (existing != null) {
          // Mantener el ID de Isar existente para actualizar el mismo registro
          variant.id = existing.id;
        }

        await isar.productVariantLocalModels.put(variant);
      });
      AppLogger.debug('💾 Variante guardada en Isar: ${variant.sku}');
    } catch (e) {
      throw CacheException('Error al guardar variante: $e');
    }
  }

  @override
  Future<void> saveVariants(List<ProductVariantLocalModel> variants) async {
    try {
      final isar = await isarDatabase.database;
      await isar.writeTxn(() async {
        await isar.productVariantLocalModels.putAll(variants);
      });
      AppLogger.debug('💾 ${variants.length} variantes guardadas en Isar');
    } catch (e) {
      throw CacheException('Error al guardar variantes: $e');
    }
  }

  @override
  Future<List<ProductVariantLocalModel>> getAllVariants() async {
    try {
      final isar = await isarDatabase.database;
      return await isar.productVariantLocalModels.where().findAll();
    } catch (e) {
      throw CacheException('Error al obtener variantes: $e');
    }
  }

  @override
  Future<List<ProductVariantLocalModel>> getVariantsByProduct(String productId) async {
    try {
      final isar = await isarDatabase.database;
      return await isar.productVariantLocalModels
          .filter()
          .productIdEqualTo(productId)
          .findAll();
    } catch (e) {
      throw CacheException('Error al obtener variantes por producto: $e');
    }
  }

  @override
  Future<ProductVariantLocalModel?> getVariantById(String id) async {
    try {
      final isar = await isarDatabase.database;
      return await isar.productVariantLocalModels
          .filter()
          .uuidEqualTo(id)
          .findFirst();
    } catch (e) {
      throw CacheException('Error al obtener variante por ID: $e');
    }
  }

  @override
  Future<void> updateVariant(ProductVariantLocalModel variant) async {
    try {
      final isar = await isarDatabase.database;
      await isar.writeTxn(() async {
        // Buscar la variante existente por UUID
        final existing = await isar.productVariantLocalModels
            .filter()
            .uuidEqualTo(variant.uuid)
            .findFirst();

        if (existing != null) {
          // Mantener el ID de Isar existente para actualizar el mismo registro
          variant.id = existing.id;
        }

        await isar.productVariantLocalModels.put(variant);
      });
      AppLogger.debug('💾 Variante actualizada en Isar: ${variant.sku}');
    } catch (e) {
      throw CacheException('Error al actualizar variante: $e');
    }
  }

  @override
  Future<void> deleteVariant(String id) async {
    try {
      final isar = await isarDatabase.database;
      await isar.writeTxn(() async {
        await isar.productVariantLocalModels
            .filter()
            .uuidEqualTo(id)
            .deleteAll();
      });
      AppLogger.debug('💾 Variante eliminada de Isar: $id');
    } catch (e) {
      throw CacheException('Error al eliminar variante: $e');
    }
  }

  @override
  Future<void> clearAllVariants() async {
    try {
      final isar = await isarDatabase.database;
      await isar.writeTxn(() async {
        await isar.productVariantLocalModels.clear();
      });
      AppLogger.debug('💾 Todas las variantes eliminadas de Isar');
    } catch (e) {
      throw CacheException('Error al limpiar variantes: $e');
    }
  }

  @override
  Future<List<ProductVariantLocalModel>> getPendingSyncVariants() async {
    try {
      final isar = await isarDatabase.database;
      return await isar.productVariantLocalModels
          .filter()
          .pendingSyncEqualTo(true)
          .findAll();
    } catch (e) {
      throw CacheException('Error al obtener variantes pendientes: $e');
    }
  }

  @override
  Stream<List<ProductVariantLocalModel>> watchAllVariants() async* {
    try {
      final isar = await isarDatabase.database;
      yield* isar.productVariantLocalModels
          .where()
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException('Error al observar variantes: $e');
    }
  }

  @override
  Stream<List<ProductVariantLocalModel>> watchVariantsByProduct(String productId) async* {
    try {
      final isar = await isarDatabase.database;
      yield* isar.productVariantLocalModels
          .filter()
          .productIdEqualTo(productId)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException('Error al observar variantes por producto: $e');
    }
  }
}
