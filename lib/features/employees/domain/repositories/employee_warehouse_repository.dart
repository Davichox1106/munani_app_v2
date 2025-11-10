import '../entities/employee_warehouse.dart';

/// Repositorio para gestionar empleados de almacén
abstract class EmployeeWarehouseRepository {
  /// Obtiene todos los empleados activos
  Stream<List<EmployeeWarehouse>> getAll();

  /// Obtiene todos los empleados (activos e inactivos)
  Stream<List<EmployeeWarehouse>> getAllIncludingInactive();

  /// Busca empleados por nombre o email
  Future<List<EmployeeWarehouse>> search(String query);

  /// Obtiene un empleado por email
  Future<EmployeeWarehouse?> getByEmail(String email);

  /// Crea un nuevo empleado
  Future<EmployeeWarehouse> create({
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? position,
    String? department,
    String? notes,
    required String createdBy,
  });

  /// Actualiza un empleado
  Future<EmployeeWarehouse> update(EmployeeWarehouse employee, String updatedBy);

  /// Desactiva un empleado
  Future<void> deactivate(String employeeId);

  /// Activa un empleado
  Future<void> activate(String employeeId);

  /// Verificar si existe un CI (excluyendo opcionalmente un ID específico)
  Future<bool> existsCi(String ci, {String? excludeId});

  /// Sincronizar empleados con backend
  Future<void> syncEmployees();
}
