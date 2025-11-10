import '../../domain/entities/purchase_item.dart';

/// Modelo remoto de PurchaseItem para Supabase
///
/// Maneja serialización/deserialización con PostgreSQL
class PurchaseItemRemoteModel {
  final String id;
  final String purchaseId;
  final String productVariantId;
  final int quantity;
  final double unitCost;
  final double subtotal;
  final DateTime createdAt;

  const PurchaseItemRemoteModel({
    required this.id,
    required this.purchaseId,
    required this.productVariantId,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
    required this.createdAt,
  });

  // ============================================================================
  // CONVERSIONES
  // ============================================================================

  /// Crear desde JSON de Supabase
  factory PurchaseItemRemoteModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemRemoteModel(
      id: json['id'] as String,
      purchaseId: json['purchase_id'] as String,
      productVariantId: json['product_variant_id'] as String,
      quantity: json['quantity'] as int,
      unitCost: (json['unit_cost'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
      'unit_cost': unitCost,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convertir a entidad de dominio
  /// Requiere productName y variantName del JOIN
  PurchaseItem toEntity({
    required String productName,
    required String variantName,
  }) {
    return PurchaseItem(
      id: id,
      purchaseId: purchaseId,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      quantity: quantity,
      unitCost: unitCost,
      subtotal: subtotal,
      createdAt: createdAt,
    );
  }

  /// Crear desde entidad de dominio
  factory PurchaseItemRemoteModel.fromEntity(PurchaseItem entity) {
    return PurchaseItemRemoteModel(
      id: entity.id,
      purchaseId: entity.purchaseId,
      productVariantId: entity.productVariantId,
      quantity: entity.quantity,
      unitCost: entity.unitCost,
      subtotal: entity.subtotal,
      createdAt: entity.createdAt,
    );
  }
}
