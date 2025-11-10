import 'package:equatable/equatable.dart';
import '../../../domain/entities/store.dart';

/// Eventos del StoreBloc
abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las tiendas
class LoadAllStores extends StoreEvent {
  const LoadAllStores();
}

/// Buscar tienda por ID
class LoadStoreById extends StoreEvent {
  final String id;

  const LoadStoreById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Crear nueva tienda
class CreateStore extends StoreEvent {
  final String name;
  final String address;
  final String? phone;
  final String? managerId;
  final String? paymentQrUrl;
  final String? paymentQrDescription;

  const CreateStore({
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

/// Actualizar tienda existente
class UpdateStore extends StoreEvent {
  final Store store;

  const UpdateStore(this.store);

  @override
  List<Object?> get props => [store];
}

/// Eliminar tienda
class DeleteStore extends StoreEvent {
  final String id;

  const DeleteStore(this.id);

  @override
  List<Object?> get props => [id];
}

/// Sincronizar tiendas desde backend
class SyncStores extends StoreEvent {
  const SyncStores();
}

/// Buscar tiendas por query
class SearchStores extends StoreEvent {
  final String query;

  const SearchStores(this.query);

  @override
  List<Object?> get props => [query];
}

/// Evento interno cuando las tiendas cambian en el stream
class StoresChanged extends StoreEvent {
  final List<Store> stores;

  const StoresChanged(this.stores);

  @override
  List<Object?> get props => [stores];
}







