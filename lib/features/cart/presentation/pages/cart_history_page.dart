import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_history_cubit.dart';
import 'cart_checkout_page.dart';

class CartHistoryPage extends StatelessWidget {
  final String customerId;

  const CartHistoryPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de pedidos'),
        actions: [
          BlocBuilder<CartHistoryCubit, CartHistoryState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar historial',
                onPressed:
                    state.isSyncing ? null : () => context.read<CartHistoryCubit>().refresh(),
              );
            },
          ),
        ],
      ),
      body: BlocListener<CartHistoryCubit, CartHistoryState>(
        listenWhen: (previous, current) => current.error != null && current.error != previous.error,
        listener: (context, state) {
          final error = state.error;
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<CartHistoryCubit, CartHistoryState>(
          builder: (context, state) {
            if (state.status == CartHistoryStatus.loading && state.carts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final refreshIndicator = RefreshIndicator(
              onRefresh: () => context.read<CartHistoryCubit>().refresh(),
              child: state.carts.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        _EmptyHistoryView(),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.carts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cart = state.carts[index];
                        return _CartHistoryTile(
                          cart: cart,
                          dateFormat: dateFormat,
                          onOpen: () => _openCheckout(context, cart),
                        );
                      },
                    ),
            );

            return Column(
              children: [
                AnimatedOpacity(
                  opacity: state.isSyncing ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: state.isSyncing
                      ? const LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: AppColors.surfaceBeige,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                        )
                      : const SizedBox(height: 2),
                ),
                Expanded(child: refreshIndicator),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context, Cart cart) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: CartCheckoutPage(cart: cart),
        ),
      ),
    );
  }
}

class _CartHistoryTile extends StatelessWidget {
  final Cart cart;
  final DateFormat dateFormat;
  final VoidCallback onOpen;

  const _CartHistoryTile({
    required this.cart,
    required this.dateFormat,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(cart.status);
    final statusLabel = _statusLabel(cart.status);

    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cart.locationName ?? 'Sin ubicación',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total de artículos: ${cart.totalItems}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Monto total: ${cart.subtotal.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Actualizado: ${dateFormat.format(cart.updatedAt)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ver detalle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 72,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'No tienes pedidos previos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Aquí aparecerán tus pedidos en revisión, aprobados o rechazados.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

Color _statusColor(CartStatus status) {
  switch (status) {
    case CartStatus.awaitingPayment:
      return AppColors.warning;
    case CartStatus.paymentSubmitted:
      return AppColors.info;
    case CartStatus.paymentRejected:
      return AppColors.error;
    case CartStatus.completed:
      return AppColors.success;
    case CartStatus.cancelled:
      return Colors.grey;
    case CartStatus.pending:
      return AppColors.primaryBrown;
  }
}

String _statusLabel(CartStatus status) {
  switch (status) {
    case CartStatus.awaitingPayment:
      return 'Pendiente de pago';
    case CartStatus.paymentSubmitted:
      return 'Comprobante enviado';
    case CartStatus.paymentRejected:
      return 'Pago rechazado';
    case CartStatus.completed:
      return 'Completado';
    case CartStatus.cancelled:
      return 'Cancelado';
    case CartStatus.pending:
      return 'En progreso';
  }
}



