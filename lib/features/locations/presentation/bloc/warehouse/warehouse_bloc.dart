import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_warehouses.dart';
import '../../../domain/usecases/create_warehouse.dart' as usecases;
import '../../../domain/usecases/update_warehouse.dart' as usecases;
import '../../../domain/usecases/delete_warehouse.dart' as usecases;
import '../../../domain/usecases/search_warehouses.dart' as usecases;
import '../../../domain/repositories/location_repository.dart';
import 'warehouse_event.dart';
import 'warehouse_state.dart';

/// BLoC de Warehouses (Almacenes)
///
/// Maneja el estado y la lógica de negocio de los almacenes
class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  final GetAllWarehouses getAllWarehouses;
  final usecases.CreateWarehouse createWarehouse;
  final usecases.UpdateWarehouse updateWarehouse;
  final usecases.DeleteWarehouse deleteWarehouse;
  final usecases.SearchWarehouses searchWarehouses;
  final LocationRepository repository;

  StreamSubscription? _warehousesSubscription;

  WarehouseBloc({
    required this.getAllWarehouses,
    required this.createWarehouse,
    required this.updateWarehouse,
    required this.deleteWarehouse,
    required this.searchWarehouses,
    required this.repository,
  }) : super(const WarehouseInitial()) {
    on<LoadAllWarehouses>(_onLoadAllWarehouses);
    on<CreateWarehouse>(_onCreateWarehouse);
    on<UpdateWarehouse>(_onUpdateWarehouse);
    on<DeleteWarehouse>(_onDeleteWarehouse);
    on<SyncWarehouses>(_onSyncWarehouses);
    on<SearchWarehouses>(_onSearchWarehouses);
    on<WarehousesChanged>(_onWarehousesChanged);

    // Escuchar cambios en la base de datos local y actualizar estado automáticamente
    _warehousesSubscription = repository.watchAllWarehouses().listen((warehouses) {
      // Solo actualizar si no estamos en operación (evitar sobrescribir mensajes)
      if (state is! WarehouseLoading && state is! WarehouseCreated && state is! WarehouseUpdated && state is! WarehouseDeleted) {
        add(WarehousesChanged(warehouses));
      }
    });
  }

  /// Handler para cuando los almacenes cambian en el stream
  Future<void> _onWarehousesChanged(
    WarehousesChanged event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehouseListLoaded(event.warehouses));
  }

  /// Cargar todos los almacenes
  Future<void> _onLoadAllWarehouses(
    LoadAllWarehouses event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(const WarehouseLoading());

    final result = await getAllWarehouses();

    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (warehouses) => emit(WarehouseListLoaded(warehouses)),
    );
  }

  /// Crear nuevo almacén
  Future<void> _onCreateWarehouse(
    CreateWarehouse event,
    Emitter<WarehouseState> emit,
  ) async {
    final result = await createWarehouse(
      name: event.name,
      address: event.address,
      phone: event.phone,
      managerId: event.managerId,
      paymentQrUrl: event.paymentQrUrl,
      paymentQrDescription: event.paymentQrDescription,
    );

    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (warehouse) {
        emit(WarehouseCreated(warehouse));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Actualizar almacén existente
  Future<void> _onUpdateWarehouse(
    UpdateWarehouse event,
    Emitter<WarehouseState> emit,
  ) async {
    final result = await updateWarehouse(event.warehouse);

    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (warehouse) {
        emit(WarehouseUpdated(warehouse));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Eliminar almacén
  Future<void> _onDeleteWarehouse(
    DeleteWarehouse event,
    Emitter<WarehouseState> emit,
  ) async {
    final result = await deleteWarehouse(event.id);

    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (_) {
        emit(WarehouseDeleted(event.id));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Sincronizar con backend
  Future<void> _onSyncWarehouses(
    SyncWarehouses event,
    Emitter<WarehouseState> emit,
  ) async {
    final result = await repository.syncWarehousesFromRemote();

    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (_) {
        emit(const WarehousesSynced());
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Buscar almacenes
  Future<void> _onSearchWarehouses(
    SearchWarehouses event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(const WarehouseLoading());

    final result = await searchWarehouses(event.query);

    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (warehouses) => emit(WarehousesSearched(
        warehouses: warehouses,
        query: event.query,
      )),
    );
  }

  @override
  Future<void> close() {
    _warehousesSubscription?.cancel();
    return super.close();
  }
}

