import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/product_repository.dart';

/// UseCase: Eliminar un producto
class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<Either<Failure, void>> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
