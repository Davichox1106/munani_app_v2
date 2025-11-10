import '../../domain/entities/inventory_item.dart';

/// Modelo remoto de Inventory para Supabase
///
/// Maneja serialización/deserialización con PostgreSQL
class InventoryRemoteModel {
  final String id;
  final String productVariantId;
  final String locationId;
  final String locationType;
  final int quantity;
  final int minStock;
  final int maxStock;
  final DateTime lastUpdated;
  final String updatedBy;
  // Costos (opcionales)
  final double? unitCost;
  final double? totalCost;
  final double? lastCost;
  final List<String> imageUrls;

  const InventoryRemoteModel({
    required this.id,
    required this.productVariantId,
    required this.locationId,
    required this.locationType,
    required this.quantity,
    required this.minStock,
    required this.maxStock,
    required this.lastUpdated,
    required this.updatedBy,
    this.unitCost,
    this.totalCost,
    this.lastCost,
    this.imageUrls = const [],
  });

  // ============================================================================
  // CONVERSIONES
  // ============================================================================

  /// Crear desde JSON de Supabase
  factory InventoryRemoteModel.fromJson(Map<String, dynamic> json) {
    return InventoryRemoteModel(
      id: json['id'] as String,
      productVariantId: json['product_variant_id'] as String,
      locationId: json['location_id'] as String,
      locationType: json['location_type'] as String,
      quantity: json['quantity'] as int,
      minStock: json['min_stock'] as int,
      maxStock: json['max_stock'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      updatedBy: json['updated_by'] as String,
      unitCost: (json['unit_cost'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      lastCost: (json['last_cost'] as num?)?.toDouble(),
      imageUrls: (json['image_urls'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_variant_id': productVariantId,
      'location_id': locationId,
      'location_type': locationType,
      'quantity': quantity,
      'min_stock': minStock,
      'max_stock': maxStock,
      'last_updated': lastUpdated.toIso8601String(),
      'updated_by': updatedBy,
      if (unitCost != null) 'unit_cost': unitCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (lastCost != null) 'last_cost': lastCost,
      'image_urls': imageUrls,
    };
  }

  /// Convertir a entidad de dominio
  InventoryItem toEntity() {
    return InventoryItem(
      id: id,
      productVariantId: productVariantId,
      locationId: locationId,
      locationType: locationType,
      quantity: quantity,
      minStock: minStock,
      maxStock: maxStock,
      lastUpdated: lastUpdated,
      updatedBy: updatedBy,
      unitCost: unitCost,
      totalCost: totalCost,
      lastCost: lastCost,
      imageUrls: List<String>.from(imageUrls),
    );
  }

  /// Crear desde entidad de dominio
  factory InventoryRemoteModel.fromEntity(InventoryItem item) {
    return InventoryRemoteModel(
      id: item.id,
      productVariantId: item.productVariantId,
      locationId: item.locationId,
      locationType: item.locationType,
      quantity: item.quantity,
      minStock: item.minStock,
      maxStock: item.maxStock,
      lastUpdated: item.lastUpdated,
      updatedBy: item.updatedBy,
      unitCost: item.unitCost,
      totalCost: item.totalCost,
      lastCost: item.lastCost,
      imageUrls: List<String>.from(item.imageUrls),
    );
  }
}
