import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sync_queue_item.dart';

/// Contrato del repositorio de sincronización
///
/// Define las operaciones para gestionar la sincronización offline-first
abstract class SyncRepository {
  /// Agregar item a la cola de sincronización
  Future<Either<Failure, void>> addToQueue(SyncQueueItem item);

  /// Obtener todos los items pendientes de sincronización
  Future<Either<Failure, List<SyncQueueItem>>> getPendingItems();

  /// Obtener items fallidos (que excedieron reintentos)
  Future<Either<Failure, List<SyncQueueItem>>> getFailedItems();

  /// Sincronizar un item específico con el backend
  Future<Either<Failure, void>> syncItem(SyncQueueItem item);

  /// Sincronizar todos los items pendientes
  Future<Either<Failure, int>> syncAll();

  /// Reintentar sincronización de items fallidos
  Future<Either<Failure, int>> retryFailed();

  /// Eliminar item de la cola (solo si se sincronizó exitosamente)
  Future<Either<Failure, void>> removeFromQueue(String itemId);

  /// Limpiar items completados de la cola
  Future<Either<Failure, int>> clearCompleted();

  /// Obtener número de items pendientes
  Future<Either<Failure, int>> getPendingCount();

  /// Verificar si hay items pendientes
  Future<Either<Failure, bool>> hasPendingItems();

  /// Stream de cambios en la cola (para actualizaciones en tiempo real)
  Stream<int> get pendingItemsStream;
}
