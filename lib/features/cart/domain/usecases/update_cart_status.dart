import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_status.dart';
import '../repositories/cart_repository.dart';

class UpdateCartStatus {
  final CartRepository repository;

  const UpdateCartStatus(this.repository);

  Future<Either<Failure, Cart>> call({
    required String customerId,
    required String cartId,
    required CartStatus status,
  }) {
    return repository.updateStatus(
      customerId: customerId,
      cartId: cartId,
      status: status,
    );
  }
}








