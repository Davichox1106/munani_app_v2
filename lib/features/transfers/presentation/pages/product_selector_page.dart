import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/utils/app_logger.dart';

/// Página para seleccionar un producto del inventario
class ProductSelectorPage extends StatefulWidget {
  const ProductSelectorPage({super.key});

  @override
  State<ProductSelectorPage> createState() => _ProductSelectorPageState();
}

class _ProductSelectorPageState extends State<ProductSelectorPage> {
  String _searchQuery = '';
  String _locationFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Cargar inventario al iniciar
    context.read<InventoryBloc>().add(LoadAllInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
              if (_searchQuery.isNotEmpty) {
                context.read<InventoryBloc>().add(SearchInventory(_searchQuery));
              } else {
                context.read<InventoryBloc>().add(LoadAllInventory());
              }
            },
          ),
        ],
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
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar producto',
                    hintText: 'Nombre del producto...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<InventoryBloc>().add(SearchInventory(value));
                    } else {
                      context.read<InventoryBloc>().add(LoadAllInventory());
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Filtro de ubicación
                DropdownButtonFormField<String>(
                  initialValue: _locationFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por ubicación',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todas las ubicaciones')),
                    DropdownMenuItem(value: 'store', child: Text('Solo tiendas')),
                    DropdownMenuItem(value: 'warehouse', child: Text('Solo almacenes')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _locationFilter = value!;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InventoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar inventario',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<InventoryBloc>().add(LoadAllInventory());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is InventoryLoaded) {
                  final filteredItems = _filterItems(state.items);
                  
                  if (filteredItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay productos disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _InventoryItemCard(
                        item: item,
                        onTap: () => _selectItem(item),
                      );
                    },
                  );
                }

                return const Center(child: Text('Estado desconocido'));
              },
            ),
          ),
        ],
      ),
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    var filtered = items;

    // Filtrar por ubicación
    if (_locationFilter != 'all') {
      filtered = filtered.where((item) => item.locationType == _locationFilter).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return (item.productName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (item.variantName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // EXCLUIR productos de la tienda del usuario actual (no puede transferir desde su propia tienda)
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final currentUser = authState.user;
      AppLogger.debug('🔍 ProductSelector: Usuario actual: ${currentUser.name}');
      AppLogger.debug('🔍 ProductSelector: assignedLocationId: ${currentUser.assignedLocationId}');
      AppLogger.debug('🔍 ProductSelector: assignedLocationType: ${currentUser.assignedLocationType}');
      
      // Si el usuario tiene una ubicación asignada, excluirla de las opciones
      if (currentUser.assignedLocationId != null && currentUser.assignedLocationType != null) {
        AppLogger.debug('🔍 ProductSelector: Excluyendo ubicación propia: ${currentUser.assignedLocationType} - ${currentUser.assignedLocationId}');
        final beforeCount = filtered.length;
        filtered = filtered.where((item) {
          final isOwnLocation = item.locationType == currentUser.assignedLocationType && 
                               item.locationId == currentUser.assignedLocationId;
          AppLogger.debug('🔍 ProductSelector: Item ${item.locationName} (${item.locationId}) vs Usuario (${currentUser.assignedLocationId}) - Es propia: $isOwnLocation');
          return !isOwnLocation;
        }).toList();
        AppLogger.debug('🔍 ProductSelector: Filtrados $beforeCount -> ${filtered.length} items');
        
        // Log de items restantes
        for (var item in filtered) {
          AppLogger.debug('🔍 ProductSelector: Item restante: ${item.locationName} (${item.locationType}) - ${item.locationId}');
        }
      } else {
        AppLogger.debug('🔍 ProductSelector: Usuario sin ubicación asignada, no se excluye nada');
      }
    } else {
      AppLogger.debug('🔍 ProductSelector: Usuario no autenticado');
    }

    return filtered;
  }

  void _applyFilters() {
    // Aplicar filtros sin recargar desde el servidor
    setState(() {});
  }

  void _selectItem(InventoryItem item) {
    Navigator.of(context).pop(item);
  }
}

/// Card para mostrar un item del inventario
class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const _InventoryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre del producto
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.productName ?? 'Producto sin nombre',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // Badge de stock
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStockColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.quantity} unidades',
                      style: TextStyle(
                        color: _getStockColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Variante
              if (item.variantName != null)
                Text(
                  item.variantName!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Ubicación
              Row(
                children: [
                  Icon(
                    item.locationType == 'store' ? Icons.store : Icons.warehouse,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.locationName ?? 'Sin ubicación',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Stock mínimo
              if (item.quantity <= item.minStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stock bajo',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (item.quantity <= item.minStock) {
      return AppColors.warning;
    } else if (item.quantity >= item.maxStock) {
      return AppColors.success;
    } else {
      return AppColors.accentBlue;
    }
  }
}
