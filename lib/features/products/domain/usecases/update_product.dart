import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// UseCase: Actualizar un producto existente
class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.updateProduct(product);
  }
}
