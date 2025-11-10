import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import 'sale_form_page.dart';
import 'sale_detail_page.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesBasedOnRole();
      // Disparar sincronización inicial para poblar desde Supabase
      context.read<SaleBloc>().add(const SyncSales());
    });
  }

  void _loadSalesBasedOnRole() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      final user = auth.user;
      if ((user.role == 'store_manager' || user.role == 'warehouse_manager') && user.hasAssignedLocation) {
        context.read<SaleBloc>().add(LoadSalesByLocation(user.assignedLocationId!));
      } else {
        context.read<SaleBloc>().add(const LoadSales());
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
      _loadSalesBasedOnRole();
    } else {
      context.read<SaleBloc>().add(SearchSales(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _loadSalesBasedOnRole();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<SaleBloc>().add(const SyncSales()),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por número o cliente...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadSalesBasedOnRole();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: BlocConsumer<SaleBloc, SaleState>(
              listener: (context, state) {
                if (state is SaleOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                } else if (state is SaleError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is SaleInitial || state is SaleLoading || state is SaleSyncing) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SaleLoaded) {
                  final sales = state.sales;
                  if (sales.isEmpty) {
                    return const Center(child: Text('No hay ventas'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        child: ListTile(
                          title: Text(sale.saleNumber ?? sale.id.substring(0, 8)),
                          subtitle: Text('${sale.customerName ?? 'Cliente'} • ${sale.status.name} • ${sale.total.toStringAsFixed(2)}'),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<SaleBloc>(),
                                  child: SaleDetailPage(saleId: sale.id),
                                ),
                              ),
                            );
                            _loadSalesBasedOnRole();
                          },
                        ),
                      );
                    },
                  );
                }
                if (state is SaleError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 12),
                        const Text('Error al cargar ventas'),
                        const SizedBox(height: 8),
                        Text(state.message, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SaleBloc>(),
                child: const SaleFormPage(),
              ),
            ),
          );
          if (res == true) {
            _loadSalesBasedOnRole();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
      ),
    );
  }
}
