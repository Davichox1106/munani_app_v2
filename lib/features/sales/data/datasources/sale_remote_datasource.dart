import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale_remote_model.dart';
import '../models/sale_item_remote_model.dart';

abstract class SaleRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAllSales();
  Future<List<Map<String, dynamic>>> getSalesByLocation(String locationId);
  Future<Map<String, dynamic>> getSaleById(String id);
  Future<SaleRemoteModel> createSale(Map<String, dynamic> data);
  Future<SaleRemoteModel> updateSale(String id, Map<String, dynamic> data);
  Future<void> deleteSale(String id);

  // Items
  Future<List<Map<String, dynamic>>> getSaleItems(String saleId);
  Future<SaleItemRemoteModel> createSaleItem(Map<String, dynamic> data);
  Future<SaleItemRemoteModel> updateSaleItem(String id, Map<String, dynamic> data);
  Future<void> deleteSaleItem(String id);
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final SupabaseClient supabaseClient;
  SaleRemoteDataSourceImpl({required this.supabaseClient});

  Future<String> _getLocationName(String locationId, String locationType) async {
    try {
      if (locationType == 'store') {
        final r = await supabaseClient.from('stores').select('name').eq('id', locationId).single();
        return r['name'] as String? ?? 'Desconocido';
      } else {
        final r = await supabaseClient.from('warehouses').select('name').eq('id', locationId).single();
        return r['name'] as String? ?? 'Desconocido';
      }
    } catch (_) {
      return 'Desconocido';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllSales() async {
    final response = await supabaseClient
        .from('sales')
        .select('*')
        .order('sale_date', ascending: false);

    final List<Map<String, dynamic>> result = [];
    for (final json in response as List) {
      final locationName = await _getLocationName(json['location_id'] as String, json['location_type'] as String);
      final map = Map<String, dynamic>.from(json);
      map['location_name'] = locationName;
      result.add(map);
    }
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesByLocation(String locationId) async {
    final response = await supabaseClient
        .from('sales')
        .select('*')
        .eq('location_id', locationId)
        .order('sale_date', ascending: false);

    final List<Map<String, dynamic>> result = [];
    for (final json in response as List) {
      final locationName = await _getLocationName(json['location_id'] as String, json['location_type'] as String);
      final map = Map<String, dynamic>.from(json);
      map['location_name'] = locationName;
      result.add(map);
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getSaleById(String id) async {
    final response = await supabaseClient.from('sales').select('*').eq('id', id).single();
    final map = Map<String, dynamic>.from(response);
    map['location_name'] = await _getLocationName(map['location_id'] as String, map['location_type'] as String);
    return map;
  }

  @override
  Future<SaleRemoteModel> createSale(Map<String, dynamic> data) async {
    final response = await supabaseClient.from('sales').insert(data).select().single();
    final full = await getSaleById(response['id']);
    return SaleRemoteModel.fromJson(full);
  }

  @override
  Future<SaleRemoteModel> updateSale(String id, Map<String, dynamic> data) async {
    final response = await supabaseClient.from('sales').update(data).eq('id', id).select();
    if (response.isEmpty) {
      throw Exception('Venta con ID $id no encontrada para actualizar');
    }
    final full = await getSaleById(id);
    return SaleRemoteModel.fromJson(full);
  }

  @override
  Future<void> deleteSale(String id) async {
    await supabaseClient.from('sales').update({'status': 'cancelled'}).eq('id', id);
  }

  // Items
  @override
  Future<List<Map<String, dynamic>>> getSaleItems(String saleId) async {
    final response = await supabaseClient
        .from('sale_items')
        .select('*, product_variants!inner(variant_name, products!inner(name))')
        .eq('sale_id', saleId)
        .order('created_at', ascending: true);

    return (response as List).map((json) {
      final pv = json['product_variants'] as Map<String, dynamic>?;
      final products = pv?['products'] as Map<String, dynamic>?;
      final productName = products?['name'] as String? ?? 'Desconocido';
      final variantName = pv?['variant_name'] as String? ?? 'Desconocido';
      final map = Map<String, dynamic>.from(json);
      map['product_name'] = productName;
      map['variant_name'] = variantName;
      return map;
    }).toList();
  }

  @override
  Future<SaleItemRemoteModel> createSaleItem(Map<String, dynamic> data) async {
    final response = await supabaseClient.from('sale_items').insert(data).select().single();
    final items = await getSaleItems(response['sale_id']);
    final full = items.firstWhere((e) => e['id'] == response['id']);
    return SaleItemRemoteModel.fromJson(full);
  }

  @override
  Future<SaleItemRemoteModel> updateSaleItem(String id, Map<String, dynamic> data) async {
    final response = await supabaseClient.from('sale_items').update(data).eq('id', id).select().single();
    final items = await getSaleItems(response['sale_id']);
    final full = items.firstWhere((e) => e['id'] == id);
    return SaleItemRemoteModel.fromJson(full);
  }

  @override
  Future<void> deleteSaleItem(String id) async {
    await supabaseClient.from('sale_items').delete().eq('id', id);
  }
}
