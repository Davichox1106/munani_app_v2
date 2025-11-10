import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier.dart';

/// Eventos del SupplierBloc
abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los proveedores activos
class LoadSuppliers extends SupplierEvent {
  const LoadSuppliers();
}

/// Buscar proveedores por nombre o RUC/NIT
class SearchSuppliers extends SupplierEvent {
  final String query;

  const SearchSuppliers(this.query);

  @override
  List<Object?> get props => [query];
}

/// Crear nuevo proveedor
class CreateSupplier extends SupplierEvent {
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? rucNit;
  final String? notes;
  final String createdBy;

  const CreateSupplier({
    required this.name,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.rucNit,
    this.notes,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        name,
        contactName,
        phone,
        email,
        address,
        rucNit,
        notes,
        createdBy,
      ];
}

/// Actualizar proveedor existente
class UpdateSupplier extends SupplierEvent {
  final Supplier supplier;
  final String updatedBy;

  const UpdateSupplier({
    required this.supplier,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [supplier, updatedBy];
}

/// Eliminar (desactivar) proveedor
class DeleteSupplier extends SupplierEvent {
  final String supplierId;

  const DeleteSupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

/// Sincronizar proveedores con backend
class SyncSuppliers extends SupplierEvent {
  const SyncSuppliers();
}

/// Crear proveedor de prueba (solo para desarrollo)
class CreateTestSupplier extends SupplierEvent {
  const CreateTestSupplier();
}