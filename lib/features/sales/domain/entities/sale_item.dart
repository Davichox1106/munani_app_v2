import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String productVariantId;
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;

  const SaleItem({
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

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productVariantId,
    String? productName,
    String? variantName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        saleId,
        productVariantId,
        productName,
        variantName,
        quantity,
        unitPrice,
        subtotal,
        createdAt,
      ];
}
