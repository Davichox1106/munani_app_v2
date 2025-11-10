import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_remote_model.dart';

/// Remote datasource for products (Supabase)
/// Handles all API calls for products
abstract class ProductRemoteDataSource {
  /// Get all products
  Future<List<ProductRemoteModel>> getAllProducts();

  /// Get product by ID
  Future<ProductRemoteModel> getProductById(String id);

  /// Get products by category
  Future<List<ProductRemoteModel>> getProductsByCategory(String category);

  /// Search products by name
  Future<List<ProductRemoteModel>> searchProducts(String query);

  /// Create new product
  Future<ProductRemoteModel> createProduct(ProductRemoteModel product);

  /// Update existing product
  Future<ProductRemoteModel> updateProduct(ProductRemoteModel product);

  /// Delete product
  Future<void> deleteProduct(String id);

  /// Get products created by specific user
  Future<List<ProductRemoteModel>> getProductsByCreator(String userId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String _tableName = 'products';

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductRemoteModel>> getAllProducts() async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  @override
  Future<ProductRemoteModel> getProductById(String id) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return ProductRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  @override
  Future<List<ProductRemoteModel>> getProductsByCategory(String category) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('category', category)
          .order('name');

      return (response as List)
          .map((json) => ProductRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  @override
  Future<List<ProductRemoteModel>> searchProducts(String query) async {
    try {
      // Using PostgreSQL full-text search
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .textSearch('name', query, config: 'spanish')
          .order('name');

      return (response as List)
          .map((json) => ProductRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }

  @override
  Future<ProductRemoteModel> createProduct(ProductRemoteModel product) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .insert(product.toJson())
          .select()
          .single();

      return ProductRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  @override
  Future<ProductRemoteModel> updateProduct(ProductRemoteModel product) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return ProductRemoteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  @override
  Future<List<ProductRemoteModel>> getProductsByCreator(String userId) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductRemoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos del usuario: $e');
    }
  }
}
