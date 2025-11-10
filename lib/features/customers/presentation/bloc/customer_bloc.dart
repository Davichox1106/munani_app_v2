import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;
  CustomerBloc({required this.repository}) : super(const CustomerInitial()) {
    on<LoadCustomers>(_onLoad);
    on<SearchCustomers>(_onSearch);
    on<SyncCustomers>(_onSync);
  }

  Future<void> _onLoad(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(const CustomerLoading());
    try {
      await emit.forEach(
        repository.watchAllCustomers(),
        onData: (list) => CustomerLoaded(list),
        onError: (error, _) => CustomerError(error.toString()),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchCustomers event, Emitter<CustomerState> emit) async {
    emit(const CustomerLoading());
    try {
      final list = await repository.search(event.query);
      emit(CustomerLoaded(list));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSync(SyncCustomers event, Emitter<CustomerState> emit) async {
    emit(const CustomerSyncing());
    try {
      await repository.syncCustomers();
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError('Error al sincronizar clientes: $e'));
    }
  }
}
