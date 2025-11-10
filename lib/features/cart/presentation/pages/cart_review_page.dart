import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/payment_receipt.dart';
import '../../domain/repositories/cart_repository.dart';
import '../bloc/cart_review_bloc.dart';

class CartReviewPage extends StatefulWidget {
  final String? locationId;
  final String? locationType;

  const CartReviewPage({
    super.key,
    this.locationId,
    this.locationType,
  });

  @override
  State<CartReviewPage> createState() => _CartReviewPageState();
}

class _CartReviewPageState extends State<CartReviewPage> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  late final CartReviewBloc _reviewBloc;

  @override
  void initState() {
    super.initState();
    _reviewBloc = sl<CartReviewBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reviewBloc.add(
        LoadCartsForReview(
          locationId: widget.locationId,
          locationType: widget.locationType,
        ),
      );
    });
  }

  @override
  void dispose() {
    _reviewBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final managerId = authState is AuthAuthenticated ? authState.user.id : null;

    return BlocProvider<CartReviewBloc>.value(
      value: _reviewBloc,
      child: Builder(
        builder: (context) {
          return BlocConsumer<CartReviewBloc, CartReviewState>(
            listener: (context, state) {
              if (state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: AppColors.success,
                  ),
                );
                context
                    .read<CartReviewBloc>()
                    .add(const CartReviewMessageCleared());
              }
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppColors.error,
                  ),
                );
                context
                    .read<CartReviewBloc>()
                    .add(const CartReviewMessageCleared());
              }
            },
            builder: (context, state) {
              final bloc = context.read<CartReviewBloc>();
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Pedidos pendientes'),
                  actions: [
                    IconButton(
                      onPressed: state.status == CartReviewStatus.loading
                          ? null
                          : () => bloc.add(
                                LoadCartsForReview(
                                  locationId: widget.locationId,
                                  locationType: widget.locationType,
                                ),
                              ),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                body: _buildBody(context, state, managerId),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CartReviewState state,
    String? managerId,
  ) {
    if (state.status == CartReviewStatus.loading &&
        state.carts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.carts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<CartReviewBloc>().add(
                LoadCartsForReview(
                  locationId: widget.locationId,
                  locationType: widget.locationType,
                ),
              );
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No hay pedidos en revisión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Cuando un cliente envíe un comprobante de pago aparecerá aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CartReviewBloc>().add(
              LoadCartsForReview(
                locationId: widget.locationId,
                locationType: widget.locationType,
              ),
            );
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.carts.length,
        itemBuilder: (context, index) {
          final cart = state.carts[index];
          return _buildCartCard(
            context,
            cart,
            managerId,
            state.actionInProgress,
          );
        },
      ),
    );
  }

  Widget _buildCartCard(
    BuildContext context,
    Cart cart,
    String? managerId,
    bool actionInProgress,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.primaryBrown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cart.customerName ?? 'Cliente ${cart.customerId}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _dateFormat.format(cart.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            if (cart.customerEmail != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cart.customerEmail!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  cart.locationType == 'store'
                      ? Icons.store
                      : Icons.warehouse,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cart.locationName ?? 'Ubicación no especificada',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Productos',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}× ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        item.productName ??
                            item.variantName ??
                            item.productVariantId,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (item.subtotal).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  cart.subtotal.toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: cart.latestReceipt == null
                      ? null
                      : () => _viewReceipt(context, cart.latestReceipt!),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Ver comprobante'),
                ),
                OutlinedButton.icon(
                  onPressed: actionInProgress || managerId == null
                      ? null
                      : () => _showRejectDialog(context, cart, managerId),
                  icon: const Icon(Icons.close_outlined),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
                FilledButton.icon(
                  onPressed: actionInProgress || managerId == null
                      ? null
                      : () => context.read<CartReviewBloc>().add(
                            ApproveCartRequested(
                              cartId: cart.id,
                              managerId: managerId,
                            ),
                          ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aprobar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewReceipt(
    BuildContext parentContext,
    PaymentReceipt receipt,
  ) async {
    final repository = sl<CartRepository>();
    final result = await repository.createReceiptDownloadUrl(
      storagePath: receipt.storagePath,
      expiresIn: const Duration(minutes: 15),
    );

    if (!mounted || !parentContext.mounted) return;
    final messenger = ScaffoldMessenger.of(parentContext);

    result.fold(
      (failure) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar el comprobante: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (url) {
        showDialog(
          context: parentContext,
          builder: (_) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Comprobante',
                    style: Theme.of(parentContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 380,
                  width: 320,
                  child: InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(parentContext).pop(),
                  child: const Text('Cerrar'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRejectDialog(
    BuildContext parentContext,
    Cart cart,
    String managerId,
  ) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: parentContext,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe el motivo para rechazar el pedido (opcional).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(parentContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(parentContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    final notes = notesController.text.trim();
    notesController.dispose();

    if (confirmed != true) return;
    if (!mounted || !parentContext.mounted) return;

    parentContext.read<CartReviewBloc>().add(
          RejectCartRequested(
            cartId: cart.id,
            managerId: managerId,
            notes: notes.isEmpty ? null : notes,
          ),
        );
  }
}

