import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/store.dart';
import '../bloc/store/store_bloc.dart';
import '../bloc/store/store_event.dart';
import '../bloc/store/store_state.dart';
import 'store_form_page.dart';

/// Página de lista de tiendas
class StoreListPage extends StatelessWidget {
  const StoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoreBloc>()..add(const LoadAllStores()),
      child: const _StoreListView(),
    );
  }
}

class _StoreListView extends StatefulWidget {
  const _StoreListView();

  @override
  State<_StoreListView> createState() => _StoreListViewState();
}

class _StoreListViewState extends State<_StoreListView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<StoreBloc>().add(const LoadAllStores());
    } else {
      context.read<StoreBloc>().add(SearchStores(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  context.read<StoreBloc>().add(const LoadAllStores());
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<StoreBloc>().add(const SyncStores());
            },
            tooltip: 'Sincronizar con servidor',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StoreBloc>().add(const LoadAllStores());
            },
            tooltip: 'Refrescar lista',
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (PermissionHelper.canCreateStores(user)) {
              return FloatingActionButton.extended(
                onPressed: () => _navigateToForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Nueva Tienda'),
                backgroundColor: AppColors.primaryOrange,
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
                            context.read<StoreBloc>().add(const LoadAllStores());
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
            child: BlocConsumer<StoreBloc, StoreState>(
              listener: (context, state) {
                if (state is StoreError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is StoreCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Tienda creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is StoreDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ Tienda eliminada'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (state is StoresSynced) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Sincronización completada'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is StoreLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StoreListLoaded) {
                  if (state.stores.isEmpty) {
                    return _EmptyState(
                      onCreatePressed: () => _navigateToForm(context),
                    );
                  }

                  return _StoreList(
                    stores: state.stores,
                    onAddPressed: () => _navigateToForm(context),
                    onEditPressed: (store) => _navigateToForm(context, store: store),
                    onDeletePressed: (store) => _showDeleteConfirmation(context, store),
                  );
                }

                if (state is StoresSearched) {
                  if (state.stores.isEmpty) {
                    return _EmptySearchState(query: state.query);
                  }

                  return _StoreList(
                    stores: state.stores,
                    onAddPressed: () => _navigateToForm(context),
                    onEditPressed: (store) => _navigateToForm(context, store: store),
                    onDeletePressed: (store) => _showDeleteConfirmation(context, store),
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

  void _navigateToForm(BuildContext context, {Store? store}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoreFormPage(store: store),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Tienda'),
        content: Text('¿Estás seguro de eliminar "${store.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StoreBloc>().add(DeleteStore(store.id));
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

class _StoreList extends StatelessWidget {
  final List<Store> stores;
  final VoidCallback onAddPressed;
  final Function(Store) onEditPressed;
  final Function(Store) onDeletePressed;

  const _StoreList({
    required this.stores,
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
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _StoreCard(
                store: store,
                onTap: () => onEditPressed(store),
                onDelete: () => onDeletePressed(store),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StoreCard({
    required this.store,
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
          canEdit = PermissionHelper.canEditStore(user, store.id);
          canDelete = PermissionHelper.canDeleteStores(user);
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: store.isActive ? AppColors.success : Colors.grey,
              child: Icon(
                Icons.store,
                color: Colors.white,
              ),
            ),
            title: Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.address),
                if (store.phone != null) Text('📞 ${store.phone}'),
                if (!store.isActive)
                  const Text(
                    'INACTIVA',
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
                    tooltip: 'Editar tienda',
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Eliminar tienda',
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
            Icons.store_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tiendas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea la primera tienda para comenzar',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreatePressed,
            icon: const Icon(Icons.add),
            label: const Text('Crear Tienda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
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
            'No se encontraron tiendas que coincidan con "$query"',
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