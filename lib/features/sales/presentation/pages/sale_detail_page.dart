import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sale.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart' as sale_event;
import '../bloc/sale_state.dart';

class SaleDetailPage extends StatefulWidget {
  final String saleId;
  const SaleDetailPage({super.key, required this.saleId});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<SaleBloc>().add(sale_event.LoadSaleDetail(widget.saleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Venta')),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is SaleLoading || state is SaleInitial || state is SaleDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SaleError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is SaleItemsLoaded) {
            final sale = state.sale;
            final items = state.items;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text(sale.saleNumber ?? sale.id),
                    subtitle: Text('Estado: ${sale.status.name}'),
                    trailing: Text(sale.total.toStringAsFixed(2)),
                  ),
                ),
                const SizedBox(height: 12),
                if (sale.customerName != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(sale.customerName!),
                      subtitle: const Text('Cliente'),
                    ),
                  ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      const ListTile(title: Text('Ítems')),
                      const Divider(height: 0),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Sin ítems', style: TextStyle(color: Colors.grey)),
                        ),
                      ...items.map((it) => ListTile(
                            title: Text(it.productName),
                            subtitle: Text('Cant: ${it.quantity} • Precio: ${it.unitPrice.toStringAsFixed(2)}'),
                            trailing: Text(it.subtotal.toStringAsFixed(2)),
                          )),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is! SaleItemsLoaded) return const SizedBox(height: 0);
          final sale = state.sale;
          if (sale.status == SaleStatus.completed || sale.status == SaleStatus.cancelled) {
            return const SizedBox(height: 0);
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.read<SaleBloc>().add(sale_event.CancelSale(sale.id)),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.read<SaleBloc>().add(sale_event.CompleteSale(sale.id)),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Completar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
