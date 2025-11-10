import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../locations/domain/entities/store.dart';
import '../../../locations/domain/entities/warehouse.dart';
import '../../../locations/presentation/bloc/store/store_bloc.dart';
import '../../../locations/presentation/bloc/store/store_event.dart';
import '../../../locations/presentation/bloc/store/store_state.dart';
import '../../../locations/presentation/bloc/warehouse/warehouse_bloc.dart';
import '../../../locations/presentation/bloc/warehouse/warehouse_event.dart';
import '../../../locations/presentation/bloc/warehouse/warehouse_state.dart';

/// Modelo para retornar ubicación seleccionada
class SelectedLocation {
  final String id;
  final String name;
  final String type; // 'store' o 'warehouse'
  final String address;

  const SelectedLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
  });
}

/// Página para seleccionar ubicación destino de la compra (tienda o almacén)
class PurchaseLocationSelectorPage extends StatefulWidget {
  const PurchaseLocationSelectorPage({super.key});

  @override
  State<PurchaseLocationSelectorPage> createState() =>
      _PurchaseLocationSelectorPageState();
}

class _PurchaseLocationSelectorPageState
    extends State<PurchaseLocationSelectorPage> {
  String _searchQuery = '';
  String _locationType = 'all'; // 'all', 'store', 'warehouse'

  @override
  void initState() {
    super.initState();
    // Los BLoCs ya cargan los datos al crearse (ver purchase_form_page.dart)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Destino'),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar ubicación',
                    hintText: 'Nombre o dirección...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filtro por tipo
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'all',
                      label: Text('Todos'),
                      icon: Icon(Icons.list),
                    ),
                    ButtonSegment(
                      value: 'warehouse',
                      label: Text('Almacenes'),
                      icon: Icon(Icons.warehouse),
                    ),
                    ButtonSegment(
                      value: 'store',
                      label: Text('Tiendas'),
                      icon: Icon(Icons.store),
                    ),
                  ],
                  selected: {_locationType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _locationType = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),

          // Lista de ubicaciones
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<StoreBloc>().add(const LoadAllStores());
                context.read<WarehouseBloc>().add(const LoadAllWarehouses());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Almacenes
                    if (_locationType == 'all' || _locationType == 'warehouse')
                      _buildWarehousesSection(),

                    if (_locationType == 'all') const SizedBox(height: 24),

                    // Sección de Tiendas
                    if (_locationType == 'all' || _locationType == 'store')
                      _buildStoresSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir sección de almacenes
  Widget _buildWarehousesSection() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is WarehouseError) {
          return _buildErrorWidget(
            'Error al cargar almacenes',
            state.message,
            () => context.read<WarehouseBloc>().add(const LoadAllWarehouses()),
          );
        }

        if (state is WarehouseListLoaded) {
          final warehouses = _filterWarehouses(state.warehouses);

          if (warehouses.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return _buildEmptySearch('almacenes');
            }
            return _buildEmptyState(
              'No hay almacenes',
              Icons.warehouse,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_locationType == 'all')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warehouse,
                        color: AppColors.accentBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Almacenes (${warehouses.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentBlue,
                            ),
                      ),
                    ],
                  ),
                ),
              ...warehouses.map((warehouse) => _LocationCard(
                    name: warehouse.name,
                    address: warehouse.address,
                    phone: warehouse.phone,
                    icon: Icons.warehouse,
                    iconColor: AppColors.accentBlue,
                    isActive: warehouse.isActive,
                    onTap: () => _selectLocation(
                      id: warehouse.id,
                      name: warehouse.name,
                      type: 'warehouse',
                      address: warehouse.address,
                    ),
                  )),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Construir sección de tiendas
  Widget _buildStoresSection() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        if (state is StoreLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is StoreError) {
          return _buildErrorWidget(
            'Error al cargar tiendas',
            state.message,
            () => context.read<StoreBloc>().add(const LoadAllStores()),
          );
        }

        if (state is StoreListLoaded) {
          final stores = _filterStores(state.stores);

          if (stores.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return _buildEmptySearch('tiendas');
            }
            return _buildEmptyState(
              'No hay tiendas',
              Icons.store,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_locationType == 'all')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.store,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tiendas (${stores.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                      ),
                    ],
                  ),
                ),
              ...stores.map((store) => _LocationCard(
                    name: store.name,
                    address: store.address,
                    phone: store.phone,
                    icon: Icons.store,
                    iconColor: AppColors.primaryOrange,
                    isActive: store.isActive,
                    onTap: () => _selectLocation(
                      id: store.id,
                      name: store.name,
                      type: 'store',
                      address: store.address,
                    ),
                  )),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Filtrar almacenes por búsqueda
  List<Warehouse> _filterWarehouses(List<Warehouse> warehouses) {
    if (_searchQuery.isEmpty) return warehouses;

    return warehouses.where((warehouse) {
      final nameMatch = warehouse.name.toLowerCase().contains(_searchQuery);
      final addressMatch =
          warehouse.address.toLowerCase().contains(_searchQuery);
      return nameMatch || addressMatch;
    }).toList();
  }

  /// Filtrar tiendas por búsqueda
  List<Store> _filterStores(List<Store> stores) {
    if (_searchQuery.isEmpty) return stores;

    return stores.where((store) {
      final nameMatch = store.name.toLowerCase().contains(_searchQuery);
      final addressMatch = store.address.toLowerCase().contains(_searchQuery);
      return nameMatch || addressMatch;
    }).toList();
  }

  /// Construir widget de error
  Widget _buildErrorWidget(String title, String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir widget de estado vacío
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir widget de búsqueda vacía
  Widget _buildEmptySearch(String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron $type',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros términos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seleccionar ubicación y retornar
  void _selectLocation({
    required String id,
    required String name,
    required String type,
    required String address,
  }) {
    final location = SelectedLocation(
      id: id,
      name: name,
      type: type,
      address: address,
    );

    Navigator.of(context).pop(location);
  }
}

/// Card para mostrar una ubicación
class _LocationCard extends StatelessWidget {
  final String name;
  final String address;
  final String? phone;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final VoidCallback onTap;

  const _LocationCard({
    required this.name,
    required this.address,
    this.phone,
    required this.icon,
    required this.iconColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (!isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Inactivo',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (phone != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Icono de selección
              if (isActive)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
