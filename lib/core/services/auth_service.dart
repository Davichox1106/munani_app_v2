import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../di/injection_container.dart' as di;
import '../../core/utils/app_logger.dart';

/// Servicio para manejo de autenticación y JWT
/// 
/// OWASP A07:2021 - Identification and Authentication Failures
/// - Maneja refresh automático del JWT
/// - Verifica roles en tiempo real
/// - Gestiona sesiones seguras
class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Verificar si el JWT actual tiene el rol necesario
  static bool hasRole(String requiredRole) {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      final userRole = user.appMetadata['user_role'] as String?;
      return userRole == requiredRole;
    } catch (e) {
      AppLogger.error('❌ Error verificando rol: $e');
      return false;
    }
  }

  /// Verificar si el usuario es admin
  static bool isAdmin() {
    return hasRole('admin');
  }

  /// Verificar si el usuario es manager (store o warehouse)
  static bool isManager() {
    return hasRole('store_manager') || hasRole('warehouse_manager');
  }

  /// Verificar si el usuario es admin o manager
  static bool isAdminOrManager() {
    return isAdmin() || isManager();
  }

  /// Forzar refresh del JWT
  /// 
  /// ESTRATEGIA: Si el JWT no tiene rol pero el usuario SÍ tiene rol en BD,
  /// forzamos un logout completo para que haga re-login y obtenga JWT fresco
  static Future<bool> refreshJWT() async {
    try {
      AppLogger.debug('🔄 Intentando refresh del JWT...');
      
      // Obtener el usuario actual
      final user = _client.auth.currentUser;
      if (user == null) {
        AppLogger.error('❌ No hay usuario autenticado en Supabase');
        await _performCompleteLogout();
        return false;
      }

      // Verificar si el usuario tiene rol en BD
      final bdRole = await _getUserRoleFromDB(user.id);
      if (bdRole == null) {
        AppLogger.error('❌ Usuario no existe en BD o no tiene rol');
        await _performCompleteLogout();
        return false;
      }

      AppLogger.debug('   → Usuario SÍ tiene rol en BD: $bdRole');
      
      // Intentar refresh normal primero
      try {
        final response = await _client.auth.refreshSession();
        if (response.session != null) {
          final role = response.session?.user.userMetadata?['user_role'];
          if (role != null) {
            AppLogger.info('✅ JWT refrescado exitosamente con rol: $role');
            return true;
          } else {
            AppLogger.warning('⚠️ refreshSession() no incluye rol en metadata');
            AppLogger.debug('🚪 Forzando logout completo para obtener JWT fresco...');
            await _performCompleteLogout();
            return false;
          }
        }
      } catch (e) {
        AppLogger.warning('⚠️ Refresh normal falló: $e');
      }

      // Si llegamos aquí, el refresh falló completamente
      AppLogger.error('❌ No se pudo refrescar JWT');
      await _performCompleteLogout();
      return false;
      
    } catch (e) {
      AppLogger.error('❌ Error refrescando JWT: $e');
      await _performCompleteLogout();
      return false;
    }
  }

  /// Verificar si el JWT necesita refresh
  /// 
  /// Un JWT necesita refresh si:
  /// - No tiene el rol en userMetadata
  /// - El rol no coincide con el de la BD
  static Future<bool> needsJWTRefresh() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return true;

      final jwtRole = user.userMetadata?['user_role'] as String?;
      
      // Si no tiene rol en JWT, verificar en BD primero
      if (jwtRole == null) {
        AppLogger.warning('⚠️ JWT no tiene rol');
        
        // Verificar si el usuario existe en BD y tiene rol
        final bdRole = await _getUserRoleFromDB(user.id);
        if (bdRole != null) {
          AppLogger.debug('   → Usuario SÍ tiene rol en BD: $bdRole');
          AppLogger.debug('   → Necesita re-login para obtener JWT fresco');
          return true; // Necesita re-login completo
        } else {
          AppLogger.debug('   → Usuario NO existe en BD');
          return true;
        }
      }

      // Verificar que el rol en JWT coincida con el de la BD
      final bdRole = await _getUserRoleFromDB(user.id);
      if (bdRole != null && bdRole != jwtRole) {
        AppLogger.warning('⚠️ Rol en JWT ($jwtRole) no coincide con BD ($bdRole), necesita refresh');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('❌ Error verificando necesidad de refresh: $e');
      return true; // En caso de error, asumir que necesita refresh
    }
  }

  /// Obtener rol del usuario desde la BD
  static Future<String?> _getUserRoleFromDB(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();
      
      return response['role'] as String?;
    } catch (e) {
      AppLogger.error('❌ Error obteniendo rol de BD: $e');
      return null;
    }
  }

  /// Forzar logout si el JWT no se puede refrescar
  /// 
  /// NOTA: Ya no se usa, dejamos que Supabase maneje el logout automáticamente
  @Deprecated('Ya no se necesita, Supabase maneja el logout automáticamente')
  static Future<void> forceLogout() async {
    try {
      AppLogger.debug('🚪 Forzando logout por JWT inválido...');
      await _client.auth.signOut();
    } catch (e) {
      AppLogger.error('❌ Error en logout forzado: $e');
    }
  }

  /// Verificar y refrescar JWT si es necesario
  /// 
  /// SOLUCIÓN CORRECTA: Forzar logout si JWT no tiene rol
  /// Esto obliga al usuario a re-login y obtener JWT fresco con rol
  static Future<bool> ensureValidJWT() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        AppLogger.error('❌ No hay usuario autenticado');
        return false;
      }

      // Verificar si el JWT tiene el rol (en appMetadata, no userMetadata)
      final jwtRole = user.appMetadata['user_role'] as String?;
      if (jwtRole != null) {
        AppLogger.info('✅ JWT válido con rol: $jwtRole');
        return true;
      }

      // JWT no tiene rol, verificar en BD
      final bdRole = await _getUserRoleFromDB(user.id);
      if (bdRole == null) {
        AppLogger.error('❌ Usuario no tiene rol en BD');
        return false;
      }

      AppLogger.warning('⚠️ JWT sin rol pero usuario SÍ tiene rol en BD: $bdRole');
      AppLogger.debug('🚪 Forzando logout para obtener JWT fresco con rol...');
      
      // Forzar logout para que haga re-login y obtenga JWT con rol
      await _performCompleteLogout();
      return false;
      
    } catch (e) {
      AppLogger.error('❌ Error en ensureValidJWT: $e');
      return false;
    }
  }

  /// Realizar logout completo (Supabase + Isar)
  /// 
  /// Este método debe llamar al AuthRepository para limpiar correctamente
  /// tanto la sesión de Supabase como el caché local de Isar
  static Future<void> _performCompleteLogout() async {
    try {
      AppLogger.debug('🚪 _performCompleteLogout: Iniciando logout completo...');
      
      // Obtener el repositorio de autenticación
      final authRepo = di.sl<AuthRepository>();
      
      // Llamar al método logout del repositorio
      // Esto limpiará Isar Y cerrará sesión en Supabase
      final result = await authRepo.logout();
      
      result.fold(
        (failure) {
          AppLogger.error('❌ Error en logout del repositorio: ${failure.message}');
          // Intentar logout directo de Supabase
          _client.auth.signOut();
        },
        (_) => AppLogger.info('✅ Logout completo ejecutado (Supabase + Isar)'),
      );
    } catch (e) {
      // Si falla, al menos intentar limpiar Supabase
      AppLogger.error('❌ Error en logout completo: $e');
      AppLogger.warning('⚠️ Intentando logout solo de Supabase...');
      await _client.auth.signOut();
    }
  }
}
