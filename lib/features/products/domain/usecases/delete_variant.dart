import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/product_variant_repository.dart';

/// Use Case: Eliminar variante
class DeleteVariant {
  final ProductVariantRepository repository;

  DeleteVariant(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteVariant(id);
  }
}
