part of 'cart_review_bloc.dart';

abstract class CartReviewEvent extends Equatable {
  const CartReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartsForReview extends CartReviewEvent {
  final String? locationId;
  final String? locationType;

  const LoadCartsForReview({
    this.locationId,
    this.locationType,
  });

  @override
  List<Object?> get props => [locationId, locationType];
}

class ApproveCartRequested extends CartReviewEvent {
  final String cartId;
  final String managerId;
  final String? notes;

  const ApproveCartRequested({
    required this.cartId,
    required this.managerId,
    this.notes,
  });

  @override
  List<Object?> get props => [cartId, managerId, notes];
}

class RejectCartRequested extends CartReviewEvent {
  final String cartId;
  final String managerId;
  final String? notes;

  const RejectCartRequested({
    required this.cartId,
    required this.managerId,
    this.notes,
  });

  @override
  List<Object?> get props => [cartId, managerId, notes];
}

class CartReviewMessageCleared extends CartReviewEvent {
  const CartReviewMessageCleared();
}








