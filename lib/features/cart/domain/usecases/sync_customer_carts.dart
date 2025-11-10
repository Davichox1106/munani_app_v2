import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart_status.dart';
import '../repositories/cart_repository.dart';

class SyncCustomerCarts {
  final CartRepository repository;

  const SyncCustomerCarts(this.repository);

  Future<Either<Failure, int>> call({
    required String customerId,
    List<CartStatus>? statuses,
  }) {
    return repository.syncCustomerCarts(
      customerId: customerId,
      statuses: statuses,
    );
  }
}



