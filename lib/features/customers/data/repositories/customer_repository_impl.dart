import '../../../../core/network/network_info.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_local_model.dart';
import '../models/customer_remote_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource local;
  final CustomerRemoteDataSource remote;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({required this.local, required this.remote, required this.networkInfo});

  @override
  Stream<List<Customer>> watchAllCustomers() async* {
    await for (final models in local.watchAllCustomers()) {
      yield models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<Customer?> getById(String id) async {
    final m = await local.getById(id);
    return m?.toEntity();
  }

  @override
  Future<Customer?> getByCi(String ci) async {
    final m = await local.getByCi(ci);
    return m?.toEntity();
  }

  @override
  Future<List<Customer>> search(String query) async {
    final ms = await local.search(query);
    return ms.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Customer> create(Customer customer) async {
    final now = DateTime.now();
    final sanitizedPhone = customer.phone != null ? InputSanitizer.sanitizePhone(customer.phone!) : null;
    final sanitizedAddress = customer.address != null ? InputSanitizer.sanitizeAddress(customer.address!) : null;
    final sanitizedEmail = customer.email != null ? InputSanitizer.sanitizeEmail(customer.email!) : null;
    final sanitizedCustomer = customer.copyWith(
      ci: InputSanitizer.sanitizeAlphanumeric(customer.ci, allowSpaces: false),
      name: InputSanitizer.sanitizeFreeText(customer.name),
      phone: sanitizedPhone?.isEmpty ?? true ? null : sanitizedPhone,
      email: sanitizedEmail?.isEmpty ?? true ? null : sanitizedEmail,
      address: sanitizedAddress?.isEmpty ?? true ? null : sanitizedAddress,
      assignedLocationName: customer.assignedLocationName != null
          ? InputSanitizer.sanitizeFreeText(customer.assignedLocationName!)
          : null,
      updatedAt: now,
    );

    final localModel = CustomerLocalModel.fromEntity(sanitizedCustomer)..needsSync = true;
    await local.save(localModel);

    if (await networkInfo.isConnected) {
      try {
        final remoteModel = CustomerRemoteModel.fromEntity(sanitizedCustomer);
        await remote.create(remoteModel.toJson());
        localModel.needsSync = false;
        localModel.lastSyncedAt = DateTime.now();
        await local.save(localModel);
      } catch (_) {}
    }

    return sanitizedCustomer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    final updated = customer.copyWith(updatedAt: DateTime.now());
    final localModel = CustomerLocalModel.fromEntity(updated)..needsSync = true;
    await local.save(localModel);

    if (await networkInfo.isConnected) {
      try {
        final remoteModel = CustomerRemoteModel.fromEntity(updated);
        await remote.update(updated.id, remoteModel.toJson());
        localModel.needsSync = false;
        localModel.lastSyncedAt = DateTime.now();
        await local.save(localModel);
      } catch (_) {}
    }

    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await local.delete(id);
    if (await networkInfo.isConnected) {
      try {
        await remote.delete(id);
      } catch (_) {}
    }
  }

  @override
  Future<void> syncCustomers() async {
    if (!await networkInfo.isConnected) return;

    // Upload unsynced
    final pending = await local.getUnsynced();
    for (final m in pending) {
      try {
        final remoteModel = CustomerRemoteModel.fromEntity(m.toEntity());
        try {
          await remote.update(m.uuid, remoteModel.toJson());
        } catch (_) {
          await remote.create(remoteModel.toJson());
        }
        m.needsSync = false;
        m.lastSyncedAt = DateTime.now();
        await local.save(m);
      } catch (_) {}
    }

    // Download
    final remotes = await remote.getAll();
    for (final r in remotes) {
      final entity = r.toEntity();
      final model = CustomerLocalModel.fromEntity(entity)..needsSync = false..lastSyncedAt = DateTime.now();
      await local.save(model);
    }
  }
}
