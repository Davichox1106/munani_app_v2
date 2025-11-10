import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../sync/presentation/widgets/sync_indicator.dart';
// Nota: widget de tarjeta de cliente incluido al final de este archivo
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'customer_form_page.dart';

class CustomersListPage extends StatefulWidget {
  const CustomersListPage({super.key});

  @override
  State<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<CustomerBloc>().add(const LoadCustomers());
    } else {
      context.read<CustomerBloc>().add(SearchCustomers(query));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(const LoadCustomers());
      context.read<CustomerBloc>().add(const SyncCustomers());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  context.read<CustomerBloc>().add(const LoadCustomers());
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<CustomerBloc>().add(const SyncCustomers()),
          ),
          const SyncIndicator(showLabel: false),
          const SizedBox(width: 8),
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
                  hintText: 'Buscar por CI o nombre...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<CustomerBloc>().add(const LoadCustomers());
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
            child: BlocConsumer<CustomerBloc, CustomerState>(
              listener: (context, state) {
                if (state is CustomerError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is CustomerInitial || state is CustomerLoading || state is CustomerSyncing) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CustomerLoaded) {
                  final customers = state.customers;
                  if (customers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No hay clientes', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Text('Agrega tu primer cliente', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CustomerBloc>().add(const SyncCustomers());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final c = customers[index];
                        return _CustomerCard(
                          customer: c,
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CustomerFormPage(existing: c)),
                            );
                            if (result == true && context.mounted) {
                              context.read<CustomerBloc>().add(const LoadCustomers());
                            }
                          },
                        );
                      },
                    ),
                  );
                }
                return const Center(child: Text('Error al cargar clientes'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox();
          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerFormPage()),
              );
              if (result == true && context.mounted) {
                context.read<CustomerBloc>().add(const LoadCustomers());
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Cliente'),
          );
        },
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const _CustomerCard({required this.customer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CI: ${customer.ci}'),
            if (customer.phone != null) Text('Tel: ${customer.phone}'),
            if (customer.email != null) Text('Email: ${customer.email}'),
            if (customer.assignedLocationName != null)
              Text(
                'Ubicación: ${customer.assignedLocationName} ${customer.assignedLocationType == 'store' ? '(Tienda)' : '(Almacén)'}',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
