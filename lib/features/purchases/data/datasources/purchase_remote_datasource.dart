import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase_remote_model.dart';
import '../models/purchase_item_remote_model.dart';

/// DataSource remoto para Purchases usando Supabase
///
/// OWASP A01: RLS habilitado en Supabase
/// OWASP A07: Autenticación con JWT
abstract class PurchaseRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAllPurchases();
  Future<List<Map<String, dynamic>>> getPurchasesByLocation(String locationId);
  Future<Map<String, dynamic>> getPurchaseById(String id);
  Future<PurchaseRemoteModel> createPurchase(Map<String, dynamic> data);
  Future<PurchaseRemoteModel> updatePurchase(String id, Map<String, dynamic> data);
  Future<void> deletePurchase(String id);

  // Purchase Items
  Future<List<Map<String, dynamic>>> getPurchaseItems(String purchaseId);
  Future<PurchaseItemRemoteModel> createPurchaseItem(Map<String, dynamic> data);
  Future<PurchaseItemRemoteModel> updatePurchaseItem(String id, Map<String, dynamic> data);
  Future<void> deletePurchaseItem(String id);
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final SupabaseClient supabaseClient;

  PurchaseRemoteDataSourceImpl({required this.supabaseClient});

  /// Obtener nombre de ubicación (store o warehouse)
  Future<String> _getLocationName(String locationId, String locationType) async {
    try {
      if (locationType == 'store') {
        final response = await supabaseClient
            .from('stores')
            .select('name')
            .eq('id', locationId)
            .single();
        return response['name'] as String? ?? 'Desconocido';
      } else if (locationType == 'warehouse') {
        final response = await supabaseClient
            .from('warehouses')
            .select('name')
            .eq('id', locationId)
            .single();
        return response['name'] as String? ?? 'Desconocido';
      }
      return 'Desconocido';
    } catch (e) {
      return 'Desconocido';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    final response = await supabaseClient
        .from('purchases')
        .select('''
          *,
          suppliers!inner(name)
        ''')
        .order('purchase_date', ascending: false);

    final List<Map<String, dynamic>> result = [];
    
    for (final json in response as List) {
      // Agregar supplier_name al JSON
      final suppliers = json['suppliers'] as Map<String, dynamic>?;
      final supplierName = suppliers?['name'] as String? ?? 'Desconocido';

      // Obtener nombre de ubicación por separado
      final locationName = await _getLocationName(
        json['location_id'] as String,
        json['location_type'] as String,
      );

      final Map<String, dynamic> item = Map<String, dynamic>.from(json);
      item['supplier_name'] = supplierName;
      item['location_name'] = locationName;
      result.add(item);
    }
    
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getPurchasesByLocation(
    String locationId,
  ) async {
    final response = await supabaseClient
        .from('purchases')
        .select('''
          *,
          suppliers!inner(name)
        ''')
        .eq('location_id', locationId)
        .order('purchase_date', ascending: false);

    final List<Map<String, dynamic>> result = [];
    
    for (final json in response as List) {
      final suppliers = json['suppliers'] as Map<String, dynamic>?;
      final supplierName = suppliers?['name'] as String? ?? 'Desconocido';

      final locationName = await _getLocationName(
        json['location_id'] as String,
        json['location_type'] as String,
      );

      final Map<String, dynamic> item = Map<String, dynamic>.from(json);
      item['supplier_name'] = supplierName;
      item['location_name'] = locationName;
      result.add(item);
    }
    
    return result;
  }

  @override
  Future<Map<String, dynamic>> getPurchaseById(String id) async {
    final response = await supabaseClient
        .from('purchases')
        .select('''
          *,
          suppliers!inner(name)
        ''')
        .eq('id', id)
        .single();

    final suppliers = response['suppliers'] as Map<String, dynamic>?;
    final supplierName = suppliers?['name'] as String? ?? 'Desconocido';

    final locationName = await _getLocationName(
      response['location_id'] as String,
      response['location_type'] as String,
    );

    final Map<String, dynamic> result = Map<String, dynamic>.from(response);
    result['supplier_name'] = supplierName;
    result['location_name'] = locationName;
    return result;
  }

  @override
  Future<PurchaseRemoteModel> createPurchase(Map<String, dynamic> data) async {
    // Crear la compra sin joins (el trigger SQL generará el purchase_number)
    final response = await supabaseClient
        .from('purchases')
        .insert(data)
        .select()
        .single();

    // Obtener supplier_name y location_name con un query adicional
    final fullData = await getPurchaseById(response['id']);
    return PurchaseRemoteModel.fromJson(fullData);
  }

  @override
  Future<PurchaseRemoteModel> updatePurchase(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await supabaseClient
        .from('purchases')
        .update(data)
        .eq('id', id)
        .select();

    // Verificar si se actualizó algún registro
    if (response.isEmpty) {
      throw Exception('Compra con ID $id no encontrada para actualizar');
    }

    // Obtener datos completos después de actualizar
    final fullData = await getPurchaseById(id);
    return PurchaseRemoteModel.fromJson(fullData);
  }

  @override
  Future<void> deletePurchase(String id) async {
    // Soft delete: marcar como cancelled en lugar de eliminar
    await supabaseClient
        .from('purchases')
        .update({'status': 'cancelled'})
        .eq('id', id);
  }

  // ============================================================================
  // PURCHASE ITEMS
  // ============================================================================

  @override
  Future<List<Map<String, dynamic>>> getPurchaseItems(String purchaseId) async {
    final response = await supabaseClient
        .from('purchase_items')
        .select('''
          *,
          product_variants!inner(
            product_id,
            variant_name,
            products!inner(name)
          )
        ''')
        .eq('purchase_id', purchaseId)
        .order('created_at', ascending: true);

    return (response as List).map((json) {
      final productVariants = json['product_variants'] as Map<String, dynamic>?;
      final products = productVariants?['products'] as Map<String, dynamic>?;
      final productName = products?['name'] as String? ?? 'Desconocido';
      final variantName = productVariants?['variant_name'] as String? ?? 'Desconocido';

      final Map<String, dynamic> result = Map<String, dynamic>.from(json);
      result['product_name'] = productName;
      result['variant_name'] = variantName;
      return result;
    }).toList();
  }

  @override
  Future<PurchaseItemRemoteModel> createPurchaseItem(
    Map<String, dynamic> data,
  ) async {
    final response = await supabaseClient
        .from('purchase_items')
        .upsert(data, onConflict: 'id')
        .select()
        .single();

    // Obtener datos completos con el JOIN
    final items = await getPurchaseItems(response['purchase_id']);
    final fullItem = items.firstWhere((item) => item['id'] == response['id']);

    return PurchaseItemRemoteModel.fromJson(fullItem);
  }

  @override
  Future<PurchaseItemRemoteModel> updatePurchaseItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await supabaseClient
        .from('purchase_items')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    // Obtener datos completos con el JOIN
    final items = await getPurchaseItems(response['purchase_id']);
    final fullItem = items.firstWhere((item) => item['id'] == id);

    return PurchaseItemRemoteModel.fromJson(fullItem);
  }

  @override
  Future<void> deletePurchaseItem(String id) async {
    await supabaseClient
        .from('purchase_items')
        .delete()
        .eq('id', id);
  }
}
