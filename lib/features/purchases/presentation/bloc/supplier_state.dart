import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier.dart';

/// Estados del SupplierBloc
abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class SupplierInitial extends SupplierState {
  const SupplierInitial();
}

/// Cargando proveedores
class SupplierLoading extends SupplierState {
  const SupplierLoading();
}

/// Guardando proveedor (crear/actualizar)
class SupplierSaving extends SupplierState {
  const SupplierSaving();
}

/// Proveedores cargados exitosamente
class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;

  const SupplierLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

/// Operación exitosa (crear/actualizar/eliminar)
class SupplierOperationSuccess extends SupplierState {
  final String message;
  final Supplier? supplier;

  const SupplierOperationSuccess({
    required this.message,
    this.supplier,
  });

  @override
  List<Object?> get props => [message, supplier];
}

/// Sincronizando proveedores
class SupplierSyncing extends SupplierState {
  const SupplierSyncing();
}

/// Sincronización completada
class SupplierSyncSuccess extends SupplierState {
  final String message;

  const SupplierSyncSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error
class SupplierError extends SupplierState {
  final String message;

  const SupplierError(this.message);

  @override
  List<Object?> get props => [message];
}
