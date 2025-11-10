import '../repositories/supplier_repository.dart';

/// UseCase: Eliminar (desactivar) proveedor
class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  /// Soft delete: marca el proveedor como inactivo
  Future<void> call(String supplierId) {
    return repository.deleteSupplier(supplierId);
  }
}
