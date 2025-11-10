import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';

/// Estados del InventoryBloc
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

/// Cargando inventario
class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

/// Inventario cargado exitosamente
class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;

  const InventoryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Inventario por ubicación cargado
class InventoryByLocationLoaded extends InventoryState {
  final List<InventoryItem> items;
  final String locationId;
  final String locationType;

  const InventoryByLocationLoaded({
    required this.items,
    required this.locationId,
    required this.locationType,
  });

  @override
  List<Object?> get props => [items, locationId, locationType];
}

/// Stock bajo cargado
class LowStockInventoryLoaded extends InventoryState {
  final List<InventoryItem> items;

  const LowStockInventoryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Inventario creado exitosamente
class InventoryCreated extends InventoryState {
  final InventoryItem item;
  final String message;

  const InventoryCreated({
    required this.item,
    this.message = 'Inventario creado exitosamente',
  });

  @override
  List<Object?> get props => [item, message];
}

/// Inventario actualizado exitosamente
class InventoryUpdated extends InventoryState {
  final InventoryItem item;
  final String message;

  const InventoryUpdated({
    required this.item,
    this.message = 'Inventario actualizado',
  });

  @override
  List<Object?> get props => [item, message];
}

/// Inventario eliminado exitosamente
class InventoryDeleted extends InventoryState {
  final String message;

  const InventoryDeleted({
    this.message = 'Inventario eliminado',
  });

  @override
  List<Object?> get props => [message];
}

/// Inventario buscado exitosamente
class InventorySearched extends InventoryState {
  final List<InventoryItem> items;
  final String query;

  const InventorySearched({
    required this.items,
    required this.query,
  });

  @override
  List<Object?> get props => [items, query];
}

/// Error en operación de inventario
class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}










