import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sync/presentation/widgets/sync_indicator.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../bloc/variant_bloc.dart';
import '../bloc/variant_event.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';
import 'variant_list_page.dart';

/// Página de lista de productos
///
/// Muestra todos los productos con funcionalidad de:
/// - Búsqueda por nombre
/// - Filtros por categoría
/// - Crear nuevo producto
/// - Editar/Eliminar producto existente
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  ProductCategory? _selectedCategory;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<ProductBloc>().add(const LoadProducts());
    } else {
      context.read<ProductBloc>().add(SearchProducts(query));
    }
  }

  void _onCategorySelected(ProductCategory? category) {
    setState(() {
      _selectedCategory = category;
    });

    context.read<ProductBloc>().add(FilterProductsByCategory(category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Productos'),
          actions: [
            // Botón de búsqueda
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    context.read<ProductBloc>().add(const LoadProducts());
                  }
                });
              },
            ),
            // Indicador de sincronización
            const SyncIndicator(showLabel: false),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Barra de búsqueda (si está activa)
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductBloc>().add(const LoadProducts());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

            // Filtros por categoría
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _CategoryChip(
                    label: 'Todos',
                    isSelected: _selectedCategory == null,
                    onTap: () => _onCategorySelected(null),
                  ),
                  ...ProductCategory.values.map((category) {
                    return _CategoryChip(
                      label: category.displayName,
                      isSelected: _selectedCategory == category,
                      onTap: () => _onCategorySelected(category),
                    );
                  }),
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
                          Text(
                            'Error al cargar productos',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
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

                  if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primer producto',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProductBloc>().add(const LoadProducts());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return _ProductCard(
                            product: product,
                            onViewDetail: () => _navigateToDetail(context, product),
                            onEdit: () => _navigateToEdit(context, product),
                            onDelete: () => _confirmDelete(context, product),
                            onViewVariants: () => _navigateToVariants(context, product),
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
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              final user = authState.user;
              if (PermissionHelper.canCreateProducts(user)) {
                return FloatingActionButton.extended(
                  onPressed: () => _navigateToCreate(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Producto'),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductBloc>(),
          child: const ProductFormPage(),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductBloc>(),
          child: ProductFormPage(product: product),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProduct(product.id));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Producto "${product.name}" eliminado'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToVariants(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<VariantBloc>()..add(LoadVariantsByProduct(product.id)),
          child: VariantListPage(product: product),
        ),
      ),
    );
  }
}

/// Widget para chip de categoría
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

/// Widget para card de producto en la lista
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewVariants;

  const _ProductCard({
    required this.product,
    required this.onViewDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onViewVariants,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool canEdit = false;
        bool canDelete = false;

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          canEdit = PermissionHelper.canEditProducts(user);
          canDelete = PermissionHelper.canDeleteProducts(user);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onViewDetail,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeading(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(product.category),
                                  size: 16,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product.category.displayName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                            if (product.description != null && product.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                product.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Venta: \$${product.basePriceSell.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.accentGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Compra: \$${product.basePriceBuy.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (product.hasVariants)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Var',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'Ver detalle',
                        child: IconButton(
                          icon: const Icon(Icons.visibility_outlined),
                          color: AppColors.accentBlue,
                          onPressed: onViewDetail,
                        ),
                      ),
                      if (canEdit)
                        Tooltip(
                          message: 'Editar',
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: AppColors.accentBlue,
                            onPressed: onEdit,
                          ),
                        ),
                      Tooltip(
                        message: 'Ver variantes',
                        child: IconButton(
                          icon: const Icon(Icons.inventory_2_outlined),
                          color: AppColors.info,
                          onPressed: onViewVariants,
                        ),
                      ),
                      if (canDelete)
                        Tooltip(
                          message: 'Eliminar',
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.error,
                            onPressed: onDelete,
                          ),
                        ),
                      if (!canEdit && !canDelete)
                        const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading() {
    if (product.imageUrls.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          _getCategoryIcon(product.category),
          color: AppColors.primaryOrange,
          size: 36,
        ),
      );
    }

    final firstImage = product.imageUrls.first;
    final isRemote = firstImage.startsWith('http');
    final imageWidget = isRemote
        ? Image.network(
            firstImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 32),
          )
        : Image.file(
            File(firstImage),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 32),
          );

    return Hero(
      tag: 'product-thumb-${product.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 72,
          height: 72,
          child: imageWidget,
        ),
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

