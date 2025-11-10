import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store_remote_model.dart';

/// Remote datasource for stores (Supabase)
abstract class StoreRemoteDataSource {
  Future<List<StoreRemoteModel>> getAllStores();
  Future<StoreRemoteModel> getStoreById(String id);
  Future<StoreRemoteModel> createStore(StoreRemoteModel store);
  Future<StoreRemoteModel> updateStore(StoreRemoteModel store);
  Future<void> deleteStore(String id);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String _tableName = 'stores';

  StoreRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StoreRemoteModel>> getAllStores() async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => StoreRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tiendas: $e');
    }
  }

  @override
  Future<StoreRemoteModel> getStoreById(String id) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return StoreRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener tienda: $e');
    }
  }

  @override
  Future<StoreRemoteModel> createStore(StoreRemoteModel store) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .insert(store.toJson())
          .select()
          .single();

      return StoreRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear tienda: $e');
    }
  }

  @override
  Future<StoreRemoteModel> updateStore(StoreRemoteModel store) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .update(store.toJson())
          .eq('id', store.id)
          .select()
          .single();

      return StoreRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar tienda: $e');
    }
  }

  @override
  Future<void> deleteStore(String id) async {
    try {
      // Soft delete: marcar como inactiva
      await supabaseClient
          .from(_tableName)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar tienda: $e');
    }
  }
}
