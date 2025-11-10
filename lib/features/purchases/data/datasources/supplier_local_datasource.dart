import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/supplier_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// DataSource local para Suppliers usando Isar
///
/// OWASP A04: Arquitectura Offline-First
abstract class SupplierLocalDataSource {
  Stream<List<SupplierLocalModel>> watchAllSuppliers();
  Stream<List<SupplierLocalModel>> watchActiveSuppliers();
  Future<SupplierLocalModel?> getSupplierById(String uuid);
  Future<List<SupplierLocalModel>> getAllSuppliersList();
  Future<List<SupplierLocalModel>> getActiveSuppliersList();
  Future<List<SupplierLocalModel>> searchSuppliers(String query);
  Future<SupplierLocalModel> saveSupplier(SupplierLocalModel supplier);
  Future<void> deleteSupplier(String uuid);
  Future<List<SupplierLocalModel>> getUnsyncedSuppliers();
}

class SupplierLocalDataSourceImpl implements SupplierLocalDataSource {
  final IsarDatabase isarDatabase;

  SupplierLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<SupplierLocalModel>> watchAllSuppliers() async* {
    final isar = await isarDatabase.database;
    yield* isar.supplierLocalModels
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<SupplierLocalModel>> watchActiveSuppliers() async* {
    AppLogger.debug('🔍 SupplierLocalDataSource - Obteniendo base de datos Isar...');
    final isar = await isarDatabase.database;
    
    AppLogger.debug('🔍 SupplierLocalDataSource - Consultando proveedores activos...');
    final count = await isar.supplierLocalModels
        .filter()
        .isActiveEqualTo(true)
        .count();
    AppLogger.debug('📊 SupplierLocalDataSource - Proveedores activos encontrados: $count');
    
    AppLogger.debug('🔍 SupplierLocalDataSource - Creando stream...');
    yield* isar.supplierLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<SupplierLocalModel?> getSupplierById(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.supplierLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<SupplierLocalModel>> getAllSuppliersList() async {
    final isar = await isarDatabase.database;
    return await isar.supplierLocalModels
        .where()
        .sortByName()
        .findAll();
  }

  @override
  Future<List<SupplierLocalModel>> getActiveSuppliersList() async {
    final isar = await isarDatabase.database;
    return await isar.supplierLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  @override
  Future<List<SupplierLocalModel>> searchSuppliers(String query) async {
    final isar = await isarDatabase.database;
    final lowercaseQuery = query.toLowerCase();

    return await isar.supplierLocalModels
        .filter()
        .nameContains(lowercaseQuery, caseSensitive: false)
        .or()
        .rucNitContains(lowercaseQuery, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  @override
  Future<SupplierLocalModel> saveSupplier(SupplierLocalModel supplier) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      // Buscar proveedor existente por UUID
      final existing = await isar.supplierLocalModels
          .filter()
          .uuidEqualTo(supplier.uuid)
          .findFirst();

      if (existing != null) {
        // Mantener el ID de Isar existente para actualizar el mismo registro
        supplier.id = existing.id;
      }

      await isar.supplierLocalModels.put(supplier);
    });
    return supplier;
  }

  @override
  Future<void> deleteSupplier(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final supplier = await isar.supplierLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (supplier != null) {
        await isar.supplierLocalModels.delete(supplier.id);
      }
    });
  }

  @override
  Future<List<SupplierLocalModel>> getUnsyncedSuppliers() async {
    final isar = await isarDatabase.database;
    return await isar.supplierLocalModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }
}
