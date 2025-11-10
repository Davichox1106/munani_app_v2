import 'package:uuid/uuid.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/employee_warehouse.dart';
import '../../domain/repositories/employee_warehouse_repository.dart';
import '../datasources/employee_warehouse_local_datasource.dart';
import '../datasources/employee_warehouse_remote_datasource.dart';
import '../models/employee_warehouse_local_model.dart';

/// Implementación del repositorio de Employee Warehouse con patrón Offline-First
class EmployeeWarehouseRepositoryImpl implements EmployeeWarehouseRepository {
  final EmployeeWarehouseLocalDataSource localDataSource;
  final EmployeeWarehouseRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  EmployeeWarehouseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Stream<List<EmployeeWarehouse>> getAll() async* {
    try {
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      await for (final models in localDataSource.watchActiveEmployees()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching employees: $e');
    }
  }

  @override
  Stream<List<EmployeeWarehouse>> getAllIncludingInactive() async* {
    try {
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      await for (final models in localDataSource.watchAllEmployees()) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      throw Exception('Error watching employees: $e');
    }
  }

  @override
  Future<List<EmployeeWarehouse>> search(String query) async {
    try {
      final models = await localDataSource.searchEmployees(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error searching employees: $e');
    }
  }

  @override
  Future<EmployeeWarehouse?> getByEmail(String email) async {
    try {
      final local = await localDataSource.getEmployeeByEmail(email);
      if (local != null) {
        return local.toEntity();
      }

      if (await networkInfo.isConnected) {
        final remote = await remoteDatasource.getByEmail(email);
        if (remote != null) {
          final localModel = EmployeeWarehouseLocalModel.fromEntity(remote);
          await localDataSource.saveEmployee(localModel);
          return remote;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error getting employee by email: $e');
    }
  }

  @override
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
  }) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final newEmployee = EmployeeWarehouse(
        id: uuid,
        name: name,
        contactName: contactName,
        phone: phone,
        email: email,
        ci: ci,
        address: address,
        position: position,
        department: department,
        notes: notes,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        createdBy: createdBy,
        updatedBy: createdBy,
      );

      final localModel = EmployeeWarehouseLocalModel.fromEntity(newEmployee)
        ..isSynced = false;
      await localDataSource.saveEmployee(localModel);

      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.create(
            name: name,
            contactName: contactName,
            phone: phone,
            email: email,
            ci: ci,
            address: address,
            position: position,
            department: department,
            notes: notes,
            createdBy: createdBy,
          );

          localModel.markAsSynced();
          await localDataSource.saveEmployee(localModel);
        } catch (e) {
          AppLogger.error('Error syncing employee: $e');
        }
      }

      return newEmployee;
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

  @override
  Future<EmployeeWarehouse> update(EmployeeWarehouse employee, String updatedBy) async {
    try {
      final updatedEmployee = employee.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      final localModel = EmployeeWarehouseLocalModel.fromEntity(updatedEmployee)
        ..isSynced = false;
      await localDataSource.saveEmployee(localModel);

      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.update(
            id: employee.id,
            name: updatedEmployee.name,
            contactName: updatedEmployee.contactName,
            phone: updatedEmployee.phone,
            email: updatedEmployee.email,
            ci: updatedEmployee.ci,
            address: updatedEmployee.address,
            position: updatedEmployee.position,
            department: updatedEmployee.department,
            notes: updatedEmployee.notes,
            updatedBy: updatedBy,
          );

          localModel.markAsSynced();
          await localDataSource.saveEmployee(localModel);
        } catch (e) {
          AppLogger.error('Error syncing employee update: $e');
        }
      }

      return updatedEmployee;
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  @override
  Future<void> deactivate(String employeeId) async {
    try {
      final local = await localDataSource.getEmployeeById(employeeId);
      if (local != null) {
        local.isActive = false;
        local.markAsUnsynced();
        await localDataSource.saveEmployee(local);

        if (await networkInfo.isConnected) {
          try {
            await remoteDatasource.deactivate(employeeId);
            local.markAsSynced();
            await localDataSource.saveEmployee(local);
          } catch (e) {
            AppLogger.error('Error syncing employee deactivation: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Error deactivating employee: $e');
    }
  }

  @override
  Future<void> activate(String employeeId) async {
    try {
      final local = await localDataSource.getEmployeeById(employeeId);
      if (local != null) {
        local.isActive = true;
        local.markAsUnsynced();
        await localDataSource.saveEmployee(local);

        if (await networkInfo.isConnected) {
          try {
            await remoteDatasource.activate(employeeId);
            local.markAsSynced();
            await localDataSource.saveEmployee(local);
          } catch (e) {
            AppLogger.error('Error syncing employee activation: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Error activating employee: $e');
    }
  }

  @override
  Future<bool> existsCi(String ci, {String? excludeId}) async {
    try {
      final local = await localDataSource.getEmployeeByCi(ci);
      if (local != null && local.uuid != excludeId) {
        return true;
      }

      if (await networkInfo.isConnected) {
        return await remoteDatasource.existsCi(ci, excludeId: excludeId);
      }

      return false;
    } catch (e) {
      throw Exception('Error checking CI existence: $e');
    }
  }

  @override
  Future<void> syncEmployees() async {
    if (!await networkInfo.isConnected) return;

    try {
      AppLogger.info('📋 Sincronizando empleados bidireccional (Warehouse)...');

      // 1. SUBIR cambios locales no sincronizados
      final unsynced = await localDataSource.getUnsyncedEmployees();
      AppLogger.info('📤 Subiendo ${unsynced.length} empleados no sincronizados...');

      for (final localModel in unsynced) {
        try {
          final entity = localModel.toEntity();
          final remoteExists = await remoteDatasource.getByEmail(entity.email);

          if (remoteExists == null) {
            await remoteDatasource.create(
              name: entity.name,
              contactName: entity.contactName,
              phone: entity.phone,
              email: entity.email,
              ci: entity.ci,
              address: entity.address,
              position: entity.position,
              department: entity.department,
              notes: entity.notes,
              createdBy: entity.createdBy ?? '',
            );
            AppLogger.info('✅ Empleado ${entity.email} creado en Supabase');
          } else {
            await remoteDatasource.update(
              id: entity.id,
              name: entity.name,
              contactName: entity.contactName,
              phone: entity.phone,
              email: entity.email,
              ci: entity.ci,
              address: entity.address,
              position: entity.position,
              department: entity.department,
              notes: entity.notes,
              updatedBy: entity.updatedBy ?? '',
            );
            AppLogger.info('✅ Empleado ${entity.email} actualizado en Supabase');
          }

          localModel.markAsSynced();
          await localDataSource.saveEmployee(localModel);
        } catch (e) {
          AppLogger.error('❌ Error sincronizando empleado ${localModel.uuid}: $e');
        }
      }

      // 2. DESCARGAR desde Supabase
      AppLogger.info('📥 Descargando empleados desde Supabase...');
      final remoteEmployeesStream = remoteDatasource.getAll();
      final remoteEmployees = await remoteEmployeesStream.first;
      AppLogger.info('📥 Descargados ${remoteEmployees.length} empleados de Supabase');

      // 3. Guardar en Isar
      for (final remoteEmployee in remoteEmployees) {
        try {
          final localModel = EmployeeWarehouseLocalModel.fromEntity(remoteEmployee);
          localModel.markAsSynced();
          await localDataSource.saveEmployee(localModel);
        } catch (e) {
          AppLogger.error('❌ Error guardando empleado ${remoteEmployee.id}: $e');
        }
      }

      AppLogger.info('✅ Sincronización bidireccional completada (Warehouse)');
    } catch (e) {
      AppLogger.error('❌ Error en sincronización completa: $e');
    }
  }

  void _syncInBackground() {
    syncEmployees().catchError((error) {
      AppLogger.error('Background sync error: $error');
    });
  }
}
