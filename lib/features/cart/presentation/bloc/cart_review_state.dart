part of 'cart_review_bloc.dart';

enum CartReviewStatus { initial, loading, success, failure }

class CartReviewState extends Equatable {
  final CartReviewStatus status;
  final List<Cart> carts;
  final String? message;
  final String? error;
  final bool actionInProgress;
  final String? filterLocationId;
  final String? filterLocationType;

  const CartReviewState({
    this.status = CartReviewStatus.initial,
    this.carts = const [],
    this.message,
    this.error,
    this.actionInProgress = false,
    this.filterLocationId,
    this.filterLocationType,
  });

  CartReviewState copyWith({
    CartReviewStatus? status,
    List<Cart>? carts,
    String? message,
    String? error,
    bool? actionInProgress,
    String? filterLocationId,
    String? filterLocationType,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return CartReviewState(
      status: status ?? this.status,
      carts: carts ?? this.carts,
      message: clearMessage ? null : message ?? this.message,
      error: clearError ? null : error ?? this.error,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      filterLocationId: filterLocationId ?? this.filterLocationId,
      filterLocationType: filterLocationType ?? this.filterLocationType,
    );
  }

  @override
  List<Object?> get props => [
        status,
        carts,
        message,
        error,
        actionInProgress,
        filterLocationId,
        filterLocationType,
      ];
}








