import '../entities/supplier.dart';

/// Repositorio abstracto para Suppliers
///
/// Define el contrato que debe implementar el repositorio de datos
abstract class SupplierRepository {
  /// Obtener stream de todos los proveedores
  Stream<List<Supplier>> watchAllSuppliers();

  /// Obtener stream de proveedores activos
  Stream<List<Supplier>> watchActiveSuppliers();

  /// Obtener proveedor por ID
  Future<Supplier?> getSupplierById(String id);

  /// Obtener lista de proveedores activos
  Future<List<Supplier>> getActiveSuppliers();

  /// Buscar proveedores por nombre o RUC/NIT
  Future<List<Supplier>> searchSuppliers(String query);

  /// Crear nuevo proveedor
  Future<Supplier> createSupplier(Supplier supplier);

  /// Actualizar proveedor existente
  Future<Supplier> updateSupplier(Supplier supplier);

  /// Eliminar proveedor (soft delete: isActive = false)
  Future<void> deleteSupplier(String id);

  /// Sincronizar proveedores con backend
  Future<void> syncSuppliers();
}
