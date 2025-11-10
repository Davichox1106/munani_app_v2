import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/get_all_inventory.dart';
import '../../domain/usecases/get_inventory_by_location.dart';
import '../../domain/usecases/get_low_stock_inventory.dart';
import '../../domain/usecases/update_inventory_quantity.dart' as usecases;
import '../../domain/usecases/adjust_inventory.dart' as usecases;
import '../../domain/usecases/search_inventory.dart' as usecases;
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

/// BLoC de Inventory
///
/// Maneja el estado y la lógica de negocio del inventario
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetAllInventory getAllInventory;
  final GetInventoryByLocation getInventoryByLocation;
  final GetLowStockInventory getLowStockInventory;
  final usecases.UpdateInventoryQuantity updateInventoryQuantity;
  final usecases.AdjustInventory adjustInventory;
  final usecases.SearchInventory searchInventory;
  final InventoryRepository repository;

  InventoryBloc({
    required this.getAllInventory,
    required this.getInventoryByLocation,
    required this.getLowStockInventory,
    required this.updateInventoryQuantity,
    required this.adjustInventory,
    required this.searchInventory,
    required this.repository,
  }) : super(const InventoryInitial()) {
    on<LoadAllInventory>(_onLoadAllInventory);
    on<LoadInventoryByLocation>(_onLoadInventoryByLocation);
    on<LoadLowStockInventory>(_onLoadLowStockInventory);
    on<LoadStoreInventory>(_onLoadStoreInventory);
    on<LoadWarehouseInventory>(_onLoadWarehouseInventory);
    on<SearchInventory>(_onSearchInventory);
    on<CreateInventoryItem>(_onCreateInventoryItem);
    on<UpdateInventoryQuantity>(_onUpdateInventoryQuantity);
    on<AdjustInventory>(_onAdjustInventory);
    on<UpdateStockLevels>(_onUpdateStockLevels);
    on<DeleteInventoryItem>(_onDeleteInventoryItem);
  }

  /// Cargar todo el inventario
  Future<void> _onLoadAllInventory(
    LoadAllInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    await emit.forEach<Either<Failure, List<InventoryItem>>>(
      getAllInventory(),
      onData: (result) {
        return result.fold(
          (failure) => InventoryError(failure.message),
          (items) => InventoryLoaded(items),
        );
      },
    );
  }

  /// Cargar inventario por ubicación
  Future<void> _onLoadInventoryByLocation(
    LoadInventoryByLocation event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    await emit.forEach<Either<Failure, List<InventoryItem>>>(
      getInventoryByLocation(
        locationId: event.locationId,
        locationType: event.locationType,
      ),
      onData: (result) {
        return result.fold(
          (failure) => InventoryError(failure.message),
          (items) => InventoryByLocationLoaded(
            items: items,
            locationId: event.locationId,
            locationType: event.locationType,
          ),
        );
      },
    );
  }

  /// Cargar inventario con stock bajo
  Future<void> _onLoadLowStockInventory(
    LoadLowStockInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    await emit.forEach<Either<Failure, List<InventoryItem>>>(
      getLowStockInventory(),
      onData: (result) {
        return result.fold(
          (failure) => InventoryError(failure.message),
          (items) => LowStockInventoryLoaded(items),
        );
      },
    );
  }

  /// Crear nuevo ítem de inventario
  Future<void> _onCreateInventoryItem(
    CreateInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await repository.createInventoryItem(
      productVariantId: event.productVariantId,
      locationId: event.locationId,
      locationType: event.locationType,
      quantity: event.quantity,
      minStock: event.minStock,
      maxStock: event.maxStock,
      updatedBy: event.updatedBy,
      productName: event.productName,
      variantName: event.variantName,
      locationName: event.locationName,
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (item) {
        emit(InventoryCreated(item: item));
        // NO recargamos aquí - el stream de Isar ya actualiza automáticamente
      },
    );
  }

  /// Actualizar cantidad de inventario
  Future<void> _onUpdateInventoryQuantity(
    UpdateInventoryQuantity event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await updateInventoryQuantity(
      id: event.id,
      newQuantity: event.newQuantity,
      updatedBy: event.updatedBy,
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (item) {
        emit(InventoryUpdated(
          item: item,
          message: 'Cantidad actualizada a ${item.quantity}',
        ));
        // NO recargamos aquí - el stream de Isar ya actualiza automáticamente
      },
    );
  }

  /// Ajustar inventario (incrementar/decrementar)
  Future<void> _onAdjustInventory(
    AdjustInventory event,
    Emitter<InventoryState> emit,
  ) async {
    // Guardar el estado actual para saber qué recargar después
    final currentState = state;

    final result = await adjustInventory(
      id: event.id,
      delta: event.delta,
      updatedBy: event.updatedBy,
    );

    await result.fold(
      (failure) async => emit(InventoryError(failure.message)),
      (item) async {
        final action = event.delta > 0 ? 'incrementado' : 'decrementado';
        emit(InventoryUpdated(
          item: item,
          message: 'Inventario $action (${event.delta > 0 ? '+' : ''}${event.delta})',
        ));

        // Esperar un momento para que el stream de Isar actualice
        await Future.delayed(const Duration(milliseconds: 100));

        // Recargar según el estado previo para reflejar cambios en la UI
        if (currentState is InventoryByLocationLoaded) {
          add(LoadInventoryByLocation(
            locationId: currentState.locationId,
            locationType: currentState.locationType,
          ));
        } else if (currentState is LowStockInventoryLoaded) {
          add(const LoadLowStockInventory());
        } else {
          add(const LoadAllInventory());
        }
      },
    );
  }

  /// Actualizar niveles de stock
  Future<void> _onUpdateStockLevels(
    UpdateStockLevels event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await repository.updateStockLevels(
      id: event.id,
      minStock: event.minStock,
      maxStock: event.maxStock,
      updatedBy: event.updatedBy,
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (item) {
        emit(InventoryUpdated(
          item: item,
          message: 'Niveles de stock actualizados',
        ));
        // NO recargamos aquí - el stream de Isar ya actualiza automáticamente
      },
    );
  }

  /// Eliminar ítem de inventario
  Future<void> _onDeleteInventoryItem(
    DeleteInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await repository.deleteInventoryItem(event.id);

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) {
        emit(const InventoryDeleted(
          message: 'Inventario eliminado',
        ));
        // NO recargamos aquí - el stream de Isar ya actualiza automáticamente
      },
    );
  }

  /// Cargar inventario solo de tiendas
  Future<void> _onLoadStoreInventory(
    LoadStoreInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final result = await repository.getInventoryByLocationType('store');

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventory) => emit(InventoryLoaded(inventory)),
    );
  }

  /// Cargar inventario solo de almacenes
  Future<void> _onLoadWarehouseInventory(
    LoadWarehouseInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final result = await repository.getInventoryByLocationType('warehouse');

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventory) => emit(InventoryLoaded(inventory)),
    );
  }

  /// Buscar inventario
  Future<void> _onSearchInventory(
    SearchInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final result = await searchInventory(event.query);

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventory) => emit(InventorySearched(
        items: inventory,
        query: event.query,
      )),
    );
  }
}




