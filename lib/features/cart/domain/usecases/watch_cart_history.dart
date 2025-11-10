import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_status.dart';
import '../repositories/cart_repository.dart';

class WatchCartHistory {
  final CartRepository repository;

  const WatchCartHistory(this.repository);

  Stream<Either<Failure, List<Cart>>> call({
    required String customerId,
    List<CartStatus>? statuses,
  }) {
    return repository.watchCustomerCartHistory(
      customerId: customerId,
      statuses: statuses,
    );
  }
}



