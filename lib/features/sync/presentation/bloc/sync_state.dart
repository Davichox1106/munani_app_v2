import 'package:equatable/equatable.dart';

/// Estados del SyncBloc
///
/// Maneja el estado de sincronización offline-first
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - sincronización inactiva
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// Sincronización en progreso
class SyncInProgress extends SyncState {
  final int totalItems;
  final int processedItems;
  final String? currentEntity;

  const SyncInProgress({
    required this.totalItems,
    required this.processedItems,
    this.currentEntity,
  });

  @override
  List<Object?> get props => [totalItems, processedItems, currentEntity];

  /// Progreso como porcentaje (0.0 a 1.0)
  double get progress {
    if (totalItems == 0) return 0.0;
    return processedItems / totalItems;
  }

  /// Progreso como porcentaje (0 a 100)
  int get progressPercent {
    return (progress * 100).round();
  }
}

/// Sincronización completada exitosamente
class SyncSuccess extends SyncState {
  final int syncedItems;
  final DateTime syncedAt;

  const SyncSuccess({
    required this.syncedItems,
    required this.syncedAt,
  });

  @override
  List<Object?> get props => [syncedItems, syncedAt];
}

/// Error durante la sincronización
class SyncError extends SyncState {
  final String message;
  final int failedItems;

  const SyncError({
    required this.message,
    this.failedItems = 0,
  });

  @override
  List<Object?> get props => [message, failedItems];
}

/// Estado cuando hay items pendientes de sincronizar
class SyncPending extends SyncState {
  final int pendingItems;

  const SyncPending({required this.pendingItems});

  @override
  List<Object?> get props => [pendingItems];
}

/// Estado cuando no hay conexión a internet
class SyncNoConnection extends SyncState {
  final int pendingItems;

  const SyncNoConnection({required this.pendingItems});

  @override
  List<Object?> get props => [pendingItems];
}

/// Estado ocioso - todo sincronizado
class SyncIdle extends SyncState {
  final DateTime? lastSyncAt;

  const SyncIdle({this.lastSyncAt});

  @override
  List<Object?> get props => [lastSyncAt];
}
