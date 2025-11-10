import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../bloc/variant_bloc.dart';
import '../bloc/variant_event.dart';
import '../bloc/variant_state.dart';
import 'variant_form_page.dart';

/// Página de lista de variantes de un producto
class VariantListPage extends StatelessWidget {
  final Product product;

  const VariantListPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Variantes'),
            Text(
              product.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (PermissionHelper.canCreateProductVariants(user)) {
              return FloatingActionButton(
                onPressed: () => _navigateToCreate(context),
                child: const Icon(Icons.add),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocConsumer<VariantBloc, VariantState>(
        listener: (context, state) {
          if (state is VariantCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state is VariantUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state is VariantDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Recargar lista después de eliminar
            context.read<VariantBloc>().add(LoadVariantsByProduct(product.id));
          }

          if (state is VariantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VariantLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VariantsLoaded) {
            if (state.variants.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<VariantBloc>().add(LoadVariantsByProduct(product.id));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.variants.length,
                itemBuilder: (context, index) {
                  final variant = state.variants[index];
                  return _buildVariantCard(context, variant);
                },
              ),
            );
          }

          if (state is VariantError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<VariantBloc>().add(LoadVariantsByProduct(product.id));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tune, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay variantes',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea la primera variante de este producto',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreate(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear Variante'),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(BuildContext context, ProductVariant variant) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool canEdit = false;
        bool canDelete = false;
        
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          canEdit = PermissionHelper.canEditProductVariants(user);
          canDelete = PermissionHelper.canDeleteProductVariants(user);
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: variant.isActive ? AppColors.success : AppColors.error,
              child: Icon(
                variant.isActive ? Icons.check : Icons.block,
                color: Colors.white,
              ),
            ),
            title: Text(
              variant.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('SKU: ${variant.sku}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Venta: \$${variant.priceSell.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Compra: \$${variant.priceBuy.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.info),
                    onPressed: () => _navigateToEdit(context, variant),
                    tooltip: 'Editar variante',
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _confirmDelete(context, variant),
                    tooltip: 'Eliminar variante',
                  ),
                if (!canEdit && !canDelete)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VariantBloc>(),
          child: VariantFormPage(product: product),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, ProductVariant variant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VariantBloc>(),
          child: VariantFormPage(
            product: product,
            variant: variant,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductVariant variant) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Variante'),
        content: Text(
          '¿Estás seguro de eliminar "${variant.displayName}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VariantBloc>().add(DeleteVariantEvent(variant.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
