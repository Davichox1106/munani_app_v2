import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:munani_app/core/utils/app_logger.dart';

/// Utilidad simple para depurar autenticación
class DebugAuthSimple {
  /// Verificar estado de autenticación actual
  static void debugAuth() {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final session = supabase.auth.currentSession;

    AppLogger.debug('🔍 DEBUG AUTH SIMPLE:');
    AppLogger.debug('   Usuario actual: ${currentUser?.email}');
    AppLogger.debug('   Sesión activa: ${session != null}');

    if (session != null) {
      AppLogger.debug('   JWT Claims: ${session.user.appMetadata}');
      AppLogger.debug('   User Role: ${session.user.appMetadata['user_role']}');

      final isAdmin = session.user.appMetadata['user_role'] == 'admin';
      AppLogger.debug('   Es Admin: $isAdmin');

      if (isAdmin) {
        AppLogger.debug('✅ PERFECTO: Usuario autenticado como admin');
      } else {
        AppLogger.error('❌ ERROR: Usuario NO es admin');
      }
    } else {
      AppLogger.error('❌ ERROR: No hay sesión activa');
      AppLogger.info('   Solución: Iniciar sesión en la app');
    }
  }

  /// Verificar si puede crear usuarios
  static bool canCreateUsers() {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      AppLogger.error('❌ No hay sesión activa');
      return false;
    }

    final isAdmin = session.user.appMetadata['user_role'] == 'admin';
    AppLogger.debug('🔍 Puede crear usuarios: $isAdmin');

    return isAdmin;
  }
}





















