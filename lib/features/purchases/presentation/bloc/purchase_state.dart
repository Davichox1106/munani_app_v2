import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_with_items.dart';

/// Estados del PurchaseBloc
abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PurchaseInitial extends PurchaseState {
  const PurchaseInitial();
}

/// Cargando compras
class PurchaseLoading extends PurchaseState {
  const PurchaseLoading();
}

/// Cargando detalle de compra
class PurchaseDetailLoading extends PurchaseState {
  const PurchaseDetailLoading();
}

/// Compras cargadas exitosamente
class PurchaseLoaded extends PurchaseState {
  final List<Purchase> purchases;

  const PurchaseLoaded(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

/// Detalle de compra cargado
class PurchaseDetailLoaded extends PurchaseState {
  final PurchaseWithItems purchaseWithItems;

  const PurchaseDetailLoaded(this.purchaseWithItems);

  @override
  List<Object?> get props => [purchaseWithItems];
}

/// Creando compra
class PurchaseCreating extends PurchaseState {
  const PurchaseCreating();
}

/// Compra creada exitosamente
class PurchaseCreated extends PurchaseState {
  final Purchase purchase;
  final String message;

  const PurchaseCreated({
    required this.purchase,
    required this.message,
  });

  @override
  List<Object?> get props => [purchase, message];
}

/// Operación exitosa (agregar/actualizar/eliminar item)
class PurchaseItemOperationSuccess extends PurchaseState {
  final String message;
  final String purchaseId;

  const PurchaseItemOperationSuccess({
    required this.message,
    required this.purchaseId,
  });

  @override
  List<Object?> get props => [message, purchaseId];
}

/// Recibiendo compra (aplicando al inventario)
class PurchaseReceiving extends PurchaseState {
  const PurchaseReceiving();
}

/// Compra recibida exitosamente
class PurchaseReceived extends PurchaseState {
  final Purchase purchase;
  final String message;

  const PurchaseReceived({
    required this.purchase,
    required this.message,
  });

  @override
  List<Object?> get props => [purchase, message];
}

/// Cancelando compra
class PurchaseCancelling extends PurchaseState {
  const PurchaseCancelling();
}

/// Compra cancelada exitosamente
class PurchaseCancelled extends PurchaseState {
  final String message;

  const PurchaseCancelled(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sincronizando compras
class PurchaseSyncing extends PurchaseState {
  const PurchaseSyncing();
}

/// Sincronización completada
class PurchaseSyncSuccess extends PurchaseState {
  final String message;

  const PurchaseSyncSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error
class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}
