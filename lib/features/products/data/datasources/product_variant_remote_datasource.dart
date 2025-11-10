import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_variant_remote_model.dart';

/// Contrato para el data source remoto de variantes de productos
abstract class ProductVariantRemoteDataSource {
  /// Obtener todas las variantes desde Supabase
  Future<List<ProductVariantRemoteModel>> getAllVariants();

  /// Obtener variantes por producto desde Supabase
  Future<List<ProductVariantRemoteModel>> getVariantsByProduct(String productId);

  /// Obtener variante por ID desde Supabase
  Future<ProductVariantRemoteModel> getVariantById(String id);

  /// Crear variante en Supabase
  Future<ProductVariantRemoteModel> createVariant(ProductVariantRemoteModel variant);

  /// Actualizar variante en Supabase
  Future<ProductVariantRemoteModel> updateVariant(ProductVariantRemoteModel variant);

  /// Eliminar variante en Supabase
  Future<void> deleteVariant(String id);
}

/// Implementación del data source remoto usando Supabase
///
/// Maneja la comunicación con Supabase para variantes de productos:
/// 1. Operaciones CRUD en Supabase
/// 2. Sincronización de datos
/// 3. Manejo de errores de red
class ProductVariantRemoteDataSourceImpl implements ProductVariantRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductVariantRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductVariantRemoteModel>> getAllVariants() async {
    try {
      final response = await supabaseClient
          .from('product_variants')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductVariantRemoteModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al obtener variantes: ${e.message}');
    } catch (e) {
      throw ServerException('Error de conexión al obtener variantes: $e');
    }
  }

  @override
  Future<List<ProductVariantRemoteModel>> getVariantsByProduct(String productId) async {
    try {
      final response = await supabaseClient
          .from('product_variants')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductVariantRemoteModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al obtener variantes por producto: ${e.message}');
    } catch (e) {
      throw ServerException('Error de conexión al obtener variantes por producto: $e');
    }
  }

  @override
  Future<ProductVariantRemoteModel> getVariantById(String id) async {
    try {
      final response = await supabaseClient
          .from('product_variants')
          .select()
          .eq('id', id)
          .single();

      return ProductVariantRemoteModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Error al obtener variante: ${e.message}');
    } catch (e) {
      throw ServerException('Error de conexión al obtener variante: $e');
    }
  }

  @override
  Future<ProductVariantRemoteModel> createVariant(ProductVariantRemoteModel variant) async {
    try {
      final response = await supabaseClient
          .from('product_variants')
          .insert(variant.toJson())
          .select()
          .single();

      return ProductVariantRemoteModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Error al crear variante: ${e.message}');
    } catch (e) {
      throw ServerException('Error de conexión al crear variante: $e');
    }
  }

  @override
  Future<ProductVariantRemoteModel> updateVariant(ProductVariantRemoteModel variant) async {
    try {
      final response = await supabaseClient
          .from('product_variants')
          .update(variant.toJson())
          .eq('id', variant.id)
          .select()
          .single();

      return ProductVariantRemoteModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Error al actualizar variante: ${e.message}');
    } catch (e) {
      throw ServerException('Error de conexión al actualizar variante: $e');
    }
  }

  @override
  Future<void> deleteVariant(String id) async {
    try {
      await supabaseClient
          .from('product_variants')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException('Error al eliminar variante: ${e.message}');
    } catch (e) {
      throw ServerException('Error de conexión al eliminar variante: $e');
    }
  }
}





















