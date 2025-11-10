import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/bloc/variant_bloc.dart';
import '../../../products/presentation/bloc/variant_event.dart';
import '../../../products/presentation/bloc/variant_state.dart';
import 'quick_product_form_dialog.dart';

/// Página para seleccionar un producto/variante para agregar a la compra
class PurchaseProductSelectorPage extends StatefulWidget {
  const PurchaseProductSelectorPage({super.key});

  @override
  State<PurchaseProductSelectorPage> createState() =>
      _PurchaseProductSelectorPageState();
}

class _PurchaseProductSelectorPageState
    extends State<PurchaseProductSelectorPage> {
  ProductCategory? _selectedCategory;
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    context.read<ProductBloc>().add(const LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Producto'),
        backgroundColor: AppColors.primaryOrange,
        actions: [
          // Filtro de solo activos
          Tooltip(
            message: _showOnlyActive
                ? 'Mostrando solo activos'
                : 'Mostrando todos',
            child: IconButton(
              icon: Icon(
                _showOnlyActive ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _showOnlyActive = !_showOnlyActive;
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar producto',
                    hintText: 'Nombre del producto...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<ProductBloc>().add(const LoadProducts());
                    } else {
                      context.read<ProductBloc>().add(SearchProducts(value));
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Filtros por categoría
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'Todos',
                        isSelected: _selectedCategory == null,
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          context
                              .read<ProductBloc>()
                              .add(const FilterProductsByCategory(null));
                        },
                      ),
                      ...ProductCategory.values.map((category) {
                        return _CategoryChip(
                          label: category.displayName,
                          isSelected: _selectedCategory == category,
                          onTap: () {
                            setState(() => _selectedCategory = category);
                            context
                                .read<ProductBloc>()
                                .add(FilterProductsByCategory(category));
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ProductError) {
                  return _buildErrorWidget(state.message);
                }

                if (state is ProductsLoaded) {
                  final products = _filterProducts(state.products);

                  if (products.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductBloc>().add(const LoadProducts());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductCard(
                          product: product,
                          onVariantSelected: (variant) {
                            Navigator.of(context).pop(variant);
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickProductForm(),
        backgroundColor: AppColors.accentGreen,
        icon: const Icon(Icons.add),
        label: const Text('Crear Producto'),
      ),
    );
  }

  /// Filtrar productos según criterios
  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Nota: Product no tiene campo isActive,
    // el filtro se aplicaría a nivel de variantes

    return filtered;
  }

  /// Mostrar formulario rápido de creación
  Future<void> _showQuickProductForm() async {
    final variant = await showDialog<ProductVariant>(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProductBloc>()),
          BlocProvider.value(value: context.read<VariantBloc>()),
        ],
        child: const QuickProductFormDialog(),
      ),
    );

    if (variant != null && mounted) {
      // Retornar la variante creada
      Navigator.of(context).pop(variant);
    }
  }

  /// Widget de error
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductBloc>().add(const LoadProducts());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Widget de estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay productos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿No encuentras el producto?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showQuickProductForm(),
            icon: const Icon(Icons.add),
            label: const Text('Crear Producto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de categoría
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryOrange,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Card de producto expandible que muestra sus variantes
class _ProductCard extends StatefulWidget {
  final Product product;
  final Function(ProductVariant) onVariantSelected;

  const _ProductCard({
    required this.product,
    required this.onVariantSelected,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isExpanded = false;
  VariantBloc? _variantBloc;

  @override
  void dispose() {
    _variantBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header del producto
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded && _variantBloc == null) {
                  // Crear BLoC y cargar variantes cuando se expande por primera vez
                  _variantBloc = sl<VariantBloc>();
                  _variantBloc!.add(
                    LoadVariantsByProduct(widget.product.id),
                  );
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono del producto
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.product.category),
                      color: AppColors.primaryOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Información del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.category.displayName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Compra: \$${widget.product.basePriceBuy.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.product.hasVariants) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Con variantes',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Icono de expandir
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Lista de variantes (expandible)
          if (_isExpanded && _variantBloc != null)
            BlocBuilder<VariantBloc, VariantState>(
              bloc: _variantBloc!,
              builder: (context, state) {
                if (state is VariantLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is VariantError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                if (state is VariantsLoaded) {
                  if (state.variants.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No hay variantes disponibles',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return Column(
                    children: state.variants.map((variant) {
                      return _VariantTile(
                        variant: variant,
                        productName: widget.product.name,
                        onTap: () => widget.onVariantSelected(variant),
                      );
                    }).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.barritasNutritivas:
        return Icons.restaurant;
      case ProductCategory.barritasProteicas:
        return Icons.fitness_center;
      case ProductCategory.barritasDieteticas:
        return Icons.eco;
      case ProductCategory.otros:
        return Icons.category;
    }
  }
}

/// Tile de variante
class _VariantTile extends StatelessWidget {
  final ProductVariant variant;
  final String productName;
  final VoidCallback onTap;

  const _VariantTile({
    required this.variant,
    required this.productName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: variant.isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
          color: variant.isActive
              ? Colors.transparent
              : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            // Indicador de estado
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: variant.isActive ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Información de la variante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: variant.isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'SKU: ${variant.sku}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Compra: \$${variant.priceBuy.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Icono de selección
            if (variant.isActive)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              )
            else
              const Text(
                'Inactivo',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
