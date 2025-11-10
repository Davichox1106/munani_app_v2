import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';

/// Repository interface for Product operations
/// Implements offline-first strategy:
/// - Write operations: save locally first, then queue for sync
/// - Read operations: read from local, sync in background
abstract class ProductRepository {
  /// Get all products
  /// Returns local data immediately, syncs in background
  Future<Either<Failure, List<Product>>> getAllProducts();

  /// Get product by ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Get products by category
  Future<Either<Failure, List<Product>>> getProductsByCategory(ProductCategory category);

  /// Search products by name
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Create new product
  /// Saves locally first, then queues for sync
  Future<Either<Failure, Product>> createProduct({
    required String name,
    String? description,
    required ProductCategory category,
    required double basePriceSell,
    required double basePriceBuy,
    required bool hasVariants,
    required List<String> imageUrls,
    required String createdBy,
  });

  /// Update existing product
  /// Saves locally first, then queues for sync
  Future<Either<Failure, Product>> updateProduct(Product product);

  /// Delete product
  /// Deletes locally first, then queues for sync
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Sync products from remote to local
  /// Fetches all products from Supabase and updates local database
  Future<Either<Failure, void>> syncFromRemote();

  /// Watch all products (stream)
  Stream<List<Product>> watchAllProducts();

  /// Watch products by category (stream)
  Stream<List<Product>> watchProductsByCategory(ProductCategory category);
}
