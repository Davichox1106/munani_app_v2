import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class SubmitPaymentReceipt {
  final CartRepository repository;

  const SubmitPaymentReceipt(this.repository);

  Future<Either<Failure, Cart>> call({
    required String customerId,
    required String cartId,
    required String filePath,
    String? originalFileName,
    String? notes,
  }) {
    return repository.submitPaymentReceipt(
      customerId: customerId,
      cartId: cartId,
      filePath: filePath,
      originalFileName: originalFileName,
      notes: notes,
    );
  }
}








