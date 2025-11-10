import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Servicio de Rate Limiting para prevenir ataques de fuerza bruta
///
/// Características (según OWASP ASVS 2.2.1):
/// - Bloqueo temporal después de N intentos fallidos
/// - Incremento exponencial del tiempo de bloqueo
/// - Registro de intentos de login
/// - Limpieza automática de registros antiguos
class RateLimiterService {
  static const String _keyPrefix = 'rate_limiter_';
  static const String _blockPrefix = 'blocked_until_';
  static const int maxAttempts = 5; // Máximo intentos antes de bloquear
  static const Duration attemptWindow = Duration(minutes: 15); // Ventana de tiempo
  static const Duration initialBlockDuration = Duration(minutes: 5); // Primer bloqueo
  static const Duration maxBlockDuration = Duration(hours: 1); // Máximo bloqueo

  final SharedPreferences _prefs;

  RateLimiterService(this._prefs);

  /// Registra un intento de login fallido
  ///
  /// Retorna true si el usuario está bloqueado
  Future<bool> recordFailedAttempt(String email) async {
    final now = DateTime.now();
    final key = _getAttemptsKey(email);
    final blockKey = _getBlockKey(email);

    // Verificar si ya está bloqueado
    if (await isBlocked(email)) {
      AppLogger.warning('🚫 Rate Limiter: Usuario $email está bloqueado');
      return true;
    }

    // Obtener intentos previos
    final attempts = await _getAttempts(email);

    // Agregar nuevo intento
    attempts.add(now.millisecondsSinceEpoch);

    // Guardar intentos
    await _prefs.setStringList(
      key,
      attempts.map((a) => a.toString()).toList(),
    );

    AppLogger.debug('🔒 Rate Limiter: Intento fallido registrado para $email (${attempts.length}/$maxAttempts)');

    // Verificar si se excedió el límite
    if (attempts.length >= maxAttempts) {
      // Calcular duración del bloqueo (aumenta exponencialmente)
      final blockCount = await _getBlockCount(email);
      final blockDuration = _calculateBlockDuration(blockCount);
      final blockedUntil = now.add(blockDuration);

      // Guardar bloqueo
      await _prefs.setInt(blockKey, blockedUntil.millisecondsSinceEpoch);
      await _incrementBlockCount(email);

      AppLogger.warning('⛔ Rate Limiter: Usuario $email BLOQUEADO por ${blockDuration.inMinutes} minutos (bloqueo #${blockCount + 1})');

      // Limpiar intentos
      await _prefs.remove(key);

      return true;
    }

    return false;
  }

  /// Registra un login exitoso (limpia intentos fallidos)
  Future<void> recordSuccessfulAttempt(String email) async {
    final key = _getAttemptsKey(email);
    final blockKey = _getBlockKey(email);
    final blockCountKey = _getBlockCountKey(email);

    // Limpiar todos los registros
    await _prefs.remove(key);
    await _prefs.remove(blockKey);
    await _prefs.remove(blockCountKey);

    AppLogger.debug('✅ Rate Limiter: Login exitoso para $email, registros limpiados');
  }

  /// Verifica si un usuario está bloqueado
  Future<bool> isBlocked(String email) async {
    final blockKey = _getBlockKey(email);
    final blockedUntil = _prefs.getInt(blockKey);

    if (blockedUntil == null) {
      return false;
    }

    final now = DateTime.now();
    final blockTime = DateTime.fromMillisecondsSinceEpoch(blockedUntil);

    // Si el tiempo de bloqueo ya pasó, desbloquear
    if (now.isAfter(blockTime)) {
      await _prefs.remove(blockKey);
      AppLogger.debug('🔓 Rate Limiter: Bloqueo expirado para $email');
      return false;
    }

    return true;
  }

  /// Obtiene el tiempo restante de bloqueo en minutos
  Future<int> getRemainingBlockTime(String email) async {
    final blockKey = _getBlockKey(email);
    final blockedUntil = _prefs.getInt(blockKey);

    if (blockedUntil == null) {
      return 0;
    }

    final now = DateTime.now();
    final blockTime = DateTime.fromMillisecondsSinceEpoch(blockedUntil);

    if (now.isAfter(blockTime)) {
      return 0;
    }

    final remaining = blockTime.difference(now);
    return remaining.inMinutes + 1; // +1 para redondear hacia arriba
  }

  /// Obtiene el número de intentos fallidos actuales
  Future<int> getFailedAttempts(String email) async {
    final attempts = await _getAttempts(email);
    return attempts.length;
  }

  /// Limpia todos los registros de rate limiting (admin only)
  Future<void> clearAllRecords() async {
    final keys = _prefs.getKeys().where((k) =>
      k.startsWith(_keyPrefix) || k.startsWith(_blockPrefix)
    ).toList();

    for (final key in keys) {
      await _prefs.remove(key);
    }

    AppLogger.info('🗑️ Rate Limiter: Todos los registros limpiados');
  }

  /// Desbloquea manualmente un usuario (admin only)
  Future<void> unblockUser(String email) async {
    final blockKey = _getBlockKey(email);
    final key = _getAttemptsKey(email);

    await _prefs.remove(blockKey);
    await _prefs.remove(key);

    AppLogger.info('🔓 Rate Limiter: Usuario $email desbloqueado manualmente');
  }

  // ==================== MÉTODOS PRIVADOS ====================

  String _getAttemptsKey(String email) => '$_keyPrefix${email.toLowerCase()}';
  String _getBlockKey(String email) => '$_blockPrefix${email.toLowerCase()}';
  String _getBlockCountKey(String email) => '${_keyPrefix}block_count_${email.toLowerCase()}';

  /// Obtiene los intentos fallidos dentro de la ventana de tiempo
  Future<List<int>> _getAttempts(String email) async {
    final key = _getAttemptsKey(email);
    final raw = _prefs.getStringList(key) ?? [];

    final now = DateTime.now();
    final cutoff = now.subtract(attemptWindow);

    // Filtrar solo intentos dentro de la ventana de tiempo
    final validAttempts = raw
        .map((s) => int.parse(s))
        .where((timestamp) {
          final attemptTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return attemptTime.isAfter(cutoff);
        })
        .toList();

    return validAttempts;
  }

  /// Obtiene el contador de bloqueos
  Future<int> _getBlockCount(String email) async {
    final key = _getBlockCountKey(email);
    return _prefs.getInt(key) ?? 0;
  }

  /// Incrementa el contador de bloqueos
  Future<void> _incrementBlockCount(String email) async {
    final key = _getBlockCountKey(email);
    final current = await _getBlockCount(email);
    await _prefs.setInt(key, current + 1);
  }

  /// Calcula la duración del bloqueo (exponencial)
  Duration _calculateBlockDuration(int blockCount) {
    // Bloqueo 1: 5 minutos
    // Bloqueo 2: 10 minutos
    // Bloqueo 3: 20 minutos
    // Bloqueo 4+: 60 minutos (máximo)

    final minutes = (initialBlockDuration.inMinutes * (1 << blockCount)).clamp(
      initialBlockDuration.inMinutes,
      maxBlockDuration.inMinutes,
    );

    return Duration(minutes: minutes);
  }
}
