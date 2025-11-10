import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/isar_database.dart';
import '../network/network_info.dart';
import '../services/auto_sync_service.dart';
import '../services/full_sync_service.dart';
import '../services/payment_qr_storage_service.dart';
import '../services/product_image_storage_service.dart';
import '../services/rate_limiter_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Sync Feature
import '../../features/sync/data/repositories/sync_repository_impl.dart';
import '../../features/sync/domain/repositories/sync_repository.dart';
import '../../features/sync/presentation/bloc/sync_bloc.dart';

// Products Feature
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/create_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/usecases/get_all_products.dart';
import '../../features/products/domain/usecases/get_products_by_category.dart';
import '../../features/products/domain/usecases/search_products.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';

// Products Variants Feature
import '../../features/products/data/datasources/product_variant_local_datasource.dart';
import '../../features/products/data/datasources/product_variant_remote_datasource.dart';
import '../../features/products/data/repositories/product_variant_repository_impl.dart';
import '../../features/products/domain/repositories/product_variant_repository.dart';
import '../../features/products/domain/usecases/create_variant.dart';
import '../../features/products/domain/usecases/delete_variant.dart';
import '../../features/products/domain/usecases/get_variants_by_product.dart';
import '../../features/products/domain/usecases/update_variant.dart';
import '../../features/products/presentation/bloc/variant_bloc.dart';

// Locations Feature
import '../../features/locations/presentation/bloc/store/store_bloc.dart';
import '../../features/locations/presentation/bloc/warehouse/warehouse_bloc.dart';
import '../../features/locations/data/datasources/store_local_datasource.dart';
import '../../features/locations/data/datasources/store_remote_datasource.dart';
import '../../features/locations/data/datasources/warehouse_local_datasource.dart';
import '../../features/locations/data/datasources/warehouse_remote_datasource.dart';
import '../../features/locations/data/repositories/location_repository_impl.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/locations/domain/usecases/create_store.dart';
import '../../features/locations/domain/usecases/create_warehouse.dart';
import '../../features/locations/domain/usecases/update_store.dart';
import '../../features/locations/domain/usecases/update_warehouse.dart';
import '../../features/locations/domain/usecases/delete_store.dart';
import '../../features/locations/domain/usecases/delete_warehouse.dart';
import '../../features/locations/domain/usecases/get_all_stores.dart';
import '../../features/locations/domain/usecases/get_all_warehouses.dart';
import '../../features/locations/domain/usecases/search_stores.dart';
import '../../features/locations/domain/usecases/search_warehouses.dart';

// Inventory Feature (Fase 4)
import '../../features/inventory/data/datasources/inventory_local_datasource.dart';
import '../../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/get_all_inventory.dart';
import '../../features/inventory/domain/usecases/get_inventory_by_location.dart';
import '../../features/inventory/domain/usecases/get_low_stock_inventory.dart';
import '../../features/inventory/domain/usecases/update_inventory_quantity.dart';
import '../../features/inventory/domain/usecases/adjust_inventory.dart';
import '../../features/inventory/domain/usecases/search_inventory.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

// Users Feature (Fase 8 - Gestión de Usuarios)
import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_all_users.dart';
import '../../features/users/domain/usecases/create_user.dart' as user_usecases;
import '../../features/users/domain/usecases/update_user.dart' as user_usecases;
import '../../features/users/domain/usecases/deactivate_user.dart';
import '../../features/users/data/datasources/user_local_datasource.dart';
import '../../features/users/domain/services/location_name_service.dart';
import '../../features/users/presentation/bloc/user_management_bloc.dart';

// Transfers Feature (Fase 5)
import '../../features/transfers/data/datasources/transfer_local_datasource.dart';
import '../../features/transfers/data/datasources/transfer_local_datasource_impl.dart';
import '../../features/transfers/data/datasources/transfer_remote_datasource.dart';
import '../../features/transfers/data/datasources/transfer_remote_datasource_impl.dart';
import '../../features/transfers/data/repositories/transfer_repository_impl.dart';
import '../../features/transfers/domain/repositories/transfer_repository.dart';

// Purchases Feature (Fase 6)
import '../../features/purchases/data/datasources/supplier_local_datasource.dart';
import '../../features/purchases/data/datasources/supplier_remote_datasource.dart';
import '../../features/purchases/data/datasources/purchase_local_datasource.dart';
import '../../features/purchases/data/datasources/purchase_remote_datasource.dart';
import '../../features/purchases/data/repositories/supplier_repository_impl.dart';
import '../../features/purchases/data/repositories/purchase_repository_impl.dart';
import '../../features/purchases/domain/repositories/supplier_repository.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../../features/purchases/domain/usecases/get_suppliers.dart';
import '../../features/purchases/domain/usecases/create_supplier.dart';
import '../../features/purchases/domain/usecases/update_supplier.dart';
import '../../features/purchases/domain/usecases/delete_supplier.dart';
import '../../features/purchases/domain/usecases/get_purchases.dart';
import '../../features/purchases/domain/usecases/get_purchase_with_items.dart';
import '../../features/purchases/domain/usecases/create_purchase.dart';
import '../../features/purchases/domain/usecases/add_purchase_item.dart';
import '../../features/purchases/domain/usecases/update_purchase_item.dart';
import '../../features/purchases/domain/usecases/remove_purchase_item.dart';
import '../../features/purchases/domain/usecases/receive_purchase.dart';
import '../../features/purchases/domain/usecases/cancel_purchase.dart';
import '../../features/purchases/domain/usecases/sync_purchases.dart';
import '../../features/purchases/presentation/bloc/supplier_bloc.dart';
import '../../features/purchases/presentation/bloc/purchase_bloc.dart';

// Employees Feature (Fase 7)
import '../../features/employees/data/datasources/administrator_local_datasource.dart';
import '../../features/employees/data/datasources/administrator_remote_datasource.dart';
import '../../features/employees/data/datasources/employee_store_local_datasource.dart';
import '../../features/employees/data/datasources/employee_store_remote_datasource.dart';
import '../../features/employees/data/datasources/employee_warehouse_local_datasource.dart';
import '../../features/employees/data/datasources/employee_warehouse_remote_datasource.dart';
import '../../features/employees/data/repositories/administrator_repository_impl.dart';
import '../../features/employees/data/repositories/employee_store_repository_impl.dart';
import '../../features/employees/data/repositories/employee_warehouse_repository_impl.dart';
import '../../features/employees/domain/repositories/administrator_repository.dart';
import '../../features/employees/domain/repositories/employee_store_repository.dart';
import '../../features/employees/domain/repositories/employee_warehouse_repository.dart';

import '../../features/transfers/domain/usecases/get_all_transfers.dart';
import '../../features/transfers/domain/usecases/create_transfer.dart';
import '../../features/transfers/domain/usecases/update_transfer.dart';
import '../../features/transfers/domain/usecases/delete_transfer.dart';
import '../../features/transfers/domain/usecases/search_transfers.dart';
import '../../features/transfers/domain/usecases/get_transfer_by_id.dart';
import '../../features/transfers/presentation/bloc/transfer_bloc.dart';

import '../../features/sales/data/datasources/sale_local_datasource.dart';
import '../../features/sales/data/datasources/sale_remote_datasource.dart';
import '../../features/sales/data/repositories/sale_repository_impl.dart';
import '../../features/sales/domain/repositories/sale_repository.dart';
import '../../features/sales/presentation/bloc/sale_bloc.dart';
import '../../features/customers/data/datasources/customer_local_datasource.dart';
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';

// Cart Feature
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/watch_active_cart.dart';
import '../../features/cart/domain/usecases/add_item_to_cart.dart';
import '../../features/cart/domain/usecases/update_cart_item_quantity.dart';
import '../../features/cart/domain/usecases/remove_cart_item.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/domain/usecases/update_cart_status.dart';
import '../../features/cart/domain/usecases/submit_payment_receipt.dart';
import '../../features/cart/domain/usecases/watch_cart_history.dart';
import '../../features/cart/domain/usecases/sync_customer_carts.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_history_cubit.dart';
import '../../features/cart/presentation/bloc/cart_review_bloc.dart';

// Reports Feature
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/locations/data/datasources/location_local_datasource.dart';

final sl = GetIt.instance; // Service Locator

/// Inicializar todas las dependencias
Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
      rateLimiterService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Repository (Offline-First: usa Isar + Supabase)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  //! Core
  // Isar Database (Offline-First)
  sl.registerLazySingleton(() => IsarDatabase.instance);

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl(),
      internetConnection: sl(),
    ),
  );

  //! External
  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => InternetConnection());

  // Supabase - Se inicializará en main.dart
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton<PaymentQrStorageService>(
    () => PaymentQrStorageService(supabaseClient: sl()),
  );
  sl.registerLazySingleton<ProductImageStorageService>(
    () => ProductImageStorageService(supabaseClient: sl()),
  );

  // SharedPreferences - Para rate limiting y otras preferencias
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Rate Limiter Service - Prevención de ataques de fuerza bruta
  sl.registerLazySingleton<RateLimiterService>(
    () => RateLimiterService(sl()),
  );

  //! Features - Sync (Fase 2)
  // Bloc
  sl.registerFactory(
    () => SyncBloc(
      syncRepository: sl(),
      networkInfo: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(
      isarDatabase: sl(),
      networkInfo: sl(),
      supabaseClient: Supabase.instance.client,
    ),
  );

  //! Services - Sincronización Automática
  // FullSyncService - Sincronización completa desde Supabase
  sl.registerLazySingleton(
    () => FullSyncService.create(),
  );

  // AutoSyncService - Sincronización automática en background
  sl.registerLazySingleton(
    () => AutoSyncService(
      fullSyncService: sl(),
      networkInfo: sl(),
      syncIntervalMinutes: 5, // Sincronizar cada 5 minutos
    ),
  );

  //! Features - Products (Fase 2/3)
  // Data Sources (PRIMERO - son las dependencias base)
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  // Repository (SEGUNDO - usa los data sources)
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      syncRepository: sl(),
      isarDatabase: sl(),
    ),
  );

  // Use Cases (TERCERO - usan el repository)
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductsByCategory(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // Bloc (ÚLTIMO - usa los use cases)
  sl.registerFactory(
    () => ProductBloc(
      getAllProducts: sl(),
      searchProducts: sl(),
      getProductsByCategory: sl(),
      createProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
      productRepository: sl(),
    ),
  );

  //! Features - Product Variants (Fase 4)
  // Data Sources (PRIMERO - son las dependencias base)
  sl.registerLazySingleton<ProductVariantLocalDataSource>(
    () => ProductVariantLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<ProductVariantRemoteDataSource>(
    () => ProductVariantRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  // Repository (SEGUNDO - usa los data sources)
  sl.registerLazySingleton<ProductVariantRepository>(
    () => ProductVariantRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      syncRepository: sl(),
    ),
  );

  // Use Cases (TERCERO - usan el repository)
  sl.registerLazySingleton(() => GetVariantsByProduct(sl()));
  sl.registerLazySingleton(() => CreateVariant(sl()));
  sl.registerLazySingleton(() => UpdateVariant(sl()));
  sl.registerLazySingleton(() => DeleteVariant(sl()));

  // Bloc (ÚLTIMO - usa los use cases)
  sl.registerFactory(
    () => VariantBloc(
      getVariantsByProduct: sl(),
      createVariant: sl(),
      updateVariant: sl(),
      deleteVariant: sl(),
    ),
  );

  //! Features - Locations (Fase 2)
  // Blocs
  sl.registerFactory(
    () => StoreBloc(
      getAllStores: sl(),
      createStore: sl(),
      updateStore: sl(),
      deleteStore: sl(),
      searchStores: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => WarehouseBloc(
      getAllWarehouses: sl(),
      createWarehouse: sl(),
      updateWarehouse: sl(),
      deleteWarehouse: sl(),
      searchWarehouses: sl(),
      repository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllStores(sl()));
  sl.registerLazySingleton(() => GetAllWarehouses(sl()));
  sl.registerLazySingleton(() => CreateStore(sl()));
  sl.registerLazySingleton(() => CreateWarehouse(sl()));
  sl.registerLazySingleton(() => UpdateStore(sl()));
  sl.registerLazySingleton(() => UpdateWarehouse(sl()));
  sl.registerLazySingleton(() => DeleteStore(sl()));
  sl.registerLazySingleton(() => DeleteWarehouse(sl()));
  sl.registerLazySingleton(() => SearchStores(sl()));
  sl.registerLazySingleton(() => SearchWarehouses(sl()));

  // Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      storeLocalDataSource: sl(),
      storeRemoteDataSource: sl(),
      warehouseLocalDataSource: sl(),
      warehouseRemoteDataSource: sl(),
      networkInfo: sl(),
      syncRepository: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<StoreLocalDataSource>(
    () => StoreLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  sl.registerLazySingleton<WarehouseLocalDataSource>(
    () => WarehouseLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<WarehouseRemoteDataSource>(
    () => WarehouseRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  //! Features - Inventory (Fase 4)
  // Bloc
  sl.registerFactory(
    () => InventoryBloc(
      getAllInventory: sl(),
      getInventoryByLocation: sl(),
      getLowStockInventory: sl(),
      updateInventoryQuantity: sl(),
      adjustInventory: sl(),
      searchInventory: sl(),
      repository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllInventory(sl()));
  sl.registerLazySingleton(() => GetInventoryByLocation(sl()));
  sl.registerLazySingleton(() => GetLowStockInventory(sl()));
  sl.registerLazySingleton(() => UpdateInventoryQuantity(sl()));
  sl.registerLazySingleton(() => AdjustInventory(sl()));
  sl.registerLazySingleton(() => SearchInventory(sl()));

  // Repository
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      isarDatabase: sl(),
      syncRepository: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  //! Features - Cart
  // Bloc
  sl.registerFactory(
    () => CartBloc(
      watchActiveCart: sl(),
      addItemToCart: sl(),
      updateCartItemQuantity: sl(),
      removeCartItem: sl(),
      clearCart: sl(),
      updateCartStatus: sl(),
      submitPaymentReceipt: sl(),
    ),
  );

  sl.registerFactory(
    () => CartHistoryCubit(
      watchCartHistory: sl(),
      syncCustomerCarts: sl(),
    ),
  );

  sl.registerFactory(
    () => CartReviewBloc(
      cartRepository: sl(),
      adjustInventory: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => WatchActiveCart(sl()));
  sl.registerLazySingleton(() => AddItemToCart(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantity(sl()));
  sl.registerLazySingleton(() => RemoveCartItem(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));
  sl.registerLazySingleton(() => UpdateCartStatus(sl()));
  sl.registerLazySingleton(() => SubmitPaymentReceipt(sl()));
  sl.registerLazySingleton(() => WatchCartHistory(sl()));
  sl.registerLazySingleton(() => SyncCustomerCarts(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      isarDatabase: sl(),
      networkInfo: sl(),
      syncRepository: sl(),
      supabaseClient: sl(),
      customerRepository: sl(),
    ),
  );

  //! Features - Users Management (Fase 8)
  // Bloc
  sl.registerFactory(
    () => UserManagementBloc(
      getAllUsers: sl(),
      createUser: sl(),
      updateUser: sl(),
      deactivateUser: sl(),
      repository: sl(),
      getCurrentUser: sl(),
      locationNameService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllUsers(sl()));
  sl.registerLazySingleton(() => user_usecases.CreateUser(sl()));
  sl.registerLazySingleton(() => user_usecases.UpdateUser(sl()));
  sl.registerLazySingleton(() => DeactivateUser(sl()));

  // Services
  sl.registerLazySingleton(
    () => LocationNameService(
      locationRepository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      isarDatabase: sl(),
      syncRepository: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );
  
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  //! Features - Transfers (Fase 5)
  // Bloc
  sl.registerFactory(
    () => TransferBloc(
      repository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllTransfers(repository: sl()));
  sl.registerLazySingleton(() => CreateTransfer(repository: sl()));
  sl.registerLazySingleton(() => UpdateTransfer(repository: sl()));
  sl.registerLazySingleton(() => DeleteTransfer(repository: sl()));
  sl.registerLazySingleton(() => SearchTransfers(repository: sl()));
  sl.registerLazySingleton(() => GetTransferById(repository: sl()));

  // Repository
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      isarDatabase: sl(),
      syncRepository: sl(),
      inventoryRepository: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<TransferLocalDataSource>(
    () => TransferLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  //! Features - Purchases (Fase 6)
  // Blocs
  sl.registerFactory(
    () => SupplierBloc(
      getSuppliers: sl(),
      createSupplier: sl(),
      updateSupplier: sl(),
      deleteSupplier: sl(),
      syncPurchases: sl(),
    ),
  );

  sl.registerFactory(
    () => PurchaseBloc(
      getPurchases: sl(),
      getPurchaseWithItems: sl(),
      createPurchase: sl(),
      addPurchaseItem: sl(),
      updatePurchaseItem: sl(),
      removePurchaseItem: sl(),
      receivePurchase: sl(),
      cancelPurchase: sl(),
      syncPurchases: sl(),
    ),
  );

  // Use Cases - Suppliers
  sl.registerLazySingleton(() => GetSuppliers(sl()));
  sl.registerLazySingleton(() => CreateSupplier(sl()));
  sl.registerLazySingleton(() => UpdateSupplier(sl()));
  sl.registerLazySingleton(() => DeleteSupplier(sl()));

  // Use Cases - Purchases
  sl.registerLazySingleton(() => GetPurchases(sl()));
  sl.registerLazySingleton(() => GetPurchaseWithItems(sl()));
  sl.registerLazySingleton(() => CreatePurchase(sl()));
  sl.registerLazySingleton(() => AddPurchaseItem(sl()));
  sl.registerLazySingleton(() => UpdatePurchaseItem(sl()));
  sl.registerLazySingleton(() => RemovePurchaseItem(sl()));
  sl.registerLazySingleton(() => ReceivePurchase(sl()));
  sl.registerLazySingleton(() => CancelPurchase(sl()));
  sl.registerLazySingleton(
    () => SyncPurchases(
      purchaseRepository: sl(),
      supplierRepository: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      supplierLocalDataSource: sl(),
      supplierRemoteDataSource: sl(),
      inventoryLocalDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources - Suppliers
  sl.registerLazySingleton<SupplierLocalDataSource>(
    () => SupplierLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<SupplierRemoteDataSource>(
    () => SupplierRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  // Data Sources - Purchases
  sl.registerLazySingleton<PurchaseLocalDataSource>(
    () => PurchaseLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  //! Features - Sales (Fase 8)
  // Data Sources
  sl.registerLazySingleton<SaleLocalDataSource>(
    () => SaleLocalDataSourceImpl(
      isarDatabase: sl(),
    ),
  );

  sl.registerLazySingleton<SaleRemoteDataSource>(
    () => SaleRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Bloc
  sl.registerFactory(
    () => SaleBloc(
      repository: sl(),
    ),
  );

  //! Features - Customers (Fase 9)
  // Data Sources
  sl.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(isarDatabase: sl()),
  );
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(local: sl(), remote: sl(), networkInfo: sl()),
  );

  // Bloc
  sl.registerFactory(() => CustomerBloc(repository: sl()));

  //! Features - Employees (Fase 7)
  // Repositories
  sl.registerLazySingleton<AdministratorRepository>(
    () => AdministratorRepositoryImpl(
      localDataSource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AdministratorRepositoryImpl>(
    () => AdministratorRepositoryImpl(
      localDataSource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<EmployeeStoreRepository>(
    () => EmployeeStoreRepositoryImpl(
      localDataSource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<EmployeeStoreRepositoryImpl>(
    () => EmployeeStoreRepositoryImpl(
      localDataSource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<EmployeeWarehouseRepository>(
    () => EmployeeWarehouseRepositoryImpl(
      localDataSource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<EmployeeWarehouseRepositoryImpl>(
    () => EmployeeWarehouseRepositoryImpl(
      localDataSource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources - Local
  sl.registerLazySingleton<AdministratorLocalDataSource>(
    () => AdministratorLocalDataSourceImpl(isarDatabase: sl()),
  );

  sl.registerLazySingleton<EmployeeStoreLocalDataSource>(
    () => EmployeeStoreLocalDataSourceImpl(isarDatabase: sl()),
  );

  sl.registerLazySingleton<EmployeeWarehouseLocalDataSource>(
    () => EmployeeWarehouseLocalDataSourceImpl(isarDatabase: sl()),
  );

  // Data Sources - Remote
  sl.registerLazySingleton(
    () => AdministratorRemoteDatasource(sl()),
  );

  sl.registerLazySingleton(
    () => EmployeeStoreRemoteDatasource(sl()),
  );

  sl.registerLazySingleton(
    () => EmployeeWarehouseRemoteDatasource(sl()),
  );

  // Nota: Sección de Ventas registrada más arriba (Fase 8)

  //! Features - Reports (Fase 12)
  // Data Source - LocationLocalDataSource (combines Store and Warehouse)
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(
      storeLocalDataSource: sl(),
      warehouseLocalDataSource: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(
      saleLocalDataSource: sl(),
      purchaseLocalDataSource: sl(),
      transferLocalDataSource: sl(),
      locationLocalDataSource: sl(),
    ),
  );

  // Bloc
  sl.registerFactory(
    () => ReportsBloc(repository: sl()),
  );

  // Nota: Agregar más dependencias según se vayan creando
  // - Orders/Cart Feature (Fase 8)
  // - Sales Feature (Fase 9)
}

/// Limpiar todas las dependencias (útil para testing)
Future<void> reset() async {
  await sl.reset();
}
