import 'package:isar/isar.dart';
import '../../../../core/database/isar_database.dart';
import '../../domain/entities/transfer_request.dart';
import '../models/transfer_request_local_model.dart';
import 'transfer_local_datasource.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del datasource local para transferencias
class TransferLocalDataSourceImpl implements TransferLocalDataSource {
  final IsarDatabase isarDatabase;

  TransferLocalDataSourceImpl({required this.isarDatabase});

  @override
  Future<List<TransferRequestLocalModel>> getAllTransfers() async {
    final isar = await isarDatabase.database;
    return await isar.transferRequestLocalModels.where().findAll();
  }

  @override
  Stream<List<TransferRequestLocalModel>> watchAllTransfers() async* {
    final isar = await isarDatabase.database;
    yield* isar.transferRequestLocalModels
        .where()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<TransferRequestLocalModel>> getTransfersByLocation(
    String locationId,
    String locationType,
  ) async {
    final isar = await isarDatabase.database;
    final allTransfers = await isar.transferRequestLocalModels.where().findAll();
    return allTransfers.where((transfer) {
      return (transfer.fromLocationId == locationId && transfer.fromLocationType == locationType) ||
             (transfer.toLocationId == locationId && transfer.toLocationType == locationType);
    }).toList();
  }

  @override
  Future<List<TransferRequestLocalModel>> getPendingTransfersByLocation(
    String locationId,
    String locationType,
  ) async {
    final isar = await isarDatabase.database;
    final allTransfers = await isar.transferRequestLocalModels.where().findAll();
    return allTransfers.where((transfer) {
      return transfer.toLocationId == locationId && 
             transfer.toLocationType == locationType &&
             transfer.status == TransferStatus.pending;
    }).toList();
  }

  @override
  Future<List<TransferRequestLocalModel>> getTransfersByUser(String userId) async {
    final isar = await isarDatabase.database;
    final allTransfers = await isar.transferRequestLocalModels.where().findAll();
    return allTransfers.where((transfer) {
      return transfer.requestedBy == userId;
    }).toList();
  }

  @override
  Future<TransferRequestLocalModel> createTransfer(TransferRequestLocalModel transfer) async {
    AppLogger.debug('📝 LocalDataSource: Creando transferencia en Isar...');
    AppLogger.debug('   UUID: ${transfer.uuid}');
    AppLogger.debug('   requestedBy: "${transfer.requestedBy}"');
    AppLogger.debug('   updatedBy: "${transfer.updatedBy}"');

    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      await isar.transferRequestLocalModels.put(transfer);
    });

    AppLogger.info('✅ LocalDataSource: Transferencia guardada en Isar');
    return transfer;
  }

  @override
  Future<TransferRequestLocalModel> updateTransfer(TransferRequestLocalModel transfer) async {
    try {
      AppLogger.debug('🔄 LocalDataSource: Actualizando transferencia en Isar...');
      AppLogger.debug('   ID de Isar: ${transfer.id}');
      AppLogger.debug('   UUID: ${transfer.uuid}');
      AppLogger.debug('   Estado: ${transfer.status}');

      final isar = await isarDatabase.database;

      // Buscar si ya existe por UUID
      final existing = await isar.transferRequestLocalModels
          .filter()
          .uuidEqualTo(transfer.uuid)
          .findFirst();

      await isar.writeTxn(() async {
        AppLogger.debug('🔄 LocalDataSource: Ejecutando transacción...');

        if (existing != null) {
          // Si existe, preservar el ID de Isar y actualizar
          AppLogger.debug('   Transferencia existente encontrada, actualizando...');
          transfer.id = existing.id;
        } else {
          AppLogger.debug('   Transferencia nueva, insertando...');
        }

        await isar.transferRequestLocalModels.put(transfer);
        AppLogger.info('✅ LocalDataSource: Transferencia guardada en Isar');
      });

      AppLogger.info('✅ LocalDataSource: Actualización completada');
      return transfer;
    } catch (e) {
      AppLogger.error('❌ LocalDataSource: Error actualizando transferencia: $e');
      AppLogger.debug('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransfer(String transferId) async {
    final isar = await isarDatabase.database;
    await isar.writeTxn(() async {
      await isar.transferRequestLocalModels.deleteByUuid(transferId);
    });
  }

  @override
  Future<List<TransferRequestLocalModel>> searchTransfers(String query) async {
    final isar = await isarDatabase.database;
    final allTransfers = await isar.transferRequestLocalModels
        .where()
        .sortByRequestedAtDesc()
        .findAll();
    
    final queryLower = query.toLowerCase().trim();
    if (queryLower.isEmpty) {
      return allTransfers;
    }
    
    return allTransfers.where((transfer) {
      return transfer.productName.toLowerCase().contains(queryLower) ||
             transfer.variantName.toLowerCase().contains(queryLower) ||
             transfer.fromLocationName.toLowerCase().contains(queryLower) ||
             transfer.toLocationName.toLowerCase().contains(queryLower) ||
             transfer.requestedByName.toLowerCase().contains(queryLower) ||
             transfer.notes?.toLowerCase().contains(queryLower) == true;
    }).toList();
  }

  @override
  Future<TransferRequestLocalModel?> getTransferById(String transferId) async {
    final isar = await isarDatabase.database;
    return await isar.transferRequestLocalModels.getByUuid(transferId);
  }
}
