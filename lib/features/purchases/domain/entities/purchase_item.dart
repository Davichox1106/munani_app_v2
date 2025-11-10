import 'package:equatable/equatable.dart';

/// Entidad que representa un ítem individual dentro de una compra
class PurchaseItem extends Equatable {
  final String id;
  final String purchaseId;
  final String productVariantId;
  final String productName;
  final String variantName;
  final int quantity;
  final double unitCost;
  final double subtotal;
  final DateTime createdAt;

  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
    required this.createdAt,
  });

  /// Crea una copia con nuevos valores
  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productVariantId,
    String? productName,
    String? variantName,
    int? quantity,
    double? unitCost,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calcula el subtotal basado en cantidad y costo unitario
  static double calculateSubtotal(int quantity, double unitCost) {
    return quantity * unitCost;
  }

  /// Obtiene el nombre completo del producto (producto + variante)
  String get fullProductName {
    return '$productName - $variantName';
  }

  @override
  List<Object?> get props => [
        id,
        purchaseId,
        productVariantId,
        productName,
        variantName,
        quantity,
        unitCost,
        subtotal,
        createdAt,
      ];
}
