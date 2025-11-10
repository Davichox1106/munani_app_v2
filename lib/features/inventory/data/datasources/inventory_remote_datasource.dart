import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_remote_model.dart';

/// DataSource remoto para Inventory usando Supabase
///
/// OWASP A01: RLS habilitado en Supabase
/// OWASP A07: Autenticación con JWT
abstract class InventoryRemoteDataSource {
  Future<List<InventoryRemoteModel>> getAllInventory();
  Future<List<InventoryRemoteModel>> getInventoryByLocation(
    String locationId,
    String locationType,
  );
  Future<InventoryRemoteModel> getInventoryItem(String id);
  Future<InventoryRemoteModel> createInventoryItem(
    Map<String, dynamic> data,
  );
  Future<InventoryRemoteModel> updateInventoryItem(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteInventoryItem(String id);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  InventoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<InventoryRemoteModel>> getAllInventory() async {
    final response = await supabaseClient
        .from('inventory')
        .select()
        .order('last_updated', ascending: false);

    return (response as List)
        .map((json) => InventoryRemoteModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<InventoryRemoteModel>> getInventoryByLocation(
    String locationId,
    String locationType,
  ) async {
    final response = await supabaseClient
        .from('inventory')
        .select()
        .eq('location_id', locationId)
        .eq('location_type', locationType)
        .order('last_updated', ascending: false);

    return (response as List)
        .map((json) => InventoryRemoteModel.fromJson(json))
        .toList();
  }

  @override
  Future<InventoryRemoteModel> getInventoryItem(String id) async {
    final response = await supabaseClient
        .from('inventory')
        .select()
        .eq('id', id)
        .single();

    return InventoryRemoteModel.fromJson(response);
  }

  @override
  Future<InventoryRemoteModel> createInventoryItem(
    Map<String, dynamic> data,
  ) async {
    final response = await supabaseClient
        .from('inventory')
        .insert(data)
        .select()
        .single();

    return InventoryRemoteModel.fromJson(response);
  }

  @override
  Future<InventoryRemoteModel> updateInventoryItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await supabaseClient
        .from('inventory')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return InventoryRemoteModel.fromJson(response);
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    await supabaseClient.from('inventory').delete().eq('id', id);
  }
}
