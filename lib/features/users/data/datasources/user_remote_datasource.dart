import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/entities/user.dart' as domain;
import '../../../auth/data/models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

/// DataSource remoto para gestión de usuarios en Supabase
///
/// Operaciones administrativas de usuarios
/// Requiere privilegios de admin
abstract class UserRemoteDataSource {
  Future<List<domain.User>> getAllUsers();
  Future<domain.User> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedLocationId,
    String? assignedLocationType,
  });
  Future<domain.User> updateUser({
    required String userId,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
  });
  Future<void> deactivateUser(String userId);
  Future<domain.User> getUserById(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<domain.User>> getAllUsers() async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  @override
  Future<domain.User> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? assignedLocationId,
    String? assignedLocationType,
  }) async {
    try {
      AppLogger.debug('🔐 UserRemoteDataSource: Creando usuario via Edge Function...');
      
      // Llamar a Edge Function segura (tiene acceso al Service Role Key)
      final response = await supabaseClient.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (assignedLocationId != null) 'assignedLocationId': assignedLocationId,
          if (assignedLocationType != null) 'assignedLocationType': assignedLocationType,
        },
      );

      // Verificar errores
      if (response.status != 200) {
        final error = response.data?['error'] ?? 'Error desconocido';
        AppLogger.error('❌ Edge Function error: $error');
        throw Exception(error);
      }

      // Extraer usuario del response
      final userData = response.data['user'];
      if (userData == null) {
        throw Exception('Respuesta inválida del servidor');
      }

      AppLogger.info('✅ Usuario creado exitosamente: ${userData['name']}');

      // Convertir a UserModel
      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error('❌ Error al crear usuario: $e');
      throw Exception('Error al crear usuario: $e');
    }
  }

  @override
  Future<domain.User> updateUser({
    required String userId,
    String? name,
    String? role,
    String? assignedLocationId,
    String? assignedLocationType,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (assignedLocationId != null) {
        updates['assigned_location_id'] = assignedLocationId;
      } else if (assignedLocationId == null && assignedLocationType == null) {
        updates['assigned_location_id'] = null;
      }
      if (assignedLocationType != null) {
        updates['assigned_location_type'] = assignedLocationType;
      } else if (assignedLocationId == null && assignedLocationType == null) {
        updates['assigned_location_type'] = null;
      }

      if (assignedLocationId != null && assignedLocationType != null) {
        if (assignedLocationType == 'store') {
          final storeData = await supabaseClient
              .from('stores')
              .select('name')
              .eq('id', assignedLocationId)
              .maybeSingle();
          updates['assigned_location_name'] = storeData?['name'];
        } else if (assignedLocationType == 'warehouse') {
          final warehouseData = await supabaseClient
              .from('warehouses')
              .select('name')
              .eq('id', assignedLocationId)
              .maybeSingle();
          updates['assigned_location_name'] = warehouseData?['name'];
        }
      } else if (assignedLocationId == null && assignedLocationType == null) {
        updates['assigned_location_name'] = null;
      }

      if (isActive != null) updates['is_active'] = isActive;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await supabaseClient.from('users').update(updates).eq('id', userId);

      return await getUserById(userId);
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  @override
  Future<void> deactivateUser(String userId) async {
    try {
      await supabaseClient
          .from('users')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al desactivar usuario: $e');
    }
  }

  @override
  Future<domain.User> getUserById(String userId) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }
}
