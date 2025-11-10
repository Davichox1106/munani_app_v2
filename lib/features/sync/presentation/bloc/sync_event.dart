import 'package:equatable/equatable.dart';

/// Eventos del SyncBloc
///
/// Representa las acciones que el usuario puede realizar
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Iniciar sincronización manual
class SyncStarted extends SyncEvent {
  const SyncStarted();
}

/// Verificar estado de sincronización
class SyncStatusRequested extends SyncEvent {
  const SyncStatusRequested();
}

/// Reintentar sincronización de items fallidos
class SyncRetryFailed extends SyncEvent {
  const SyncRetryFailed();
}

/// Limpiar cola de sincronización (solo items completados)
class SyncClearCompleted extends SyncEvent {
  const SyncClearCompleted();
}

/// Cancelar sincronización en progreso
class SyncCancelled extends SyncEvent {
  const SyncCancelled();
}

/// Verificar conexión a internet
class SyncCheckConnection extends SyncEvent {
  const SyncCheckConnection();
}

/// Iniciar sincronización automática en background
class SyncStartAutoSync extends SyncEvent {
  final Duration interval;

  const SyncStartAutoSync({
    this.interval = const Duration(minutes: 5),
  });

  @override
  List<Object?> get props => [interval];
}

/// Detener sincronización automática
class SyncStopAutoSync extends SyncEvent {
  const SyncStopAutoSync();
}
