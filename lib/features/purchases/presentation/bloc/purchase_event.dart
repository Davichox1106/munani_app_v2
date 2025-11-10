import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item.dart';

/// Eventos del PurchaseBloc
abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las compras
class LoadPurchases extends PurchaseEvent {
  const LoadPurchases();
}

/// Cargar compras por ubicación
class LoadPurchasesByLocation extends PurchaseEvent {
  final String locationId;

  const LoadPurchasesByLocation(this.locationId);

  @override
  List<Object?> get props => [locationId];
}

/// Cargar compras por estado
class LoadPurchasesByStatus extends PurchaseEvent {
  final PurchaseStatus status;

  const LoadPurchasesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Buscar compras
class SearchPurchases extends PurchaseEvent {
  final String query;

  const SearchPurchases(this.query);

  @override
  List<Object?> get props => [query];
}

/// Cargar detalle de compra con items
class LoadPurchaseDetail extends PurchaseEvent {
  final String purchaseId;

  const LoadPurchaseDetail(this.purchaseId);

  @override
  List<Object?> get props => [purchaseId];
}

/// Crear nueva compra
class CreatePurchase extends PurchaseEvent {
  final String supplierId;
  final String supplierName;
  final String locationId;
  final String locationType;
  final String locationName;
  final String? invoiceNumber;
  final DateTime? purchaseDate;
  final String? notes;
  final String createdBy;

  const CreatePurchase({
    required this.supplierId,
    required this.supplierName,
    required this.locationId,
    required this.locationType,
    required this.locationName,
    this.invoiceNumber,
    this.purchaseDate,
    this.notes,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        supplierId,
        supplierName,
        locationId,
        locationType,
        locationName,
        invoiceNumber,
        purchaseDate,
        notes,
        createdBy,
      ];
}

/// Agregar item a compra
class AddPurchaseItem extends PurchaseEvent {
  final String purchaseId;
  final String productVariantId;
  final String productName;
  final String variantName;
  final int quantity;
  final double unitCost;

  const AddPurchaseItem({
    required this.purchaseId,
    required this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitCost,
  });

  @override
  List<Object?> get props => [
        purchaseId,
        productVariantId,
        productName,
        variantName,
        quantity,
        unitCost,
      ];
}

/// Actualizar item de compra
class UpdatePurchaseItem extends PurchaseEvent {
  final PurchaseItem item;
  final int? quantity;
  final double? unitCost;

  const UpdatePurchaseItem({
    required this.item,
    this.quantity,
    this.unitCost,
  });

  @override
  List<Object?> get props => [item, quantity, unitCost];
}

/// Eliminar item de compra
class RemovePurchaseItem extends PurchaseEvent {
  final String itemId;
  final String purchaseId;

  const RemovePurchaseItem({
    required this.itemId,
    required this.purchaseId,
  });

  @override
  List<Object?> get props => [itemId, purchaseId];
}

/// Recibir compra (aplica al inventario)
class ReceivePurchase extends PurchaseEvent {
  final String purchaseId;
  final String receivedBy;

  const ReceivePurchase({
    required this.purchaseId,
    required this.receivedBy,
  });

  @override
  List<Object?> get props => [purchaseId, receivedBy];
}

/// Cancelar compra
class CancelPurchase extends PurchaseEvent {
  final String purchaseId;
  final String cancelledBy;
  final String? cancellationReason;

  const CancelPurchase({
    required this.purchaseId,
    required this.cancelledBy,
    this.cancellationReason,
  });

  @override
  List<Object?> get props => [purchaseId, cancelledBy, cancellationReason];
}

/// Sincronizar compras
class SyncPurchases extends PurchaseEvent {
  const SyncPurchases();
}
