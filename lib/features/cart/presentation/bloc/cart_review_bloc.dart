import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../inventory/domain/usecases/adjust_inventory.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import '../../domain/repositories/cart_repository.dart';

part 'cart_review_event.dart';
part 'cart_review_state.dart';

class CartReviewBloc extends Bloc<CartReviewEvent, CartReviewState> {
  final CartRepository cartRepository;
  final AdjustInventory adjustInventory;

  CartReviewBloc({
    required this.cartRepository,
    required this.adjustInventory,
  }) : super(const CartReviewState()) {
    on<LoadCartsForReview>(_onLoadCarts);
    on<ApproveCartRequested>(_onApproveCart);
    on<RejectCartRequested>(_onRejectCart);
    on<CartReviewMessageCleared>(_onMessageCleared);
  }

  Future<void> _onLoadCarts(
    LoadCartsForReview event,
    Emitter<CartReviewState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CartReviewStatus.loading,
        filterLocationId: event.locationId,
        filterLocationType: event.locationType,
        clearMessage: true,
        clearError: true,
      ),
    );

    final result = await cartRepository.fetchCartsByStatus(
      status: CartStatus.paymentSubmitted,
      locationId: event.locationId,
      locationType: event.locationType,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartReviewStatus.failure,
          error: failure.message,
        ),
      ),
      (carts) => emit(
        state.copyWith(
          status: CartReviewStatus.success,
          carts: carts,
        ),
      ),
    );
  }

  Future<void> _onApproveCart(
    ApproveCartRequested event,
    Emitter<CartReviewState> emit,
  ) async {
    emit(
      state.copyWith(
        actionInProgress: true,
        clearError: true,
        clearMessage: true,
      ),
    );

    final cartResult = await cartRepository.getCartById(event.cartId);

    final cart = cartResult.fold<Cart?>(
      (failure) {
        emit(
          state.copyWith(
            actionInProgress: false,
            error: failure.message,
          ),
        );
        return null;
      },
      (cart) => cart,
    );

    if (cart == null) return;

    for (final item in cart.items) {
      final adjustResult = await adjustInventory(
        id: item.inventoryId,
        delta: -item.quantity,
        updatedBy: event.managerId,
      );

      if (adjustResult.isLeft()) {
        final failure =
            adjustResult.fold((l) => l, (r) => null)!;
        emit(
          state.copyWith(
            actionInProgress: false,
            error: 'No se pudo ajustar inventario: ${failure.message}',
          ),
        );
        return;
      }
    }

    final receiptsResult = await cartRepository.updatePaymentReceiptsStatus(
      cartId: event.cartId,
      reviewerId: event.managerId,
      status: 'approved',
      notes: event.notes,
    );

    if (receiptsResult.isLeft()) {
      final failure = receiptsResult.fold((l) => l, (r) => null)!;
      emit(
        state.copyWith(
          actionInProgress: false,
          error: failure.message,
        ),
      );
      return;
    }

    final statusResult = await cartRepository.updateStatus(
      customerId: cart.customerId,
      cartId: cart.id,
      status: CartStatus.completed,
    );

    statusResult.fold(
      (failure) => emit(
        state.copyWith(
          actionInProgress: false,
          error: failure.message,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            actionInProgress: false,
            message: 'Pedido aprobado y stock actualizado',
          ),
        );
        add(
          LoadCartsForReview(
            locationId: state.filterLocationId,
            locationType: state.filterLocationType,
          ),
        );
      },
    );
  }

  Future<void> _onRejectCart(
    RejectCartRequested event,
    Emitter<CartReviewState> emit,
  ) async {
    emit(
      state.copyWith(
        actionInProgress: true,
        clearError: true,
        clearMessage: true,
      ),
    );

    final receiptsResult = await cartRepository.updatePaymentReceiptsStatus(
      cartId: event.cartId,
      reviewerId: event.managerId,
      status: 'rejected',
      notes: event.notes,
    );

    if (receiptsResult.isLeft()) {
      final failure = receiptsResult.fold((l) => l, (r) => null)!;
      emit(
        state.copyWith(
          actionInProgress: false,
          error: failure.message,
        ),
      );
      return;
    }

    final cartResult = await cartRepository.getCartById(event.cartId);
    final cart = cartResult.fold<Cart?>(
      (failure) {
        emit(
          state.copyWith(
            actionInProgress: false,
            error: failure.message,
          ),
        );
        return null;
      },
      (cart) => cart,
    );

    if (cart == null) return;

    final statusResult = await cartRepository.updateStatus(
      customerId: cart.customerId,
      cartId: cart.id,
      status: CartStatus.paymentRejected,
    );

    statusResult.fold(
      (failure) => emit(
        state.copyWith(
          actionInProgress: false,
          error: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            actionInProgress: false,
            message: 'Pedido marcado como rechazado',
          ),
        );
        add(
          LoadCartsForReview(
            locationId: state.filterLocationId,
            locationType: state.filterLocationType,
          ),
        );
      },
    );
  }

  void _onMessageCleared(
    CartReviewMessageCleared event,
    Emitter<CartReviewState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }
}

