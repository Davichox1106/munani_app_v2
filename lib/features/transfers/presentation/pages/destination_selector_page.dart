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

/// Página para seleccionar ubicación origen (donde está el producto)
class DestinationSelectorPage extends StatefulWidget {
  final InventoryItem selectedProduct;
  
  const DestinationSelectorPage({
    super.key,
    required this.selectedProduct,
  });

  @override
  State<DestinationSelectorPage> createState() => _DestinationSelectorPageState();
}

class _DestinationSelectorPageState extends State<DestinationSelectorPage> {
  String _typeFilter = 'all'; // all, store, warehouse
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Cargar todo el inventario
    context.read<InventoryBloc>().add(const LoadAllInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Origen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // La búsqueda se aplica automáticamente con onChanged
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del producto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.primaryOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Producto: ${widget.selectedProduct.productName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.selectedProduct.variantName != null)
                        Text(
                          'Variante: ${widget.selectedProduct.variantName}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
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
                    labelText: 'Buscar ubicación',
                    hintText: 'Nombre de la ubicación...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filtro de tipo
                DropdownButtonFormField<String>(
                  initialValue: _typeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de ubicación',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todas las ubicaciones')),
                    DropdownMenuItem(value: 'store', child: Text('Solo tiendas')),
                    DropdownMenuItem(value: 'warehouse', child: Text('Solo almacenes')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _typeFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Lista de ubicaciones con inventario
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                return _buildInventoryList(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(InventoryState state) {
    // Mostrar loading
    if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar error
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<InventoryBloc>().add(const LoadAllInventory());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Obtener inventario
    List<InventoryItem> inventoryItems = [];
    if (state is InventoryLoaded) {
      // Filtrar solo el producto seleccionado
      inventoryItems = state.items.where((item) => 
        item.productVariantId == widget.selectedProduct.productVariantId
      ).toList();
    }

    // Aplicar filtros
    final filteredItems = _filterInventoryItems(inventoryItems);

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ubicaciones con este producto',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El producto no está disponible en ninguna ubicación',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
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
        return _InventoryCard(
          item: item,
          onTap: () => _selectLocation(item),
        );
      },
    );
  }

  List<InventoryItem> _filterInventoryItems(List<InventoryItem> items) {
    var filtered = items;

    // Filtrar por tipo
    if (_typeFilter != 'all') {
      filtered = filtered.where((item) => item.locationType == _typeFilter).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.locationName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      }).toList();
    }

    // Solo items con stock > 0
    filtered = filtered.where((item) => item.quantity > 0).toList();

    // EXCLUIR la tienda del usuario actual (no puede transferir desde su propia tienda)
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final currentUser = authState.user;
      AppLogger.debug('🔍 DestinationSelector: Usuario actual: ${currentUser.name}');
      AppLogger.debug('🔍 DestinationSelector: assignedLocationId: ${currentUser.assignedLocationId}');
      AppLogger.debug('🔍 DestinationSelector: assignedLocationType: ${currentUser.assignedLocationType}');
      
      // Si el usuario tiene una ubicación asignada, excluirla de las opciones
      if (currentUser.assignedLocationId != null && currentUser.assignedLocationType != null) {
        AppLogger.debug('🔍 DestinationSelector: Excluyendo ubicación propia: ${currentUser.assignedLocationType} - ${currentUser.assignedLocationId}');
        final beforeCount = filtered.length;
        filtered = filtered.where((item) {
          final isOwnLocation = item.locationType == currentUser.assignedLocationType && 
                               item.locationId == currentUser.assignedLocationId;
          AppLogger.debug('🔍 DestinationSelector: Item ${item.locationName} (${item.locationId}) vs Usuario (${currentUser.assignedLocationId}) - Es propia: $isOwnLocation');
          return !isOwnLocation;
        }).toList();
        AppLogger.debug('🔍 DestinationSelector: Filtrados $beforeCount -> ${filtered.length} items');
        
        // Log de items restantes
        for (var item in filtered) {
          AppLogger.debug('🔍 DestinationSelector: Item restante: ${item.locationName} (${item.locationType}) - ${item.locationId}');
        }
      } else {
        AppLogger.debug('🔍 DestinationSelector: Usuario sin ubicación asignada, no se excluye nada');
      }
    } else {
      AppLogger.debug('🔍 DestinationSelector: Usuario no autenticado');
    }

    return filtered;
  }

  void _selectLocation(InventoryItem item) {
    Navigator.of(context).pop({
      'id': item.locationId,
      'name': item.locationName ?? 'Ubicación desconocida',
      'type': item.locationType,
    });
  }
}

/// Card para mostrar un item de inventario
class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const _InventoryCard({
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
          child: Row(
            children: [
              // Ícono según tipo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.locationType == 'store' ? Icons.store : Icons.warehouse,
                  color: _getTypeColor(),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.locationName ?? 'Ubicación desconocida',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.locationType == 'store' ? 'Tienda' : 'Almacén',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stock disponible
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStockColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: _getStockColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.quantity} unidades',
                            style: TextStyle(
                              color: _getStockColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    return item.locationType == 'store' ? AppColors.accentBlue : AppColors.accentGreen;
  }

  Color _getStockColor() {
    if (item.quantity <= 0) return AppColors.error;
    if (item.quantity <= 10) return AppColors.warning;
    return AppColors.success;
  }
}
