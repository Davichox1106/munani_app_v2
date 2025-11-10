import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio centralizado de logging para la aplicación
///
/// Características de seguridad (OWASP A09):
/// - Logs estructurados en formato JSON
/// - Almacenamiento persistente en archivos
/// - Redacción automática de datos sensibles
/// - Logs de eventos de seguridad
/// - Retención de logs (30 días)
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static File? _securityLogFile;
  static File? _generalLogFile;
  static bool _initialized = false;

  /// Inicializa el sistema de logging (llamar al inicio de la app)
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      _securityLogFile = File('${logsDir.path}/security_$dateStr.log');
      _generalLogFile = File('${logsDir.path}/general_$dateStr.log');

      // Limpiar logs antiguos (más de 30 días)
      await _cleanOldLogs(logsDir);

      _initialized = true;
      info('📋 Sistema de logging inicializado correctamente');
    } catch (e) {
      stderr.writeln('⚠️ Error inicializando sistema de logging: $e');
    }
  }

  /// Limpia logs de más de 30 días
  static Future<void> _cleanOldLogs(Directory logsDir) async {
    try {
      final now = DateTime.now();
      final files = await logsDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          if (age.inDays > 30) {
            await file.delete();
            debug('🗑️ Log antiguo eliminado: ${file.path}');
          }
        }
      }
    } catch (e) {
      warning('⚠️ Error limpiando logs antiguos: $e');
    }
  }

  /// Redacta (oculta) información sensible en mensajes de log
  static String _redactSensitiveData(String message) {
    var redacted = message;

    // Ocultar contraseñas
    redacted = redacted.replaceAllMapped(
      RegExp(r'password["\s:=]+[^\s",}]+', caseSensitive: false),
      (match) => 'password=***REDACTED***',
    );

    // Ocultar tokens
    redacted = redacted.replaceAllMapped(
      RegExp(r'token["\s:=]+[^\s",}]+', caseSensitive: false),
      (match) => 'token=***REDACTED***',
    );

    // Ocultar API keys
    redacted = redacted.replaceAllMapped(
      RegExp(r'api[_-]?key["\s:=]+[^\s",}]+', caseSensitive: false),
      (match) => 'api_key=***REDACTED***',
    );

    // Ocultar JWT (Bearer tokens)
    redacted = redacted.replaceAllMapped(
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      (match) => 'Bearer ***REDACTED***',
    );

    // Ocultar parte del email (mantener dominio visible)
    redacted = redacted.replaceAllMapped(
      RegExp(r'\b([a-zA-Z0-9._%+-]{1,3})[a-zA-Z0-9._%+-]*@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b'),
      (match) => '${match.group(1)}***@${match.group(2)}',
    );

    return redacted;
  }

  /// Guarda un log en archivo
  static Future<void> _saveToFile(File? file, String message) async {
    if (file == null || !_initialized) return;

    try {
      final redactedMessage = _redactSensitiveData(message);
      await file.writeAsString(
        '$redactedMessage\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      stderr.writeln('⚠️ Error guardando log en archivo: $e');
    }
  }

  /// Log de nivel debug
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _saveToFile(_generalLogFile, '[DEBUG] ${DateTime.now().toIso8601String()} - $message');
  }

  /// Log de nivel info
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _saveToFile(_generalLogFile, '[INFO] ${DateTime.now().toIso8601String()} - $message');
  }

  /// Log de nivel warning
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _saveToFile(_generalLogFile, '[WARNING] ${DateTime.now().toIso8601String()} - $message');
  }

  /// Log de nivel error
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _saveToFile(_generalLogFile, '[ERROR] ${DateTime.now().toIso8601String()} - $message ${error != null ? '| Error: $error' : ''}');
  }

  /// Log de nivel fatal/crítico
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _saveToFile(_generalLogFile, '[FATAL] ${DateTime.now().toIso8601String()} - $message ${error != null ? '| Error: $error' : ''}');
  }

  // ========== LOGS DE SEGURIDAD (A09 - OWASP) ==========

  /// Registra un evento de seguridad en formato JSON estructurado
  ///
  /// Eventos incluyen:
  /// - Login exitoso/fallido
  /// - Creación/modificación/eliminación de usuarios
  /// - Cambios de permisos
  /// - Acceso denegado
  /// - Operaciones sensibles
  static Future<void> logSecurityEvent({
    required SecurityEventType eventType,
    required String userId,
    String? userEmail,
    String? targetUserId,
    String? targetResource,
    String? action,
    bool success = true,
    String? details,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'eventType': eventType.name,
      'severity': _getSeverity(eventType, success),
      'userId': userId,
      'userEmail': userEmail,
      'targetUserId': targetUserId,
      'targetResource': targetResource,
      'action': action,
      'success': success,
      'details': details,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };

    // Remover campos nulos
    logEntry.removeWhere((key, value) => value == null);

    final jsonLog = jsonEncode(logEntry);
    final emoji = success ? '✅' : '❌';
    final message = '$emoji SECURITY EVENT: ${eventType.name} - ${success ? 'SUCCESS' : 'FAILED'} - User: ${userEmail ?? userId}';

    // Log en consola
    if (success) {
      info(message);
    } else {
      warning(message);
    }

    // Guardar en archivo de seguridad
    await _saveToFile(_securityLogFile, jsonLog);
  }

  /// Determina la severidad del evento
  static String _getSeverity(SecurityEventType eventType, bool success) {
    if (!success) {
      switch (eventType) {
        case SecurityEventType.loginAttempt:
        case SecurityEventType.loginBlocked:
          return 'HIGH';
        case SecurityEventType.userDeletion:
        case SecurityEventType.permissionChange:
          return 'CRITICAL';
        default:
          return 'MEDIUM';
      }
    }

    switch (eventType) {
      case SecurityEventType.userCreation:
      case SecurityEventType.userDeletion:
      case SecurityEventType.permissionChange:
        return 'HIGH';
      case SecurityEventType.loginAttempt:
      case SecurityEventType.logout:
        return 'MEDIUM';
      default:
        return 'LOW';
    }
  }

  /// Obtiene los logs de seguridad de hoy
  static Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    if (_securityLogFile == null || !await _securityLogFile!.exists()) {
      return [];
    }

    try {
      final content = await _securityLogFile!.readAsString();
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty);

      return lines.map((line) {
        try {
          return jsonDecode(line) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{};
        }
      }).where((log) => log.isNotEmpty).toList();
    } catch (e) {
      error('Error leyendo logs de seguridad: $e');
      return [];
    }
  }

  /// Exporta logs de seguridad en formato JSON
  static Future<String?> exportSecurityLogs() async {
    try {
      final logs = await getSecurityLogs();
      return jsonEncode(logs);
    } catch (e) {
      error('Error exportando logs: $e');
      return null;
    }
  }
}

/// Tipos de eventos de seguridad según OWASP A09
enum SecurityEventType {
  loginAttempt,        // Intento de login (exitoso o fallido)
  loginBlocked,        // Login bloqueado por rate limiting
  logout,              // Cierre de sesión
  userCreation,        // Creación de usuario
  userModification,    // Modificación de usuario
  userDeletion,        // Eliminación/desactivación de usuario
  permissionChange,    // Cambio de permisos o roles
  accessDenied,        // Acceso denegado (403/401)
  sensitiveOperation,  // Operación sensible (transferencia, compra, etc.)
  dataExport,          // Exportación de datos
  configurationChange, // Cambio de configuración del sistema
}
