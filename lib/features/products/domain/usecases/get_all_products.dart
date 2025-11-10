import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// UseCase: Obtener todos los productos
///
/// Retorna lista de productos desde local,
/// sincroniza en background si hay conexión
class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getAllProducts();
  }

  /// Watch products (stream for real-time updates)
  Stream<List<Product>> watch() {
    return repository.watchAllProducts();
  }
}
