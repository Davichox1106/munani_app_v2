import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/warehouse.dart';
import '../bloc/warehouse/warehouse_bloc.dart';
import '../bloc/warehouse/warehouse_event.dart';
import '../bloc/warehouse/warehouse_state.dart';
import 'warehouse_form_page.dart';

/// Página de lista de almacenes
class WarehouseListPage extends StatelessWidget {
  const WarehouseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WarehouseBloc>()..add(const LoadAllWarehouses()),
      child: const _WarehouseListView(),
    );
  }
}

class _WarehouseListView extends StatefulWidget {
  const _WarehouseListView();

  @override
  State<_WarehouseListView> createState() => _WarehouseListViewState();
}

class _WarehouseListViewState extends State<_WarehouseListView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<WarehouseBloc>().add(const LoadAllWarehouses());
    } else {
      context.read<WarehouseBloc>().add(SearchWarehouses(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenes'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  context.read<WarehouseBloc>().add(const LoadAllWarehouses());
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<WarehouseBloc>().add(const SyncWarehouses());
            },
            tooltip: 'Sincronizar con servidor',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WarehouseBloc>().add(const LoadAllWarehouses());
            },
            tooltip: 'Refrescar lista',
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (PermissionHelper.canCreateWarehouses(user)) {
              return FloatingActionButton.extended(
                onPressed: () => _navigateToForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Almacén'),
                backgroundColor: AppColors.warning,
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, dirección o teléfono...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<WarehouseBloc>().add(const LoadAllWarehouses());
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
          Expanded(
            child: BlocConsumer<WarehouseBloc, WarehouseState>(
              listener: (context, state) {
                if (state is WarehouseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is WarehouseCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Almacén creado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is WarehouseDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ Almacén eliminado'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (state is WarehousesSynced) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Sincronización completada'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is WarehouseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WarehouseListLoaded) {
                  if (state.warehouses.isEmpty) {
                    return _EmptyState(
                      onCreatePressed: () => _navigateToForm(context),
                    );
                  }

                  return _WarehouseList(
                    warehouses: state.warehouses,
                    onAddPressed: () => _navigateToForm(context),
                    onEditPressed: (warehouse) => _navigateToForm(context, warehouse: warehouse),
                    onDeletePressed: (warehouse) => _showDeleteConfirmation(context, warehouse),
                  );
                }

                if (state is WarehousesSearched) {
                  if (state.warehouses.isEmpty) {
                    return _EmptySearchState(query: state.query);
                  }

                  return _WarehouseList(
                    warehouses: state.warehouses,
                    onAddPressed: () => _navigateToForm(context),
                    onEditPressed: (warehouse) => _navigateToForm(context, warehouse: warehouse),
                    onDeletePressed: (warehouse) => _showDeleteConfirmation(context, warehouse),
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

  void _navigateToForm(BuildContext context, {Warehouse? warehouse}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WarehouseFormPage(warehouse: warehouse),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Warehouse warehouse) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Almacén'),
        content: Text('¿Estás seguro de eliminar "${warehouse.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WarehouseBloc>().add(DeleteWarehouse(warehouse.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _WarehouseList extends StatelessWidget {
  final List<Warehouse> warehouses;
  final VoidCallback onAddPressed;
  final Function(Warehouse) onEditPressed;
  final Function(Warehouse) onDeletePressed;

  const _WarehouseList({
    required this.warehouses,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: warehouses.length,
            itemBuilder: (context, index) {
              final warehouse = warehouses[index];
              return _WarehouseCard(
                warehouse: warehouse,
                onTap: () => onEditPressed(warehouse),
                onDelete: () => onDeletePressed(warehouse),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WarehouseCard({
    required this.warehouse,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool canEdit = false;
        bool canDelete = false;
        
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          canEdit = PermissionHelper.canEditWarehouse(user, warehouse.id);
          canDelete = PermissionHelper.canDeleteWarehouses(user);
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: warehouse.isActive ? AppColors.warning : Colors.grey,
              child: Icon(
                Icons.warehouse,
                color: Colors.white,
              ),
            ),
            title: Text(
              warehouse.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(warehouse.address),
                if (warehouse.phone != null) Text('📞 ${warehouse.phone}'),
                if (!warehouse.isActive)
                  const Text(
                    'INACTIVO',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onTap,
                    tooltip: 'Editar almacén',
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Eliminar almacén',
                  ),
                if (!canEdit && !canDelete)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
            onTap: canEdit ? onTap : null,
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const _EmptyState({required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay almacenes registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea el primer almacén para comenzar',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreatePressed,
            icon: const Icon(Icons.add),
            label: const Text('Crear Almacén'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String query;

  const _EmptySearchState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron almacenes que coincidan con "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}