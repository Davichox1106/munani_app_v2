import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_history_cubit.dart';
import 'cart_checkout_page.dart';
import 'cart_history_page.dart';

class CustomerCartPage extends StatelessWidget {
  const CustomerCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi carrito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de pedidos',
            onPressed: () => _openHistory(context),
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<CartBloc>().add(const CartMessageShown());
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<CartBloc>().add(const CartMessageShown());
          }
        },
        builder: (context, state) {
          final cart = state.cart;

          if (cart == null || cart.items.isEmpty) {
            return const _EmptyCartView();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              _CartSummary(
                subtotal: cart.subtotal,
                totalItems: cart.totalItems,
                onClear: () =>
                    context.read<CartBloc>().add(const CartClearRequested()),
                onCheckout: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CartBloc>(),
                        child: CartCheckoutPage(cart: cart),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _openHistory(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para ver tu historial.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final customerId = authState.user.id;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<CartBloc>(),
            ),
            BlocProvider(
              create: (_) => sl<CartHistoryCubit>()
                ..load(customerId: customerId),
            ),
          ],
          child: CartHistoryPage(customerId: customerId),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartBloc = context.read<CartBloc>();
    final imagePath = item.imageUrls.isNotEmpty ? item.imageUrls.first : null;
    final isRemote = imagePath != null && imagePath.startsWith('http');
    final imageWidget = imagePath == null
        ? Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.textSecondary),
          )
        : (isRemote
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: AppColors.textSecondary),
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: AppColors.textSecondary),
              ));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imageWidget,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Producto',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (item.variantName != null)
                    Text(
                      item.variantName!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Precio: ${item.unitPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Subtotal: ${item.subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: item.quantity > 1
                            ? () => cartBloc.add(
                                  CartUpdateItemQty(
                                    cartItemId: item.id,
                                    quantity: item.quantity - 1,
                                    availableQuantity: item.availableQuantity,
                                  ),
                                )
                            : null,
                      ),
                      Text(
                        '${item.quantity}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: item.quantity < item.availableQuantity
                            ? () => cartBloc.add(
                                  CartUpdateItemQty(
                                    cartItemId: item.id,
                                    quantity: item.quantity + 1,
                                    availableQuantity: item.availableQuantity,
                                  ),
                                )
                            : null,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => cartBloc.add(
                          CartRemoveItemEvent(item.id),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar'),
                      ),
                    ],
                  ),
                  if (item.quantity >= item.availableQuantity)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'No hay más unidades disponibles',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final int totalItems;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.totalItems,
    required this.onClear,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Artículos',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '$totalItems',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtotal.toStringAsFixed(2),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onCheckout,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primaryBrown,
            ),
            child: const Text('Proceder al pago'),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Vaciar carrito'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu carrito está vacío',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega productos desde el catálogo para comenzar tu compra.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

