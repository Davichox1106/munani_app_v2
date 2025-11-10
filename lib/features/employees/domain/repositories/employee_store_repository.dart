import '../entities/employee_store.dart';

/// Repositorio para gestionar empleados de tienda
abstract class EmployeeStoreRepository {
  /// Obtiene todos los empleados activos
  Stream<List<EmployeeStore>> getAll();

  /// Obtiene todos los empleados (activos e inactivos)
  Stream<List<EmployeeStore>> getAllIncludingInactive();

  /// Busca empleados por nombre o email
  Future<List<EmployeeStore>> search(String query);

  /// Obtiene un empleado por email
  Future<EmployeeStore?> getByEmail(String email);

  /// Crea un nuevo empleado
  Future<EmployeeStore> create({
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
  Future<EmployeeStore> update(EmployeeStore employee, String updatedBy);

  /// Desactiva un empleado
  Future<void> deactivate(String employeeId);

  /// Activa un empleado
  Future<void> activate(String employeeId);

  /// Verificar si existe un CI (excluyendo opcionalmente un ID específico)
  Future<bool> existsCi(String ci, {String? excludeId});

  /// Sincronizar empleados con backend
  Future<void> syncEmployees();
}
