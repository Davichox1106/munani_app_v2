import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

/// UseCase: Obtener stream de proveedores activos
class GetSuppliers {
  final SupplierRepository repository;

  GetSuppliers(this.repository);

  /// Obtener stream de todos los proveedores
  Stream<List<Supplier>> call() {
    return repository.watchActiveSuppliers();
  }

  /// Obtener lista de proveedores activos (no stream)
  Future<List<Supplier>> getList() {
    return repository.getActiveSuppliers();
  }

  /// Buscar proveedores por nombre o RUC/NIT
  Future<List<Supplier>> search(String query) {
    return repository.searchSuppliers(query);
  }
}
