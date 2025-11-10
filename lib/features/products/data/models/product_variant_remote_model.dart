import '../../domain/entities/product_variant.dart';

/// Remote model for ProductVariant (Supabase)
/// Maps to/from JSON for API communication
class ProductVariantRemoteModel {
  final String id;
  final String productId;
  final String sku;
  final String? variantName;
  final Map<String, dynamic>? variantAttributes;
  final double priceSell;
  final double priceBuy;
  final bool isActive;
  final DateTime createdAt;

  const ProductVariantRemoteModel({
    required this.id,
    required this.productId,
    required this.sku,
    this.variantName,
    this.variantAttributes,
    required this.priceSell,
    required this.priceBuy,
    required this.isActive,
    required this.createdAt,
  });

  /// Convert from Supabase JSON to remote model
  factory ProductVariantRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantRemoteModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      sku: json['sku'] as String,
      variantName: json['variant_name'] as String?,
      variantAttributes: json['variant_attributes'] != null
          ? Map<String, dynamic>.from(json['variant_attributes'] as Map)
          : null,
      priceSell: (json['price_sell'] as num).toDouble(),
      priceBuy: (json['price_buy'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'sku': sku,
      'variant_name': variantName,
      'variant_attributes': variantAttributes,
      'price_sell': priceSell,
      'price_buy': priceBuy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert remote model to domain entity
  ProductVariant toEntity() {
    return ProductVariant(
      id: id,
      productId: productId,
      sku: sku,
      variantName: variantName,
      variantAttributes: variantAttributes,
      priceSell: priceSell,
      priceBuy: priceBuy,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Create remote model from domain entity
  factory ProductVariantRemoteModel.fromEntity(ProductVariant variant) {
    return ProductVariantRemoteModel(
      id: variant.id,
      productId: variant.productId,
      sku: variant.sku,
      variantName: variant.variantName,
      variantAttributes: variant.variantAttributes,
      priceSell: variant.priceSell,
      priceBuy: variant.priceBuy,
      isActive: variant.isActive,
      createdAt: variant.createdAt,
    );
  }
}
