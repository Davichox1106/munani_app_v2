import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../bloc/variant_bloc.dart';
import '../bloc/variant_event.dart';
import '../bloc/variant_state.dart';

/// Página de formulario de variantes
class VariantFormPage extends StatefulWidget {
  final Product product;
  final ProductVariant? variant; // null = crear, con valor = editar

  const VariantFormPage({
    super.key,
    required this.product,
    this.variant,
  });

  @override
  State<VariantFormPage> createState() => _VariantFormPageState();
}

class _VariantFormPageState extends State<VariantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _variantNameController = TextEditingController();
  final _priceSellController = TextEditingController();
  final _priceBuyController = TextEditingController();
  final _attributeKeyController = TextEditingController();
  final _attributeValueController = TextEditingController();

  final Map<String, dynamic> _attributes = {};
  bool _isLoading = false;
  bool _isActive = true;

  bool get _isEditMode => widget.variant != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      _skuController.text = widget.variant!.sku;
      _variantNameController.text = widget.variant!.variantName ?? '';
      _priceSellController.text = widget.variant!.priceSell.toString();
      _priceBuyController.text = widget.variant!.priceBuy.toString();
      _isActive = widget.variant!.isActive;
      if (widget.variant!.variantAttributes != null) {
        _attributes.addAll(widget.variant!.variantAttributes!);
      }
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _variantNameController.dispose();
    _priceSellController.dispose();
    _priceBuyController.dispose();
    _attributeKeyController.dispose();
    _attributeValueController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    if (_isEditMode) {
      // Editar variante existente
      final updatedVariant = widget.variant!.copyWith(
        sku: _skuController.text.trim(),
        variantName: _variantNameController.text.trim().isEmpty
            ? null
            : _variantNameController.text.trim(),
        priceSell: double.parse(_priceSellController.text),
        priceBuy: double.parse(_priceBuyController.text),
        variantAttributes: _attributes.isEmpty ? null : _attributes,
        isActive: _isActive,
      );

      context.read<VariantBloc>().add(UpdateVariantEvent(updatedVariant));
    } else {
      // Crear nueva variante
      context.read<VariantBloc>().add(
            CreateVariantEvent(
              productId: widget.product.id,
              sku: _skuController.text.trim(),
              variantName: _variantNameController.text.trim().isEmpty
                  ? null
                  : _variantNameController.text.trim(),
              priceSell: double.parse(_priceSellController.text),
              priceBuy: double.parse(_priceBuyController.text),
              variantAttributes: _attributes.isEmpty ? null : _attributes,
            ),
          );
    }
  }

  void _addAttribute() {
    final key = _attributeKeyController.text.trim();
    final value = _attributeValueController.text.trim();

    if (key.isNotEmpty && value.isNotEmpty) {
      setState(() {
        _attributes[key] = value;
        _attributeKeyController.clear();
        _attributeValueController.clear();
      });
    }
  }

  void _removeAttribute(String key) {
    setState(() {
      _attributes.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Variante' : 'Nueva Variante'),
      ),
      body: BlocListener<VariantBloc, VariantState>(
        listener: (context, state) {
          if (state is VariantCreated || state is VariantUpdated) {
            Navigator.of(context).pop();
          }

          if (state is VariantError) {
            setState(() => _isLoading = false);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Información del producto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: AppColors.primaryOrange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Producto',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SKU
                TextFormField(
                  controller: _skuController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'SKU *',
                    hintText: 'Ej: BAR-CHO-040',
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El SKU es requerido';
                    }
                    if (value.trim().length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Nombre de variante
                TextFormField(
                  controller: _variantNameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (opcional)',
                    hintText: 'Ej: Chocolate 40g',
                    prefixIcon: Icon(Icons.label),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Precios
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceSellController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Precio Venta *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.sell),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.price,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _priceBuyController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Precio Compra *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.shopping_cart),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.price,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Estado activo
                SwitchListTile(
                  value: _isActive,
                  onChanged: _isLoading ? null : (value) => setState(() => _isActive = value),
                  title: const Text('Variante Activa'),
                  subtitle: Text(_isActive ? 'Disponible para venta' : 'Oculta'),
                  activeThumbColor: AppColors.success,
                ),
                const SizedBox(height: 24),

                // Atributos
                Text(
                  'Atributos (opcional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ej: sabor=frutilla, proteínas=18g, formato=pack x12',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                // Agregar atributo
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _attributeKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Clave',
                          hintText: 'sabor',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _attributeValueController,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          hintText: 'chocolate',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addAttribute,
                      icon: const Icon(Icons.add_circle, color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de atributos
                if (_attributes.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attributes.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeAttribute(entry.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

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
                  label: Text(_isEditMode ? 'Guardar Cambios' : 'Crear Variante'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Información
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
}
