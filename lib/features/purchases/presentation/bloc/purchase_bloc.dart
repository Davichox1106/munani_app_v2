import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_purchases.dart';
import '../../domain/usecases/get_purchase_with_items.dart';
import '../../domain/usecases/create_purchase.dart' as create_usecase;
import '../../domain/usecases/add_purchase_item.dart' as add_item_usecase;
import '../../domain/usecases/update_purchase_item.dart' as update_item_usecase;
import '../../domain/usecases/remove_purchase_item.dart' as remove_item_usecase;
import '../../domain/usecases/receive_purchase.dart' as receive_usecase;
import '../../domain/usecases/cancel_purchase.dart' as cancel_usecase;
import '../../domain/usecases/sync_purchases.dart' as sync_usecase;
import 'purchase_event.dart';
import 'purchase_state.dart';
import '../../../../core/utils/app_logger.dart';

/// BLoC para gestionar el estado de Purchases
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final GetPurchases getPurchases;
  final GetPurchaseWithItems getPurchaseWithItems;
  final create_usecase.CreatePurchase createPurchase;
  final add_item_usecase.AddPurchaseItem addPurchaseItem;
  final update_item_usecase.UpdatePurchaseItem updatePurchaseItem;
  final remove_item_usecase.RemovePurchaseItem removePurchaseItem;
  final receive_usecase.ReceivePurchase receivePurchase;
  final cancel_usecase.CancelPurchase cancelPurchase;
  final sync_usecase.SyncPurchases syncPurchases;

  StreamSubscription? _purchasesSubscription;

  PurchaseBloc({
    required this.getPurchases,
    required this.getPurchaseWithItems,
    required this.createPurchase,
    required this.addPurchaseItem,
    required this.updatePurchaseItem,
    required this.removePurchaseItem,
    required this.receivePurchase,
    required this.cancelPurchase,
    required this.syncPurchases,
  }) : super(const PurchaseInitial()) {
    on<LoadPurchases>(_onLoadPurchases);
    on<LoadPurchasesByLocation>(_onLoadPurchasesByLocation);
    on<LoadPurchasesByStatus>(_onLoadPurchasesByStatus);
    on<SearchPurchases>(_onSearchPurchases);
    on<LoadPurchaseDetail>(_onLoadPurchaseDetail);
    on<CreatePurchase>(_onCreatePurchase);
    on<AddPurchaseItem>(_onAddPurchaseItem);
    on<UpdatePurchaseItem>(_onUpdatePurchaseItem);
    on<RemovePurchaseItem>(_onRemovePurchaseItem);
    on<ReceivePurchase>(_onReceivePurchase);
    on<CancelPurchase>(_onCancelPurchase);
    on<SyncPurchases>(_onSyncPurchases);
  }

  Future<void> _onLoadPurchases(
    LoadPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    try {
      await _purchasesSubscription?.cancel();
      await emit.forEach(
        getPurchases(),
        onData: (purchases) => PurchaseLoaded(purchases),
        onError: (error, stackTrace) {
          // Log de diagnóstico para identificar por qué falla la lista
          // (p.ej., errores de Isar, mapeos de enum, etc.)
          // ignore: avoid_print
          AppLogger.error('❌ PurchaseBloc stream error (all): $error');
          return PurchaseError(error.toString());
        },
      );
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onLoadPurchasesByLocation(
    LoadPurchasesByLocation event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    try {
      await _purchasesSubscription?.cancel();
      await emit.forEach(
        getPurchases.byLocation(event.locationId),
        onData: (purchases) => PurchaseLoaded(purchases),
        onError: (error, stackTrace) {
          // ignore: avoid_print
          AppLogger.error('❌ PurchaseBloc stream error (byLocation): $error');
          return PurchaseError(error.toString());
        },
      );
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onLoadPurchasesByStatus(
    LoadPurchasesByStatus event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    try {
      await _purchasesSubscription?.cancel();
      await emit.forEach(
        getPurchases.byStatus(event.status),
        onData: (purchases) => PurchaseLoaded(purchases),
        onError: (error, _) => PurchaseError(error.toString()),
      );
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onSearchPurchases(
    SearchPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    try {
      final purchases = await getPurchases.search(event.query);
      emit(PurchaseLoaded(purchases));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onLoadPurchaseDetail(
    LoadPurchaseDetail event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    try {
      final purchaseWithItems = await getPurchaseWithItems(event.purchaseId);
      if (purchaseWithItems != null) {
        emit(PurchaseDetailLoaded(purchaseWithItems));
      } else {
        emit(const PurchaseError('Compra no encontrada'));
      }
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onCreatePurchase(
    CreatePurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseCreating());

    try {
      final purchase = await createPurchase(
        supplierId: event.supplierId,
        supplierName: event.supplierName,
        locationId: event.locationId,
        locationType: event.locationType,
        locationName: event.locationName,
        invoiceNumber: event.invoiceNumber,
        purchaseDate: event.purchaseDate,
        notes: event.notes,
        createdBy: event.createdBy,
      );

      emit(PurchaseCreated(
        purchase: purchase,
        message: 'Compra creada exitosamente',
      ));
    } catch (e) {
      emit(PurchaseError('Error al crear compra: ${e.toString()}'));
    }
  }

  Future<void> _onAddPurchaseItem(
    AddPurchaseItem event,
    Emitter<PurchaseState> emit,
  ) async {
    try {
      await addPurchaseItem(
        purchaseId: event.purchaseId,
        productVariantId: event.productVariantId,
        productName: event.productName,
        variantName: event.variantName,
        quantity: event.quantity,
        unitCost: event.unitCost,
      );

      emit(PurchaseItemOperationSuccess(
        message: 'Producto agregado exitosamente',
        purchaseId: event.purchaseId,
      ));

      // Recargar detalle de compra
      add(LoadPurchaseDetail(event.purchaseId));
    } catch (e) {
      emit(PurchaseError('Error al agregar producto: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePurchaseItem(
    UpdatePurchaseItem event,
    Emitter<PurchaseState> emit,
  ) async {
    try {
      await updatePurchaseItem(
        item: event.item,
        quantity: event.quantity,
        unitCost: event.unitCost,
      );

      emit(PurchaseItemOperationSuccess(
        message: 'Producto actualizado exitosamente',
        purchaseId: event.item.purchaseId,
      ));

      // Recargar detalle de compra
      add(LoadPurchaseDetail(event.item.purchaseId));
    } catch (e) {
      emit(PurchaseError('Error al actualizar producto: ${e.toString()}'));
    }
  }

  Future<void> _onRemovePurchaseItem(
    RemovePurchaseItem event,
    Emitter<PurchaseState> emit,
  ) async {
    try {
      await removePurchaseItem(
        itemId: event.itemId,
        purchaseId: event.purchaseId,
      );

      emit(PurchaseItemOperationSuccess(
        message: 'Producto eliminado exitosamente',
        purchaseId: event.purchaseId,
      ));

      // Recargar detalle de compra
      add(LoadPurchaseDetail(event.purchaseId));
    } catch (e) {
      emit(PurchaseError('Error al eliminar producto: ${e.toString()}'));
    }
  }

  Future<void> _onReceivePurchase(
    ReceivePurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseReceiving());

    try {
      final purchase = await receivePurchase(
        purchaseId: event.purchaseId,
        receivedBy: event.receivedBy,
      );

      emit(PurchaseReceived(
        purchase: purchase,
        message: 'Compra recibida y aplicada al inventario exitosamente',
      ));

      // Recargar lista de compras
      add(const LoadPurchases());
    } catch (e) {
      emit(PurchaseError('Error al recibir compra: ${e.toString()}'));
    }
  }

  Future<void> _onCancelPurchase(
    CancelPurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseCancelling());

    try {
      await cancelPurchase(event.purchaseId);

      emit(const PurchaseCancelled('Compra cancelada exitosamente'));

      // Recargar lista de compras
      add(const LoadPurchases());
    } catch (e) {
      emit(PurchaseError('Error al cancelar compra: ${e.toString()}'));
    }
  }

  Future<void> _onSyncPurchases(
    SyncPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseSyncing());

    try {
      await syncPurchases();
      emit(const PurchaseSyncSuccess('Compras sincronizadas exitosamente'));

      // Recargar lista de compras
      add(const LoadPurchases());
    } catch (e) {
      emit(PurchaseError('Error al sincronizar compras: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _purchasesSubscription?.cancel();
    return super.close();
  }
}
