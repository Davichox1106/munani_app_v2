import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';
import 'inputs/cart_add_item_params.dart';

class AddItemToCart {
  final CartRepository repository;

  const AddItemToCart(this.repository);

  Future<Either<Failure, Cart>> call({
    required String customerId,
    required CartAddItemParams item,
    required int quantity,
  }) {
    return repository.addItem(
      customerId: customerId,
      item: item,
      quantity: quantity,
    );
  }
}








