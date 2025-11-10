import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import '../../domain/usecases/add_item_to_cart.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/inputs/cart_add_item_params.dart';
import '../../domain/usecases/remove_cart_item.dart';
import '../../domain/usecases/submit_payment_receipt.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';
import '../../domain/usecases/update_cart_status.dart';
import '../../domain/usecases/watch_active_cart.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final WatchActiveCart watchActiveCart;
  final AddItemToCart addItemToCart;
  final UpdateCartItemQuantity updateCartItemQuantity;
  final RemoveCartItem removeCartItem;
  final ClearCart clearCart;
  final UpdateCartStatus updateCartStatus;
  final SubmitPaymentReceipt submitPaymentReceipt;

  String? _customerId;

  CartBloc({
    required this.watchActiveCart,
    required this.addItemToCart,
    required this.updateCartItemQuantity,
    required this.removeCartItem,
    required this.clearCart,
    required this.updateCartStatus,
    required this.submitPaymentReceipt,
  }) : super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartAddInventoryItem>(_onAddInventoryItem);
    on<CartUpdateItemQty>(_onUpdateItemQty);
    on<CartRemoveItemEvent>(_onRemoveItem);
    on<CartClearRequested>(_onClearCart);
    on<CartCheckoutInitiated>(_onCheckoutInitiated);
    on<CartSubmitReceipt>(_onSubmitReceipt);
    on<CartMessageShown>(_onMessageShown);
  }

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    _customerId = event.customerId;

    await emit.forEach<Either<Failure, Cart?>>(
      watchActiveCart(customerId: event.customerId),
      onData: (result) {
        return result.fold(
          (failure) => state.copyWith(
            status: CartBlocStatus.failure,
            error: failure.message,
          ),
          (cart) => state.copyWith(
            cart: cart,
            status: CartBlocStatus.success,
            clearMessage: true,
            clearError: true,
          ),
        );
      },
      onError: (error, stackTrace) => state.copyWith(
        status: CartBlocStatus.failure,
        error: error.toString(),
      ),
    );
  }

  Future<void> _onAddInventoryItem(
    CartAddInventoryItem event,
    Emitter<CartState> emit,
  ) async {
    final customerId = _customerId;
    if (customerId == null) return;

    emit(state.copyWith(status: CartBlocStatus.loading, clearMessage: true, clearError: true));

    final inventory = event.inventory;
    final params = CartAddItemParams(
      inventoryId: inventory.id,
      productVariantId: inventory.productVariantId,
      productName: inventory.productName,
      variantName: inventory.variantName,
      imageUrls: inventory.imageUrls,
      locationId: inventory.locationId,
      locationType: inventory.locationType,
      locationName: inventory.locationName,
      unitPrice: inventory.unitCost ?? 0,
      availableQuantity: inventory.quantity,
    );

    final result = await addItemToCart(
      customerId: customerId,
      item: params,
      quantity: event.quantity,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartBlocStatus.failure,
          error: failure.message,
        ),
      ),
      (cart) => emit(
        state.copyWith(
          cart: cart,
          status: CartBlocStatus.success,
          message: 'Producto agregado al carrito',
        ),
      ),
    );
  }

  Future<void> _onUpdateItemQty(
    CartUpdateItemQty event,
    Emitter<CartState> emit,
  ) async {
    final customerId = _customerId;
    if (customerId == null) return;

    emit(state.copyWith(status: CartBlocStatus.loading, clearMessage: true, clearError: true));

    final result = await updateCartItemQuantity(
      customerId: customerId,
      cartItemId: event.cartItemId,
      quantity: event.quantity,
      availableQuantity: event.availableQuantity,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartBlocStatus.failure,
          error: failure.message,
        ),
      ),
      (cart) => emit(
        state.copyWith(
          cart: cart,
          status: CartBlocStatus.success,
          message: 'Cantidad actualizada',
        ),
      ),
    );
  }

  Future<void> _onRemoveItem(
    CartRemoveItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final customerId = _customerId;
    if (customerId == null) return;

    emit(state.copyWith(status: CartBlocStatus.loading, clearMessage: true, clearError: true));

    final result = await removeCartItem(
      customerId: customerId,
      cartItemId: event.cartItemId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartBlocStatus.failure,
          error: failure.message,
        ),
      ),
      (cart) => emit(
        state.copyWith(
          cart: cart,
          status: CartBlocStatus.success,
          message: 'Producto eliminado del carrito',
        ),
      ),
    );
  }

  Future<void> _onClearCart(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    final customerId = _customerId;
    if (customerId == null) return;

    emit(state.copyWith(status: CartBlocStatus.loading, clearMessage: true, clearError: true));

    final result = await clearCart(customerId: customerId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartBlocStatus.failure,
          error: failure.message,
        ),
      ),
      (cart) => emit(
        state.copyWith(
          cart: cart,
          status: CartBlocStatus.success,
          message: 'Carrito limpiado',
        ),
      ),
    );
  }

  Future<void> _onCheckoutInitiated(
    CartCheckoutInitiated event,
    Emitter<CartState> emit,
  ) async {
    final customerId = _customerId;
    final cart = state.cart;

    if (customerId == null || cart == null) {
      return;
    }

    if (cart.id != event.cartId ||
        cart.status == CartStatus.awaitingPayment ||
        cart.status == CartStatus.paymentSubmitted ||
        cart.status == CartStatus.completed ||
        cart.status == CartStatus.paymentRejected ||
        cart.status == CartStatus.cancelled) {
      return;
    }

    emit(
      state.copyWith(
        status: CartBlocStatus.loading,
        clearError: true,
        clearMessage: true,
      ),
    );

    final result = await updateCartStatus(
      customerId: customerId,
      cartId: event.cartId,
      status: CartStatus.awaitingPayment,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartBlocStatus.failure,
          error: failure.message,
        ),
      ),
      (updatedCart) => emit(
        state.copyWith(
          cart: updatedCart,
          status: CartBlocStatus.success,
          clearMessage: true,
        ),
      ),
    );
  }

  Future<void> _onSubmitReceipt(
    CartSubmitReceipt event,
    Emitter<CartState> emit,
  ) async {
    final customerId = _customerId;
    if (customerId == null) {
      return;
    }

    emit(
      state.copyWith(
        status: CartBlocStatus.loading,
        clearError: true,
        clearMessage: true,
      ),
    );

    final result = await submitPaymentReceipt(
      customerId: customerId,
      cartId: event.cartId,
      filePath: event.filePath,
      originalFileName: event.fileName,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartBlocStatus.failure,
          error: failure.message,
        ),
      ),
      (updatedCart) => emit(
        state.copyWith(
          cart: updatedCart,
          status: CartBlocStatus.success,
          message: 'Comprobante enviado para revisión',
        ),
      ),
    );
  }

  void _onMessageShown(CartMessageShown event, Emitter<CartState> emit) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }
}

