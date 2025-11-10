part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  final String customerId;

  const CartStarted(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class CartAddInventoryItem extends CartEvent {
  final InventoryItem inventory;
  final int quantity;

  const CartAddInventoryItem({
    required this.inventory,
    required this.quantity,
  });

  @override
  List<Object?> get props => [inventory, quantity];
}

class CartUpdateItemQty extends CartEvent {
  final String cartItemId;
  final int quantity;
  final int availableQuantity;

  const CartUpdateItemQty({
    required this.cartItemId,
    required this.quantity,
    required this.availableQuantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity, availableQuantity];
}

class CartRemoveItemEvent extends CartEvent {
  final String cartItemId;

  const CartRemoveItemEvent(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class CartClearRequested extends CartEvent {
  const CartClearRequested();
}

class CartCheckoutInitiated extends CartEvent {
  final String cartId;

  const CartCheckoutInitiated({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}

class CartSubmitReceipt extends CartEvent {
  final String cartId;
  final String filePath;
  final String? fileName;
  final String? notes;

  const CartSubmitReceipt({
    required this.cartId,
    required this.filePath,
    this.fileName,
    this.notes,
  });

  @override
  List<Object?> get props => [cartId, filePath, fileName, notes];
}

class CartMessageShown extends CartEvent {
  const CartMessageShown();
}

