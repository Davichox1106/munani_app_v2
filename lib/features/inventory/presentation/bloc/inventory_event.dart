import 'package:equatable/equatable.dart';

/// Eventos del InventoryBloc
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todo el inventario
class LoadAllInventory extends InventoryEvent {
  const LoadAllInventory();
}

/// Crear nuevo ítem de inventario
class CreateInventoryItem extends InventoryEvent {
  final String productVariantId;
  final String locationId;
  final String locationType;
  final int quantity;
  final int minStock;
  final int maxStock;
  final String updatedBy;

  // Campos opcionales para mostrar en UI
  final String? productName;
  final String? variantName;
  final String? locationName;

  const CreateInventoryItem({
    required this.productVariantId,
    required this.locationId,
    required this.locationType,
    required this.quantity,
    required this.minStock,
    required this.maxStock,
    required this.updatedBy,
    this.productName,
    this.variantName,
    this.locationName,
  });

  @override
  List<Object?> get props => [
        productVariantId,
        locationId,
        locationType,
        quantity,
        minStock,
        maxStock,
        updatedBy,
        productName,
        variantName,
        locationName,
      ];
}

/// Cargar inventario por ubicación
class LoadInventoryByLocation extends InventoryEvent {
  final String locationId;
  final String locationType;

  const LoadInventoryByLocation({
    required this.locationId,
    required this.locationType,
  });

  @override
  List<Object?> get props => [locationId, locationType];
}

/// Cargar inventario con stock bajo
class LoadLowStockInventory extends InventoryEvent {
  const LoadLowStockInventory();
}

/// Cargar inventario solo de tiendas
class LoadStoreInventory extends InventoryEvent {
  const LoadStoreInventory();
}

/// Cargar inventario solo de almacenes
class LoadWarehouseInventory extends InventoryEvent {
  const LoadWarehouseInventory();
}

/// Actualizar cantidad de inventario
class UpdateInventoryQuantity extends InventoryEvent {
  final String id;
  final int newQuantity;
  final String updatedBy;

  const UpdateInventoryQuantity({
    required this.id,
    required this.newQuantity,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [id, newQuantity, updatedBy];
}

/// Ajustar inventario (incrementar/decrementar)
class AdjustInventory extends InventoryEvent {
  final String id;
  final int delta;
  final String updatedBy;

  const AdjustInventory({
    required this.id,
    required this.delta,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [id, delta, updatedBy];
}

/// Actualizar niveles de stock (min/max)
class UpdateStockLevels extends InventoryEvent {
  final String id;
  final int minStock;
  final int maxStock;
  final String updatedBy;

  const UpdateStockLevels({
    required this.id,
    required this.minStock,
    required this.maxStock,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [id, minStock, maxStock, updatedBy];
}

/// Eliminar ítem de inventario
class DeleteInventoryItem extends InventoryEvent {
  final String id;

  const DeleteInventoryItem(this.id);

  @override
  List<Object?> get props => [id];
}

/// Buscar inventario por query
class SearchInventory extends InventoryEvent {
  final String query;

  const SearchInventory(this.query);

  @override
  List<Object?> get props => [query];
}




