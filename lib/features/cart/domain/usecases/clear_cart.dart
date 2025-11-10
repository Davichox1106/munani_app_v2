import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class ClearCart {
  final CartRepository repository;

  const ClearCart(this.repository);

  Future<Either<Failure, Cart>> call({
    required String customerId,
  }) {
    return repository.clearCart(customerId: customerId);
  }
}








