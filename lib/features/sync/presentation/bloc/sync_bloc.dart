import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';
import '../../../../core/utils/app_logger.dart';

/// BLoC para gestionar sincronización Offline-First
///
/// Responsabilidades:
/// - Sincronizar datos locales (Isar) con backend (Supabase)
/// - Gestionar cola de sincronización
/// - Resolver conflictos usando timestamps (last-write-wins)
/// - Manejar reintentos de operaciones fallidas
/// - Sincronización automática en background
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository syncRepository;
  final NetworkInfo networkInfo;
  Timer? _autoSyncTimer;
  bool _isAutoSyncActive = false;
  StreamSubscription<int>? _queueSubscription;

  SyncBloc({
    required this.syncRepository,
    required this.networkInfo,
  }) : super(const SyncInitial()) {
    on<SyncStarted>(_onSyncStarted);
    on<SyncStatusRequested>(_onSyncStatusRequested);
    on<SyncRetryFailed>(_onSyncRetryFailed);
    on<SyncClearCompleted>(_onSyncClearCompleted);
    on<SyncCancelled>(_onSyncCancelled);
    on<SyncCheckConnection>(_onSyncCheckConnection);
    on<SyncStartAutoSync>(_onSyncStartAutoSync);
    on<SyncStopAutoSync>(_onSyncStopAutoSync);

    // Iniciar monitoreo del stream de la cola
    _startQueueMonitoring();
  }

  /// Iniciar monitoreo de la cola de sincronización
  void _startQueueMonitoring() {
    AppLogger.debug('👁️ Iniciando monitoreo de cola de sincronización');

    _queueSubscription = syncRepository.pendingItemsStream.listen(
      (pendingCount) {
        AppLogger.debug('📊 Cola actualizada: $pendingCount items pendientes');

        // Solo actualizar el estado si no estamos sincronizando
        if (state is! SyncInProgress) {
          if (pendingCount > 0) {
            // ignore: invalid_use_of_visible_for_testing_member
            emit(SyncPending(pendingItems: pendingCount));
          } else {
            // ignore: invalid_use_of_visible_for_testing_member
            emit(const SyncIdle(lastSyncAt: null));
          }
        }
      },
      onError: (error) {
        AppLogger.error('❌ Error monitoreando cola: $error');
        // ignore: invalid_use_of_visible_for_testing_member
        emit(SyncError(message: error.toString()));
      },
    );
  }

  /// Handler: Iniciar sincronización manual
  Future<void> _onSyncStarted(
    SyncStarted event,
    Emitter<SyncState> emit,
  ) async {
    try {
      // 1. Verificar conexión a internet
      if (!await networkInfo.isConnected) {
        final countResult = await syncRepository.getPendingCount();
        final pendingCount = countResult.fold((l) => 0, (count) => count);
        emit(SyncNoConnection(pendingItems: pendingCount));
        AppLogger.warning('⚠️ Sin conexión - $pendingCount items pendientes');
        return;
      }

      // 2. Obtener items pendientes de la cola
      final pendingResult = await syncRepository.getPendingItems();
      
      await pendingResult.fold(
        (failure) async {
          emit(SyncError(message: failure.message));
          AppLogger.error('❌ Error al obtener items pendientes: ${failure.message}');
        },
        (items) async {
          if (items.isEmpty) {
            emit(SyncSuccess(syncedItems: 0, syncedAt: DateTime.now()));
            AppLogger.info('✅ No hay items pendientes de sincronización');
            return;
          }

          AppLogger.debug('🔄 Sincronización iniciada - ${items.length} items');
          emit(SyncInProgress(
            totalItems: items.length,
            processedItems: 0,
          ));

          // 3. Sincronizar todos los items
          final result = await syncRepository.syncAll();

          result.fold(
            (failure) {
              emit(SyncError(message: failure.message));
              AppLogger.error('❌ Error en sincronización: ${failure.message}');
            },
            (syncedCount) {
              emit(SyncSuccess(
                syncedItems: syncedCount,
                syncedAt: DateTime.now(),
              ));
              AppLogger.info('✅ Sincronización completada: $syncedCount items');
            },
          );
        },
      );
    } catch (e) {
      AppLogger.error('❌ Error inesperado en sincronización: $e');
      emit(SyncError(message: e.toString()));
    }
  }

  /// Handler: Verificar estado de sincronización
  Future<void> _onSyncStatusRequested(
    SyncStatusRequested event,
    Emitter<SyncState> emit,
  ) async {
    try {
      final countResult = await syncRepository.getPendingCount();

      countResult.fold(
        (failure) => emit(SyncError(message: failure.message)),
        (pendingItems) {
          if (pendingItems > 0) {
            emit(SyncPending(pendingItems: pendingItems));
          } else {
            emit(const SyncIdle(lastSyncAt: null));
          }
        },
      );
    } catch (e) {
      emit(SyncError(message: e.toString()));
    }
  }

  /// Handler: Reintentar items fallidos
  Future<void> _onSyncRetryFailed(
    SyncRetryFailed event,
    Emitter<SyncState> emit,
  ) async {
    try {
      // Verificar conexión
      if (!await networkInfo.isConnected) {
        emit(const SyncError(message: 'No hay conexión a internet'));
        return;
      }

      AppLogger.debug('🔄 Reintentando items fallidos');
      emit(const SyncInProgress(totalItems: 0, processedItems: 0));

      final result = await syncRepository.retryFailed();

      result.fold(
        (failure) => emit(SyncError(message: failure.message)),
        (syncedCount) {
          emit(SyncSuccess(
            syncedItems: syncedCount,
            syncedAt: DateTime.now(),
          ));
          AppLogger.info('✅ Reintentos completados: $syncedCount items');
        },
      );
    } catch (e) {
      emit(SyncError(message: e.toString()));
    }
  }

  /// Handler: Limpiar items completados
  Future<void> _onSyncClearCompleted(
    SyncClearCompleted event,
    Emitter<SyncState> emit,
  ) async {
    try {
      AppLogger.info('🗑️ Limpiando items completados');

      final result = await syncRepository.clearCompleted();

      result.fold(
        (failure) => emit(SyncError(message: failure.message)),
        (count) {
          AppLogger.info('✅ $count items completados eliminados');
          emit(const SyncIdle());
        },
      );
    } catch (e) {
      emit(SyncError(message: e.toString()));
    }
  }

  /// Handler: Cancelar sincronización
  Future<void> _onSyncCancelled(
    SyncCancelled event,
    Emitter<SyncState> emit,
  ) async {
    AppLogger.debug('⏸️ Sincronización cancelada');
    emit(const SyncIdle());
  }

  /// Handler: Verificar conexión
  Future<void> _onSyncCheckConnection(
    SyncCheckConnection event,
    Emitter<SyncState> emit,
  ) async {
    try {
      final hasConnection = await networkInfo.isConnected;

      if (!hasConnection) {
        final countResult = await syncRepository.getPendingCount();
        final pendingCount = countResult.fold((l) => 0, (count) => count);
        emit(SyncNoConnection(pendingItems: pendingCount));
      } else {
        // Si hay conexión y items pendientes, iniciar sincronización automática
        final hasPendingResult = await syncRepository.hasPendingItems();
        hasPendingResult.fold(
          (failure) => emit(const SyncIdle()),
          (hasPending) {
            if (hasPending) {
              add(const SyncStarted());
            } else {
              emit(const SyncIdle());
            }
          },
        );
      }
    } catch (e) {
      emit(SyncError(message: e.toString()));
    }
  }

  /// Handler: Iniciar sincronización automática
  Future<void> _onSyncStartAutoSync(
    SyncStartAutoSync event,
    Emitter<SyncState> emit,
  ) async {
    if (_isAutoSyncActive) {
      AppLogger.warning('⚠️ Sincronización automática ya está activa');
      return;
    }

    _isAutoSyncActive = true;
    _autoSyncTimer = Timer.periodic(event.interval, (timer) {
      AppLogger.debug('⏰ Sincronización automática disparada');
      add(const SyncStarted());
    });

    AppLogger.debug('🔄 Sincronización automática iniciada (cada ${event.interval.inMinutes} min)');
  }

  /// Handler: Detener sincronización automática
  Future<void> _onSyncStopAutoSync(
    SyncStopAutoSync event,
    Emitter<SyncState> emit,
  ) async {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _isAutoSyncActive = false;

    AppLogger.debug('⏹️ Sincronización automática detenida');
  }

  @override
  Future<void> close() {
    _autoSyncTimer?.cancel();
    _queueSubscription?.cancel();
    return super.close();
  }
}
