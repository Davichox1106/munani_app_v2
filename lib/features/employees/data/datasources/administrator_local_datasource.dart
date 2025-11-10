import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/administrator_local_model.dart';

/// DataSource local para Administrators usando Isar
///
/// OWASP A04: Arquitectura Offline-First
abstract class AdministratorLocalDataSource {
  Stream<List<AdministratorLocalModel>> watchAllAdministrators();
  Stream<List<AdministratorLocalModel>> watchActiveAdministrators();
  Future<AdministratorLocalModel?> getAdministratorById(String uuid);
  Future<List<AdministratorLocalModel>> getAllAdministratorsList();
  Future<List<AdministratorLocalModel>> getActiveAdministratorsList();
  Future<List<AdministratorLocalModel>> searchAdministrators(String query);
  Future<AdministratorLocalModel> saveAdministrator(AdministratorLocalModel administrator);
  Future<void> deleteAdministrator(String uuid);
  Future<List<AdministratorLocalModel>> getUnsyncedAdministrators();
  Future<AdministratorLocalModel?> getAdministratorByEmail(String email);
  Future<AdministratorLocalModel?> getAdministratorByCi(String ci);
}

class AdministratorLocalDataSourceImpl implements AdministratorLocalDataSource {
  final IsarDatabase isarDatabase;

  AdministratorLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<AdministratorLocalModel>> watchAllAdministrators() async* {
    final isar = await isarDatabase.database;
    yield* isar.administratorLocalModels
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<AdministratorLocalModel>> watchActiveAdministrators() async* {
    final isar = await isarDatabase.database;
    yield* isar.administratorLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<AdministratorLocalModel?> getAdministratorById(String uuid) async {
    final isar = await isarDatabase.database;
    return await isar.administratorLocalModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
  }

  @override
  Future<List<AdministratorLocalModel>> getAllAdministratorsList() async {
    final isar = await isarDatabase.database;
    return await isar.administratorLocalModels
        .where()
        .sortByName()
        .findAll();
  }

  @override
  Future<List<AdministratorLocalModel>> getActiveAdministratorsList() async {
    final isar = await isarDatabase.database;
    return await isar.administratorLocalModels
        .filter()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  @override
  Future<List<AdministratorLocalModel>> searchAdministrators(String query) async {
    final isar = await isarDatabase.database;
    final lowercaseQuery = query.toLowerCase();

    return await isar.administratorLocalModels
        .filter()
        .nameContains(lowercaseQuery, caseSensitive: false)
        .or()
        .emailContains(lowercaseQuery, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  @override
  Future<AdministratorLocalModel> saveAdministrator(AdministratorLocalModel administrator) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      // Buscar administrador existente por UUID
      final existing = await isar.administratorLocalModels
          .filter()
          .uuidEqualTo(administrator.uuid)
          .findFirst();

      if (existing != null) {
        // Mantener el ID de Isar existente para actualizar el mismo registro
        administrator.id = existing.id;
      }

      await isar.administratorLocalModels.put(administrator);
    });
    return administrator;
  }

  @override
  Future<void> deleteAdministrator(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final administrator = await isar.administratorLocalModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (administrator != null) {
        await isar.administratorLocalModels.delete(administrator.id);
      }
    });
  }

  @override
  Future<List<AdministratorLocalModel>> getUnsyncedAdministrators() async {
    final isar = await isarDatabase.database;
    return await isar.administratorLocalModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<AdministratorLocalModel?> getAdministratorByEmail(String email) async {
    final isar = await isarDatabase.database;
    return await isar.administratorLocalModels
        .filter()
        .emailEqualTo(email)
        .findFirst();
  }

  @override
  Future<AdministratorLocalModel?> getAdministratorByCi(String ci) async {
    final isar = await isarDatabase.database;
    return await isar.administratorLocalModels
        .filter()
        .ciEqualTo(ci)
        .findFirst();
  }
}
