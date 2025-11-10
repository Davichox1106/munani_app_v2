import 'package:equatable/equatable.dart';

/// Entidad de dominio para Inventario
///
/// Representa el stock de una variante de producto en una ubicación específica
/// (tienda o almacén). Incluye información sobre cantidades actuales y umbrales
/// de stock mínimo y máximo para generar alertas.
///
/// OWASP A01:2021 - Broken Access Control
/// RLS garantiza que los usuarios solo ven inventario de su ubicación asignada
class Inventory extends Equatable {
  final String id; // UUID
  final String productVariantId; // UUID -> product_variants
  final String locationId; // UUID -> stores/warehouses
  final LocationType locationType; // 'store' o 'warehouse'
  final int quantity; // Cantidad actual en stock
  final int minStock; // Umbral mínimo para alerta de stock bajo
  final int maxStock; // Umbral máximo para alerta de sobrestock
  final DateTime lastUpdated; // Última modificación
  final String updatedBy; // UUID del usuario que hizo la última modificación

  const Inventory({
    required this.id,
    required this.productVariantId,
    required this.locationId,
    required this.locationType,
    required this.quantity,
    required this.minStock,
    required this.maxStock,
    required this.lastUpdated,
    required this.updatedBy,
  });

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
      ];

  /// Verifica si el stock está bajo (por debajo del umbral mínimo)
  bool get isLowStock => quantity <= minStock;

  /// Verifica si hay sobrestock (por encima del umbral máximo)
  bool get isOverStock => quantity >= maxStock;

  /// Verifica si el stock está en rango óptimo
  bool get isOptimalStock => quantity > minStock && quantity < maxStock;

  /// Verifica si el stock está agotado
  bool get isOutOfStock => quantity == 0;

  /// Calcula el porcentaje de stock respecto al máximo
  double get stockPercentage {
    if (maxStock == 0) return 0;
    return (quantity / maxStock) * 100;
  }

  /// Calcula cuántas unidades faltan para llegar al stock mínimo
  int get unitsUntilMinStock {
    final diff = quantity - minStock;
    return diff < 0 ? diff.abs() : 0;
  }

  /// Calcula cuántas unidades faltan para llegar al stock máximo
  int get unitsUntilMaxStock {
    final diff = maxStock - quantity;
    return diff > 0 ? diff : 0;
  }

  /// Copia del inventario con campos actualizados
  Inventory copyWith({
    String? id,
    String? productVariantId,
    String? locationId,
    LocationType? locationType,
    int? quantity,
    int? minStock,
    int? maxStock,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return Inventory(
      id: id ?? this.id,
      productVariantId: productVariantId ?? this.productVariantId,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Tipo de ubicación para el inventario
enum LocationType {
  store, // Tienda
  warehouse, // Almacén
}

/// Extensión para convertir LocationType a String y viceversa
extension LocationTypeExtension on LocationType {
  String get value {
    switch (this) {
      case LocationType.store:
        return 'store';
      case LocationType.warehouse:
        return 'warehouse';
    }
  }

  String get displayName {
    switch (this) {
      case LocationType.store:
        return 'Tienda';
      case LocationType.warehouse:
        return 'Almacén';
    }
  }

  static LocationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'store':
        return LocationType.store;
      case 'warehouse':
        return LocationType.warehouse;
      default:
        return LocationType.store;
    }
  }
}
