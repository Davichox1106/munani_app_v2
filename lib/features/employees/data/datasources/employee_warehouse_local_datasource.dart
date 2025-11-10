import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/employee_warehouse_local_model.dart';

/// DataSource local para Employee Warehouse usando Isar
///
/// OWASP A04: Arquitectura Offline-First
abstract class EmployeeWarehouseLocalDataSource {
  Stream<List<EmployeeWarehouseLocalModel>> watchAllEmployees();
  Stream<List<EmployeeWarehouseLocalModel>> watchActiveEmployees();
  Future<EmployeeWarehouseLocalModel?> getEmployeeById(String uuid);
  Future<List<EmployeeWarehouseLocalModel>> getAllEmployeesList();
  Future<List<EmployeeWarehouseLocalModel>> getActiveEmployeesList();
  Future<List<EmployeeWarehouseLocalModel>> searchEmployees(String query);
  Future<EmployeeWarehouseLocalModel> saveEmployee(EmployeeWarehouseLocalModel employee);
  Future<void> deleteEmployee(String uuid);
  Future<List<EmployeeWarehouseLocalModel>> getUnsyncedEmployees();
  Future<EmployeeWarehouseLocalModel?> getEmployeeByEmail(String email);
  Future<EmployeeWarehouseLocalModel?> getEmployeeByCi(String ci);
}

class EmployeeWarehouseLocalDataSourceImpl implements EmployeeWarehouseLocalDataSource {
  final IsarDatabase isarDatabase;

  EmployeeWarehouseLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<EmployeeWarehouseLocalModel>> watchAllEmployees() async* {
    final isar = await isarDatabase.database;
    yield* isar.employeeWarehouseLocalModels
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<EmployeeWarehouseLocalModel>> watchActiveEmployees() async* {
    final isar = await isarDatabase.database;
    yield* isar.employeeWarehouseLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<EmployeeWarehouseLocalModel?> getEmployeeById(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.employeeWarehouseLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<EmployeeWarehouseLocalModel>> getAllEmployeesList() async {
    final isar = await isarDatabase.database;
    return await isar.employeeWarehouseLocalModels
        .where()
        .sortByName()
        .findAll();
  }

  @override
  Future<List<EmployeeWarehouseLocalModel>> getActiveEmployeesList() async {
    final isar = await isarDatabase.database;
    return await isar.employeeWarehouseLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  @override
  Future<List<EmployeeWarehouseLocalModel>> searchEmployees(String query) async {
    final isar = await isarDatabase.database;
    final lowercaseQuery = query.toLowerCase();

    return await isar.employeeWarehouseLocalModels
        .filter()
        .nameContains(lowercaseQuery, caseSensitive: false)
        .or()
        .emailContains(lowercaseQuery, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  @override
  Future<EmployeeWarehouseLocalModel> saveEmployee(EmployeeWarehouseLocalModel employee) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      // Buscar empleado existente por UUID
      final existing = await isar.employeeWarehouseLocalModels
          .filter()
          .uuidEqualTo(employee.uuid)
          .findFirst();

      if (existing != null) {
        // Mantener el ID de Isar existente para actualizar el mismo registro
        employee.id = existing.id;
      }

      await isar.employeeWarehouseLocalModels.put(employee);
    });
    return employee;
  }

  @override
  Future<void> deleteEmployee(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final employee = await isar.employeeWarehouseLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (employee != null) {
        await isar.employeeWarehouseLocalModels.delete(employee.id);
      }
    });
  }

  @override
  Future<List<EmployeeWarehouseLocalModel>> getUnsyncedEmployees() async {
    final isar = await isarDatabase.database;
    return await isar.employeeWarehouseLocalModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<EmployeeWarehouseLocalModel?> getEmployeeByEmail(String email) async {
    final isar = await isarDatabase.database;
    return await isar.employeeWarehouseLocalModels
        .filter()
        .emailEqualTo(email)
        .findFirst();
  }

  @override
  Future<EmployeeWarehouseLocalModel?> getEmployeeByCi(String ci) async {
    final isar = await isarDatabase.database;
    return await isar.employeeWarehouseLocalModels
        .filter()
        .ciEqualTo(ci)
        .findFirst();
  }
}
