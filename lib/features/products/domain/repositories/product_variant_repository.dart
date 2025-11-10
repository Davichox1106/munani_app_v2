import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_variant.dart';

/// Repository interface for ProductVariant operations
/// Implements offline-first strategy:
/// - Write operations: save locally first, then queue for sync
/// - Read operations: read from local, sync in background
abstract class ProductVariantRepository {
  /// Get all variants
  /// Returns local data immediately, syncs in background
  Future<Either<Failure, List<ProductVariant>>> getAllVariants();

  /// Get variants by product ID
  Future<Either<Failure, List<ProductVariant>>> getVariantsByProduct(String productId);

  /// Get variant by ID
  Future<Either<Failure, ProductVariant>> getVariantById(String id);

  /// Create new variant
  /// Saves locally first, then queues for sync
  Future<Either<Failure, ProductVariant>> createVariant({
    required String productId,
    required String sku,
    String? variantName,
    Map<String, dynamic>? variantAttributes,
    required double priceSell,
    required double priceBuy,
    required bool isActive,
  });

  /// Update existing variant
  /// Saves locally first, then queues for sync
  Future<Either<Failure, ProductVariant>> updateVariant(ProductVariant variant);

  /// Delete variant
  /// Deletes locally first, then queues for sync
  Future<Either<Failure, void>> deleteVariant(String id);

  /// Sync variants from remote to local
  /// Fetches all variants from Supabase and updates local database
  Future<Either<Failure, void>> syncFromRemote();

  /// Watch all variants (stream)
  Stream<List<ProductVariant>> watchAllVariants();

  /// Watch variants by product (stream)
  Stream<List<ProductVariant>> watchVariantsByProduct(String productId);
}