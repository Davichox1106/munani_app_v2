import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/sale.dart';
import '../../../customers/presentation/pages/customer_selector_page.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/sale_item.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart' as sale_event;
import '../bloc/sale_state.dart';
import '../../../transfers/presentation/pages/product_selector_page.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';

class SaleFormPage extends StatefulWidget {
  final Sale? existing;
  const SaleFormPage({super.key, this.existing});

  @override
  State<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends State<SaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  List<SaleItem> _items = [];
  String? _selectedCustomerName;
  String? _locationId; // para admins sin ubicación asignada
  String? _locationType; // 'store' | 'warehouse'

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _customerController.text = widget.existing!.customerName ?? '';
      _notesController.text = widget.existing!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addItemFromInventory() async {
    final selected = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<InventoryBloc>(
          create: (_) => di.sl<InventoryBloc>(),
          child: const ProductSelectorPage(),
        ),
      ),
    );
    if (selected == null) return;

    // Prellenar precio con costo conocido del inventario (unitCost o lastCost)
    final inv = selected; // InventoryItem
    // Si no hay ubicación definida (admin), tomarla del ítem seleccionado
    _locationId ??= inv.locationId;
    _locationType ??= inv.locationType;
    final initialPrice = (inv.unitCost ?? inv.lastCost ?? 0).toStringAsFixed(2);
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: initialPrice);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar ítem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Precio unitario'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Agregar')),
        ],
      ),
    );
    if (confirmed != true) return;

    final qty = int.tryParse(qtyController.text) ?? 1;
    final price = double.tryParse(priceController.text) ?? 0.0;
    setState(() {
      _items = List.from(_items)
        ..add(SaleItem(
          id: '',
          saleId: widget.existing?.id ?? '',
          productVariantId: inv.productVariantId,
          productName: inv.productName ?? 'Producto',
          variantName: inv.variantName,
          quantity: qty,
          unitPrice: price,
          subtotal: qty * price,
          createdAt: DateTime.now(),
        ));
    });
  }

  double get _subtotal => _items.fold(0.0, (a, b) => a + b.subtotal);
  double get _tax => 0.0; // placeholder IVA si aplica
  double get _total => _subtotal + _tax;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final user = authState.user;
      // Determinar ubicación: del usuario o del primer ítem
      final locId = user.assignedLocationId ?? _locationId ?? '';
      final locType = user.assignedLocationType ?? _locationType ?? 'store';
      if (locId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona al menos un ítem para definir la ubicación'), backgroundColor: Colors.red),
        );
        setState(() => _saving = false);
        return;
      }

      final sale = Sale(
        id: '', // repo asigna UUID
        locationId: locId,
        locationType: locType,
        saleNumber: null,
        customerName: _selectedCustomerName?.isNotEmpty == true
            ? _selectedCustomerName
            : (_customerController.text.trim().isEmpty ? null : _customerController.text.trim()),
        saleDate: DateTime.now(),
        subtotal: _subtotal,
        tax: _tax,
        total: _total,
        status: SaleStatus.pending,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: user.id,
      );

      context.read<SaleBloc>().add(sale_event.CreateSaleWithItems(sale: sale, items: _items));
    } finally {
      setState(() => _saving = false);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Venta' : 'Nueva Venta')),
      body: BlocListener<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state is SaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selector de cliente (placeholder: búsqueda por texto)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customerController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        onTap: _saving
                            ? null
                            : () async {
                                final selected = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider<CustomerBloc>(
                                      create: (_) => di.sl<CustomerBloc>(),
                                      child: const CustomerSelectorPage(),
                                    ),
                                  ),
                                );
                                if (selected != null && mounted) {
                                  setState(() {
                                    _selectedCustomerName = selected.name;
                                    _customerController.text = selected.name;
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saving
                          ? null
                          : () async {
                              final selected = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider<CustomerBloc>(
                                    create: (_) => di.sl<CustomerBloc>(),
                                    child: const CustomerSelectorPage(),
                                  ),
                                ),
                              );
                              if (selected != null) {
                                setState(() {
                                  _selectedCustomerName = selected.name;
                                  _customerController.text = selected.name;
                                });
                              }
                            },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Items
                Card(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final it = _items[index];
                          return ListTile(
                            title: Text(it.productName),
                            subtitle: Text('Cant: ${it.quantity}  •  Precio: ${it.unitPrice.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(it.subtotal.toStringAsFixed(2)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: _saving
                                      ? null
                                      : () {
                                          setState(() {
                                            _items = List.from(_items)..removeAt(index);
                                          });
                                        },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _saving ? null : _addItemFromInventory,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar ítem'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notas
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Totales
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Subtotal'),
                          Text(_subtotal.toStringAsFixed(2)),
                        ]),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Impuestos'),
                          Text(_tax.toStringAsFixed(2)),
                        ]),
                        const Divider(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : (isEdit ? 'Actualizar' : 'Crear Venta')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
