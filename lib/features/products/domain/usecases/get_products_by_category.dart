import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// UseCase: Obtener productos por categoría
class GetProductsByCategory {
  final ProductRepository repository;

  GetProductsByCategory(this.repository);

  Future<Either<Failure, List<Product>>> call(ProductCategory category) async {
    return await repository.getProductsByCategory(category);
  }

  /// Watch products by category (stream)
  Stream<List<Product>> watch(ProductCategory category) {
    return repository.watchProductsByCategory(category);
  }
}
