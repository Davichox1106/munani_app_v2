import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sync/presentation/widgets/sync_indicator.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart' as supplier_event;
import '../bloc/supplier_state.dart';
import '../widgets/supplier_card.dart';
import 'supplier_form_page.dart';

/// Página de lista de proveedores
class SuppliersListPage extends StatefulWidget {
  const SuppliersListPage({super.key});

  @override
  State<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends State<SuppliersListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(const supplier_event.LoadSuppliers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<SupplierBloc>().add(const supplier_event.LoadSuppliers());
    } else {
      context.read<SupplierBloc>().add(supplier_event.SearchSuppliers(query));
    }
  }

  void _syncSuppliers() {
    context.read<SupplierBloc>().add(const supplier_event.SyncSuppliers());
  }

  void _deleteSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar Proveedor'),
        content: Text(
          '¿Está seguro que desea desactivar el proveedor "${supplier.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SupplierBloc>()
                  .add(supplier_event.DeleteSupplier(supplier.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  context
                      .read<SupplierBloc>()
                      .add(const supplier_event.LoadSuppliers());
                }
              });
            },
          ),
          // Botón de sincronización
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncSuppliers,
          ),
          // Indicador de sincronización
          const SyncIndicator(showLabel: false),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o RUC/NIT...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<SupplierBloc>()
                                .add(const supplier_event.LoadSuppliers());
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

          // Lista de proveedores
          Expanded(
            child: BlocConsumer<SupplierBloc, SupplierState>(
              listener: (context, state) {
                if (state is SupplierError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is SupplierOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is SupplierSyncSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SupplierLoading || state is SupplierSyncing) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SupplierLoaded) {
                  final suppliers = state.suppliers;

                  if (suppliers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay proveedores',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega tu primer proveedor',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<SupplierBloc>()
                          .add(const supplier_event.SyncSuppliers());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        return SupplierCard(
                          supplier: supplier,
                          onTap: () async {
                            final bloc = context.read<SupplierBloc>();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (newContext) => BlocProvider.value(
                                  value: bloc,
                                  child: SupplierFormPage(supplier: supplier),
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              bloc.add(const supplier_event.LoadSuppliers());
                            }
                          },
                          onDelete: () => _deleteSupplier(supplier),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: Text('Error al cargar proveedores'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox();

          // Solo admins pueden crear proveedores
          if (!PermissionHelper.canManageSuppliers(authState.user)) {
            return const SizedBox();
          }

          return FloatingActionButton.extended(
            onPressed: () async {
              final bloc = context.read<SupplierBloc>();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (newContext) => BlocProvider.value(
                    value: bloc,
                    child: const SupplierFormPage(),
                  ),
                ),
              );
              if (result == true && mounted) {
                bloc.add(const supplier_event.LoadSuppliers());
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Proveedor'),
          );
        },
      ),
    );
  }
}
