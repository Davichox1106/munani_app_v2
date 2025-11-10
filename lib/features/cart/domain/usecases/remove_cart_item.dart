import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItem {
  final CartRepository repository;

  const RemoveCartItem(this.repository);

  Future<Either<Failure, Cart>> call({
    required String customerId,
    required String cartItemId,
  }) {
    return repository.removeItem(
      customerId: customerId,
      cartItemId: cartItemId,
    );
  }
}








