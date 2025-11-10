import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String cartId;
  final String inventoryId;
  final String productVariantId;
  final String? productName;
  final String? variantName;
  final List<String> imageUrls;
  final int quantity;
  final int availableQuantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.inventoryId,
    required this.productVariantId,
    this.productName,
    this.variantName,
    this.imageUrls = const [],
    required this.quantity,
    required this.availableQuantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  CartItem copyWith({
    String? id,
    String? cartId,
    String? inventoryId,
    String? productVariantId,
    String? productName,
    String? variantName,
    List<String>? imageUrls,
    int? quantity,
    int? availableQuantity,
    double? unitPrice,
    double? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      inventoryId: inventoryId ?? this.inventoryId,
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      imageUrls: imageUrls ?? this.imageUrls,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cartId,
        inventoryId,
        productVariantId,
        productName,
        variantName,
        imageUrls,
        quantity,
        availableQuantity,
        unitPrice,
        subtotal,
        createdAt,
        updatedAt,
      ];
}








