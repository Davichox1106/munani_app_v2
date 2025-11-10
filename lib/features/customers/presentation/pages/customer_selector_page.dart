import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerSelectorPage extends StatefulWidget {
  const CustomerSelectorPage({super.key});

  @override
  State<CustomerSelectorPage> createState() => _CustomerSelectorPageState();
}

class _CustomerSelectorPageState extends State<CustomerSelectorPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
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
        title: const Text('Seleccionar cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              Navigator.of(context).pop<Customer?>(null);
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (q) {
                if (q.isEmpty) {
                  context.read<CustomerBloc>().add(const LoadCustomers());
                } else {
                  context.read<CustomerBloc>().add(SearchCustomers(q));
                }
              },
              decoration: const InputDecoration(
                hintText: 'Buscar por CI, nombre o email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerInitial || state is CustomerLoading || state is CustomerSyncing) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerLoaded) {
            final customers = state.customers;
            if (customers.isEmpty) {
              return const Center(child: Text('No hay clientes'));
            }
            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final c = customers[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(c.name.substring(0, 1).toUpperCase())),
                  title: Text(c.name),
                  subtitle: Text('CI: ${c.ci}${c.phone != null ? ' • ${c.phone}' : ''}'),
                  onTap: () => Navigator.of(context).pop<Customer>(c),
                );
              },
            );
          }
          if (state is CustomerError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
