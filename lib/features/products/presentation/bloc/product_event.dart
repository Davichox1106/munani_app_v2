import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

/// Eventos del ProductBloc
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los productos
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Buscar productos por query
class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filtrar productos por categoría
class FilterProductsByCategory extends ProductEvent {
  final ProductCategory? category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Crear nuevo producto
class CreateProduct extends ProductEvent {
  final String name;
  final String? description;
  final ProductCategory category;
  final double basePriceSell;
  final double basePriceBuy;
  final bool hasVariants;
  final List<String> imageUrls;
  final String createdBy;

  const CreateProduct({
    required this.name,
    this.description,
    required this.category,
    required this.basePriceSell,
    required this.basePriceBuy,
    required this.hasVariants,
    required this.imageUrls,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [name, description, category, basePriceSell, basePriceBuy, hasVariants, imageUrls, createdBy];
}

/// Actualizar producto existente
class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Eliminar producto
class DeleteProduct extends ProductEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Sincronizar productos desde servidor
class SyncProducts extends ProductEvent {
  const SyncProducts();
}

/// Evento interno: productos actualizados (desde stream reactivo)
/// Este evento es disparado automáticamente por el stream de productos
class ProductsUpdatedInternal extends ProductEvent {
  final List<Product> products;

  const ProductsUpdatedInternal(this.products);

  @override
  List<Object?> get props => [products];
}
