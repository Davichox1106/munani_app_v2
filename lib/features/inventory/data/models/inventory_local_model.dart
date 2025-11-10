import 'package:isar/isar.dart';
import '../../domain/entities/inventory_item.dart';

part 'inventory_local_model.g.dart';

/// Modelo local de Inventory para Isar
///
/// OWASP A02: Datos locales en Isar (sin encriptación en versión free)
/// OWASP A09: Auditoría con updatedBy
@collection
class InventoryLocalModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String uuid; // UUID remoto de Supabase

  @Index()
  late String productVariantId;

  @Index()
  late String locationId;

  @Index()
  late String locationType; // 'store' o 'warehouse'

  late int quantity;
  late int minStock;
  late int maxStock;

  @Index()
  late DateTime lastUpdated;

  late String updatedBy;

  // Campos adicionales para mostrar en UI (desnormalizados para performance)
  String? productName;
  String? variantName;
  String? locationName;
  // Costos (opcionales)
  double? unitCost;
  double? totalCost;
  double? lastCost;
  DateTime? costUpdatedAt;
  List<String> imageUrls = [];

  // Campos de sincronización
  @Index()
  bool needsSync = false;
  DateTime? lastSyncedAt;

  // ============================================================================
  // CONSTRUCTORES
  // ============================================================================

  InventoryLocalModel();

  /// Crear desde entidad de dominio
  InventoryLocalModel.fromEntity(InventoryItem item) {
    uuid = item.id;
    productVariantId = item.productVariantId;
    locationId = item.locationId;
    locationType = item.locationType;
    quantity = item.quantity;
    minStock = item.minStock;
    maxStock = item.maxStock;
    lastUpdated = item.lastUpdated;
    updatedBy = item.updatedBy;
    productName = item.productName;
    variantName = item.variantName;
    locationName = item.locationName;
    unitCost = item.unitCost;
    totalCost = item.totalCost;
    lastCost = item.lastCost;
    imageUrls = List<String>.from(item.imageUrls);
    // costUpdatedAt: mantener nulo si no se proporciona
  }

  /// Crear desde datos remotos (Supabase)
  factory InventoryLocalModel.fromRemote(Map<String, dynamic> json) {
    return InventoryLocalModel()
      ..uuid = json['id'] as String
      ..productVariantId = json['product_variant_id'] as String
      ..locationId = json['location_id'] as String
      ..locationType = json['location_type'] as String
      ..quantity = json['quantity'] as int
      ..minStock = json['min_stock'] as int
      ..maxStock = json['max_stock'] as int
      ..lastUpdated = DateTime.parse(json['last_updated'] as String)
      ..updatedBy = json['updated_by'] as String
      ..productName = json['product_name'] as String?
      ..variantName = json['variant_name'] as String?
      ..locationName = json['location_name'] as String?
      // Costos
      ..unitCost = (json['unit_cost'] as num?)?.toDouble()
      ..totalCost = (json['total_cost'] as num?)?.toDouble()
      ..lastCost = (json['last_cost'] as num?)?.toDouble()
      ..costUpdatedAt = json['cost_updated_at'] != null
          ? DateTime.parse(json['cost_updated_at'] as String)
          : null
      ..imageUrls = (json['image_urls'] as List?)
              ?.whereType<String>()
              .toList() ??
          <String>[];
  }

  // ============================================================================
  // CONVERSIONES
  // ============================================================================

  /// Convertir a entidad de dominio
  InventoryItem toEntity() {
    return InventoryItem(
      id: uuid,
      productVariantId: productVariantId,
      locationId: locationId,
      locationType: locationType,
      quantity: quantity,
      minStock: minStock,
      maxStock: maxStock,
      lastUpdated: lastUpdated,
      updatedBy: updatedBy,
      productName: productName,
      variantName: variantName,
      locationName: locationName,
      unitCost: unitCost,
      totalCost: totalCost,
      lastCost: lastCost,
      imageUrls: List<String>.from(imageUrls),
    );
  }

  /// Convertir a JSON para sincronización
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'product_variant_id': productVariantId,
      'location_id': locationId,
      'location_type': locationType,
      'quantity': quantity,
      'min_stock': minStock,
      'max_stock': maxStock,
      'last_updated': lastUpdated.toIso8601String(),
      'updated_by': updatedBy,
      'location_name': locationName,
      if (unitCost != null) 'unit_cost': unitCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (lastCost != null) 'last_cost': lastCost,
      if (costUpdatedAt != null) 'cost_updated_at': costUpdatedAt!.toIso8601String(),
      'image_urls': imageUrls,
    };
  }
}
