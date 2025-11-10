import '../../domain/entities/sale_item.dart';

class SaleItemRemoteModel {
  final String id;
  final String saleId;
  final String productVariantId;
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;

  SaleItemRemoteModel({
    required this.id,
    required this.saleId,
    required this.productVariantId,
    required this.productName,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
  });

  factory SaleItemRemoteModel.fromJson(Map<String, dynamic> json) {
    return SaleItemRemoteModel(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      productVariantId: json['product_variant_id'] as String,
      productName: (json['product_name'] ?? '') as String,
      variantName: json['variant_name'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_variant_id': productVariantId,
      'product_name': productName,
      'variant_name': variantName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SaleItem toEntity() => SaleItem(
        id: id,
        saleId: saleId,
        productVariantId: productVariantId,
        productName: productName,
        variantName: variantName,
        quantity: quantity,
        unitPrice: unitPrice,
        subtotal: subtotal,
        createdAt: createdAt,
      );

  static SaleItemRemoteModel fromEntity(SaleItem e) => SaleItemRemoteModel(
        id: e.id,
        saleId: e.saleId,
        productVariantId: e.productVariantId,
        productName: e.productName,
        variantName: e.variantName,
        quantity: e.quantity,
        unitPrice: e.unitPrice,
        subtotal: e.subtotal,
        createdAt: e.createdAt,
      );
}
