import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sale_repository.dart';
import 'sale_event.dart';
import 'sale_state.dart';
import '../../domain/entities/sale_item.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../../core/di/injection_container.dart' as di;

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleRepository repository;
  StreamSubscription? _sub;

  SaleBloc({required this.repository}) : super(const SaleInitial()) {
    on<LoadSales>(_onLoadSales);
    on<LoadSalesByLocation>(_onLoadSalesByLocation);
    on<LoadSalesByStatus>(_onLoadSalesByStatus);
    on<SearchSales>(_onSearchSales);
    on<LoadSaleDetail>(_onLoadSaleDetail);
    on<CreateSale>(_onCreateSale);
    on<CreateSaleWithItems>(_onCreateSaleWithItems);
    on<AddSaleItem>(_onAddSaleItem);
    on<CompleteSale>(_onCompleteSale);
    on<CancelSale>(_onCancelSale);
    on<SyncSales>(_onSyncSales);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SaleState> emit) async {
    emit(const SaleLoading());
    try {
      await _sub?.cancel();
      await emit.forEach(
        repository.watchAllSales(),
        onData: (sales) => SaleLoaded(sales),
        onError: (error, _) => SaleError(error.toString()),
      );
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> _onLoadSalesByLocation(LoadSalesByLocation event, Emitter<SaleState> emit) async {
    emit(const SaleLoading());
    try {
      await _sub?.cancel();
      await emit.forEach(
        repository.watchSalesByLocation(event.locationId),
        onData: (sales) => SaleLoaded(sales),
        onError: (error, _) => SaleError(error.toString()),
      );
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> _onLoadSalesByStatus(LoadSalesByStatus event, Emitter<SaleState> emit) async {
    emit(const SaleLoading());
    try {
      await _sub?.cancel();
      await emit.forEach(
        repository.watchSalesByStatus(event.status),
        onData: (sales) => SaleLoaded(sales),
        onError: (error, _) => SaleError(error.toString()),
      );
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> _onSearchSales(SearchSales event, Emitter<SaleState> emit) async {
    emit(const SaleLoading());
    try {
      final sales = await repository.searchSales(event.query);
      emit(SaleLoaded(sales));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> _onLoadSaleDetail(LoadSaleDetail event, Emitter<SaleState> emit) async {
    emit(const SaleDetailLoading());
    try {
      final sale = await repository.getSaleById(event.saleId);
      if (sale == null) {
        emit(const SaleError('Venta no encontrada'));
        return;
      }
      final items = await repository.getSaleItems(event.saleId);
      emit(SaleItemsLoaded(sale: sale, items: items));
    } catch (e) {
      emit(SaleError('Error cargando detalle: $e'));
    }
  }

  Future<void> _onCreateSale(CreateSale event, Emitter<SaleState> emit) async {
    emit(const SaleCreating());
    try {
      await repository.createSale(event.sale);
      emit(const SaleOperationSuccess('Venta creada'));
      add(const LoadSales());
    } catch (e) {
      emit(SaleError('Error al crear venta: $e'));
    }
  }

  Future<void> _onCreateSaleWithItems(CreateSaleWithItems event, Emitter<SaleState> emit) async {
    emit(const SaleCreating());
    try {
      final created = await repository.createSale(event.sale);
      for (final it in event.items) {
        await repository.addSaleItem(it.copyWith(saleId: created.id));
      }
      emit(const SaleOperationSuccess('Venta creada'));
      add(const LoadSales());
    } catch (e) {
      emit(SaleError('Error al crear venta: $e'));
    }
  }

  Future<void> _onAddSaleItem(AddSaleItem event, Emitter<SaleState> emit) async {
    try {
      final item = SaleItem(
        id: 'temp',
        saleId: event.saleId,
        productVariantId: event.productVariantId,
        productName: event.productName,
        variantName: event.variantName,
        quantity: event.quantity,
        unitPrice: event.unitPrice,
        subtotal: event.quantity * event.unitPrice,
        createdAt: DateTime.now(),
      );
      await repository.addSaleItem(item);
      emit(const SaleOperationSuccess('Producto agregado a la venta'));
    } catch (e) {
      emit(SaleError('Error al agregar item: $e'));
    }
  }

  Future<void> _onCompleteSale(CompleteSale event, Emitter<SaleState> emit) async {
    try {
      final completed = await repository.completeSale(event.saleId);

      // Descuento local inmediato de inventario
      try {
        final invRepo = di.sl<InventoryRepository>();
        final items = await repository.getSaleItems(event.saleId);
        for (final it in items) {
          final either = await invRepo.getInventoryByVariant(it.productVariantId);
          final list = either.fold<List<InventoryItem>>((l) => [], (r) => r);
          if (list.isNotEmpty) {
            InventoryItem match;
            try {
              match = list.firstWhere(
                (ii) => ii.locationId == completed.locationId && ii.locationType == completed.locationType,
              );
            } catch (_) {
              match = list.first;
            }
            await invRepo.adjustInventory(id: match.id, delta: -it.quantity, updatedBy: completed.createdBy);
          }
        }
      } catch (_) {}

      // Auto-sync ventas
      add(const SyncSales());
      emit(const SaleOperationSuccess('Venta completada'));
      add(const LoadSales());
    } catch (e) {
      emit(SaleError('Error al completar venta: $e'));
    }
  }

  Future<void> _onCancelSale(CancelSale event, Emitter<SaleState> emit) async {
    try {
      await repository.cancelSale(event.saleId);
      add(const SyncSales());
      emit(const SaleOperationSuccess('Venta cancelada'));
      add(const LoadSales());
    } catch (e) {
      emit(SaleError('Error al cancelar venta: $e'));
    }
  }

  Future<void> _onSyncSales(SyncSales event, Emitter<SaleState> emit) async {
    emit(const SaleSyncing());
    try {
      await repository.syncSales();
      emit(const SaleOperationSuccess('Ventas sincronizadas'));
      add(const LoadSales());
    } catch (e) {
      emit(SaleError('Error al sincronizar: $e'));
    }
  }
}
