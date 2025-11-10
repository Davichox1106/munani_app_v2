import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_product.dart' as use_cases;
import '../../domain/usecases/delete_product.dart' as use_cases;
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_products_by_category.dart';
import '../../domain/usecases/search_products.dart' as use_cases;
import '../../domain/usecases/update_product.dart' as use_cases;
import 'product_event.dart';
import 'product_state.dart';
import '../../../../core/utils/app_logger.dart';

/// ProductBloc - Gestiona el estado de los productos
///
/// Implementa arquitectura BLoC con Clean Architecture
/// - Escucha eventos (ProductEvent)
/// - Ejecuta use cases
/// - Emite estados (ProductState)
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;
  final use_cases.SearchProducts searchProducts;
  final GetProductsByCategory getProductsByCategory;
  final use_cases.CreateProduct createProduct;
  final use_cases.UpdateProduct updateProduct;
  final use_cases.DeleteProduct deleteProduct;
  final ProductRepository productRepository;

  StreamSubscription? _productsSubscription;

  ProductBloc({
    required this.getAllProducts,
    required this.searchProducts,
    required this.getProductsByCategory,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.productRepository,
  }) : super(const ProductInitial()) {
    // Registrar manejadores de eventos
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SyncProducts>(_onSyncProducts);
    on<ProductsUpdatedInternal>(_onProductsUpdated);

    // Suscribirse a cambios en tiempo real
    _subscribeToProducts();
  }

  /// Cargar todos los productos (snapshot único)
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getAllProducts();

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  /// Productos actualizados (desde stream reactivo)
  void _onProductsUpdated(
    ProductsUpdatedInternal event,
    Emitter<ProductState> emit,
  ) {
    // Solo actualizar si estamos en estado ProductsLoaded o si es el estado inicial
    if (state is ProductsLoaded || state is ProductInitial || state is ProductCreated || state is ProductUpdated) {
      emit(ProductsLoaded(products: event.products));
    }
  }

  /// Suscribirse a cambios en tiempo real
  void _subscribeToProducts() {
    _productsSubscription = getAllProducts.watch().listen(
      (products) {
        add(ProductsUpdatedInternal(products));
      },
    );
  }

  /// Buscar productos
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await searchProducts(event.query);

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(
        products: products,
        currentSearch: event.query,
      )),
    );
  }

  /// Filtrar por categoría
  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    if (event.category == null) {
      // Sin filtro, obtener todos
      final result = await getAllProducts();
      result.fold(
        (failure) => emit(ProductError(failure.message)),
        (products) => emit(ProductsLoaded(products: products)),
      );
    } else {
      // Filtrar por categoría
      final result = await getProductsByCategory(event.category!);
      result.fold(
        (failure) => emit(ProductError(failure.message)),
        (products) => emit(ProductsLoaded(
          products: products,
          currentFilter: event.category,
        )),
      );
    }
  }

  /// Crear producto
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    AppLogger.debug('🔄 ProductBloc: Creando producto: ${event.name}');

    final result = await createProduct(
      name: event.name,
      description: event.description,
      category: event.category,
      basePriceSell: event.basePriceSell,
      basePriceBuy: event.basePriceBuy,
      hasVariants: event.hasVariants,
      imageUrls: event.imageUrls,
      createdBy: event.createdBy,
    );

    result.fold(
      (failure) {
        AppLogger.error('❌ ProductBloc: Error creando producto: ${failure.message}');
        emit(ProductError(failure.message));
      },
      (product) {
        AppLogger.info('✅ ProductBloc: Producto creado exitosamente: ${product.name}');
        emit(ProductCreated(product));
        add(const LoadProducts());
      },
    );
  }

  /// Actualizar producto
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    final result = await updateProduct(event.product);

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) {
        emit(ProductUpdated(product));
        add(const LoadProducts());
      },
    );
  }

  /// Eliminar producto
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    final result = await deleteProduct(event.productId);

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        emit(ProductDeleted(event.productId));
        add(const LoadProducts());
      },
    );
  }

  /// Sincronizar productos desde servidor
  Future<void> _onSyncProducts(
    SyncProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductSyncing());

    final result = await productRepository.syncFromRemote();

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        emit(const ProductSynced(0));
        // Stream reactivo se encarga de actualizar la lista automáticamente
      },
    );
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}
