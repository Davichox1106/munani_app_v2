import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';

abstract class SaleState extends Equatable {
  const SaleState();
  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {
  const SaleInitial();
}

class SaleLoading extends SaleState {
  const SaleLoading();
}

class SaleLoaded extends SaleState {
  final List<Sale> sales;
  const SaleLoaded(this.sales);
  @override
  List<Object?> get props => [sales];
}

class SaleDetailLoading extends SaleState {
  const SaleDetailLoading();
}

class SaleItemsLoaded extends SaleState {
  final Sale sale;
  final List<SaleItem> items;
  const SaleItemsLoaded({required this.sale, required this.items});
  @override
  List<Object?> get props => [sale, items];
}

class SaleCreating extends SaleState {
  const SaleCreating();
}

class SaleSyncing extends SaleState {
  const SaleSyncing();
}

class SaleOperationSuccess extends SaleState {
  final String message;
  const SaleOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class SaleError extends SaleState {
  final String message;
  const SaleError(this.message);
  @override
  List<Object?> get props => [message];
}
