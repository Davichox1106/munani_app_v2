import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/product_variant.dart';

part 'product_variant_local_model.g.dart';

/// Modelo de Isar para ProductVariant (Base de datos local)
///
/// Almacena las variantes de productos con sus atributos JSON.
/// Cada variante tiene un SKU único y precio específico.
@collection
class ProductVariantLocalModel {
  /// ID local de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  /// UUID de la variante (sincronización con Supabase)
  @Index(unique: true)
  late String uuid;

  /// UUID del producto padre
  @Index()
  late String productId;

  /// SKU único de la variante
  @Index(unique: true)
  late String sku;

  /// Nombre descriptivo de la variante (ej: "Rojo - Grande")
  String? variantName;

  /// Atributos de la variante en formato JSON string
  /// Ej: {"sabor": "chocolate", "proteinas": "18g", "formato": "pack x12"}
  String? variantAttributesJson;

  /// Precio de venta de la variante
  late double priceSell;
  
  /// Precio de compra de la variante
  late double priceBuy;

  /// Indica si la variante está activa
  late bool isActive;

  /// Fecha de creación
  late DateTime createdAt;

  /// Control de sincronización
  bool pendingSync = false;

  /// Fecha de última sincronización
  DateTime? syncedAt;

  /// Constructor vacío requerido por Isar
  ProductVariantLocalModel();

  /// Constructor desde entidad de dominio
  factory ProductVariantLocalModel.fromEntity(ProductVariant variant) {
    return ProductVariantLocalModel()
      ..uuid = variant.id
      ..productId = variant.productId
      ..sku = variant.sku
      ..variantName = variant.variantName
      ..variantAttributesJson = variant.variantAttributes != null
          ? jsonEncode(variant.variantAttributes)
          : null
      ..priceSell = variant.priceSell
      ..priceBuy = variant.priceBuy
      ..isActive = variant.isActive
      ..createdAt = variant.createdAt
      ..syncedAt = DateTime.now();
  }

  /// Convertir a entidad de dominio
  ProductVariant toEntity() {
    Map<String, dynamic>? attributes;
    if (variantAttributesJson != null) {
      try {
        attributes = jsonDecode(variantAttributesJson!) as Map<String, dynamic>;
      } catch (e) {
        attributes = null;
      }
    }

    return ProductVariant(
      id: uuid,
      productId: productId,
      sku: sku,
      variantName: variantName,
      variantAttributes: attributes,
      priceSell: priceSell,
      priceBuy: priceBuy,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Convertir a JSON para sincronización con Supabase
  Map<String, dynamic> toJson() {
    Map<String, dynamic>? attributes;
    if (variantAttributesJson != null) {
      try {
        attributes = jsonDecode(variantAttributesJson!);
      } catch (e) {
        attributes = null;
      }
    }

    return {
      'id': uuid,
      'product_id': productId,
      'sku': sku,
      'variant_name': variantName,
      'variant_attributes': attributes,
      'price_sell': priceSell,
      'price_buy': priceBuy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Constructor desde modelo remoto (para sincronización)
  factory ProductVariantLocalModel.fromRemote({
    required String id,
    required String productId,
    required String sku,
    String? variantName,
    Map<String, dynamic>? variantAttributes,
    required double priceSell,
    required double priceBuy,
    required bool isActive,
    required DateTime createdAt,
  }) {
    return ProductVariantLocalModel()
      ..uuid = id
      ..productId = productId
      ..sku = sku
      ..variantName = variantName
      ..variantAttributesJson = variantAttributes != null
          ? jsonEncode(variantAttributes)
          : null
      ..priceSell = priceSell
      ..priceBuy = priceBuy
      ..isActive = isActive
      ..createdAt = createdAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Marcar como pendiente de sincronización
  void markForSync() {
    pendingSync = true;
  }

  /// Marcar como sincronizado
  void markAsSynced() {
    pendingSync = false;
    syncedAt = DateTime.now();
  }
}
