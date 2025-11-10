import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart' as supplier_event;
import '../bloc/supplier_state.dart';

class SupplierSelectorPage extends StatefulWidget {
  const SupplierSelectorPage({super.key});

  @override
  State<SupplierSelectorPage> createState() => _SupplierSelectorPageState();
}

class _SupplierSelectorPageState extends State<SupplierSelectorPage> {
  final _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar proveedor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar por NIT/RUC o nombre...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SupplierBloc, SupplierState>(
        builder: (context, state) {
          if (state is SupplierLoading || state is SupplierSyncing) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SupplierLoaded) {
            final suppliers = state.suppliers;
            if (suppliers.isEmpty) {
              return const Center(child: Text('No hay proveedores'));
            }
            return ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final s = suppliers[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(s.name.substring(0, 1).toUpperCase())),
                  title: Text(s.name),
                  subtitle: Text(s.rucNit != null ? 'NIT/RUC: ${s.rucNit}' : ''),
                  onTap: () => Navigator.of(context).pop<Supplier>(s),
                );
              },
            );
          }
          if (state is SupplierError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
