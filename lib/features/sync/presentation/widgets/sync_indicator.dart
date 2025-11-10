import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_state.dart';
import '../bloc/sync_event.dart';

/// Widget indicador de sincronización Offline-First
///
/// Muestra el estado actual de la sincronización con colores e iconos
/// Se puede colocar en AppBar o en cualquier parte de la UI
class SyncIndicator extends StatelessWidget {
  final bool showLabel;
  final bool showPendingCount;
  final VoidCallback? onTap;

  const SyncIndicator({
    super.key,
    this.showLabel = false,
    this.showPendingCount = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return InkWell(
          onTap: onTap ?? () => _handleTap(context, state),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(state),
                if (showLabel || showPendingCount) ...[
                  const SizedBox(width: 8),
                  _buildLabel(state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construir icono según el estado
  Widget _buildIcon(SyncState state) {
    IconData icon;
    Color color;

    if (state is SyncInProgress) {
      icon = Icons.sync;
      color = Colors.blue;
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          value: state.progress,
        ),
      );
    } else if (state is SyncSuccess) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (state is SyncError) {
      icon = Icons.error;
      color = Colors.red;
    } else if (state is SyncPending) {
      icon = Icons.cloud_upload;
      color = Colors.orange;
    } else if (state is SyncNoConnection) {
      icon = Icons.cloud_off;
      color = Colors.grey;
    } else {
      icon = Icons.cloud_done;
      color = Colors.grey.shade600;
    }

    return Icon(icon, size: 20, color: color);
  }

  /// Construir label según el estado
  Widget _buildLabel(SyncState state) {
    String text;
    Color color;

    if (state is SyncInProgress) {
      text = 'Sincronizando... ${state.progressPercent}%';
      color = Colors.blue;
    } else if (state is SyncSuccess) {
      text = 'Sincronizado';
      color = Colors.green;
    } else if (state is SyncError) {
      text = 'Error';
      color = Colors.red;
    } else if (state is SyncPending) {
      text = showPendingCount ? '${state.pendingItems} pendientes' : 'Pendientes';
      color = Colors.orange;
    } else if (state is SyncNoConnection) {
      text = 'Sin conexión';
      color = Colors.grey;
    } else {
      text = 'OK';
      color = Colors.grey.shade600;
    }

    if (!showLabel && showPendingCount && state is SyncPending) {
      // Solo mostrar número
      text = '${state.pendingItems}';
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Manejar tap en el indicador
  void _handleTap(BuildContext context, SyncState state) {
    if (state is SyncPending || state is SyncError) {
      // Si hay items pendientes o error, iniciar sincronización
      context.read<SyncBloc>().add(const SyncStarted());
    } else if (state is SyncInProgress) {
      // Mostrar detalles de sincronización
      _showSyncDetails(context, state);
    }
  }

  /// Mostrar detalles de sincronización en modal
  void _showSyncDetails(BuildContext context, SyncState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado de Sincronización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state is SyncInProgress) ...[
              Text('Progreso: ${state.progressPercent}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: state.progress),
              const SizedBox(height: 16),
              Text('Items: ${state.processedItems}/${state.totalItems}'),
              if (state.currentEntity != null)
                Text('Actual: ${state.currentEntity}'),
            ] else if (state is SyncPending) ...[
              Text('Items pendientes: ${state.pendingItems}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<SyncBloc>().add(const SyncStarted());
                },
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar ahora'),
              ),
            ] else if (state is SyncError) ...[
              Text('Error: ${state.message}'),
              if (state.failedItems > 0)
                Text('Items fallidos: ${state.failedItems}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<SyncBloc>().add(const SyncRetryFailed());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ] else if (state is SyncNoConnection) ...[
              const Text('No hay conexión a internet'),
              Text('Items pendientes: ${state.pendingItems}'),
              const SizedBox(height: 16),
              const Text(
                'Los cambios se sincronizarán automáticamente cuando haya conexión.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
