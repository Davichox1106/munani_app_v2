import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_stores.dart';
import '../../../domain/usecases/create_store.dart' as usecases;
import '../../../domain/usecases/update_store.dart' as usecases;
import '../../../domain/usecases/delete_store.dart' as usecases;
import '../../../domain/usecases/search_stores.dart' as usecases;
import '../../../domain/repositories/location_repository.dart';
import 'store_event.dart';
import 'store_state.dart';

/// BLoC de Stores (Tiendas)
///
/// Maneja el estado y la lógica de negocio de las tiendas
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetAllStores getAllStores;
  final usecases.CreateStore createStore;
  final usecases.UpdateStore updateStore;
  final usecases.DeleteStore deleteStore;
  final usecases.SearchStores searchStores;
  final LocationRepository repository;

  StreamSubscription? _storesSubscription;

  StoreBloc({
    required this.getAllStores,
    required this.createStore,
    required this.updateStore,
    required this.deleteStore,
    required this.searchStores,
    required this.repository,
  }) : super(const StoreInitial()) {
    on<LoadAllStores>(_onLoadAllStores);
    on<CreateStore>(_onCreateStore);
    on<UpdateStore>(_onUpdateStore);
    on<DeleteStore>(_onDeleteStore);
    on<SyncStores>(_onSyncStores);
    on<SearchStores>(_onSearchStores);
    on<StoresChanged>(_onStoresChanged);

    // Escuchar cambios en la base de datos local y actualizar estado automáticamente
    _storesSubscription = repository.watchAllStores().listen((stores) {
      // Solo actualizar si no estamos en operación (evitar sobrescribir mensajes)
      if (state is! StoreLoading && state is! StoreCreated && state is! StoreUpdated && state is! StoreDeleted) {
        add(StoresChanged(stores));
      }
    });
  }

  /// Handler para cuando las tiendas cambian en el stream
  Future<void> _onStoresChanged(
    StoresChanged event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreListLoaded(event.stores));
  }

  /// Cargar todas las tiendas
  Future<void> _onLoadAllStores(
    LoadAllStores event,
    Emitter<StoreState> emit,
  ) async {
    emit(const StoreLoading());

    final result = await getAllStores();

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (stores) => emit(StoreListLoaded(stores)),
    );
  }

  /// Crear nueva tienda
  Future<void> _onCreateStore(
    CreateStore event,
    Emitter<StoreState> emit,
  ) async {
    final result = await createStore(
      name: event.name,
      address: event.address,
      phone: event.phone,
      managerId: event.managerId,
      paymentQrUrl: event.paymentQrUrl,
      paymentQrDescription: event.paymentQrDescription,
    );

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (store) {
        emit(StoreCreated(store));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Actualizar tienda existente
  Future<void> _onUpdateStore(
    UpdateStore event,
    Emitter<StoreState> emit,
  ) async {
    final result = await updateStore(event.store);

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (store) {
        emit(StoreUpdated(store));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Eliminar tienda
  Future<void> _onDeleteStore(
    DeleteStore event,
    Emitter<StoreState> emit,
  ) async {
    final result = await deleteStore(event.id);

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (_) {
        emit(StoreDeleted(event.id));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Sincronizar con backend
  Future<void> _onSyncStores(
    SyncStores event,
    Emitter<StoreState> emit,
  ) async {
    final result = await repository.syncStoresFromRemote();

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (_) {
        emit(const StoresSynced());
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  /// Buscar tiendas
  Future<void> _onSearchStores(
    SearchStores event,
    Emitter<StoreState> emit,
  ) async {
    emit(const StoreLoading());

    final result = await searchStores(event.query);

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (stores) => emit(StoresSearched(
        stores: stores,
        query: event.query,
      )),
    );
  }

  @override
  Future<void> close() {
    _storesSubscription?.cancel();
    return super.close();
  }
}

