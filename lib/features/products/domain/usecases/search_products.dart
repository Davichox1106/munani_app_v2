import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// UseCase: Buscar productos por nombre o descripción
class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<Either<Failure, List<Product>>> call(String query) async {
    // Validar query
    if (query.trim().isEmpty) {
      // Si está vacío, retornar todos
      return await repository.getAllProducts();
    }

    return await repository.searchProducts(query.trim());
  }
}
