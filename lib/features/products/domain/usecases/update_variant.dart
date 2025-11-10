import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_variant.dart';
import '../repositories/product_variant_repository.dart';

/// Use Case: Actualizar variante
class UpdateVariant {
  final ProductVariantRepository repository;

  UpdateVariant(this.repository);

  Future<Either<Failure, ProductVariant>> call(ProductVariant variant) {
    return repository.updateVariant(variant);
  }
}
