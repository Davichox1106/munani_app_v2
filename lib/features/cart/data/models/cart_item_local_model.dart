import 'package:isar/isar.dart';

import '../../domain/entities/cart_item.dart';

part 'cart_item_local_model.g.dart';

@collection
class CartItemLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String cartId;

  @Index()
  late String inventoryId;

  late String productVariantId;
  String? productName;
  String? variantName;
  List<String> imageUrls = [];
  late int quantity;
  late int availableQuantity;
  late double unitPrice;
  late double subtotal;
  late DateTime createdAt;
  late DateTime updatedAt;

  CartItemLocalModel();

  CartItemLocalModel.fromEntity(CartItem item) {
    uuid = item.id;
    cartId = item.cartId;
    inventoryId = item.inventoryId;
    productVariantId = item.productVariantId;
    productName = item.productName;
    variantName = item.variantName;
    imageUrls = List<String>.from(item.imageUrls);
    quantity = item.quantity;
    availableQuantity = item.availableQuantity;
    unitPrice = item.unitPrice;
    subtotal = item.subtotal;
    createdAt = item.createdAt;
    updatedAt = item.updatedAt;
  }

  CartItem toEntity() {
    return CartItem(
      id: uuid,
      cartId: cartId,
      inventoryId: inventoryId,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      imageUrls: List<String>.from(imageUrls),
      quantity: quantity,
      availableQuantity: availableQuantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}








