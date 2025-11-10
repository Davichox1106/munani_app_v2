import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transfer_request_local_model.dart';
import 'transfer_remote_datasource.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del datasource remoto para transferencias usando Supabase
class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final SupabaseClient supabaseClient;

  TransferRemoteDataSourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<List<TransferRequestLocalModel>> getAllTransfers() async {
    try {
      AppLogger.debug('🔍 DEBUG TRANSFERS: Obteniendo transferencias desde Supabase...');

      // Ver el JWT actual
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        AppLogger.debug('🔑 JWT Claims: ${session.user.userMetadata}');
        AppLogger.debug('🔑 App Metadata: ${session.user.appMetadata}');
        AppLogger.debug('🔑 User ID: ${session.user.id}');
      } else {
        AppLogger.warning('⚠️ No hay sesión activa');
      }

      final response = await supabaseClient
          .from('transfers')
          .select()
          .order('requested_at', ascending: false);

      AppLogger.debug('📊 Respuesta de Supabase: ${response.length} transferencias');
      if (response.isEmpty) {
        AppLogger.warning('⚠️ RLS bloqueó las transferencias o no hay datos');
        AppLogger.debug('   Verifica que:');
        AppLogger.debug('   1. public.is_store_manager() retorna TRUE');
        AppLogger.debug('   2. assigned_location_id en JWT coincide con from_location_id o to_location_id');
        AppLogger.debug('   3. from_location_type o to_location_type es "store"');
      } else {
        AppLogger.info('✅ Transferencias obtenidas correctamente');
        for (var item in response) {
          AppLogger.debug('   - ID: ${item['id']}');
          AppLogger.debug('     FROM: ${item['from_location_id']} (${item['from_location_type']})');
          AppLogger.debug('     TO: ${item['to_location_id']} (${item['to_location_type']})');
          AppLogger.debug('     STATUS: ${item['status']}');
        }
      }

      return (response as List)
          .map((json) => TransferRequestLocalModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('❌ Error al obtener transferencias: $e');
      throw ServerException('Error al obtener transferencias: $e');
    }
  }

  @override
  Future<List<TransferRequestLocalModel>> getTransfersByLocation(
    String locationId,
    String locationType,
  ) async {
    try {
      final response = await supabaseClient
          .from('transfers')
          .select()
          .or('from_location_id.eq.$locationId,to_location_id.eq.$locationId')
          .eq('from_location_type', locationType)
          .order('requested_at', ascending: false);

      return (response as List)
          .map((json) => TransferRequestLocalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener transferencias por ubicación: $e');
    }
  }

  @override
  Future<List<TransferRequestLocalModel>> getPendingTransfersByLocation(
    String locationId,
    String locationType,
  ) async {
    try {
      final response = await supabaseClient
          .from('transfers')
          .select()
          .eq('to_location_id', locationId)
          .eq('to_location_type', locationType)
          .eq('status', 'pending')
          .order('requested_at', ascending: false);

      return (response as List)
          .map((json) => TransferRequestLocalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener transferencias pendientes: $e');
    }
  }

  @override
  Future<List<TransferRequestLocalModel>> getTransfersByUser(String userId) async {
    try {
      final response = await supabaseClient
          .from('transfers')
          .select()
          .eq('requested_by', userId)
          .order('requested_at', ascending: false);

      return (response as List)
          .map((json) => TransferRequestLocalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener transferencias por usuario: $e');
    }
  }

  @override
  Future<TransferRequestLocalModel> createTransfer(TransferRequestLocalModel transfer) async {
    try {
      final jsonData = transfer.toJson();
      AppLogger.debug('🔍 RemoteDataSource: JSON completo a enviar:');
      AppLogger.debug('   updated_by: ${jsonData['updated_by']}');
      AppLogger.debug('   requested_by: ${jsonData['requested_by']}');
      
      final response = await supabaseClient
          .from('transfers')
          .insert(jsonData)
          .select()
          .single();

      return TransferRequestLocalModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al crear transferencia: $e');
    }
  }

  @override
  Future<TransferRequestLocalModel> updateTransfer(TransferRequestLocalModel transfer) async {
    try {
      final response = await supabaseClient
          .from('transfers')
          .update(transfer.toJson())
          .eq('id', transfer.uuid)
          .select()
          .single();

      return TransferRequestLocalModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al actualizar transferencia: $e');
    }
  }

  @override
  Future<void> deleteTransfer(String transferId) async {
    try {
      await supabaseClient
          .from('transfers')
          .delete()
          .eq('id', transferId);
    } catch (e) {
      throw ServerException('Error al eliminar transferencia: $e');
    }
  }

  @override
  Future<List<TransferRequestLocalModel>> searchTransfers(String query) async {
    try {
      final response = await supabaseClient
          .from('transfers')
          .select()
          .or('product_name.ilike.%$query%,variant_name.ilike.%$query%,from_location_name.ilike.%$query%,to_location_name.ilike.%$query%')
          .order('requested_at', ascending: false);

      return (response as List)
          .map((json) => TransferRequestLocalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Error al buscar transferencias: $e');
    }
  }

  @override
  Future<TransferRequestLocalModel?> getTransferById(String transferId) async {
    try {
      final response = await supabaseClient
          .from('transfers')
          .select()
          .eq('id', transferId)
          .maybeSingle();

      if (response == null) return null;
      return TransferRequestLocalModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al obtener transferencia: $e');
    }
  }
}