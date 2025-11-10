import 'package:equatable/equatable.dart';
import '../../../domain/entities/warehouse.dart';

/// Estados del WarehouseBloc
abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WarehouseInitial extends WarehouseState {
  const WarehouseInitial();
}

/// Cargando
class WarehouseLoading extends WarehouseState {
  const WarehouseLoading();
}

/// Lista de almacenes cargada
class WarehouseListLoaded extends WarehouseState {
  final List<Warehouse> warehouses;

  const WarehouseListLoaded(this.warehouses);

  @override
  List<Object?> get props => [warehouses];
}

/// Almacén individual cargado
class WarehouseDetailLoaded extends WarehouseState {
  final Warehouse warehouse;

  const WarehouseDetailLoaded(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

/// Almacén creado exitosamente
class WarehouseCreated extends WarehouseState {
  final Warehouse warehouse;

  const WarehouseCreated(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

/// Almacén actualizado exitosamente
class WarehouseUpdated extends WarehouseState {
  final Warehouse warehouse;

  const WarehouseUpdated(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

/// Almacén eliminado exitosamente
class WarehouseDeleted extends WarehouseState {
  final String id;

  const WarehouseDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Almacenes sincronizados
class WarehousesSynced extends WarehouseState {
  const WarehousesSynced();
}

/// Almacenes buscados exitosamente
class WarehousesSearched extends WarehouseState {
  final List<Warehouse> warehouses;
  final String query;

  const WarehousesSearched({
    required this.warehouses,
    required this.query,
  });

  @override
  List<Object?> get props => [warehouses, query];
}

/// Error
class WarehouseError extends WarehouseState {
  final String message;

  const WarehouseError(this.message);

  @override
  List<Object?> get props => [message];
}







