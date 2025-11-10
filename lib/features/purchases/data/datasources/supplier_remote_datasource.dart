import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supplier_remote_model.dart';

/// DataSource remoto para Suppliers usando Supabase
///
/// OWASP A01: RLS habilitado en Supabase
/// OWASP A07: Autenticación con JWT
abstract class SupplierRemoteDataSource {
  Future<List<SupplierRemoteModel>> getAllSuppliers();
  Future<List<SupplierRemoteModel>> getActiveSuppliers();
  Future<SupplierRemoteModel> getSupplierById(String id);
  Future<SupplierRemoteModel> createSupplier(Map<String, dynamic> data);
  Future<SupplierRemoteModel> updateSupplier(String id, Map<String, dynamic> data);
  Future<void> deleteSupplier(String id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupplierRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<SupplierRemoteModel>> getAllSuppliers() async {
    final response = await supabaseClient
        .from('suppliers')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((json) => SupplierRemoteModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<SupplierRemoteModel>> getActiveSuppliers() async {
    final response = await supabaseClient
        .from('suppliers')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => SupplierRemoteModel.fromJson(json))
        .toList();
  }

  @override
  Future<SupplierRemoteModel> getSupplierById(String id) async {
    final response = await supabaseClient
        .from('suppliers')
        .select()
        .eq('id', id)
        .single();

    return SupplierRemoteModel.fromJson(response);
  }

  @override
  Future<SupplierRemoteModel> createSupplier(Map<String, dynamic> data) async {
    final response = await supabaseClient
        .from('suppliers')
        .insert(data)
        .select()
        .single();

    return SupplierRemoteModel.fromJson(response);
  }

  @override
  Future<SupplierRemoteModel> updateSupplier(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await supabaseClient
        .from('suppliers')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return SupplierRemoteModel.fromJson(response);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    // Soft delete: marcar como inactivo en lugar de eliminar físicamente
    await supabaseClient
        .from('suppliers')
        .update({'is_active': false})
        .eq('id', id);
  }
}
