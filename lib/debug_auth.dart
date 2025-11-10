import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:munani_app/core/utils/app_logger.dart';

/// Utilidad para depurar problemas de autenticación
class DebugAuth {
  /// Verificar el usuario actual y sus permisos
  static Future<void> debugCurrentUser() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      AppLogger.debug('🔍 DEBUG AUTH - Usuario actual:');
      AppLogger.debug('   ID: ${currentUser?.id}');
      AppLogger.debug('   Email: ${currentUser?.email}');
      AppLogger.debug('   Verificado: ${currentUser?.emailConfirmedAt != null}');
      
      // Verificar JWT claims
      final session = supabase.auth.currentSession;
      if (session != null) {
        AppLogger.debug('   JWT Claims: ${session.user.appMetadata}');
        AppLogger.debug('   User Role: ${session.user.appMetadata['user_role']}');

        // Verificar si es admin
        final isAdmin = session.user.appMetadata['user_role'] == 'admin';
        AppLogger.debug('   Es Admin: $isAdmin');

        if (!isAdmin) {
          AppLogger.error('❌ ERROR: Usuario actual NO es admin');
          AppLogger.info('   Solución: Iniciar sesión con usuario admin');
        } else {
          AppLogger.debug('✅ Usuario actual ES admin - puede crear usuarios');
        }
      } else {
        AppLogger.error('❌ ERROR: No hay sesión activa');
        AppLogger.info('   Solución: Iniciar sesión');
      }
      
      // Verificar datos del usuario en la tabla users
      if (currentUser != null) {
        try {
          final userData = await supabase
              .from('users')
              .select()
              .eq('email', currentUser.email!)
              .single();
          
          AppLogger.debug('   Datos en BD:');
          AppLogger.debug('     Nombre: ${userData['name']}');
          AppLogger.debug('     Rol: ${userData['role']}');
          AppLogger.debug('     Activo: ${userData['is_active']}');

          if (userData['role'] != 'admin') {
            AppLogger.error('❌ ERROR: Usuario en BD NO es admin');
            AppLogger.info('   Solución: Actualizar rol en BD');
          }
        } catch (e) {
          AppLogger.error('❌ ERROR: No se pudo obtener datos del usuario: $e');
        }
      }
      
    } catch (e) {
      AppLogger.error('❌ ERROR en debug: $e');
    }
  }
  
  /// Verificar si el usuario actual puede crear usuarios
  static Future<bool> canCreateUsers() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      if (session == null) {
        AppLogger.error('❌ No hay sesión activa');
        return false;
      }

      final isAdmin = session.user.appMetadata['user_role'] == 'admin';
      AppLogger.debug('🔍 Puede crear usuarios: $isAdmin');

      return isAdmin;
    } catch (e) {
      AppLogger.error('❌ Error verificando permisos: $e');
      return false;
    }
  }
}





















