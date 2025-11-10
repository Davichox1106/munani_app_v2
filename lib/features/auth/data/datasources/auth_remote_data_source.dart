import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Contrato para el data source remoto de autenticación
abstract class AuthRemoteDataSource {
  /// Inicia sesión con email y contraseña
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  /// Cierra la sesión del usuario actual
  Future<void> logout();

  /// Obtiene el usuario actual autenticado
  Future<UserModel> getCurrentUser();

  /// Stream que emite el estado de autenticación
  Stream<UserModel?> get authStateChanges;

  /// Actualiza el perfil del usuario
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? assignedLocationId,
    String? assignedLocationType,
  });

  /// Cambia la contraseña del usuario
  Future<void> changePassword({
    required String newPassword,
  });

  /// Solicita recuperación de contraseña
  Future<void> resetPassword({
    required String email,
  });
}

/// Implementación del data source remoto usando Supabase
///
/// OWASP A07:2021 - Identification and Authentication Failures:
/// - Usa JWT tokens manejados por Supabase
/// - Implementa refresh tokens automáticamente
/// - No almacena credenciales en el cliente
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // OWASP A07: Autenticación segura con Supabase Auth
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('No se pudo obtener el usuario');
      }

      // Obtener datos del usuario
      final userData = await supabaseClient
          .from('users')
          .select('*')
          .eq('email', response.user!.email!)
          .single();

      // Enriquecer con nombre de ubicación si es necesario
      final enrichedUserData = Map<String, dynamic>.from(userData);
      
      // Solo intentar obtener el nombre de ubicación si el usuario tiene una asignada
      if (userData['assigned_location_id'] != null && userData['assigned_location_type'] != null) {
        try {
          if (userData['assigned_location_type'] == 'store') {
            final storeData = await supabaseClient
                .from('stores')
                .select('name')
                .eq('id', userData['assigned_location_id'])
                .maybeSingle();
            
            if (storeData != null) {
              enrichedUserData['assigned_location_name'] = storeData['name'];
            }
          } else if (userData['assigned_location_type'] == 'warehouse') {
            final warehouseData = await supabaseClient
                .from('warehouses')
                .select('name')
                .eq('id', userData['assigned_location_id'])
                .maybeSingle();
            
            if (warehouseData != null) {
              enrichedUserData['assigned_location_name'] = warehouseData['name'];
            }
          }
        } catch (e) {
          // Si falla la consulta de ubicación, continuar sin el nombre
          AppLogger.warning('⚠️ No se pudo obtener nombre de ubicación: $e');
        }
      }

      return UserModel.fromJson(enrichedUserData);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // OWASP A07: Validación de contraseña se hace en el servidor
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );

      if (response.user == null) {
        throw AuthException('No se pudo crear el usuario');
      }

      // El trigger de Supabase crea automáticamente el registro en la tabla users
      // Esperamos un momento para que se ejecute el trigger
      await Future.delayed(const Duration(milliseconds: 500));

      // Obtener datos del usuario creado
      final userData = await supabaseClient
          .from('users')
          .select('*')
          .eq('id', response.user!.id)
          .single();

      // Enriquecer con nombre de ubicación si es necesario
      final enrichedUserData = Map<String, dynamic>.from(userData);
      
      // Solo intentar obtener el nombre de ubicación si el usuario tiene una asignada
      if (userData['assigned_location_id'] != null && userData['assigned_location_type'] != null) {
        try {
          if (userData['assigned_location_type'] == 'store') {
            final storeData = await supabaseClient
                .from('stores')
                .select('name')
                .eq('id', userData['assigned_location_id'])
                .maybeSingle();
            
            if (storeData != null) {
              enrichedUserData['assigned_location_name'] = storeData['name'];
            }
          } else if (userData['assigned_location_type'] == 'warehouse') {
            final warehouseData = await supabaseClient
                .from('warehouses')
                .select('name')
                .eq('id', userData['assigned_location_id'])
                .maybeSingle();
            
            if (warehouseData != null) {
              enrichedUserData['assigned_location_name'] = warehouseData['name'];
            }
          }
        } catch (e) {
          // Si falla la consulta de ubicación, continuar sin el nombre
          AppLogger.warning('⚠️ No se pudo obtener nombre de ubicación: $e');
        }
      }

      return UserModel.fromJson(enrichedUserData);
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        throw AuthException('Este email ya está registrado');
      }
      throw AuthException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        throw AuthException('No hay sesión activa');
      }

      // Obtener datos completos del usuario
      final userData = await supabaseClient
          .from('users')
          .select('*')
          .eq('email', currentUser.email!)
          .single();

      // Enriquecer con nombre de ubicación si es necesario
      final enrichedUserData = Map<String, dynamic>.from(userData);
      
      // Solo intentar obtener el nombre de ubicación si el usuario tiene una asignada
      if (userData['assigned_location_id'] != null && userData['assigned_location_type'] != null) {
        try {
          if (userData['assigned_location_type'] == 'store') {
            final storeData = await supabaseClient
                .from('stores')
                .select('name')
                .eq('id', userData['assigned_location_id'])
                .maybeSingle();
            
            if (storeData != null) {
              enrichedUserData['assigned_location_name'] = storeData['name'];
            }
          } else if (userData['assigned_location_type'] == 'warehouse') {
            final warehouseData = await supabaseClient
                .from('warehouses')
                .select('name')
                .eq('id', userData['assigned_location_id'])
                .maybeSingle();
            
            if (warehouseData != null) {
              enrichedUserData['assigned_location_name'] = warehouseData['name'];
            }
          }
        } catch (e) {
          // Si falla la consulta de ubicación, continuar sin el nombre
          AppLogger.warning('⚠️ No se pudo obtener nombre de ubicación: $e');
        }
      }

      return UserModel.fromJson(enrichedUserData);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al obtener usuario actual: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;

      if (user == null) {
        return null;
      }

      try {
        final userData = await supabaseClient
            .from('users')
            .select('*')
            .eq('email', user.email!)
            .single();

        // Enriquecer con nombre de ubicación si es necesario
        final enrichedUserData = Map<String, dynamic>.from(userData);
        
        // Solo intentar obtener el nombre de ubicación si el usuario tiene una asignada
        if (userData['assigned_location_id'] != null && userData['assigned_location_type'] != null) {
          try {
            if (userData['assigned_location_type'] == 'store') {
              final storeData = await supabaseClient
                  .from('stores')
                  .select('name')
                  .eq('id', userData['assigned_location_id'])
                  .maybeSingle();
              
              if (storeData != null) {
                enrichedUserData['assigned_location_name'] = storeData['name'];
              }
            } else if (userData['assigned_location_type'] == 'warehouse') {
              final warehouseData = await supabaseClient
                  .from('warehouses')
                  .select('name')
                  .eq('id', userData['assigned_location_id'])
                  .maybeSingle();
              
              if (warehouseData != null) {
                enrichedUserData['assigned_location_name'] = warehouseData['name'];
              }
            }
          } catch (e) {
            // Si falla la consulta de ubicación, continuar sin el nombre
            AppLogger.warning('⚠️ No se pudo obtener nombre de ubicación: $e');
          }
        }

        return UserModel.fromJson(enrichedUserData);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? assignedLocationId,
    String? assignedLocationType,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (assignedLocationId != null) {
        updates['assigned_location_id'] = assignedLocationId;
      }
      if (assignedLocationType != null) {
        updates['assigned_location_type'] = assignedLocationType;
      }

      final userData = await supabaseClient
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(userData);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String newPassword,
  }) async {
    try {
      // OWASP A07: Cambio de contraseña seguro
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException('Error al cambiar contraseña: $e');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException('Error al solicitar recuperación de contraseña: $e');
    }
  }
}
