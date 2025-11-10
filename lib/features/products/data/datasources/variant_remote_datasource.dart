import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_variant_remote_model.dart';

/// Datasource remoto para variantes (Supabase)
abstract class VariantRemoteDataSource {
  /// Obtener variantes por producto
  Future<List<ProductVariantRemoteModel>> getVariantsByProduct(String productId);

  /// Crear variante
  Future<ProductVariantRemoteModel> createVariant(ProductVariantRemoteModel variant);

  /// Actualizar variante
  Future<ProductVariantRemoteModel> updateVariant(ProductVariantRemoteModel variant);

  /// Eliminar variante
  Future<void> deleteVariant(String id);
}

class VariantRemoteDataSourceImpl implements VariantRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String _tableName = 'product_variants';

  VariantRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductVariantRemoteModel>> getVariantsByProduct(String productId) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductVariantRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener variantes: $e');
    }
  }

  @override
  Future<ProductVariantRemoteModel> createVariant(ProductVariantRemoteModel variant) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .insert(variant.toJson())
          .select()
          .single();

      return ProductVariantRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear variante: $e');
    }
  }

  @override
  Future<ProductVariantRemoteModel> updateVariant(ProductVariantRemoteModel variant) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .update(variant.toJson())
          .eq('id', variant.id)
          .select()
          .single();

      return ProductVariantRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar variante: $e');
    }
  }

  @override
  Future<void> deleteVariant(String id) async {
    try {
      await supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar variante: $e');
    }
  }
}
