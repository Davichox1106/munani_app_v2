import 'package:equatable/equatable.dart';

/// Entidad de dominio para Variante de Producto
///
/// Representa una variante específica de un producto.
/// Ejemplos: "Barrita Proteica - Chocolate", "Barrita Dietética - Frutos Rojos"
///
/// Cada variante tiene su propio SKU único y precio
class ProductVariant extends Equatable {
  final String id; // UUID
  final String productId; // UUID del producto padre
  final String sku; // Código único de la variante
  final String? variantName; // Nombre descriptivo, ej: "Rojo - Grande"
  final Map<String, dynamic>? variantAttributes; // {sabor: 'chocolate', proteinas: '18g', formato: 'pack x12'}
  final double priceSell;
  final double priceBuy;
  final bool isActive;
  final DateTime createdAt;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.sku,
    this.variantName,
    this.variantAttributes,
    required this.priceSell,
    required this.priceBuy,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        sku,
        variantName,
        variantAttributes,
        priceSell,
        priceBuy,
        isActive,
        createdAt,
      ];

  /// Copia de la variante con campos actualizados
  ProductVariant copyWith({
    String? id,
    String? productId,
    String? sku,
    String? variantName,
    Map<String, dynamic>? variantAttributes,
    double? priceSell,
    double? priceBuy,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      variantName: variantName ?? this.variantName,
      variantAttributes: variantAttributes ?? this.variantAttributes,
      priceSell: priceSell ?? this.priceSell,
      priceBuy: priceBuy ?? this.priceBuy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener valor de un atributo específico
  String? getAttribute(String key) {
    if (variantAttributes == null) return null;
    return variantAttributes![key]?.toString();
  }

  /// Verificar si tiene un atributo específico
  bool hasAttribute(String key) {
    if (variantAttributes == null) return false;
    return variantAttributes!.containsKey(key);
  }

  /// Nombre completo de la variante para mostrar
  String get displayName {
    if (variantName != null && variantName!.isNotEmpty) {
      return variantName!;
    }

    // Si no hay nombre, construir desde atributos
    if (variantAttributes != null && variantAttributes!.isNotEmpty) {
      return variantAttributes!.values.join(' - ');
    }

    return sku;
  }
}
