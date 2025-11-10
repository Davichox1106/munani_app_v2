import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_variant.dart';
import '../repositories/product_variant_repository.dart';

/// Use Case: Obtener variantes por producto
class GetVariantsByProduct {
  final ProductVariantRepository repository;

  GetVariantsByProduct(this.repository);

  Stream<Either<Failure, List<ProductVariant>>> call(String productId) {
    return repository.watchVariantsByProduct(productId).map((variants) => Right(variants));
  }
}
