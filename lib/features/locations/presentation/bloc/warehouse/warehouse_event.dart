import 'package:equatable/equatable.dart';
import '../../../domain/entities/warehouse.dart';

/// Eventos del WarehouseBloc
abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los almacenes
class LoadAllWarehouses extends WarehouseEvent {
  const LoadAllWarehouses();
}

/// Buscar almacén por ID
class LoadWarehouseById extends WarehouseEvent {
  final String id;

  const LoadWarehouseById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Crear nuevo almacén
class CreateWarehouse extends WarehouseEvent {
  final String name;
  final String address;
  final String? phone;
  final String? managerId;
  final String? paymentQrUrl;
  final String? paymentQrDescription;

  const CreateWarehouse({
    required this.name,
    required this.address,
    this.phone,
    this.managerId,
    this.paymentQrUrl,
    this.paymentQrDescription,
  });

  @override
  List<Object?> get props =>
      [name, address, phone, managerId, paymentQrUrl, paymentQrDescription];
}

/// Actualizar almacén existente
class UpdateWarehouse extends WarehouseEvent {
  final Warehouse warehouse;

  const UpdateWarehouse(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

/// Eliminar almacén
class DeleteWarehouse extends WarehouseEvent {
  final String id;

  const DeleteWarehouse(this.id);

  @override
  List<Object?> get props => [id];
}

/// Sincronizar almacenes desde backend
class SyncWarehouses extends WarehouseEvent {
  const SyncWarehouses();
}

/// Buscar almacenes por query
class SearchWarehouses extends WarehouseEvent {
  final String query;

  const SearchWarehouses(this.query);

  @override
  List<Object?> get props => [query];
}

/// Evento interno cuando los almacenes cambian en el stream
class WarehousesChanged extends WarehouseEvent {
  final List<Warehouse> warehouses;

  const WarehousesChanged(this.warehouses);

  @override
  List<Object?> get props => [warehouses];
}







