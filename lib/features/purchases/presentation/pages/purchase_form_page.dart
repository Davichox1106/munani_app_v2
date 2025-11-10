import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../locations/presentation/bloc/store/store_bloc.dart';
import '../../../locations/presentation/bloc/store/store_event.dart';
import '../../../locations/presentation/bloc/warehouse/warehouse_bloc.dart';
import '../../../locations/presentation/bloc/warehouse/warehouse_event.dart';
import '../../../products/domain/entities/product_variant.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/variant_bloc.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/purchase_bloc.dart';
import '../bloc/purchase_event.dart' as purchase_event;
import '../bloc/purchase_state.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart' as supplier_event;
import 'purchase_location_selector_page.dart';
import 'purchase_product_selector_page.dart';
import 'supplier_selector_page.dart';
import '../../../../core/utils/app_logger.dart';

/// Modelo para un ítem temporal en el formulario
class _PurchaseItemForm {
  final String productVariantId;
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitCost;

  _PurchaseItemForm({
    required this.productVariantId,
    required this.productName,
    this.variantName,
    required this.quantity,
    required this.unitCost,
  });

  double get subtotal => quantity * unitCost;

  _PurchaseItemForm copyWith({
    String? productVariantId,
    String? productName,
    String? variantName,
    int? quantity,
    double? unitCost,
  }) {
    return _PurchaseItemForm(
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}

/// Página de formulario para crear una orden de compra
class PurchaseFormPage extends StatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Supplier? _selectedSupplier;
  SelectedLocation? _selectedLocation;
  DateTime _purchaseDate = DateTime.now();
  double _taxPercentage = 15.0; // IVA por defecto 15%
  final List<_PurchaseItemForm> _items = [];

  late final SupplierBloc _supplierBloc;

  @override
  void initState() {
    super.initState();
    try {
      AppLogger.debug('🚀 PurchaseFormPage - Inicializando SupplierBloc...');
      _supplierBloc = sl<SupplierBloc>();
      AppLogger.info('✅ PurchaseFormPage - SupplierBloc creado correctamente');
      AppLogger.info('📤 PurchaseFormPage - Enviando evento LoadSuppliers...');
      _supplierBloc.add(const supplier_event.LoadSuppliers());
      AppLogger.info('✅ PurchaseFormPage - Evento LoadSuppliers enviado');
    } catch (e, stackTrace) {
      AppLogger.error('❌ PurchaseFormPage - Error inicializando SupplierBloc: $e');
      AppLogger.error('❌ PurchaseFormPage - Stack trace: $stackTrace');
      // Crear un SupplierBloc de emergencia
      _supplierBloc = sl<SupplierBloc>();
    }
  }

  @override
  void dispose() {
    _supplierBloc.close();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _tax {
    return _subtotal * (_taxPercentage / 100);
  }

  double get _total {
    return _subtotal + _tax;
  }

  void _selectSupplier() async {
    AppLogger.debug('🔍 PurchaseFormPage - Abriendo selector de proveedores...');
    AppLogger.debug('🔍 PurchaseFormPage - Estado actual del SupplierBloc: ${_supplierBloc.state.runtimeType}');
    
    final supplier = await Navigator.of(context).push<Supplier>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _supplierBloc,
          child: const SupplierSelectorPage(),
        ),
      ),
    );

    if (supplier != null) {
      setState(() {
        _selectedSupplier = supplier;
      });
    }
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _purchaseDate = date;
      });
    }
  }

  void _selectLocation() async {
    final location = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<StoreBloc>()..add(const LoadAllStores()),
            ),
            BlocProvider(
              create: (_) => sl<WarehouseBloc>()..add(const LoadAllWarehouses()),
            ),
          ],
          child: const PurchaseLocationSelectorPage(),
        ),
      ),
    );

    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  void _addItem() async {
    // Navegar al selector de productos
    final variant = await Navigator.of(context).push<ProductVariant>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ProductBloc>()),
            BlocProvider(create: (_) => sl<VariantBloc>()),
          ],
          child: const PurchaseProductSelectorPage(),
        ),
      ),
    );

    if (variant != null) {
      // Agregar cantidad y costo
      await _showQuantityAndCostDialog(variant);
    }
  }

  Future<void> _showQuantityAndCostDialog(ProductVariant variant) async {
    int quantityValue = 1;
    // Usar priceBuy de la variante, o 0.0 si es inválido (NaN o null)
    double costValue = variant.priceBuy.isFinite ? variant.priceBuy : 0.0;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cantidad y Costo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                variant.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: quantityValue.toString(),
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
                onChanged: (v) {
                  final q = int.tryParse(v);
                  if (q != null) quantityValue = q;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: costValue.toStringAsFixed(2),
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario *',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final cost = double.tryParse(value);
                  if (cost == null || cost <= 0) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
                onChanged: (v) {
                  final c = double.tryParse(v);
                  if (c != null) costValue = c;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop({
                  'quantity': quantityValue,
                  'unitCost': costValue,
                });
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result != null) {
      final item = _PurchaseItemForm(
        productVariantId: variant.id,
        productName: variant.displayName.split(' - ').first,
        variantName: variant.displayName.contains(' - ')
            ? variant.displayName.split(' - ').skip(1).join(' - ')
            : null,
        quantity: result['quantity'] as int,
        unitCost: result['unitCost'] as double,
      );

      setState(() {
        _items.add(item);
      });
    }
  }

  void _editItem(int index) async {
    // Para edición, mostrar solo el diálogo de cantidad y costo
    final item = _items[index];
    int quantityValue = item.quantity;
    double costValue = item.unitCost;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: quantityValue.toString(),
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
                onChanged: (v) {
                  final q = int.tryParse(v);
                  if (q != null) quantityValue = q;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: costValue.toStringAsFixed(2),
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario *',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final cost = double.tryParse(value);
                  if (cost == null || cost <= 0) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
                onChanged: (v) {
                  final c = double.tryParse(v);
                  if (c != null) costValue = c;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop({
                  'quantity': quantityValue,
                  'unitCost': costValue,
                });
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _items[index] = item.copyWith(
          quantity: result['quantity'] as int,
          unitCost: result['unitCost'] as double,
        );
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _savePurchase(String userId) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un proveedor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un almacén o tienda de destino'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar que todos los productVariantId sean válidos (no temporales)
    final hasInvalidItems = _items.any((item) => item.productVariantId.startsWith('temp-'));
    if (hasInvalidItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Algunos productos no son válidos. Por favor, vuelva a seleccionarlos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Crear la compra
    context.read<PurchaseBloc>().add(
      purchase_event.CreatePurchase(
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        locationId: _selectedLocation!.id,
        locationType: _selectedLocation!.type,
        locationName: _selectedLocation!.name,
        purchaseDate: _purchaseDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdBy: userId,
      ),
    );
  }

  void _addItemsToPurchase(String purchaseId) {
    // Agregar cada item a la compra
    for (final item in _items) {
      context.read<PurchaseBloc>().add(
        purchase_event.AddPurchaseItem(
          purchaseId: purchaseId,
          productVariantId: item.productVariantId,
          productName: item.productName,
          variantName: item.variantName ?? '',
          quantity: item.quantity,
          unitCost: item.unitCost,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Compra'),
      ),
      body: BlocConsumer<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          if (state is PurchaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PurchaseCreated) {
            // Agregar items a la compra creada
            _addItemsToPurchase(state.purchase.id);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final isLoading = state is PurchaseCreating;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selector de proveedor
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.business, color: AppColors.primaryOrange),
                            title: const Text('Proveedor'),
                            subtitle: Text(
                              _selectedSupplier?.name ?? 'Seleccionar proveedor',
                              style: TextStyle(
                                color: _selectedSupplier == null ? AppColors.error : null,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: isLoading ? null : _selectSupplier,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Selector de ubicación destino
                        Card(
                          child: ListTile(
                            leading: Icon(
                              _selectedLocation?.type == 'warehouse'
                                  ? Icons.warehouse
                                  : Icons.store,
                              color: AppColors.accentBlue,
                            ),
                            title: const Text('Destino'),
                            subtitle: Text(
                              _selectedLocation?.name ?? 'Seleccionar almacén o tienda',
                              style: TextStyle(
                                color: _selectedLocation == null ? AppColors.error : null,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: isLoading ? null : _selectLocation,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Selector de fecha
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Fecha de compra'),
                            subtitle: Text(dateFormat.format(_purchaseDate)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: isLoading ? null : _selectDate,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Porcentaje de IVA
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'IVA (%)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_taxPercentage.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _taxPercentage,
                                  min: 0,
                                  max: 20,
                                  divisions: 40,
                                  label: '${_taxPercentage.toStringAsFixed(1)}%',
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _taxPercentage = value;
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de productos
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Productos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!isLoading)
                                      ElevatedButton.icon(
                                        onPressed: _addItem,
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Agregar'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_items.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        'No hay productos agregados',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _items.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final item = _items[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(item.productName),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (item.variantName != null)
                                              Text(item.variantName!),
                                            Text(
                                              '${item.quantity} × ${currencyFormat.format(item.unitCost)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currencyFormat.format(item.subtotal),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (!isLoading) ...[
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 20),
                                                onPressed: () => _editItem(index),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                onPressed: () => _removeItem(index),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notas
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                            hintText: 'Información adicional...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),

                // Resumen y botón de guardar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is! AuthAuthenticated) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Resumen de totales
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(currencyFormat.format(_subtotal)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('IVA (${_taxPercentage.toStringAsFixed(1)}%):'),
                              Text(currencyFormat.format(_tax)),
                            ],
                          ),
                          const Divider(thickness: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currencyFormat.format(_total),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Botón de guardar
                          ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _savePurchase(authState.user.id),
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.shopping_cart),
                            label: Text(
                              isLoading ? 'Guardando...' : 'Crear Orden de Compra',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


