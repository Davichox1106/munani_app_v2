import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/network_info.dart';
import 'full_sync_service.dart';

/// Servicio para sincronización automática en background
///
/// Características:
/// - Sincronización al iniciar app
/// - Sincronización periódica cada X minutos
/// - Sincronización al volver del background
/// - Respeta conexión a internet
class AutoSyncService {
  final FullSyncService fullSyncService;
  final NetworkInfo networkInfo;

  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _currentUserId;
  String? _currentRole;

  // Configuración de intervalos (en minutos)
  static const int defaultSyncIntervalMinutes = 5;
  final int syncIntervalMinutes;

  AutoSyncService({
    required this.fullSyncService,
    required this.networkInfo,
    this.syncIntervalMinutes = defaultSyncIntervalMinutes,
  });

  /// Actualiza el rol activo del usuario autenticado.
  void updateUserRole(String? role, {String? userId}) {
    _currentRole = role;
    _currentUserId = userId ?? _currentUserId;
    if (role == null) {
      _currentUserId = userId;
    }
  }

  /// Sincronización inicial al abrir la app
  /// Se ejecuta automáticamente al iniciar
  Future<void> initializeApp() async {
    try {
      debugPrint('🔄 AutoSync: Iniciando sincronización inicial...');

      // Verificar conexión
      if (!await networkInfo.isConnected) {
        debugPrint('⚠️ AutoSync: Sin conexión, trabajando offline');
        return;
      }

      // Evitar sincronizaciones simultáneas
      if (_isSyncing) {
        debugPrint('⚠️ AutoSync: Ya hay una sincronización en curso');
        return;
      }

      await _performSync('Inicialización');

    } catch (e) {
      debugPrint('❌ AutoSync: Error en inicialización: $e');
    }
  }

  /// Iniciar sincronización periódica en background
  void startPeriodicSync() {
    // Cancelar timer anterior si existe
    stopPeriodicSync();

    debugPrint('⏰ AutoSync: Iniciando sincronización periódica cada $syncIntervalMinutes minutos');

    _syncTimer = Timer.periodic(
      Duration(minutes: syncIntervalMinutes),
      (_) async {
        try {
          // Verificar conexión
          if (!await networkInfo.isConnected) {
            debugPrint('⚠️ AutoSync Periódico: Sin conexión, saltando sincronización');
            return;
          }

          // Evitar sincronizaciones simultáneas
          if (_isSyncing) {
            debugPrint('⚠️ AutoSync Periódico: Ya hay una sincronización en curso');
            return;
          }

          await _performSync('Periódica');

        } catch (e) {
          debugPrint('❌ AutoSync Periódico: Error: $e');
        }
      },
    );
  }

  /// Detener sincronización periódica
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    debugPrint('⏹️ AutoSync: Sincronización periódica detenida');
  }

  /// Sincronizar cuando la app vuelve del background
  Future<void> onAppResumed() async {
    try {
      debugPrint('📱 AutoSync: App volvió del background');

      // Verificar si pasó suficiente tiempo desde la última sincronización
      if (_lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
        if (timeSinceLastSync.inMinutes < 2) {
          debugPrint('⏭️ AutoSync: Última sincronización muy reciente, saltando');
          return;
        }
      }

      // Verificar conexión
      if (!await networkInfo.isConnected) {
        debugPrint('⚠️ AutoSync: Sin conexión al retomar app');
        return;
      }

      // Evitar sincronizaciones simultáneas
      if (_isSyncing) {
        debugPrint('⚠️ AutoSync: Ya hay una sincronización en curso');
        return;
      }

      await _performSync('Retomar app');

    } catch (e) {
      debugPrint('❌ AutoSync: Error al retomar app: $e');
    }
  }

  /// Forzar sincronización manual (para el botón de la UI)
  Future<Map<String, dynamic>> forceSync() async {
    try {
      debugPrint('🔄 AutoSync: Sincronización manual forzada');

      // Verificar conexión
      if (!await networkInfo.isConnected) {
        return {
          'success': false,
          'error': 'No hay conexión a internet',
        };
      }

      return await _performSync('Manual');

    } catch (e) {
      debugPrint('❌ AutoSync: Error en sincronización manual: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Ejecutar sincronización completa
  Future<Map<String, dynamic>> _performSync(String trigger) async {
    _isSyncing = true;

    try {
      debugPrint('🔄 AutoSync [$trigger]: Iniciando sincronización...');

      final startTime = DateTime.now();
      final result = await fullSyncService.performFullSync(
        userRole: _currentRole,
        customerId: _currentUserId,
      );
      final duration = DateTime.now().difference(startTime);

      _lastSyncTime = DateTime.now();

      if (result['success'] == true) {
        debugPrint('✅ AutoSync [$trigger]: Completado en ${duration.inSeconds}s');
      } else {
        debugPrint('⚠️ AutoSync [$trigger]: Completado con errores');
      }

      return result;

    } finally {
      _isSyncing = false;
    }
  }

  /// Obtener estado de sincronización
  bool get isSyncing => _isSyncing;

  /// Obtener última vez que se sincronizó
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Obtener tiempo desde última sincronización
  Duration? get timeSinceLastSync {
    if (_lastSyncTime == null) return null;
    return DateTime.now().difference(_lastSyncTime!);
  }

  /// Cleanup al destruir el servicio
  void dispose() {
    stopPeriodicSync();
    debugPrint('🗑️ AutoSync: Servicio destruido');
  }
}
