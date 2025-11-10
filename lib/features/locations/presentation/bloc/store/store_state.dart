import 'package:equatable/equatable.dart';
import '../../../domain/entities/store.dart';

/// Estados del StoreBloc
abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class StoreInitial extends StoreState {
  const StoreInitial();
}

/// Cargando
class StoreLoading extends StoreState {
  const StoreLoading();
}

/// Lista de tiendas cargada
class StoreListLoaded extends StoreState {
  final List<Store> stores;

  const StoreListLoaded(this.stores);

  @override
  List<Object?> get props => [stores];
}

/// Tienda individual cargada
class StoreDetailLoaded extends StoreState {
  final Store store;

  const StoreDetailLoaded(this.store);

  @override
  List<Object?> get props => [store];
}

/// Tienda creada exitosamente
class StoreCreated extends StoreState {
  final Store store;

  const StoreCreated(this.store);

  @override
  List<Object?> get props => [store];
}

/// Tienda actualizada exitosamente
class StoreUpdated extends StoreState {
  final Store store;

  const StoreUpdated(this.store);

  @override
  List<Object?> get props => [store];
}

/// Tienda eliminada exitosamente
class StoreDeleted extends StoreState {
  final String id;

  const StoreDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Tiendas sincronizadas
class StoresSynced extends StoreState {
  const StoresSynced();
}

/// Tiendas buscadas exitosamente
class StoresSearched extends StoreState {
  final List<Store> stores;
  final String query;

  const StoresSearched({
    required this.stores,
    required this.query,
  });

  @override
  List<Object?> get props => [stores, query];
}

/// Error
class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}







