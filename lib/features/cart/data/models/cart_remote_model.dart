import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_status.dart';
import '../../domain/entities/payment_receipt.dart';

class CartRemoteModel {
  final String id;
  final String customerId;
  final CartStatus status;
  final String? customerName;
  final String? customerEmail;
  final String? locationId;
  final String? locationType;
  final String? locationName;
  final int totalItems;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItemRemoteModel> items;
  final List<PaymentReceiptRemoteModel> receipts;

  const CartRemoteModel({
    required this.id,
    required this.customerId,
    required this.status,
    this.customerName,
    this.customerEmail,
    this.locationId,
    this.locationType,
    this.locationName,
    required this.totalItems,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.receipts = const [],
  });

  factory CartRemoteModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['cart_items'] as List<dynamic>? ?? const [];
    final rawReceipts = json['payment_receipts'] as List<dynamic>? ?? const [];

    final customerData = json['customers'] as Map<String, dynamic>?;

    return CartRemoteModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      status: CartStatusX.fromValue(json['status'] as String),
      customerName: customerData != null ? customerData['name'] as String? : null,
      customerEmail:
          customerData != null ? customerData['email'] as String? : null,
      locationId: json['location_id'] as String?,
      locationType: json['location_type'] as String?,
      locationName: json['location_name'] as String?,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: rawItems
          .map((item) =>
              CartItemRemoteModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      receipts: rawReceipts
          .map((receipt) => PaymentReceiptRemoteModel.fromJson(
              Map<String, dynamic>.from(receipt)))
          .toList(),
    );
  }

  Cart toEntity() {
    return Cart(
      id: id,
      customerId: customerId,
      status: status,
      customerName: customerName,
      customerEmail: customerEmail,
      locationId: locationId,
      locationType: locationType,
      locationName: locationName,
      totalItems: totalItems,
      subtotal: subtotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items.map((item) => item.toEntity(id)).toList(),
      receipts: receipts.map((receipt) => receipt.toEntity()).toList(),
    );
  }
}

class CartItemRemoteModel {
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

  const CartItemRemoteModel({
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

  factory CartItemRemoteModel.fromJson(Map<String, dynamic> json) {
    return CartItemRemoteModel(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      inventoryId: json['inventory_id'] as String,
      productVariantId: json['product_variant_id'] as String,
      productName: json['product_name'] as String?,
      variantName: json['variant_name'] as String?,
      imageUrls: _mapToStringList(json['image_urls']),
      quantity: (json['quantity'] as num).toInt(),
      availableQuantity: (json['available_quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  CartItem toEntity(String cartId) {
    return CartItem(
      id: id,
      cartId: cartId,
      inventoryId: inventoryId,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      imageUrls: imageUrls,
      quantity: quantity,
      availableQuantity: availableQuantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PaymentReceiptRemoteModel {
  final String id;
  final String cartId;
  final String uploadedBy;
  final String storagePath;
  final String status;
  final String? notes;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const PaymentReceiptRemoteModel({
    required this.id,
    required this.cartId,
    required this.uploadedBy,
    required this.storagePath,
    required this.status,
    this.notes,
    this.reviewedBy,
    required this.createdAt,
    this.reviewedAt,
  });

  factory PaymentReceiptRemoteModel.fromJson(Map<String, dynamic> json) {
    return PaymentReceiptRemoteModel(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      uploadedBy: json['uploaded_by'] as String,
      storagePath: json['storage_path'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  PaymentReceipt toEntity() {
    return PaymentReceipt(
      id: id,
      storagePath: storagePath,
      status: status,
      notes: notes,
      uploadedBy: uploadedBy,
      createdAt: createdAt,
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt,
    );
  }
}

List<String> _mapToStringList(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return const [];
}








