import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/product_variant_local_model.dart';

/// Datasource local para variantes de producto (Isar)
abstract class VariantLocalDataSource {
  /// Obtener variantes por producto
  Stream<List<ProductVariantLocalModel>> watchVariantsByProduct(String productId);

  /// Obtener variante por UUID
  Future<ProductVariantLocalModel?> getVariantByUuid(String uuid);

  /// Guardar variante (insert o update)
  Future<ProductVariantLocalModel> saveVariant(ProductVariantLocalModel variant);

  /// Eliminar variante por UUID
  Future<void> deleteVariant(String uuid);
}

class VariantLocalDataSourceImpl implements VariantLocalDataSource {
  final IsarDatabase isarDatabase;

  VariantLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<ProductVariantLocalModel>> watchVariantsByProduct(String productId) async* {
    final isar = await isarDatabase.database;

    yield* isar.productVariantLocalModels
        .filter()
        .productIdEqualTo(productId)
        .watch(fireImmediately: true);
  }

  @override
  Future<ProductVariantLocalModel?> getVariantByUuid(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.productVariantLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<ProductVariantLocalModel> saveVariant(ProductVariantLocalModel variant) async {
    final isar = await isarDatabase.database;

    await isar.writeTxn(() async {
      await isar.productVariantLocalModels.put(variant);
    });

    return variant;
  }

  @override
  Future<void> deleteVariant(String uuid) async {
    final isar = await isarDatabase.database;

    final variant = await getVariantByUuid(uuid);
    if (variant != null) {
      await isar.writeTxn(() async {
        await isar.productVariantLocalModels.delete(variant.id);
      });
    }
  }
}
