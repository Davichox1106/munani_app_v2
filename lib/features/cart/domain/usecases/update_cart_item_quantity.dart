import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantity {
  final CartRepository repository;

  const UpdateCartItemQuantity(this.repository);

  Future<Either<Failure, Cart>> call({
    required String customerId,
    required String cartItemId,
    required int quantity,
    required int availableQuantity,
  }) {
    return repository.updateItemQuantity(
      customerId: customerId,
      cartItemId: cartItemId,
      quantity: quantity,
      availableQuantity: availableQuantity,
    );
  }
}








