import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_status.dart';
import '../usecases/inputs/cart_add_item_params.dart';

abstract class CartRepository {
  Stream<Either<Failure, Cart?>> watchActiveCart({
    required String customerId,
  });

  Stream<Either<Failure, List<Cart>>> watchCustomerCartHistory({
    required String customerId,
    List<CartStatus>? statuses,
  });

  Future<Either<Failure, Cart>> addItem({
    required String customerId,
    required CartAddItemParams item,
    required int quantity,
  });

  Future<Either<Failure, Cart>> updateItemQuantity({
    required String customerId,
    required String cartItemId,
    required int quantity,
    required int availableQuantity,
  });

  Future<Either<Failure, Cart>> removeItem({
    required String customerId,
    required String cartItemId,
  });

  Future<Either<Failure, Cart>> clearCart({
    required String customerId,
  });

  Future<Either<Failure, Cart>> updateStatus({
    required String customerId,
    required String cartId,
    required CartStatus status,
  });

  Future<Either<Failure, Cart>> submitPaymentReceipt({
    required String customerId,
    required String cartId,
    required String filePath,
    String? originalFileName,
    String? notes,
  });

  Future<Either<Failure, List<Cart>>> fetchCartsByStatus({
    required CartStatus status,
    String? locationId,
    String? locationType,
  });

  Future<Either<Failure, Cart>> getCartById(String cartId);

  Future<Either<Failure, void>> updatePaymentReceiptsStatus({
    required String cartId,
    required String reviewerId,
    required String status,
    String? notes,
  });

  Future<Either<Failure, String>> createReceiptDownloadUrl({
    required String storagePath,
    Duration expiresIn,
  });

  Future<Either<Failure, int>> syncCustomerCarts({
    required String customerId,
    List<CartStatus>? statuses,
  });

  Future<Either<Failure, int>> syncManagerCarts({
    String? locationId,
    String? locationType,
    List<CartStatus> statuses = const [
      CartStatus.awaitingPayment,
      CartStatus.paymentSubmitted,
      CartStatus.paymentRejected,
    ],
  });
}

