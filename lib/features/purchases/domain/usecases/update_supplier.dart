import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

/// UseCase: Actualizar proveedor existente
class UpdateSupplier {
  final SupplierRepository repository;

  UpdateSupplier(this.repository);

  Future<Supplier> call({
    required Supplier supplier,
    required String updatedBy,
  }) {
    final updatedSupplier = supplier.copyWith(
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );

    return repository.updateSupplier(updatedSupplier);
  }
}
