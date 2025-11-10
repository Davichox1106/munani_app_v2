import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

/// Estados del ProductBloc
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Cargando productos
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Productos cargados exitosamente
class ProductsLoaded extends ProductState {
  final List<Product> products;
  final ProductCategory? currentFilter;
  final String? currentSearch;

  const ProductsLoaded({
    required this.products,
    this.currentFilter,
    this.currentSearch,
  });

  @override
  List<Object?> get props => [products, currentFilter, currentSearch];

  ProductsLoaded copyWith({
    List<Product>? products,
    ProductCategory? currentFilter,
    String? currentSearch,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearch: currentSearch ?? this.currentSearch,
    );
  }
}

/// Error al cargar productos
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Producto creado exitosamente
class ProductCreated extends ProductState {
  final Product product;

  const ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Producto actualizado exitosamente
class ProductUpdated extends ProductState {
  final Product product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Producto eliminado exitosamente
class ProductDeleted extends ProductState {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Sincronizando productos
class ProductSyncing extends ProductState {
  const ProductSyncing();
}

/// Productos sincronizados exitosamente
class ProductSynced extends ProductState {
  final int count;

  const ProductSynced(this.count);

  @override
  List<Object?> get props => [count];
}
