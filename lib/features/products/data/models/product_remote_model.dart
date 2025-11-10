import 'dart:convert';

import '../../domain/entities/product.dart';

/// Remote model for Product (Supabase)
/// Maps to/from JSON for API communication
class ProductRemoteModel {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double basePriceSell;
  final double basePriceBuy;
  final bool hasVariants;
  final List<String> imageUrls;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductRemoteModel({
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

  /// Convert from Supabase JSON to remote model
  factory ProductRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProductRemoteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      basePriceSell: (json['base_price_sell'] as num).toDouble(),
      basePriceBuy: (json['base_price_buy'] as num).toDouble(),
      hasVariants: json['has_variants'] as bool,
      imageUrls: _decodeImageUrls(json['image_urls']),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'base_price_sell': basePriceSell,
      'base_price_buy': basePriceBuy,
      'has_variants': hasVariants,
      'image_urls': imageUrls,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert remote model to domain entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      category: _categoryFromString(category),
      basePriceSell: basePriceSell,
      basePriceBuy: basePriceBuy,
      hasVariants: hasVariants,
      imageUrls: List<String>.from(imageUrls),
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create remote model from domain entity
  factory ProductRemoteModel.fromEntity(Product product) {
    return ProductRemoteModel(
      id: product.id,
      name: product.name,
      description: product.description,
      category: _categoryToString(product.category),
      basePriceSell: product.basePriceSell,
      basePriceBuy: product.basePriceBuy,
      hasVariants: product.hasVariants,
      imageUrls: List<String>.from(product.imageUrls),
      createdBy: product.createdBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  static List<String> _decodeImageUrls(dynamic value) {
    if (value == null) {
      return const [];
    }
    if (value is List) {
      return value.whereType<String>().toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.whereType<String>().toList();
        }
      } catch (_) {
        return [value];
      }
      return [value];
    }
    return const [];
  }

  /// Convert string to ProductCategory enum
  static ProductCategory _categoryFromString(String category) {
    switch (category) {
      case 'barritas_nutritivas':
        return ProductCategory.barritasNutritivas;
      case 'barritas_proteicas':
        return ProductCategory.barritasProteicas;
      case 'barritas_dieteticas':
        return ProductCategory.barritasDieteticas;
      case 'otros':
        return ProductCategory.otros;
      default:
        return ProductCategory.otros;
    }
  }

  /// Convert ProductCategory enum to string
  static String _categoryToString(ProductCategory category) {
    switch (category) {
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
}
