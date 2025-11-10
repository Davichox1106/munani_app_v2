import '../di/injection_container.dart';
import '../utils/app_logger.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/repositories/product_variant_repository.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/transfers/domain/repositories/transfer_repository.dart';
import '../../features/employees/domain/repositories/administrator_repository.dart';
import '../../features/employees/domain/repositories/employee_store_repository.dart';
import '../../features/employees/domain/repositories/employee_warehouse_repository.dart';
import '../../features/purchases/domain/repositories/supplier_repository.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../network/network_info.dart';
import '../../features/sales/domain/repositories/sale_repository.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';

/// Servicio para forzar sincronización completa desde Supabase a Isar
class FullSyncService {
  final ProductRepository productRepository;
  final ProductVariantRepository productVariantRepository;
  final LocationRepository locationRepository;
  final UserRepository userRepository;
  final InventoryRepository inventoryRepository;
  final TransferRepository transferRepository;
  final AdministratorRepository administratorRepository;
  final EmployeeStoreRepository employeeStoreRepository;
  final EmployeeWarehouseRepository employeeWarehouseRepository;
  final SupplierRepository supplierRepository;
  final PurchaseRepository purchaseRepository;
  final NetworkInfo networkInfo;
  final SaleRepository saleRepository;
  final CustomerRepository customerRepository;
  final CartRepository cartRepository;

  FullSyncService({
    required this.productRepository,
    required this.productVariantRepository,
    required this.locationRepository,
    required this.userRepository,
    required this.inventoryRepository,
    required this.transferRepository,
    required this.administratorRepository,
    required this.employeeStoreRepository,
    required this.employeeWarehouseRepository,
    required this.supplierRepository,
    required this.purchaseRepository,
    required this.networkInfo,
    required this.saleRepository,
    required this.customerRepository,
    required this.cartRepository,
  });

  /// Forzar sincronización completa de todos los módulos
  Future<Map<String, dynamic>> performFullSync({
    String? userRole,
    String? customerId,
  }) async {
    final results = <String, dynamic>{};

    final role = userRole ?? 'manager';
    final isCustomer = role == 'customer';

    AppLogger.info('🔄 Iniciando sincronización completa (rol: $role)...');

    // Verificar conexión
    if (!await networkInfo.isConnected) {
      return {
        'success': false,
        'error': 'No hay conexión a internet',
        'results': results,
      };
    }

    try {
      void skipModule(String key, String reason) {
        AppLogger.info('⏭️ Omitiendo sincronización de $key: $reason');
        results[key] = {
          'success': true,
          'skipped': true,
          'message': reason,
        };
      }

      // 1. Sincronizar productos
      AppLogger.info('📦 Sincronizando productos...');
      final productResult = await productRepository.syncFromRemote();
      productResult.fold(
        (failure) => results['products'] = {'success': false, 'error': failure.message},
        (_) => results['products'] = {'success': true, 'message': 'Productos sincronizados'},
      );

      // 2. Sincronizar variantes de productos
      AppLogger.info('🔧 Sincronizando variantes de productos...');
      final variantResult = await productVariantRepository.syncFromRemote();
      variantResult.fold(
        (failure) => results['variants'] = {'success': false, 'error': failure.message},
        (_) => results['variants'] = {'success': true, 'message': 'Variantes sincronizadas'},
      );

      // 3. Sincronizar tiendas
      AppLogger.info('🏪 Sincronizando tiendas...');
      final storeResult = await locationRepository.syncStoresFromRemote();
      storeResult.fold(
        (failure) => results['stores'] = {'success': false, 'error': failure.message},
        (_) => results['stores'] = {'success': true, 'message': 'Tiendas sincronizadas'},
      );

      // 4. Sincronizar almacenes
      AppLogger.info('🏭 Sincronizando almacenes...');
      final warehouseResult = await locationRepository.syncWarehousesFromRemote();
      warehouseResult.fold(
        (failure) => results['warehouses'] = {'success': false, 'error': failure.message},
        (_) => results['warehouses'] = {'success': true, 'message': 'Almacenes sincronizados'},
      );

      // 5. Sincronizar inventarios
      AppLogger.info('📋 Sincronizando inventarios...');
      final inventoryResult = await inventoryRepository.syncFromRemote();
      inventoryResult.fold(
        (failure) => results['inventory'] = {'success': false, 'error': failure.message},
        (_) => results['inventory'] = {'success': true, 'message': 'Inventarios sincronizados'},
      );

      if (isCustomer) {
        skipModule('transfers', 'No aplica para clientes');
        skipModule('users', 'Solo personal interno');
        skipModule('administrators', 'Solo personal interno');
        skipModule('employees_store', 'Solo personal interno');
        skipModule('employees_warehouse', 'Solo personal interno');
      } else {
        // 6. Sincronizar transferencias
        AppLogger.info('🔄 Sincronizando transferencias...');
        final transferResult = await transferRepository.syncFromRemote();
        transferResult.fold(
          (failure) => results['transfers'] = {'success': false, 'error': failure.message},
          (_) => results['transfers'] = {'success': true, 'message': 'Transferencias sincronizadas'},
        );

        // 7. Sincronizar usuarios (solo obtener usuarios)
        AppLogger.info('👥 Obteniendo usuarios...');
        final userResult = await userRepository.getAllUsers();
        userResult.fold(
          (failure) => results['users'] = {'success': false, 'error': failure.message},
          (_) => results['users'] = {'success': true, 'message': 'Usuarios obtenidos'},
        );

        // 8. Sincronizar administradores
        AppLogger.info('👔 Sincronizando administradores...');
        try {
          await administratorRepository.syncAdministrators();
          results['administrators'] = {'success': true, 'message': 'Administradores sincronizados'};
        } catch (e) {
          results['administrators'] = {'success': false, 'error': e.toString()};
        }

        // 9. Sincronizar empleados de tienda
        AppLogger.info('🏪 Sincronizando empleados de tienda...');
        try {
          await employeeStoreRepository.syncEmployees();
          results['employees_store'] = {'success': true, 'message': 'Empleados de tienda sincronizados'};
        } catch (e) {
          results['employees_store'] = {'success': false, 'error': e.toString()};
        }

        // 10. Sincronizar empleados de almacén
        AppLogger.info('🏭 Sincronizando empleados de almacén...');
        try {
          await employeeWarehouseRepository.syncEmployees();
          results['employees_warehouse'] = {'success': true, 'message': 'Empleados de almacén sincronizados'};
        } catch (e) {
          results['employees_warehouse'] = {'success': false, 'error': e.toString()};
        }
      }

      // 11. Sincronizar clientes
      AppLogger.info('👤 Sincronizando clientes...');
      try {
        await customerRepository.syncCustomers();
        results['customers'] = {'success': true, 'message': 'Clientes sincronizados'};
      } catch (e) {
        results['customers'] = {'success': false, 'error': e.toString()};
      }

      if (isCustomer) {
        skipModule('suppliers', 'No aplica para clientes');
        skipModule('purchases', 'No aplica para clientes');
        skipModule('sales', 'No aplica para clientes');
        skipModule('carts', 'Sincronización de pedidos solo para managers');
        skipModule('payment_receipts', 'Sincronización de comprobantes solo para managers');

        if (customerId == null || customerId.isEmpty) {
          skipModule('customer_carts', 'ID de cliente no disponible');
        } else {
          AppLogger.info('🧾 Sincronizando pedidos del cliente...');
          final customerCartResult = await cartRepository.syncCustomerCarts(
            customerId: customerId,
          );
          customerCartResult.fold(
            (failure) => results['customer_carts'] = {
              'success': false,
              'error': failure.message,
            },
            (count) => results['customer_carts'] = {
              'success': true,
              'message': 'Pedidos del cliente sincronizados ($count)',
              'count': count,
            },
          );
        }
      } else {
        // 12. Sincronizar proveedores
        AppLogger.info('🏢 Sincronizando proveedores...');
        try {
          await supplierRepository.syncSuppliers();
          results['suppliers'] = {'success': true, 'message': 'Proveedores sincronizados'};
        } catch (e) {
          results['suppliers'] = {'success': false, 'error': e.toString()};
        }

        // 13. Sincronizar compras
        AppLogger.info('🛒 Sincronizando compras...');
        try {
          await purchaseRepository.syncPurchases();
          results['purchases'] = {'success': true, 'message': 'Compras sincronizadas'};
        } catch (e) {
          results['purchases'] = {'success': false, 'error': e.toString()};
        }

        // 14. Sincronizar ventas
        AppLogger.info('💳 Sincronizando ventas...');
        try {
          await saleRepository.syncSales();
          results['sales'] = {'success': true, 'message': 'Ventas sincronizadas'};
        } catch (e) {
          results['sales'] = {'success': false, 'error': e.toString()};
        }

        // 15. Sincronizar pedidos (carrito)
        AppLogger.info('🧾 Sincronizando pedidos (carrito)...');
        final cartsSyncResult = await cartRepository.syncManagerCarts();
        cartsSyncResult.fold(
          (failure) => results['carts'] = {
            'success': false,
            'error': failure.message,
          },
          (count) {
            results['carts'] = {
              'success': true,
              'message': 'Pedidos sincronizados ($count)',
              'count': count,
            };
            results['payment_receipts'] = {
              'success': true,
              'message': 'Comprobantes de pago actualizados',
            };
          },
        );
      }

      // Contar éxitos
      final successCount = results.values.where((r) => r['success'] == true).length;
      final totalCount = results.length;

      AppLogger.info('✅ Sincronización completada: $successCount/$totalCount módulos');

      return {
        'success': successCount == totalCount,
        'successCount': successCount,
        'totalCount': totalCount,
        'results': results,
      };

    } catch (e) {
      AppLogger.info('❌ Error en sincronización completa: $e');
      return {
        'success': false,
        'error': e.toString(),
        'results': results,
      };
    }
  }

  /// Factory method para crear instancia con dependencias
  static FullSyncService create() {
    return FullSyncService(
      productRepository: sl<ProductRepository>(),
      productVariantRepository: sl<ProductVariantRepository>(),
      locationRepository: sl<LocationRepository>(),
      userRepository: sl<UserRepository>(),
      inventoryRepository: sl<InventoryRepository>(),
      transferRepository: sl<TransferRepository>(),
      administratorRepository: sl<AdministratorRepository>(),
      employeeStoreRepository: sl<EmployeeStoreRepository>(),
      employeeWarehouseRepository: sl<EmployeeWarehouseRepository>(),
      supplierRepository: sl<SupplierRepository>(),
      purchaseRepository: sl<PurchaseRepository>(),
      networkInfo: sl<NetworkInfo>(),
      saleRepository: sl<SaleRepository>(),
      customerRepository: sl<CustomerRepository>(),
      cartRepository: sl<CartRepository>(),
    );
  }
}
