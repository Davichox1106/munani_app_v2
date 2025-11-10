import 'package:equatable/equatable.dart';

/// Entidad de dominio para Inventory Item
///
/// Representa un ítem de inventario en una ubicación específica
/// OWASP A09: Incluye auditoría con updatedBy
class InventoryItem extends Equatable {
  final String id;
  final String productVariantId;
  final String locationId;
  final String locationType; // 'store' o 'warehouse'
  final int quantity;
  final int minStock;
  final int maxStock;
  final DateTime lastUpdated;
  final String updatedBy;

  // Campos adicionales para mostrar en UI
  final String? productName;
  final String? variantName;
  final String? locationName;
  // Costos (opcionales)
  final double? unitCost;
  final double? totalCost;
  final double? lastCost;
  final List<String> imageUrls;

  const InventoryItem({
    required this.id,
    required this.productVariantId,
    required this.locationId,
    required this.locationType,
    required this.quantity,
    required this.minStock,
    required this.maxStock,
    required this.lastUpdated,
    required this.updatedBy,
    this.productName,
    this.variantName,
    this.locationName,
    this.unitCost,
    this.totalCost,
    this.lastCost,
    this.imageUrls = const [],
  });

  /// Verifica si el stock está bajo
  bool get isLowStock => quantity <= minStock;

  /// Verifica si el stock está en nivel óptimo
  bool get isOptimalStock => quantity > minStock && quantity < maxStock;

  /// Verifica si el stock está al máximo o por encima
  bool get isOverStock => quantity >= maxStock;

  /// Calcula el porcentaje de stock (0-100)
  double get stockPercentage {
    if (maxStock == 0) return 0;
    return (quantity / maxStock * 100).clamp(0, 100);
  }

  /// Copia del item con campos actualizados
  InventoryItem copyWith({
    String? id,
    String? productVariantId,
    String? locationId,
    String? locationType,
    int? quantity,
    int? minStock,
    int? maxStock,
    DateTime? lastUpdated,
    String? updatedBy,
    String? productName,
    String? variantName,
    String? locationName,
    double? unitCost,
    double? totalCost,
    double? lastCost,
    List<String>? imageUrls,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productVariantId: productVariantId ?? this.productVariantId,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      locationName: locationName ?? this.locationName,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      lastCost: lastCost ?? this.lastCost,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        locationId,
        locationType,
        quantity,
        minStock,
        maxStock,
        lastUpdated,
        updatedBy,
        productName,
        variantName,
        locationName,
        unitCost,
        totalCost,
        lastCost,
        imageUrls,
      ];
}






















