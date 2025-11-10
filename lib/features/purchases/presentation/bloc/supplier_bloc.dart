import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_suppliers.dart';
import '../../domain/usecases/create_supplier.dart' as create_usecase;
import '../../domain/usecases/update_supplier.dart' as update_usecase;
import '../../domain/usecases/delete_supplier.dart' as delete_usecase;
import '../../domain/usecases/sync_purchases.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';
import '../../../../core/utils/app_logger.dart';

/// BLoC para gestionar el estado de Suppliers
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final GetSuppliers getSuppliers;
  final create_usecase.CreateSupplier createSupplier;
  final update_usecase.UpdateSupplier updateSupplier;
  final delete_usecase.DeleteSupplier deleteSupplier;
  final SyncPurchases syncPurchases;

  StreamSubscription? _suppliersSubscription;

  SupplierBloc({
    required this.getSuppliers,
    required this.createSupplier,
    required this.updateSupplier,
    required this.deleteSupplier,
    required this.syncPurchases,
  }) : super(const SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<SearchSuppliers>(_onSearchSuppliers);
    on<CreateSupplier>(_onCreateSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
    on<SyncSuppliers>(_onSyncSuppliers);
    on<CreateTestSupplier>(_onCreateTestSupplier);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    AppLogger.debug('🔄 SupplierBloc - Iniciando carga de proveedores...');
    emit(const SupplierLoading());

    try {
      AppLogger.debug('🔄 SupplierBloc - Cancelando suscripción anterior...');
      await _suppliersSubscription?.cancel();

      AppLogger.debug('🔄 SupplierBloc - Obteniendo proveedores...');
      await for (final suppliers in getSuppliers()) {
        AppLogger.debug('📦 SupplierBloc - Proveedores recibidos: ${suppliers.length}');
        if (!isClosed) {
          AppLogger.info('✅ SupplierBloc - Emitiendo estado SupplierLoaded');
          emit(SupplierLoaded(suppliers));
        } else {
          AppLogger.warning('⚠️ SupplierBloc - No se puede emitir, bloc cerrado');
          break;
        }
      }
      AppLogger.info('✅ SupplierBloc - Stream completado');
    } catch (e) {
      AppLogger.error('❌ SupplierBloc - Error en _onLoadSuppliers: $e');
      if (!isClosed) {
        emit(SupplierError(e.toString()));
      }
    }
  }

  Future<void> _onSearchSuppliers(
    SearchSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierLoading());

    try {
      final suppliers = await getSuppliers.search(event.query);
      if (!emit.isDone) {
        emit(SupplierLoaded(suppliers));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(SupplierError(e.toString()));
      }
    }
  }

  Future<void> _onCreateSupplier(
    CreateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      final supplier = await createSupplier(
        name: event.name,
        contactName: event.contactName,
        phone: event.phone,
        email: event.email,
        address: event.address,
        rucNit: event.rucNit,
        notes: event.notes,
        createdBy: event.createdBy,
      );

      if (!emit.isDone) {
        emit(SupplierOperationSuccess(
          message: 'Proveedor creado exitosamente',
          supplier: supplier,
        ));

        // Recargar lista
        add(const LoadSuppliers());
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(SupplierError('Error al crear proveedor: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      final supplier = await updateSupplier(
        supplier: event.supplier,
        updatedBy: event.updatedBy,
      );

      if (!emit.isDone) {
        emit(SupplierOperationSuccess(
          message: 'Proveedor actualizado exitosamente',
          supplier: supplier,
        ));

        // Recargar lista
        add(const LoadSuppliers());
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(SupplierError('Error al actualizar proveedor: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      await deleteSupplier(event.supplierId);

      if (!emit.isDone) {
        emit(const SupplierOperationSuccess(
          message: 'Proveedor desactivado exitosamente',
        ));

        // Recargar lista
        add(const LoadSuppliers());
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(SupplierError('Error al eliminar proveedor: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSyncSuppliers(
    SyncSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierSyncing());

    try {
      await syncPurchases.syncSuppliersOnly();
      if (!emit.isDone) {
        emit(const SupplierSyncSuccess('Proveedores sincronizados exitosamente'));

        // Recargar lista
        add(const LoadSuppliers());
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(SupplierError('Error al sincronizar proveedores: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCreateTestSupplier(
    CreateTestSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      AppLogger.debug('🧪 Creando proveedor de prueba...');
      
      // Crear un proveedor de prueba directamente en local
      final testSupplier = await createSupplier(
        name: 'Proveedor de Prueba',
        contactName: 'Juan Pérez',
        phone: '+595 21 123-4567',
        email: 'test@proveedor.com',
        address: 'Calle de Prueba 123',
        rucNit: '80012345-7',
        notes: 'Proveedor creado automáticamente para pruebas',
        createdBy: 'test-user-id', // ID temporal
      );
      
      AppLogger.info('✅ Proveedor de prueba creado: ${testSupplier.name}');
      AppLogger.debug('🔄 Recargando lista de proveedores...');
      
      // Recargar la lista de proveedores
      add(const LoadSuppliers());
      
    } catch (e) {
      AppLogger.error('❌ Error creando proveedor de prueba: $e');
      AppLogger.error('❌ Stack trace: ${StackTrace.current}');
      if (!emit.isDone) {
        emit(SupplierError('Error creando proveedor de prueba: $e'));
      }
    }
  }

  @override
  Future<void> close() async {
    await _suppliersSubscription?.cancel();
    return super.close();
  }
}
