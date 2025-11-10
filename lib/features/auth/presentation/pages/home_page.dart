import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../sync/presentation/widgets/sync_indicator.dart';
import '../../../products/presentation/pages/product_list_page.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../inventory/presentation/pages/inventory_list_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/pages/cart_review_page.dart';
import '../../../cart/presentation/pages/customer_cart_page.dart';
import '../../../sales/presentation/bloc/sale_bloc.dart';
import '../../../sales/presentation/bloc/sale_event.dart';
import '../../../sales/presentation/pages/sales_list_page.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/pages/customers_list_page.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../locations/presentation/pages/store_list_page.dart';
import '../../../locations/presentation/pages/warehouse_list_page.dart';
import '../../../users/presentation/bloc/user_management_bloc.dart';
import '../../../users/presentation/pages/user_list_page.dart';
import '../../../employees/presentation/pages/administrators_page.dart';
import '../../../employees/presentation/pages/employees_store_page.dart';
import '../../../employees/presentation/pages/employees_warehouse_page.dart';
import '../../../transfers/presentation/pages/transfer_list_page.dart';
import '../../../transfers/presentation/bloc/transfer_bloc.dart';
import '../../../transfers/presentation/bloc/transfer_event.dart';
import '../../../purchases/presentation/pages/suppliers_list_page.dart';
import '../../../purchases/presentation/bloc/supplier_bloc.dart';
import '../../../purchases/presentation/bloc/supplier_event.dart';
import '../../../purchases/presentation/pages/purchases_list_page.dart';
import '../../../purchases/presentation/bloc/purchase_bloc.dart';
import '../../../purchases/presentation/bloc/purchase_event.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Pantalla Home - Dashboard principal
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = state.user;
        final isCustomer = user.role == 'customer';

        final moduleCards = <Widget>[
          _buildModuleCard(
            context,
            isCustomer ? 'Catálogo' : 'Inventario',
            Icons.inventory_2,
            AppColors.primaryOrange,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) =>
                            sl<InventoryBloc>()..add(const LoadAllInventory()),
                      ),
                      if (isCustomer)
                        BlocProvider(
                          create: (_) => sl<CartBloc>()..add(CartStarted(user.id)),
                        ),
                    ],
                    child: const InventoryListPage(),
                  ),
                ),
              );
            },
          ),
        ];

        if (isCustomer) {
          moduleCards.add(
            _buildModuleCard(
              context,
              'Carrito e historial',
              Icons.shopping_cart_checkout,
              AppColors.primaryBrown,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          sl<CartBloc>()..add(CartStarted(user.id)),
                      child: const CustomerCartPage(),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (!isCustomer) {
          moduleCards.addAll([
            _buildModuleCard(
              context,
              'Productos',
              Icons.shopping_bag,
              AppColors.primaryAmber,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          sl<ProductBloc>()..add(const LoadProducts()),
                      child: const ProductListPage(),
                    ),
                  ),
                );
              },
            ),
            _buildModuleCard(
              context,
              'Tiendas',
              Icons.store,
              AppColors.info,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StoreListPage(),
                  ),
                );
              },
            ),
            _buildModuleCard(
              context,
              'Almacenes',
              Icons.warehouse,
              AppColors.warning,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WarehouseListPage(),
                  ),
                );
              },
            ),
            _buildModuleCard(
              context,
              'Transferencias',
              Icons.swap_horiz,
              Colors.purple,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          sl<TransferBloc>()..add(const LoadAllTransfers()),
                      child: const TransferListPage(),
                    ),
                  ),
                );
              },
            ),
            if (user.role == 'store_manager' ||
                user.role == 'warehouse_manager' ||
                user.role == 'admin')
              _buildModuleCard(
                context,
                'Pedidos pendientes',
                Icons.pending_actions_outlined,
                Colors.blueGrey,
                () {
                  if (!user.isAdmin &&
                      (user.assignedLocationId == null ||
                          user.assignedLocationType == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Asigna una ubicación al usuario para revisar pedidos.',
                        ),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartReviewPage(
                        locationId: user.isAdmin
                            ? null
                            : user.assignedLocationId,
                        locationType: user.isAdmin
                            ? null
                            : user.assignedLocationType,
                      ),
                    ),
                  );
                },
              ),
            if (user.role == 'admin')
              _buildModuleCard(
                context,
                'Proveedores',
                Icons.business,
                Colors.teal,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            sl<SupplierBloc>()..add(const LoadSuppliers()),
                        child: const SuppliersListPage(),
                      ),
                    ),
                  );
                },
              ),
            _buildModuleCard(
              context,
              'Compras',
              Icons.shopping_cart,
              Colors.indigo,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          sl<PurchaseBloc>()..add(const LoadPurchases()),
                      child: const PurchasesListPage(),
                    ),
                  ),
                );
              },
            ),
            _buildModuleCard(
              context,
              'Ventas',
              Icons.point_of_sale,
              Colors.green,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<SaleBloc>()..add(const LoadSales()),
                      child: const SalesListPage(),
                    ),
                  ),
                );
              },
            ),
            _buildModuleCard(
              context,
              'Clientes',
              Icons.people,
              Colors.cyan,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          sl<CustomerBloc>()..add(const LoadCustomers()),
                      child: const CustomersListPage(),
                    ),
                  ),
                );
              },
            ),
            _buildModuleCard(
              context,
              'Reportes',
              Icons.assessment,
              Colors.deepOrange,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<ReportsBloc>(),
                      child: const ReportsPage(),
                    ),
                  ),
                );
              },
            ),
            if (user.isAdmin) ...[
              _buildModuleCard(
                context,
                'Usuarios',
                Icons.people,
                AppColors.error,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<UserManagementBloc>(),
                        child: UserListPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildModuleCard(
                context,
                'Administradores',
                Icons.admin_panel_settings,
                Colors.deepPurple,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdministratorsPage(),
                    ),
                  );
                },
              ),
              _buildModuleCard(
                context,
                'Empleados Tienda',
                Icons.store_mall_directory,
                Colors.blue,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmployeesStorePage(),
                    ),
                  );
                },
              ),
              _buildModuleCard(
                context,
                'Empleados Almacén',
                Icons.warehouse_outlined,
                Colors.brown,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmployeesWarehousePage(),
                    ),
                  );
                },
              ),
            ],
          ]);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Munani'),
            actions: [
              // Indicador de sincronización
              const SyncIndicator(showLabel: true),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar Sesión',
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de bienvenida
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primaryOrange,
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenido,',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    user.name,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          Icons.email,
                          'Email',
                          user.email,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          Icons.badge,
                          'Rol',
                          _getRoleLabel(user.role),
                        ),
                        if (user.hasAssignedLocation) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            Icons.location_on,
                            'Ubicación',
                            user.assignedLocationName ?? _getLocationTypeLabel(user.assignedLocationType),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          Icons.check_circle,
                          'Estado',
                          user.isActive ? 'Activo' : 'Inactivo',
                          color: user.isActive ? AppColors.success : AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sección de módulos
                Text(
                  'Módulos del Sistema',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                // Grid de módulos (próximamente)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: moduleCards,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'store_manager':
        return 'Gerente de Tienda';
      case 'warehouse_manager':
        return 'Gerente de Bodega';
      default:
        return role;
    }
  }

  String _getLocationTypeLabel(String? locationType) {
    if (locationType == null) return 'No asignada';
    switch (locationType) {
      case 'store':
        return 'Tienda';
      case 'warehouse':
        return 'Almacén';
      default:
        return locationType;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
