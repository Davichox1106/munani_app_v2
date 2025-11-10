import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  const LoadCustomers();
}

class SearchCustomers extends CustomerEvent {
  final String query;
  const SearchCustomers(this.query);
  @override
  List<Object?> get props => [query];
}

class SyncCustomers extends CustomerEvent {
  const SyncCustomers();
}
