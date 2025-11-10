import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/employee_store_local_model.dart';

/// DataSource local para Employee Store usando Isar
///
/// OWASP A04: Arquitectura Offline-First
abstract class EmployeeStoreLocalDataSource {
  Stream<List<EmployeeStoreLocalModel>> watchAllEmployees();
  Stream<List<EmployeeStoreLocalModel>> watchActiveEmployees();
  Future<EmployeeStoreLocalModel?> getEmployeeById(String uuid);
  Future<List<EmployeeStoreLocalModel>> getAllEmployeesList();
  Future<List<EmployeeStoreLocalModel>> getActiveEmployeesList();
  Future<List<EmployeeStoreLocalModel>> searchEmployees(String query);
  Future<EmployeeStoreLocalModel> saveEmployee(EmployeeStoreLocalModel employee);
  Future<void> deleteEmployee(String uuid);
  Future<List<EmployeeStoreLocalModel>> getUnsyncedEmployees();
  Future<EmployeeStoreLocalModel?> getEmployeeByEmail(String email);
  Future<EmployeeStoreLocalModel?> getEmployeeByCi(String ci);
}

class EmployeeStoreLocalDataSourceImpl implements EmployeeStoreLocalDataSource {
  final IsarDatabase isarDatabase;

  EmployeeStoreLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<EmployeeStoreLocalModel>> watchAllEmployees() async* {
    final isar = await isarDatabase.database;
    yield* isar.employeeStoreLocalModels
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<EmployeeStoreLocalModel>> watchActiveEmployees() async* {
    final isar = await isarDatabase.database;
    yield* isar.employeeStoreLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<EmployeeStoreLocalModel?> getEmployeeById(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.employeeStoreLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<EmployeeStoreLocalModel>> getAllEmployeesList() async {
    final isar = await isarDatabase.database;
    return await isar.employeeStoreLocalModels
        .where()
        .sortByName()
        .findAll();
  }

  @override
  Future<List<EmployeeStoreLocalModel>> getActiveEmployeesList() async {
    final isar = await isarDatabase.database;
    return await isar.employeeStoreLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  @override
  Future<List<EmployeeStoreLocalModel>> searchEmployees(String query) async {
    final isar = await isarDatabase.database;
    final lowercaseQuery = query.toLowerCase();

    return await isar.employeeStoreLocalModels
        .filter()
        .nameContains(lowercaseQuery, caseSensitive: false)
        .or()
        .emailContains(lowercaseQuery, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  @override
  Future<EmployeeStoreLocalModel> saveEmployee(EmployeeStoreLocalModel employee) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      // Buscar empleado existente por UUID
      final existing = await isar.employeeStoreLocalModels
          .filter()
          .uuidEqualTo(employee.uuid)
          .findFirst();

      if (existing != null) {
        // Mantener el ID de Isar existente para actualizar el mismo registro
        employee.id = existing.id;
      }

      await isar.employeeStoreLocalModels.put(employee);
    });
    return employee;
  }

  @override
  Future<void> deleteEmployee(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final employee = await isar.employeeStoreLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (employee != null) {
        await isar.employeeStoreLocalModels.delete(employee.id);
      }
    });
  }

  @override
  Future<List<EmployeeStoreLocalModel>> getUnsyncedEmployees() async {
    final isar = await isarDatabase.database;
    return await isar.employeeStoreLocalModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<EmployeeStoreLocalModel?> getEmployeeByEmail(String email) async {
    final isar = await isarDatabase.database;
    return await isar.employeeStoreLocalModels
        .filter()
        .emailEqualTo(email)
        .findFirst();
  }

  @override
  Future<EmployeeStoreLocalModel?> getEmployeeByCi(String ci) async {
    final isar = await isarDatabase.database;
    return await isar.employeeStoreLocalModels
        .filter()
        .ciEqualTo(ci)
        .findFirst();
  }
}
