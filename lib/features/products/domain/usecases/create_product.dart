import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// UseCase: Crear un nuevo producto
///
/// Guarda localmente primero (offline-first),
/// luego encola para sincronización
class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Either<Failure, Product>> call({
    required String name,
    String? description,
    required ProductCategory category,
    required double basePriceSell,
    required double basePriceBuy,
    required bool hasVariants,
    required List<String> imageUrls,
    required String createdBy,
  }) async {
    return await repository.createProduct(
      name: name,
      description: description,
      category: category,
      basePriceSell: basePriceSell,
      basePriceBuy: basePriceBuy,
      hasVariants: hasVariants,
      imageUrls: imageUrls,
      createdBy: createdBy,
    );
  }
}
