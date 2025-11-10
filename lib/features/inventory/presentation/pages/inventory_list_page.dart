import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sync/presentation/widgets/sync_indicator.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import 'inventory_form_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/pages/customer_cart_page.dart';
import 'inventory_image_gallery_page.dart';

/// Página de lista de inventario
///
/// Muestra el inventario con funcionalidad de:
/// - Ver todo el inventario (admin) o por ubicación (managers)
/// - Filtrar por alertas de stock bajo
/// - Actualizar cantidades rápidamente (+/-)
/// - Crear/editar items de inventario
class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  String _selectedFilter = 'all'; // 'all', 'low_stock', 'store', 'warehouse'
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // Cargar inventario inicial según el filtro por defecto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onFilterSelected(_selectedFilter);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _onFilterSelected(_selectedFilter);
    } else {
      context.read<InventoryBloc>().add(SearchInventory(query));
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    // Obtener el usuario actual para aplicar permisos
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return;
    }
    
    final user = authState.user;
    
    // Aplicar filtros según permisos del usuario
    // Todos los gerentes y admins pueden ver inventario de cualquier ubicación
    if (user.isAdmin || user.isStoreManager || user.isWarehouseManager) {
      switch (filter) {
        case 'all':
          context.read<InventoryBloc>().add(const LoadAllInventory());
          break;
        case 'low_stock':
          context.read<InventoryBloc>().add(const LoadLowStockInventory());
          break;
        case 'store':
          context.read<InventoryBloc>().add(const LoadStoreInventory());
          break;
        case 'warehouse':
          context.read<InventoryBloc>().add(const LoadWarehouseInventory());
          break;
        default:
          context.read<InventoryBloc>().add(const LoadAllInventory());
      }
    } else {
      // Usuario sin permisos - no cargar nada
      context.read<InventoryBloc>().add(const LoadAllInventory());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _onFilterSelected(_selectedFilter);
                }
              });
            },
          ),
          // Indicador de sincronización
          const SyncIndicator(showLabel: false),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda (si está activa)
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por producto, cantidad, usuario, fecha, estado...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onFilterSelected(_selectedFilter);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

          // Filtros horizontales
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: 'Todos',
                  icon: Icons.inventory_2,
                  isSelected: _selectedFilter == 'all',
                  onTap: () => _onFilterSelected('all'),
                ),
                _FilterChip(
                  label: 'Stock Bajo',
                  icon: Icons.warning_amber,
                  isSelected: _selectedFilter == 'low_stock',
                  onTap: () => _onFilterSelected('low_stock'),
                  color: AppColors.warning,
                ),
                _FilterChip(
                  label: 'Tiendas',
                  icon: Icons.store,
                  isSelected: _selectedFilter == 'store',
                  onTap: () => _onFilterSelected('store'),
                ),
                _FilterChip(
                  label: 'Almacenes',
                  icon: Icons.warehouse,
                  isSelected: _selectedFilter == 'warehouse',
                  onTap: () => _onFilterSelected('warehouse'),
                ),
              ],
            ),
          ),

          // Lista de inventario
          Expanded(
            child: BlocConsumer<InventoryBloc, InventoryState>(
              listener: (context, state) {
                if (state is InventoryUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is InventoryDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.warning,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is InventoryCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              buildWhen: (previous, current) {
                // Solo reconstruir cuando el estado contenga una lista de items
                // Ignorar estados de operación (Created/Updated/Deleted) para evitar parpadeos
                // El BLoC se encargará de recargar automáticamente después de actualizar
                return current is InventoryLoading ||
                    current is InventoryLoaded ||
                    current is InventoryByLocationLoaded ||
                    current is LowStockInventoryLoaded ||
                    current is InventorySearched ||
                    current is InventoryError;
              },
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is InventoryError) {
                  return Center(
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
                          'Error al cargar inventario',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<InventoryBloc>()
                                .add(const LoadAllInventory());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Obtener items según el estado
                List<InventoryItem> items = [];
                if (state is InventoryLoaded) {
                  items = state.items;
                } else if (state is InventoryByLocationLoaded) {
                  items = state.items;
                } else if (state is LowStockInventoryLoaded) {
                  items = state.items;
                } else if (state is InventorySearched) {
                  items = state.items;
                }

                final authState = context.read<AuthBloc>().state;
                final bool customerView =
                    authState is AuthAuthenticated && authState.user.role == 'customer';

                if (items.isEmpty) {
                  // Determinar el mensaje según el estado
                  String title;
                  String subtitle;
                  IconData icon;

                  if (state is InventorySearched) {
                    title = 'Sin resultados';
                    subtitle = 'No se encontraron items que coincidan con "${state.query}"';
                    icon = Icons.search_off;
                  } else if (_selectedFilter == 'low_stock') {
                    title = 'Sin alertas de stock bajo';
                    subtitle = 'Todos los productos tienen stock suficiente';
                    icon = Icons.check_circle_outline;
                  } else {
                    if (customerView) {
                      title = 'Sin productos disponibles';
                      subtitle = 'Pronto encontrarás productos en este catálogo';
                    } else {
                      title = 'No hay inventario';
                      subtitle = 'Crea tu primer item de inventario';
                    }
                    icon = Icons.inventory_2_outlined;
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _onFilterSelected(_selectedFilter);
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _InventoryCard(
                        item: item,
                        onIncrement: () => _adjustQuantity(context, item, 1),
                        onDecrement: () => _adjustQuantity(context, item, -1),
                        onEdit: () => _navigateToEdit(context, item),
                        onDelete: () => _confirmDelete(context, item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (user.role == 'customer') {
              return FloatingActionButton.extended(
                onPressed: () => _openCart(context),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Mi carrito'),
              );
            }
            if (user.isAdmin) {
              return FloatingActionButton.extended(
                onPressed: () => _navigateToCreate(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Item'),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _adjustQuantity(BuildContext context, InventoryItem item, int delta) {
    // Obtener usuario actual del AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario no autenticado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = authState.user;
    
    // Verificar permisos antes de permitir el ajuste
    if (!PermissionHelper.canEditInventoryAtLocation(
      user, 
      item.locationId, 
      item.locationType
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para modificar este inventario'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final userId = user.id;

    context.read<InventoryBloc>().add(
          AdjustInventory(
            id: item.id,
            delta: delta,
            updatedBy: userId,
          ),
        );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InventoryBloc>(),
          child: const InventoryFormPage(),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, InventoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InventoryBloc>(),
          child: InventoryFormPage(inventoryItem: item),
        ),
      ),
    );
  }

  void _openCart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: const CustomerCartPage(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Inventario'),
        content: Text(
          '¿Estás seguro de eliminar este registro de inventario?\n\n'
          'Ubicación: ${item.locationType}\n'
          'Stock actual: ${item.quantity}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryBloc>().add(DeleteInventoryItem(item.id));
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Widget para chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryOrange;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : chipColor,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: chipColor,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Widget para card de inventario en la lista
class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InventoryCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool canEdit = false;
        bool canDelete = false;
        bool isCustomer = false;

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          isCustomer = user.role == 'customer';
          canEdit = PermissionHelper.canEditInventoryAtLocation(
            user,
            item.locationId,
            item.locationType
          );
          canDelete = user.isAdmin; // Solo admins pueden eliminar
        }
        
        final outOfStock = item.quantity == 0;
        final lowStock = item.isLowStock && !outOfStock;
        final overStock = item.isOverStock;

        Color statusColor;
        IconData statusIcon;
        String statusText;

        if (outOfStock) {
          statusColor = AppColors.error;
          statusIcon = Icons.cancel;
          statusText = 'Sin Stock';
        } else if (lowStock) {
          statusColor = AppColors.warning;
          statusIcon = Icons.warning_amber;
          statusText = 'Stock Bajo';
        } else if (overStock) {
          statusColor = AppColors.info;
          statusIcon = Icons.inventory;
          statusText = 'Sobre Stock';
        } else {
          statusColor = AppColors.success;
          statusIcon = Icons.check_circle;
          statusText = 'Stock OK';
        }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status y ubicación
            Row(
              children: [
                // Indicador de estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Botones de acción
                if (!isCustomer && canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    color: AppColors.accentBlue,
                    onPressed: onEdit,
                    tooltip: 'Editar',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                if (!isCustomer && canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    color: AppColors.error,
                    onPressed: onDelete,
                    tooltip: 'Eliminar',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                if (!isCustomer && !canEdit && !canDelete)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (item.imageUrls.isNotEmpty) ...[
              _InventoryImagePreview(
                item: item,
              ),
              const SizedBox(height: 16),
            ],

            // Información principal
            Row(
              children: [
                // Cantidad actual
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock Actual',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.quantity.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                      ),
                    ],
                  ),
                ),

                if (!isCustomer)
                  // Controles de cantidad
                  Container(
                    decoration: BoxDecoration(
                      color: canEdit ? Colors.grey.shade100 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: canEdit && item.quantity > 0 ? AppColors.error : Colors.grey,
                          onPressed: canEdit && item.quantity > 0 ? onDecrement : null,
                          tooltip: canEdit ? 'Decrementar (-1)' : 'Sin permisos',
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey.shade300,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: canEdit ? AppColors.success : Colors.grey,
                          onPressed: canEdit ? onIncrement : null,
                          tooltip: canEdit ? 'Incrementar (+1)' : 'Sin permisos',
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (!isCustomer) ...[
              // Rangos de stock
              Row(
                children: [
                  _StockRangeChip(
                    label: 'Mín',
                    value: item.minStock,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _StockRangeChip(
                    label: 'Máx',
                    value: item.maxStock,
                    color: AppColors.info,
                  ),
                  const Spacer(),
                  // Porcentaje de stock
                  Text(
                    '${item.stockPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Barra de progreso de stock
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.stockPercentage / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),

              const SizedBox(height: 12),
            ],

            // Costos (visibles si hay datos)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Costo unitario: ${item.unitCost != null ? item.unitCost!.toStringAsFixed(2) : 'Pendiente'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: item.unitCost != null
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                  ],
                ),
                if (!isCustomer) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.summarize_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Costo total: ${item.totalCost != null ? item.totalCost!.toStringAsFixed(2) : 'Pendiente'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontWeight: item.totalCost != null
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.price_change_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Último costo: ${item.lastCost != null ? item.lastCost!.toStringAsFixed(2) : 'Pendiente'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontWeight: item.lastCost != null
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            if (isCustomer)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton.icon(
                  onPressed: item.quantity > 0
                      ? () => _showAddToCartDialog(context, item)
                      : null,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    item.quantity > 0 ? 'Agregar al carrito' : 'Sin stock',
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Información de producto y ubicación
            Row(
              children: [
                // Icono de producto
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.productName != null && item.variantName != null
                        ? '${item.productName} - ${item.variantName}'
                        : item.productName ?? 'Cargando producto...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Icono de ubicación
                Icon(
                  item.locationType == 'store' ? Icons.store : Icons.warehouse,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.locationName ?? 'Ubicación desconocida',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _InventoryImagePreview extends StatelessWidget {
  final InventoryItem item;

  const _InventoryImagePreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final firstImage = item.imageUrls.first;
    final isRemote = firstImage.startsWith('http');
    final imageWidget = isRemote
        ? Image.network(
            firstImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _BrokenImagePlaceholder(),
          )
        : Image.file(
            File(firstImage),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _BrokenImagePlaceholder(),
          );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InventoryImageGalleryPage(
              inventoryId: item.id,
              title: item.productName ?? 'Imágenes de inventario',
              imageUrls: item.imageUrls,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'inventory-thumb-${item.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: imageWidget,
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 36,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

Future<void> _showAddToCartDialog(
  BuildContext context,
  InventoryItem item,
) async {
  final maxQuantity = item.quantity;
  final cartBloc = context.read<CartBloc>();

  if (maxQuantity <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este producto está agotado'),
        backgroundColor: AppColors.error,
      ),
    );
    return;
  }

  int selectedQuantity = 1;

  final result = await showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Agregar al carrito'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Producto',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.variantName != null)
                  Text(
                    item.variantName!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                const SizedBox(height: 12),
                Text('Disponibles: $maxQuantity'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedQuantity > 1
                          ? () => setState(() => selectedQuantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$selectedQuantity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: selectedQuantity < maxQuantity
                          ? () => setState(() => selectedQuantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(selectedQuantity),
                child: const Text('Agregar'),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != null && result > 0) {
    cartBloc.add(
      CartAddInventoryItem(
        inventory: item,
        quantity: result,
      ),
    );
  }
}

/// Widget para mostrar rangos de stock (min/max)
class _StockRangeChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StockRangeChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
