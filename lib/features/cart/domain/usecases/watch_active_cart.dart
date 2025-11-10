import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class WatchActiveCart {
  final CartRepository repository;

  const WatchActiveCart(this.repository);

  Stream<Either<Failure, Cart?>> call({
    required String customerId,
  }) {
    return repository.watchActiveCart(customerId: customerId);
  }
}








