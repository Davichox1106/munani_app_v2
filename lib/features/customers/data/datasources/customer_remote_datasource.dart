import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_remote_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerRemoteModel>> getAll();
  Future<CustomerRemoteModel> getById(String id);
  Future<CustomerRemoteModel> getByCi(String ci);
  Future<CustomerRemoteModel> create(Map<String, dynamic> data);
  Future<CustomerRemoteModel> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;
  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CustomerRemoteModel>> getAll() async {
    final res = await supabaseClient.from('customers').select('*').order('name');
    return (res as List).map((j) => CustomerRemoteModel.fromJson(j)).toList();
  }

  @override
  Future<CustomerRemoteModel> getById(String id) async {
    final res = await supabaseClient.from('customers').select('*').eq('id', id).single();
    return CustomerRemoteModel.fromJson(res);
  }

  @override
  Future<CustomerRemoteModel> getByCi(String ci) async {
    final res = await supabaseClient.from('customers').select('*').eq('ci', ci).single();
    return CustomerRemoteModel.fromJson(res);
  }

  @override
  Future<CustomerRemoteModel> create(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    await _ensureLocationName(payload);
    final res = await supabaseClient.from('customers').insert(payload).select().single();
    return CustomerRemoteModel.fromJson(res);
  }

  @override
  Future<CustomerRemoteModel> update(String id, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    await _ensureLocationName(payload);
    final res = await supabaseClient.from('customers').update(payload).eq('id', id).select().single();
    return CustomerRemoteModel.fromJson(res);
  }

  @override
  Future<void> delete(String id) async {
    await supabaseClient.from('customers').delete().eq('id', id);
  }

  Future<void> _ensureLocationName(Map<String, dynamic> payload) async {
    final locationId = payload['assigned_location_id'] as String?;
    final locationType = payload['assigned_location_type'] as String?;

    if (locationId == null || locationType == null) {
      payload['assigned_location_name'] = null;
      return;
    }

    if (payload.containsKey('assigned_location_name') && payload['assigned_location_name'] != null) {
      return;
    }

    if (locationType == 'store') {
      final store = await supabaseClient
          .from('stores')
          .select('name')
          .eq('id', locationId)
          .maybeSingle();
      payload['assigned_location_name'] = store?['name'];
    } else if (locationType == 'warehouse') {
      final warehouse = await supabaseClient
          .from('warehouses')
          .select('name')
          .eq('id', locationId)
          .maybeSingle();
      payload['assigned_location_name'] = warehouse?['name'];
    }
  }
}
