import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warehouse_remote_model.dart';

/// Remote datasource for warehouses (Supabase)
abstract class WarehouseRemoteDataSource {
  Future<List<WarehouseRemoteModel>> getAllWarehouses();
  Future<WarehouseRemoteModel> getWarehouseById(String id);
  Future<WarehouseRemoteModel> createWarehouse(WarehouseRemoteModel warehouse);
  Future<WarehouseRemoteModel> updateWarehouse(WarehouseRemoteModel warehouse);
  Future<void> deleteWarehouse(String id);
}

class WarehouseRemoteDataSourceImpl implements WarehouseRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String _tableName = 'warehouses';

  WarehouseRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<WarehouseRemoteModel>> getAllWarehouses() async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => WarehouseRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener almacenes: $e');
    }
  }

  @override
  Future<WarehouseRemoteModel> getWarehouseById(String id) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return WarehouseRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener almacén: $e');
    }
  }

  @override
  Future<WarehouseRemoteModel> createWarehouse(WarehouseRemoteModel warehouse) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .insert(warehouse.toJson())
          .select()
          .single();

      return WarehouseRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear almacén: $e');
    }
  }

  @override
  Future<WarehouseRemoteModel> updateWarehouse(WarehouseRemoteModel warehouse) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .update(warehouse.toJson())
          .eq('id', warehouse.id)
          .select()
          .single();

      return WarehouseRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar almacén: $e');
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      // Soft delete: marcar como inactivo
      await supabaseClient
          .from(_tableName)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar almacén: $e');
    }
  }
}
