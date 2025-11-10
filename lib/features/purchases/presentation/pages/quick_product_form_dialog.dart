import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/bloc/variant_bloc.dart';
import '../../../products/presentation/bloc/variant_event.dart';
import '../../../products/presentation/bloc/variant_state.dart';

/// Diálogo para crear producto y variante rápidamente
class QuickProductFormDialog extends StatefulWidget {
  const QuickProductFormDialog({super.key});

  @override
  State<QuickProductFormDialog> createState() => _QuickProductFormDialogState();
}

class _QuickProductFormDialogState extends State<QuickProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _variantNameController = TextEditingController();
  final _priceSellController = TextEditingController();
  final _priceBuyController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.otros;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _variantNameController.dispose();
    _priceSellController.dispose();
    _priceBuyController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar autenticado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    // Crear producto primero
    context.read<ProductBloc>().add(
          CreateProduct(
            name: _nameController.text.trim(),
            description: null,
            category: _selectedCategory,
            basePriceSell: double.parse(_priceSellController.text),
            basePriceBuy: double.parse(_priceBuyController.text),
            hasVariants: true,
            imageUrls: const [],
            createdBy: authState.user.id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add_shopping_cart,
              color: AppColors.accentGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Crear Producto Nuevo',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: MultiBlocListener(
        listeners: [
          // Listener para creación de producto
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductCreated) {
                // Producto creado, ahora crear la variante
                context.read<VariantBloc>().add(
                      CreateVariantEvent(
                        productId: state.product.id,
                        sku: _skuController.text.trim(),
                        variantName: _variantNameController.text.trim().isEmpty
                            ? 'Estándar'
                            : _variantNameController.text.trim(),
                        variantAttributes: null,
                        priceSell: double.parse(_priceSellController.text),
                        priceBuy: double.parse(_priceBuyController.text),
                      ),
                    );
              }

              if (state is ProductError) {
                setState(() => _isCreating = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),

          // Listener para creación de variante
          BlocListener<VariantBloc, VariantState>(
            listener: (context, state) {
              if (state is VariantCreated) {
                // Producto y variante creados exitosamente
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto creado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Retornar la variante creada
                Navigator.of(context).pop(state.variant);
              }

              if (state is VariantError) {
                setState(() => _isCreating = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al crear variante: ${state.message}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Completa los datos mínimos para crear el producto',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre del producto
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto *',
                    hintText: 'Ej: Barrita Proteica Chocolate',
                    prefixIcon: Icon(Icons.inventory_2),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                  enabled: !_isCreating,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Categoría
                DropdownButtonFormField<ProductCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: ProductCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: _isCreating
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                ),
                const SizedBox(height: 16),

                // SKU de variante
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU *',
                    hintText: 'Ej: BAR-CHO-040',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El SKU es requerido';
                    }
                    return null;
                  },
                  enabled: !_isCreating,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Nombre de variante (opcional)
                TextFormField(
                  controller: _variantNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Variante (opcional)',
                    hintText: 'Ej: Sabor Frutos Rojos 40g',
                    prefixIcon: Icon(Icons.tune),
                    border: OutlineInputBorder(),
                    helperText: 'Si se deja vacío, se usará "Estándar"',
                  ),
                  enabled: !_isCreating,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Precios
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceSellController,
                        decoration: const InputDecoration(
                          labelText: 'Precio Venta *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.sell),
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: Validators.price,
                        enabled: !_isCreating,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceBuyController,
                        decoration: const InputDecoration(
                          labelText: 'Precio Compra *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: Validators.price,
                        enabled: !_isCreating,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Podrás editar más detalles después',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
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
      actions: [
        // Botón Cancelar
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),

        // Botón Crear
        ElevatedButton.icon(
          onPressed: _isCreating ? null : _onSave,
          icon: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add),
          label: Text(_isCreating ? 'Creando...' : 'Crear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
