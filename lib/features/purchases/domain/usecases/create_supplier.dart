import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

/// UseCase: Crear nuevo proveedor
class CreateSupplier {
  final SupplierRepository repository;

  CreateSupplier(this.repository);

  Future<Supplier> call({
    required String name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? rucNit,
    String? notes,
    required String createdBy,
  }) {
    final supplier = Supplier(
      id: '', // El repositorio generará el UUID
      name: name,
      contactName: contactName,
      phone: phone,
      email: email,
      address: address,
      rucNit: rucNit,
      notes: notes,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: createdBy,
    );

    return repository.createSupplier(supplier);
  }
}
