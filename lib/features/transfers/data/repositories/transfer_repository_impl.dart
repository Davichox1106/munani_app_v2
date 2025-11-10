import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../sync/domain/entities/sync_queue_item.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_local_datasource.dart';
import '../datasources/transfer_remote_datasource.dart';
import '../models/transfer_request_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de transferencias con patrón Offline-First
///
/// OWASP A04: Arquitectura Offline-First
/// 1. Todas las operaciones se guardan primero en Isar (local)
/// 2. Se agregan a cola de sincronización
/// 3. Se sincronizan con Supabase cuando hay conexión
class TransferRepositoryImpl implements TransferRepository {
  final TransferLocalDataSource localDataSource;
  final TransferRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final IsarDatabase isarDatabase;
  final SyncRepository syncRepository;
  final InventoryRepository inventoryRepository;

  TransferRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.isarDatabase,
    required this.syncRepository,
    required this.inventoryRepository,
  });


  @override
  Future<Either<Failure, List<TransferRequest>>> getAllTransfers() async {
    try {
      // Siempre obtener datos locales primero (offline-first)
      final localTransfers = await localDataSource.getAllTransfers();
      
      // Si hay conexión, sincronizar con el servidor
      if (await networkInfo.isConnected) {
        try {
          final remoteTransfers = await remoteDataSource.getAllTransfers();
          
          // Actualizar datos locales con los del servidor
          for (final remoteTransfer in remoteTransfers) {
            await localDataSource.updateTransfer(remoteTransfer);
          }
          
          // Retornar datos actualizados
          final updatedLocalTransfers = await localDataSource.getAllTransfers();
          final transfers = updatedLocalTransfers.map((m) => m.toEntity()).toList();
          return Right(transfers);
        } catch (e) {
          // Si falla la sincronización, retornar datos locales
          AppLogger.error('⚠️ Error al sincronizar transferencias: $e');
        }
      }
      
      // Retornar datos locales
      final transfers = localTransfers.map((m) => m.toEntity()).toList();
      return Right(transfers);
    } catch (e) {
      return Left(CacheFailure('Error al obtener transferencias: $e'));
    }
  }

  @override
  Stream<List<TransferRequest>> watchAllTransfers() {
    return localDataSource.watchAllTransfers().map(
      (localTransfers) => localTransfers.map((t) => t.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, List<TransferRequest>>> getTransfersByLocation(
    String locationId,
    String locationType,
  ) async {
    try {
      final localTransfers = await localDataSource.getTransfersByLocation(
        locationId,
        locationType,
      );
      final transfers = localTransfers.map((m) => m.toEntity()).toList();
      return Right(transfers);
    } catch (e) {
      return Left(CacheFailure('Error al obtener transferencias por ubicación: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransferRequest>>> getPendingTransfersByLocation(
    String locationId,
    String locationType,
  ) async {
    try {
      final localTransfers = await localDataSource.getPendingTransfersByLocation(
        locationId,
        locationType,
      );
      final transfers = localTransfers.map((m) => m.toEntity()).toList();
      return Right(transfers);
    } catch (e) {
      return Left(CacheFailure('Error al obtener transferencias pendientes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransferRequest>>> getTransfersByUser(String userId) async {
    try {
      final localTransfers = await localDataSource.getTransfersByUser(userId);
      final transfers = localTransfers.map((m) => m.toEntity()).toList();
      return Right(transfers);
    } catch (e) {
      return Left(CacheFailure('Error al obtener transferencias del usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> createTransferRequest(
    TransferRequest request,
  ) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      // 1. Crear modelo local
      final localModel = TransferRequestLocalModel.fromEntity(request)
        ..uuid = uuid
        ..requestedAt = now
        ..lastUpdated = now
        ..updatedBy = request.requestedBy // Establecer updatedBy con el usuario que solicita
        ..isSynced = false;

      // 2. Guardar en Isar (Offline-First)
      final savedModel = await localDataSource.createTransfer(localModel);

      // 3. Agregar a cola de sincronización
      await _addToSyncQueue(
        entityType: SyncEntityType.transfer,
        entityId: uuid,
        operation: SyncOperation.create,
        data: savedModel.toJson(),
      );

      return Right(savedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al crear solicitud de transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> approveTransferRequest(
    String transferId,
    String approvedBy,
    String approvedByName,
  ) async {
    try {
      AppLogger.debug('🔄 Iniciando aprobación de transferencia: $transferId');
      AppLogger.debug('   Aprobado por: $approvedBy ($approvedByName)');
      
      final existingTransfer = await localDataSource.getTransferById(transferId);
      if (existingTransfer == null) {
        AppLogger.error('❌ Transferencia no encontrada: $transferId');
        return Left(CacheFailure('Transferencia no encontrada'));
      }

      AppLogger.info('✅ Transferencia encontrada:');
      AppLogger.debug('   ID: ${existingTransfer.uuid}');
      AppLogger.debug('   Estado actual: ${existingTransfer.status}');
      AppLogger.debug('   ID de Isar: ${existingTransfer.id}');

      AppLogger.debug('🔄 Creando copia con nuevos valores...');
      final updatedTransfer = existingTransfer.copyWith(
        approvedBy: approvedBy,
        approvedByName: approvedByName,
        approvedAt: DateTime.now(),
        status: TransferStatus.approved,
      );

      AppLogger.info('✅ Copia creada:');
      AppLogger.debug('   ID de Isar: ${updatedTransfer.id}');
      AppLogger.debug('   UUID: ${updatedTransfer.uuid}');
      AppLogger.debug('   Estado: ${updatedTransfer.status}');
      AppLogger.debug('   Aprobado por: ${updatedTransfer.approvedBy}');

      AppLogger.debug('🔄 Actualizando en Isar...');
      final result = await localDataSource.updateTransfer(updatedTransfer);
      AppLogger.info('✅ Transferencia actualizada en Isar');

      // Actualizar inventario
      AppLogger.debug('🔄 Actualizando inventario...');
      await _updateInventoryForApprovedTransfer(result);
      AppLogger.info('✅ Inventario actualizado');

      // Agregar actualización a cola de sincronización
      AppLogger.debug('🔄 Agregando a cola de sincronización...');
      await _addToSyncQueue(
        entityType: SyncEntityType.transfer,
        entityId: transferId,
        operation: SyncOperation.update,
        data: result.toJson(),
      );
      AppLogger.info('✅ Agregado a cola de sincronización');

      return Right(result.toEntity());
    } catch (e) {
      AppLogger.error('❌ Error al aprobar transferencia: $e');
      AppLogger.debug('   Stack trace: ${StackTrace.current}');
      return Left(CacheFailure('Error al aprobar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> rejectTransferRequest(
    String transferId,
    String rejectedBy,
    String rejectedByName,
    String rejectionReason,
  ) async {
    try {
      final existingTransfer = await localDataSource.getTransferById(transferId);
      if (existingTransfer == null) {
        return Left(CacheFailure('Transferencia no encontrada'));
      }

      final updatedTransfer = existingTransfer.copyWith(
        approvedBy: rejectedBy,
        approvedByName: rejectedByName,
        approvedAt: DateTime.now(),
        rejectionReason: rejectionReason,
        status: TransferStatus.rejected,
      );

      final result = await localDataSource.updateTransfer(updatedTransfer);

      // Agregar actualización a cola de sincronización
      await _addToSyncQueue(
        entityType: SyncEntityType.transfer,
        entityId: transferId,
        operation: SyncOperation.update,
        data: result.toJson(),
      );

      return Right(result.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al rechazar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> cancelTransferRequest(
    String transferId,
    String cancelledBy,
  ) async {
    try {
      final existingTransfer = await localDataSource.getTransferById(transferId);
      if (existingTransfer == null) {
        return Left(CacheFailure('Transferencia no encontrada'));
      }

      final updatedTransfer = existingTransfer.copyWith(
        status: TransferStatus.cancelled,
        lastUpdated: DateTime.now(),
        updatedBy: cancelledBy,
      );

      final result = await localDataSource.updateTransfer(updatedTransfer);
      return Right(result.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al cancelar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> completeTransferRequest(
    String transferId,
    String completedBy,
  ) async {
    try {
      final existingTransfer = await localDataSource.getTransferById(transferId);
      if (existingTransfer == null) {
        return Left(CacheFailure('Transferencia no encontrada'));
      }

      // Nota: El movimiento de inventario se maneja automáticamente al sincronizar
      // Solo actualizamos el estado de la transferencia
      final updatedTransfer = existingTransfer.copyWith(
        status: TransferStatus.completed,
        lastUpdated: DateTime.now(),
        updatedBy: completedBy,
        isSynced: false, // ✅ Marcar como no sincronizado
      );

      final result = await localDataSource.updateTransfer(updatedTransfer);
      
      // ✅ Agregar a la cola de sincronización
      final syncItem = SyncQueueItem(
        id: result.uuid,
        entityType: SyncEntityType.transfer,
        entityId: result.uuid,
        operation: SyncOperation.update,
        data: result.toJson(),
        attempts: 0,
        createdAt: DateTime.now(),
      );
      
      await syncRepository.addToQueue(syncItem);
      
      return Right(result.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al completar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransferRequest>>> searchTransfers(String query) async {
    try {
      final localTransfers = await localDataSource.searchTransfers(query);
      final transfers = localTransfers.map((m) => m.toEntity()).toList();
      return Right(transfers);
    } catch (e) {
      return Left(CacheFailure('Error al buscar transferencias: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> createTransfer(TransferRequest transfer) async {
    try {
      final localModel = TransferRequestLocalModel.fromEntity(transfer);
      final createdTransfer = await localDataSource.createTransfer(localModel);
      return Right(createdTransfer.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al crear transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest>> updateTransfer(TransferRequest transfer) async {
    try {
      final localModel = TransferRequestLocalModel.fromEntity(transfer);
      final updatedTransfer = await localDataSource.updateTransfer(localModel);
      return Right(updatedTransfer.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al actualizar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransfer(String transferId) async {
    try {
      await localDataSource.deleteTransfer(transferId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al eliminar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferRequest?>> getTransferById(String transferId) async {
    try {
      final transfer = await localDataSource.getTransferById(transferId);
      return Right(transfer?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error al obtener transferencia: $e'));
    }
  }

  /// Agregar operación a la cola de sincronización
  Future<void> _addToSyncQueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        attempts: 0,
        createdAt: DateTime.now(),
        priority: SyncPriority.normal,
      );

      await syncRepository.addToQueue(syncItem);
      AppLogger.info('📤 Transferencia agregada a cola de sincronización: $entityId');
    } catch (e) {
      AppLogger.error('❌ Error agregando a cola de sincronización: $e');
    }
  }

  /// Actualiza el inventario cuando se aprueba una transferencia
  Future<void> _updateInventoryForApprovedTransfer(TransferRequestLocalModel transfer) async {
    try {
      AppLogger.debug('🔄 Actualizando inventario para transferencia aprobada:');
      AppLogger.debug('   Producto: ${transfer.productName} - ${transfer.variantName}');
      AppLogger.debug('   Cantidad: ${transfer.quantity}');
      AppLogger.debug('   Desde: ${transfer.fromLocationName} (${transfer.fromLocationType})');
      AppLogger.debug('   Hacia: ${transfer.toLocationName} (${transfer.toLocationType})');

      // 1. Reducir inventario en ubicación origen
      AppLogger.debug('🔄 Reduciendo inventario en ubicación origen...');
      final originInventoryStream = inventoryRepository.getInventoryByLocation(
        locationId: transfer.fromLocationId,
        locationType: transfer.fromLocationType,
      );

      final originInventoryResult = await originInventoryStream.first;
      await originInventoryResult.fold(
        (failure) async {
          AppLogger.error('❌ Error obteniendo inventario origen: ${failure.message}');
          throw Exception('Error obteniendo inventario origen: ${failure.message}');
        },
        (inventoryItems) async {
          // Buscar el item específico del producto
          final item = inventoryItems.firstWhere(
            (item) => item.productVariantId == transfer.productVariantId,
            orElse: () => throw Exception('Producto no encontrado en inventario origen'),
          );

          AppLogger.debug('🔄 Ajustando inventario origen: ${item.quantity} -> ${item.quantity - transfer.quantity}');
          final reduceResult = await inventoryRepository.adjustInventory(
            id: item.id,
            delta: -transfer.quantity, // Negativo para reducir
            updatedBy: transfer.approvedBy ?? 'Sistema',
          );

          reduceResult.fold(
            (failure) {
              AppLogger.error('❌ Error reduciendo inventario origen: ${failure.message}');
              throw Exception('Error reduciendo inventario origen: ${failure.message}');
            },
            (inventory) {
              AppLogger.info('✅ Inventario origen reducido: ${inventory.quantity} unidades');
            },
          );
        },
      );

      // 2. Aumentar inventario en ubicación destino
      AppLogger.debug('🔄 Aumentando inventario en ubicación destino...');
      final destinationInventoryStream = inventoryRepository.getInventoryByLocation(
        locationId: transfer.toLocationId,
        locationType: transfer.toLocationType,
      );

      final destinationInventoryResult = await destinationInventoryStream.first;
      await destinationInventoryResult.fold(
        (failure) async {
          AppLogger.error('❌ Error obteniendo inventario destino: ${failure.message}');
          throw Exception('Error obteniendo inventario destino: ${failure.message}');
        },
        (inventoryItems) async {
          try {
            // Buscar el item específico del producto
            final item = inventoryItems.firstWhere(
              (item) => item.productVariantId == transfer.productVariantId,
            );

            AppLogger.debug('🔄 Ajustando inventario destino existente: ${item.quantity} -> ${item.quantity + transfer.quantity}');
            final increaseResult = await inventoryRepository.adjustInventory(
              id: item.id,
              delta: transfer.quantity, // Positivo para aumentar
              updatedBy: transfer.approvedBy ?? 'Sistema',
            );

            increaseResult.fold(
              (failure) {
                AppLogger.error('❌ Error aumentando inventario destino: ${failure.message}');
                throw Exception('Error aumentando inventario destino: ${failure.message}');
              },
              (inventory) {
                AppLogger.info('✅ Inventario destino aumentado: ${inventory.quantity} unidades');
              },
            );
          } catch (e) {
            // Si no existe el producto en destino, crear nuevo item
            AppLogger.warning('⚠️ Producto no encontrado en destino, creando nuevo item...');
            final createResult = await inventoryRepository.createInventoryItem(
              productVariantId: transfer.productVariantId,
              locationId: transfer.toLocationId,
              locationType: transfer.toLocationType,
              quantity: transfer.quantity, // Cantidad inicial = cantidad transferida
              minStock: 0, // Valor por defecto
              maxStock: 1000, // Valor por defecto
              updatedBy: transfer.approvedBy ?? 'Sistema',
              productName: transfer.productName,
              variantName: transfer.variantName,
              locationName: transfer.toLocationName,
            );

            createResult.fold(
              (failure) {
                AppLogger.error('❌ Error creando inventario destino: ${failure.message}');
                throw Exception('Error creando inventario destino: ${failure.message}');
              },
              (inventory) {
                AppLogger.info('✅ Nuevo inventario destino creado: ${inventory.quantity} unidades');
              },
            );
          }
        },
      );

      AppLogger.info('✅ Inventario actualizado correctamente');
    } catch (e) {
      AppLogger.error('❌ Error actualizando inventario: $e');
      AppLogger.debug('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> syncFromRemote() async {
    try {
      AppLogger.debug('🔄 Sincronizando transferencias desde Supabase...');

      // 1. Descargar desde Supabase
      final remoteTransfers = await remoteDataSource.getAllTransfers();
      AppLogger.info('📥 Descargadas ${remoteTransfers.length} transferencias de Supabase');

      // 2. Guardar en Isar
      for (final remoteTransfer in remoteTransfers) {
        await localDataSource.updateTransfer(remoteTransfer);
      }

      AppLogger.info('✅ ${remoteTransfers.length} transferencias sincronizadas en Isar');
      return const Right(null);
    } catch (e) {
      AppLogger.error('❌ Error sincronizando transferencias: $e');
      return Left(ServerFailure('Error sincronizando transferencias: $e'));
    }
  }
}
