part of 'cart_bloc.dart';

enum CartBlocStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final Cart? cart;
  final CartBlocStatus status;
  final String? message;
  final String? error;
  final bool locationConflict;

  const CartState({
    this.cart,
    this.status = CartBlocStatus.initial,
    this.message,
    this.error,
    this.locationConflict = false,
  });

  CartState copyWith({
    Cart? cart,
    CartBlocStatus? status,
    String? message,
    String? error,
    bool? locationConflict,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      error: clearError ? null : error ?? this.error,
      locationConflict: locationConflict ?? this.locationConflict,
    );
  }

  @override
  List<Object?> get props => [cart, status, message, error, locationConflict];
}








