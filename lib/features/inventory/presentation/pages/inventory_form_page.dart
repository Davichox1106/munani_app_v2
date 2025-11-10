import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/database/isar_database.dart';
import '../../../products/data/models/product_variant_local_model.dart';
import '../../../products/data/models/product_local_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../locations/domain/entities/store.dart';
import '../../../locations/domain/entities/warehouse.dart';
import '../../../locations/domain/usecases/get_all_stores.dart';
import '../../../locations/domain/usecases/get_all_warehouses.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';

/// Página de formulario de inventario
///
/// Permite crear o editar un registro de inventario con:
/// - Variante de producto (requerido)
/// - Ubicación (tienda o almacén) (requerido)
/// - Cantidad (requerido)
/// - Stock mínimo (requerido)
/// - Stock máximo (requerido)
class InventoryFormPage extends StatefulWidget {
  final InventoryItem? inventoryItem; // null = crear, con valor = editar

  const InventoryFormPage({
    super.key,
    this.inventoryItem,
  });

  @override
  State<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _SkuOption {
  final String sku;
  final String? variantName;
  final String? productName;

  const _SkuOption({
    required this.sku,
    this.variantName,
    this.productName,
  });
}

class _InventoryFormPageState extends State<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _productVariantIdController = TextEditingController();
  final FocusNode _skuFocusNode = FocusNode();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();

  String _locationType = 'store'; // 'store' o 'warehouse'
  String? _selectedLocationId;
  String? _selectedLocationName; // Nombre de la ubicación seleccionada
  bool _isLoading = false;
  bool _isLoadingLocations = true;
  bool _isLoadingVariants = true;

  List<Store> _stores = [];
  List<Warehouse> _warehouses = [];
  List<_SkuOption> _skuOptions = [];

  bool get _isEditMode => widget.inventoryItem != null;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadVariantOptions();

    // Si es modo edición, prellenar los campos
    if (_isEditMode) {
      _productVariantIdController.text = widget.inventoryItem!.productVariantId;
      _quantityController.text = widget.inventoryItem!.quantity.toString();
      _minStockController.text = widget.inventoryItem!.minStock.toString();
      _maxStockController.text = widget.inventoryItem!.maxStock.toString();
      _locationType = widget.inventoryItem!.locationType;
      _selectedLocationId = widget.inventoryItem!.locationId;
    } else {
      // Valores por defecto para crear
      _quantityController.text = '0';
      _minStockController.text = '5';
      _maxStockController.text = '100';
    }
  }

  /// Cargar todas las tiendas y almacenes disponibles
  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);

    try {
      final getAllStores = sl<GetAllStores>();
      final getAllWarehouses = sl<GetAllWarehouses>();

      final storesResult = await getAllStores.call();
      final warehousesResult = await getAllWarehouses.call();

      storesResult.fold(
        (failure) {
          debugPrint('Error al cargar tiendas: ${failure.message}');
        },
        (stores) {
          setState(() => _stores = stores);
        },
      );

      warehousesResult.fold(
        (failure) {
          debugPrint('Error al cargar almacenes: ${failure.message}');
        },
        (warehouses) {
          setState(() => _warehouses = warehouses);
        },
      );
    } catch (e) {
      debugPrint('Error al cargar ubicaciones: $e');
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  @override
  void dispose() {
    _productVariantIdController.dispose();
    _skuFocusNode.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  Future<void> _loadVariantOptions() async {
    setState(() => _isLoadingVariants = true);
    try {
      final isar = await sl<IsarDatabase>().database;
      final variants =
          await isar.productVariantLocalModels.where().sortBySku().findAll();
      final products = await isar.productLocalModels.where().findAll();
      final productMap = {
        for (final product in products) product.uuid: product.name,
      };

      final options = variants
          .map(
            (variant) => _SkuOption(
              sku: variant.sku,
              variantName: variant.variantName,
              productName: productMap[variant.productId],
            ),
          )
          .toList()
        ..sort((a, b) => a.sku.compareTo(b.sku));

      if (!mounted) return;
      setState(() {
        _skuOptions = options;
        _isLoadingVariants = false;
      });
    } catch (e) {
      debugPrint('Error al cargar variantes: $e');
      if (mounted) {
        setState(() => _isLoadingVariants = false);
      }
    }
  }

  _SkuOption? _findOptionBySku(String sku) {
    if (sku.isEmpty) return null;
    for (final option in _skuOptions) {
      if (option.sku == sku) return option;
    }
    return null;
  }

  Future<void> _showSkuPicker() async {
    if (_skuOptions.isEmpty) return;
    final selectedSku = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Selecciona un SKU',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: _skuOptions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = _skuOptions[index];
                      final parts = [
                        if (option.productName != null &&
                            option.productName!.isNotEmpty)
                          option.productName!,
                        if (option.variantName != null &&
                            option.variantName!.isNotEmpty)
                          option.variantName!,
                      ];
                      return ListTile(
                        leading: const Icon(Icons.qr_code),
                        title: Text(option.sku),
                        subtitle:
                            parts.isEmpty ? null : Text(parts.join(' • ')),
                        onTap: () => Navigator.of(context).pop(option.sku),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedSku != null && selectedSku.isNotEmpty && mounted) {
      setState(() {
        _productVariantIdController.text = selectedSku;
      });
    }
  }

  void _onSave() async {
    // OWASP A03: Validación de entrada
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una ubicación'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Buscar la variante por SKU para obtener su UUID y nombres
    String? productVariantId;
    String? productName;
    String? variantName;
    try {
      final sku = _productVariantIdController.text.trim();
      final isar = await sl<IsarDatabase>().database;
      final variant = await isar.productVariantLocalModels.getBySku(sku);

      if (variant == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró una variante con SKU: $sku'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      productVariantId = variant.uuid;
      variantName = variant.variantName;

      // Buscar el nombre del producto usando getByUuid
      final product = await isar.productLocalModels.getByUuid(variant.productId);
      productName = product?.name;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar la variante: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar autenticado'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final int quantity = int.parse(_quantityController.text);
    final int minStock = int.parse(_minStockController.text);
    final int maxStock = int.parse(_maxStockController.text);

    // Validación adicional: minStock < maxStock
    if (minStock >= maxStock) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El stock mínimo debe ser menor que el stock máximo'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    if (_isEditMode) {
      // Editar inventario existente (solo actualizar cantidad)
      context.read<InventoryBloc>().add(
            UpdateInventoryQuantity(
              id: widget.inventoryItem!.id,
              newQuantity: quantity,
              updatedBy: authState.user.id,
            ),
          );
    } else {
      // Crear nuevo inventario
      context.read<InventoryBloc>().add(
            CreateInventoryItem(
              productVariantId: productVariantId,
              locationId: _selectedLocationId!,
              locationType: _locationType,
              quantity: quantity,
              minStock: minStock,
              maxStock: maxStock,
              updatedBy: authState.user.id,
              productName: productName,
              variantName: variantName,
              locationName: _selectedLocationName,
            ),
          );
    }
  }

  List<DropdownMenuItem<String>> _getLocationItems() {
    if (_locationType == 'store') {
      return _stores.map((store) {
        return DropdownMenuItem(
          value: store.id,
          child: Text(store.name),
        );
      }).toList();
    } else {
      return _warehouses.map((warehouse) {
        return DropdownMenuItem(
          value: warehouse.id,
          child: Text(warehouse.name),
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Inventario' : 'Nuevo Inventario'),
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }

          if (state is InventoryUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }

          if (state is InventoryError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: _isLoadingLocations
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ID de Variante de Producto
                      if (_isEditMode)
                        TextFormField(
                          controller: _productVariantIdController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'SKU de Variante de Producto *',
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isLoadingVariants)
                              const LinearProgressIndicator(minHeight: 2),
                            RawAutocomplete<_SkuOption>(
                              textEditingController: _productVariantIdController,
                              focusNode: _skuFocusNode,
                              displayStringForOption: (option) => option.sku,
                              optionsBuilder: (TextEditingValue value) {
                                if (_skuOptions.isEmpty) {
                                  return const Iterable<_SkuOption>.empty();
                                }
                                final query = value.text.trim().toLowerCase();
                                if (query.isEmpty) {
                                  return _skuOptions.take(15);
                                }
                                return _skuOptions.where(
                                  (option) =>
                                      option.sku.toLowerCase().contains(query) ||
                                      (option.productName != null &&
                                          option.productName!
                                              .toLowerCase()
                                              .contains(query)) ||
                                      (option.variantName != null &&
                                          option.variantName!
                                              .toLowerCase()
                                              .contains(query)),
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                final optionList = options.toList();
                                if (optionList.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final width =
                                    MediaQuery.of(context).size.width - 48;
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(12),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 240,
                                      ),
                                        child: SizedBox(
                                          width: width,
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: optionList.length,
                                            itemBuilder: (context, index) {
                                              final option = optionList[index];
                                              final parts = [
                                                if (option.productName != null &&
                                                    option.productName!
                                                        .isNotEmpty)
                                                  option.productName!,
                                                if (option.variantName != null &&
                                                    option.variantName!
                                                        .isNotEmpty)
                                                  option.variantName!,
                                              ];
                                              return ListTile(
                                                leading:
                                                    const Icon(Icons.qr_code),
                                                title: Text(option.sku),
                                                subtitle: parts.isEmpty
                                                    ? null
                                                    : Text(parts.join(' • ')),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              );
                                            },
                                          ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onSelected: (option) {
                                _productVariantIdController.text = option.sku;
                              },
                              fieldViewBuilder: (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    labelText:
                                        'SKU de Variante de Producto *',
                                    hintText:
                                        'Escribe para buscar o despliega la lista',
                                    prefixIcon: const Icon(Icons.qr_code),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.list_alt),
                                      tooltip: 'Ver todos los SKU',
                                      onPressed: _isLoadingVariants
                                          ? null
                                          : () async {
                                              focusNode.unfocus();
                                              await _showSkuPicker();
                                            },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'El SKU de variante es requerido';
                                    }
                                    if (value.trim().length < 3) {
                                      return 'El SKU debe tener al menos 3 caracteres';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => onFieldSubmitted(),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final option = _findOptionBySku(
                                    _productVariantIdController.text.trim());
                                if (option == null) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceBeige,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          AppColors.primaryBrown.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (option.productName != null)
                                              Text(
                                                option.productName!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            if (option.variantName != null)
                                              Text(
                                                option.variantName!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (_isEditMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'El producto y ubicación no se pueden modificar en modo edición',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Tipo de ubicación
                      DropdownButtonFormField<String>(
                        initialValue: _locationType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Ubicación *',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'store',
                            child: Row(
                              children: [
                                Icon(Icons.store, size: 20),
                                SizedBox(width: 8),
                                Text('Tienda'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'warehouse',
                            child: Row(
                              children: [
                                Icon(Icons.warehouse, size: 20),
                                SizedBox(width: 8),
                                Text('Almacén'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (_isLoading || _isEditMode)
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _locationType = value;
                                    _selectedLocationId = null; // Reset selección
                                    _selectedLocationName = null; // Reset nombre
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 16),

                      // Ubicación específica
                      if (_getLocationItems().isNotEmpty)
                        DropdownButtonFormField<String>(
                          key: ValueKey(_locationType), // Force rebuild when type changes
                          initialValue: _selectedLocationId,
                          decoration: InputDecoration(
                            labelText: _locationType == 'store'
                                ? 'Tienda *'
                                : 'Almacén *',
                            prefixIcon: Icon(
                              _locationType == 'store'
                                  ? Icons.store
                                  : Icons.warehouse,
                            ),
                          ),
                          items: _getLocationItems(),
                          onChanged: (_isLoading || _isEditMode)
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedLocationId = value;
                                    // Guardar también el nombre de la ubicación
                                    if (value != null) {
                                      if (_locationType == 'store') {
                                        _selectedLocationName = _stores
                                            .firstWhere((s) => s.id == value)
                                            .name;
                                      } else {
                                        _selectedLocationName = _warehouses
                                            .firstWhere((w) => w.id == value)
                                            .name;
                                      }
                                    }
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Debes seleccionar una ubicación';
                            }
                            return null;
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No hay ${_locationType == 'store' ? 'tiendas' : 'almacenes'} disponibles. Crea uno primero.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Cantidad
                      TextFormField(
                        controller: _quantityController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad *',
                          hintText: '0',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La cantidad es requerida';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null) {
                            return 'Ingresa un número válido';
                          }
                          if (quantity < 0) {
                            return 'La cantidad no puede ser negativa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Stock mínimo
                      TextFormField(
                        controller: _minStockController,
                        enabled: !_isLoading && !_isEditMode,
                        decoration: const InputDecoration(
                          labelText: 'Stock Mínimo *',
                          hintText: '5',
                          prefixIcon: Icon(Icons.arrow_downward),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El stock mínimo es requerido';
                          }
                          final minStock = int.tryParse(value);
                          if (minStock == null) {
                            return 'Ingresa un número válido';
                          }
                          if (minStock < 0) {
                            return 'No puede ser negativo';
                          }
                          return null;
                        },
                        readOnly: _isEditMode,
                      ),
                      const SizedBox(height: 16),

                      // Stock máximo
                      TextFormField(
                        controller: _maxStockController,
                        enabled: !_isLoading && !_isEditMode,
                        decoration: const InputDecoration(
                          labelText: 'Stock Máximo *',
                          hintText: '100',
                          prefixIcon: Icon(Icons.arrow_upward),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El stock máximo es requerido';
                          }
                          final maxStock = int.tryParse(value);
                          if (maxStock == null) {
                            return 'Ingresa un número válido';
                          }
                          if (maxStock <= 0) {
                            return 'Debe ser mayor a 0';
                          }
                          return null;
                        },
                        readOnly: _isEditMode,
                      ),

                      const SizedBox(height: 24),

                      // Información de stock
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Niveles de Stock',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildStockIndicator(
                              'Sin Stock',
                              '0 unidades',
                              AppColors.error,
                              Icons.remove_circle,
                            ),
                            const SizedBox(height: 8),
                            _buildStockIndicator(
                              'Stock Bajo',
                              '< Stock Mínimo',
                              AppColors.warning,
                              Icons.warning,
                            ),
                            const SizedBox(height: 8),
                            _buildStockIndicator(
                              'Stock OK',
                              'Entre Min y Max',
                              AppColors.success,
                              Icons.check_circle,
                            ),
                            const SizedBox(height: 8),
                            _buildStockIndicator(
                              'Sobre Stock',
                              '> Stock Máximo',
                              AppColors.info,
                              Icons.arrow_circle_up,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botón de guardar
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _onSave,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_isEditMode ? Icons.save : Icons.add),
                        label: Text(
                            _isEditMode ? 'Guardar Cambios' : 'Crear Inventario'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Información de sincronización
                      if (!_isEditMode)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cloud_outlined,
                                size: 20,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Se guardará localmente y sincronizará automáticamente',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStockIndicator(
    String label,
    String description,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
