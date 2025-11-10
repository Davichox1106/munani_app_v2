import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../models/customer_local_model.dart';

abstract class CustomerLocalDataSource {
  Stream<List<CustomerLocalModel>> watchAllCustomers();
  Future<CustomerLocalModel?> getById(String uuid);
  Future<CustomerLocalModel?> getByCi(String ci);
  Future<List<CustomerLocalModel>> search(String query);
  Future<CustomerLocalModel> save(CustomerLocalModel model);
  Future<void> delete(String uuid);
  Future<List<CustomerLocalModel>> getUnsynced();
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final IsarDatabase isarDatabase;
  CustomerLocalDataSourceImpl({required this.isarDatabase});

  @override
  Stream<List<CustomerLocalModel>> watchAllCustomers() async* {
    final isar = await isarDatabase.database;
    yield* isar.collection<CustomerLocalModel>().where().watch(fireImmediately: true);
  }

  @override
  Future<CustomerLocalModel?> getById(String uuid) async {
    final isar = await isarDatabase.database;
    final all = await isar.collection<CustomerLocalModel>().where().findAll();
    final match = all.where((m) => m.uuid == uuid);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<CustomerLocalModel?> getByCi(String ci) async {
    final isar = await isarDatabase.database;
    final all = await isar.collection<CustomerLocalModel>().where().findAll();
    final match = all.where((m) => m.ci == ci);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<CustomerLocalModel>> search(String query) async {
    final isar = await isarDatabase.database;
    final all = await isar.collection<CustomerLocalModel>().where().findAll();
    final q = query.toLowerCase();
    final filtered = all.where((m) {
      final name = m.name.toLowerCase();
      final ci = m.ci.toLowerCase();
      final email = (m.email ?? '').toLowerCase();
      return name.contains(q) || ci.contains(q) || email.contains(q);
    }).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  @override
  Future<CustomerLocalModel> save(CustomerLocalModel model) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final existingList = await isar.collection<CustomerLocalModel>().where().findAll();
      final existing = existingList.where((m) => m.uuid == model.uuid);
      if (existing.isNotEmpty) model.idIsar = existing.first.idIsar;
      await isar.collection<CustomerLocalModel>().put(model);
    });
    return model;
  }

  @override
  Future<void> delete(String uuid) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      final list = await isar.collection<CustomerLocalModel>().where().findAll();
      final match = list.where((m) => m.uuid == uuid);
      if (match.isNotEmpty) {
        await isar.collection<CustomerLocalModel>().delete(match.first.idIsar);
      }
    });
  }

  @override
  Future<List<CustomerLocalModel>> getUnsynced() async {
    final isar = await isarDatabase.database;
    final all = await isar.collection<CustomerLocalModel>().where().findAll();
    return all.where((m) => m.needsSync).toList();
  }
}
