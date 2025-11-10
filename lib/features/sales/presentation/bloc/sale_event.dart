import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();
  @override
  List<Object?> get props => [];
}

class LoadSales extends SaleEvent {
  const LoadSales();
}

class LoadSalesByLocation extends SaleEvent {
  final String locationId;
  const LoadSalesByLocation(this.locationId);
  @override
  List<Object?> get props => [locationId];
}

class LoadSalesByStatus extends SaleEvent {
  final SaleStatus status;
  const LoadSalesByStatus(this.status);
  @override
  List<Object?> get props => [status];
}

class SearchSales extends SaleEvent {
  final String query;
  const SearchSales(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadSaleDetail extends SaleEvent {
  final String saleId;
  const LoadSaleDetail(this.saleId);
  @override
  List<Object?> get props => [saleId];
}

class CreateSale extends SaleEvent {
  final Sale sale;
  const CreateSale(this.sale);
  @override
  List<Object?> get props => [sale];
}

class CreateSaleWithItems extends SaleEvent {
  final Sale sale;
  final List<SaleItem> items;
  const CreateSaleWithItems({required this.sale, required this.items});
  @override
  List<Object?> get props => [sale, items];
}

class AddSaleItem extends SaleEvent {
  final String saleId;
  final String productVariantId;
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  const AddSaleItem({
    required this.saleId,
    required this.productVariantId,
    required this.productName,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
  });
}

class CompleteSale extends SaleEvent {
  final String saleId;
  const CompleteSale(this.saleId);
  @override
  List<Object?> get props => [saleId];
}

class CancelSale extends SaleEvent {
  final String saleId;
  const CancelSale(this.saleId);
  @override
  List<Object?> get props => [saleId];
}

class SyncSales extends SaleEvent {
  const SyncSales();
}
