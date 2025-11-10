import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_variant.dart';
import '../repositories/product_variant_repository.dart';

/// Use Case: Crear variante de producto
class CreateVariant {
  final ProductVariantRepository repository;

  CreateVariant(this.repository);

  Future<Either<Failure, ProductVariant>> call({
    required String productId,
    required String sku,
    String? variantName,
    Map<String, dynamic>? variantAttributes,
    required double priceSell,
    required double priceBuy,
    bool isActive = true,
  }) {
    return repository.createVariant(
      productId: productId,
      sku: sku,
      variantName: variantName,
      variantAttributes: variantAttributes,
      priceSell: priceSell,
      priceBuy: priceBuy,
      isActive: isActive,
    );
  }
}
