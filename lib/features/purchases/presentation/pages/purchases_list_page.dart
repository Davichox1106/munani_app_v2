import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sync/presentation/widgets/sync_indicator.dart';
import '../../domain/entities/purchase.dart';
import '../bloc/purchase_bloc.dart';
import '../bloc/purchase_event.dart' as purchase_event;
import '../bloc/purchase_state.dart';
import '../widgets/purchase_card.dart';
import 'purchase_detail_page.dart';
import 'purchase_form_page.dart';

/// Página de lista de compras
class PurchasesListPage extends StatefulWidget {
  const PurchasesListPage({super.key});

  @override
  State<PurchasesListPage> createState() => _PurchasesListPageState();
}

class _PurchasesListPageState extends State<PurchasesListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  PurchaseStatus? _selectedStatus;
  bool _showLoadingOverlay = false;
  List<Purchase> _lastPurchases = const [];

  Future<T?> _withOverlay<T>(Future<T> Function() action) async {
    setState(() => _showLoadingOverlay = true);
    try {
      return await action();
    } finally {
      if (mounted) setState(() => _showLoadingOverlay = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Cargar en el siguiente frame para asegurar que los providers estén listos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchasesBasedOnRole();
    });
  }

  void _loadPurchasesBasedOnRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Si es gerente, filtrar por su ubicación asignada
      if ((user.role == 'store_manager' || user.role == 'warehouse_manager') &&
          user.hasAssignedLocation) {
        context.read<PurchaseBloc>().add(
          purchase_event.LoadPurchasesByLocation(user.assignedLocationId!),
        );
      } else {
        // Admin ve todas las compras
        context.read<PurchaseBloc>().add(const purchase_event.LoadPurchases());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadPurchasesBasedOnRole();
    } else {
      context.read<PurchaseBloc>().add(purchase_event.SearchPurchases(query));
    }
  }

  void _syncPurchases() {
    context.read<PurchaseBloc>().add(const purchase_event.SyncPurchases());
  }

  void _filterByStatus(PurchaseStatus? status) {
    setState(() {
      _selectedStatus = status;
    });

    if (status == null) {
      _loadPurchasesBasedOnRole();
    } else {
      context.read<PurchaseBloc>().add(
        purchase_event.LoadPurchasesByStatus(status),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar por Estado'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            PurchaseStatus? tempSelected = _selectedStatus;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setDialogState(() => tempSelected = null);
                    Navigator.pop(dialogContext);
                    _filterByStatus(null);
                  },
                  child: ListTile(
                    title: const Text('Todos'),
                    leading: Icon(
                      tempSelected == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: tempSelected == null ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setDialogState(() => tempSelected = PurchaseStatus.pending);
                    Navigator.pop(dialogContext);
                    _filterByStatus(PurchaseStatus.pending);
                  },
                  child: ListTile(
                    title: const Text('Pendientes'),
                    subtitle: const Text('Compras creadas pero no recibidas'),
                    leading: Icon(
                      tempSelected == PurchaseStatus.pending ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: tempSelected == PurchaseStatus.pending ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setDialogState(() => tempSelected = PurchaseStatus.received);
                    Navigator.pop(dialogContext);
                    _filterByStatus(PurchaseStatus.received);
                  },
                  child: ListTile(
                    title: const Text('Recibidas'),
                    subtitle: const Text('Compras aplicadas al inventario'),
                    leading: Icon(
                      tempSelected == PurchaseStatus.received ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: tempSelected == PurchaseStatus.received ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setDialogState(() => tempSelected = PurchaseStatus.cancelled);
                    Navigator.pop(dialogContext);
                    _filterByStatus(PurchaseStatus.cancelled);
                  },
                  child: ListTile(
                    title: const Text('Canceladas'),
                    leading: Icon(
                      tempSelected == PurchaseStatus.cancelled ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: tempSelected == PurchaseStatus.cancelled ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthAuthenticated,
      listener: (context, state) {
        _loadPurchasesBasedOnRole();
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
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
                      .read<PurchaseBloc>()
                      .add(const purchase_event.LoadPurchases());
                }
              });
            },
          ),
          // Botón de filtro
          IconButton(
            icon: Badge(
              label: _selectedStatus != null ? const Text('1') : null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterDialog,
          ),
          // Botón de sincronización
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncPurchases,
          ),
          // Indicador de sincronización
          const SyncIndicator(showLabel: false),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                  hintText: 'Buscar por número o proveedor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<PurchaseBloc>()
                                .add(const purchase_event.LoadPurchases());
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

          // Chip de filtro activo
          if (_selectedStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text('Estado: ${_selectedStatus!.name}'),
                    onDeleted: () => _filterByStatus(null),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),

          // Lista de compras
          Expanded(
            child: BlocConsumer<PurchaseBloc, PurchaseState>(
              listener: (context, state) {
                if (state is PurchaseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is PurchaseItemOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is PurchaseSyncSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  // Tras sincronizar, recargar lista
                  _loadPurchasesBasedOnRole();
                } else if (state is PurchaseReceived) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  _loadPurchasesBasedOnRole();
                } else if (state is PurchaseCancelled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  _loadPurchasesBasedOnRole();
                } else if (state is PurchaseLoaded) {
                  _lastPurchases = state.purchases;
                }
              },
              buildWhen: (previous, current) {
                // Evitar parpadeo: no reconstruir en PurchaseError si ya tenemos datos
                if (current is PurchaseError && _lastPurchases.isNotEmpty) {
                  return false;
                }
                return current is PurchaseInitial ||
                    current is PurchaseLoading ||
                    current is PurchaseSyncing ||
                    current is PurchaseLoaded ||
                    current is PurchaseError;
              },
              builder: (context, state) {
                if (state is PurchaseInitial || state is PurchaseLoading || state is PurchaseSyncing) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PurchaseError) {
                  // Si hay una lista previa, mostrarla y solo notificar por SnackBar
                  if (_lastPurchases.isNotEmpty) {
                    final authState = context.read<AuthBloc>().state;
                    var purchases = _lastPurchases;
                    if (authState is AuthAuthenticated) {
                      final user = authState.user;
                      if ((user.role == 'store_manager' || user.role == 'warehouse_manager') &&
                          user.hasAssignedLocation) {
                        purchases = purchases
                            .where((p) => p.locationId == user.assignedLocationId)
                            .toList();
                      }
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = purchases[index];
                        return PurchaseCard(
                          purchase: purchase,
                          onTap: () async {
                            await _withOverlay(() async {
                              return await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newContext) => BlocProvider.value(
                                    value: context.read<PurchaseBloc>(),
                                    child: PurchaseDetailPage(purchaseId: purchase.id),
                                  ),
                                ),
                              );
                            });
                            _loadPurchasesBasedOnRole();
                          },
                        );
                      },
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 12),
                        const Text('Error al cargar compras'),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _loadPurchasesBasedOnRole();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PurchaseLoaded) {
                  // Filtrar compras según el rol del usuario
                  List<Purchase> purchases = state.purchases;
                  final authState = context.read<AuthBloc>().state;

                  if (authState is AuthAuthenticated) {
                    final user = authState.user;
                    // Si es gerente, filtrar solo por su ubicación
                    if ((user.role == 'store_manager' || user.role == 'warehouse_manager') &&
                        user.hasAssignedLocation) {
                      purchases = purchases
                          .where((p) => p.locationId == user.assignedLocationId)
                          .toList();
                    }
                  }

                  if (purchases.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedStatus != null
                                ? 'No hay compras con este estado'
                                : 'No hay compras',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedStatus != null
                                ? 'Intenta con otro filtro'
                                : 'Crea tu primera orden de compra',
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
                          .read<PurchaseBloc>()
                          .add(const purchase_event.SyncPurchases());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = purchases[index];
                        return PurchaseCard(
                          purchase: purchase,
                          onTap: () async {
                            await _withOverlay(() async {
                              return await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newContext) => BlocProvider.value(
                                    value: context.read<PurchaseBloc>(),
                                    child: PurchaseDetailPage(purchaseId: purchase.id),
                                  ),
                                ),
                              );
                            });
                            // Siempre recargar al volver, independientemente del resultado
                            _loadPurchasesBasedOnRole();
                          },
                        );
                      },
                    ),
                  );
                }

                // Para cualquier otro estado transitorio, mostrar carga y esperar al stream
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
          ),
          if (_showLoadingOverlay)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox();

          // Solo admins pueden crear compras
          if (authState.user.role != 'admin') {
            return const SizedBox();
          }

          return FloatingActionButton.extended(
            onPressed: () async {
              final purchaseBloc = context.read<PurchaseBloc>();
              final result = await _withOverlay(() async {
                return await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: purchaseBloc,
                      child: const PurchaseFormPage(),
                    ),
                  ),
                );
              });
              if (result == true) {
                purchaseBloc.add(const purchase_event.LoadPurchases());
              }
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Nueva Compra'),
          );
        },
      ),
    )
  );
  }
}
