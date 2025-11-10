import 'package:equatable/equatable.dart';

/// Entidad de dominio para Producto
///
/// Representa un producto base en el sistema de inventario.
/// Los productos pueden tener variantes (colores, tamaños, etc.)
///
/// Categorías disponibles: barritas_nutritivas, barritas_proteicas, barritas_dieteticas, otros
class Product extends Equatable {
  final String id; // UUID
  final String name;
  final String? description;
  final ProductCategory category;
  final double basePriceSell;
  final double basePriceBuy;
  final bool hasVariants;
  final List<String> imageUrls;
  final String createdBy; // UUID del usuario que lo creó
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.basePriceSell,
    required this.basePriceBuy,
    required this.hasVariants,
    this.imageUrls = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        basePriceSell,
        basePriceBuy,
        hasVariants,
        imageUrls,
        createdBy,
        createdAt,
        updatedAt,
      ];

  /// Copia del producto con campos actualizados
  Product copyWith({
    String? id,
    String? name,
    String? description,
    ProductCategory? category,
    double? basePriceSell,
    double? basePriceBuy,
    bool? hasVariants,
    List<String>? imageUrls,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      basePriceSell: basePriceSell ?? this.basePriceSell,
      basePriceBuy: basePriceBuy ?? this.basePriceBuy,
      hasVariants: hasVariants ?? this.hasVariants,
      imageUrls: imageUrls ?? this.imageUrls,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Categorías de productos disponibles
enum ProductCategory {
  barritasNutritivas,
  barritasProteicas,
  barritasDieteticas,
  otros,
}

/// Extensión para convertir ProductCategory a String y viceversa
extension ProductCategoryExtension on ProductCategory {
  String get value {
    switch (this) {
      case ProductCategory.barritasNutritivas:
        return 'barritas_nutritivas';
      case ProductCategory.barritasProteicas:
        return 'barritas_proteicas';
      case ProductCategory.barritasDieteticas:
        return 'barritas_dieteticas';
      case ProductCategory.otros:
        return 'otros';
    }
  }

  String get displayName {
    switch (this) {
      case ProductCategory.barritasNutritivas:
        return 'Barritas Nutritivas';
      case ProductCategory.barritasProteicas:
        return 'Barritas Proteicas';
      case ProductCategory.barritasDieteticas:
        return 'Barritas Dietéticas';
      case ProductCategory.otros:
        return 'Otros';
    }
  }

  static ProductCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'barritas_nutritivas':
      case 'barritas nutritivas':
        return ProductCategory.barritasNutritivas;
      case 'barritas_proteicas':
      case 'barritas proteicas':
        return ProductCategory.barritasProteicas;
      case 'barritas_dieteticas':
      case 'barritas dieteticas':
      case 'barritas dietéticas':
        return ProductCategory.barritasDieteticas;
      case 'otros':
      default:
        return ProductCategory.otros;
    }
  }
}
