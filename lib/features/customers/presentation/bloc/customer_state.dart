import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  const CustomerLoaded(this.customers);
  @override
  List<Object?> get props => [customers];
}

class CustomerSyncing extends CustomerState {
  const CustomerSyncing();
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
  @override
  List<Object?> get props => [message];
}
