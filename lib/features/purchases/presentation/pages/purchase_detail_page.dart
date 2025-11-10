import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/purchase.dart';
import '../bloc/purchase_bloc.dart';
import '../bloc/purchase_event.dart' as purchase_event;
import '../bloc/purchase_state.dart';
import '../widgets/purchase_item_tile.dart';
import '../../domain/entities/purchase_with_items.dart';

/// Página de detalle de una compra
/// Muestra la información completa de la compra y sus ítems
/// Permite recibir o cancelar la compra según su estado
class PurchaseDetailPage extends StatefulWidget {
  final String purchaseId;

  const PurchaseDetailPage({
    super.key,
    required this.purchaseId,
  });

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  PurchaseWithItems? _lastDetail;
  @override
  void initState() {
    super.initState();
    _loadPurchaseDetail();
  }

  void _loadPurchaseDetail() {
    context.read<PurchaseBloc>().add(
      purchase_event.LoadPurchaseDetail(widget.purchaseId),
    );
  }

  void _receivePurchase(Purchase purchase, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recibir Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Confirma que ha recibido esta compra?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Al confirmar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• La compra se marcará como recibida'),
            const Text('• Los productos se agregarán al inventario'),
            const Text('• No podrá modificar la compra'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PurchaseBloc>().add(
                purchase_event.ReceivePurchase(
                  purchaseId: purchase.id,
                  receivedBy: userId,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Recibir Compra'),
          ),
        ],
      ),
    );
  }

  void _cancelPurchase(Purchase purchase, String userId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Está seguro que desea cancelar esta compra?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación',
                hintText: 'Ingrese el motivo...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.pop(dialogContext);
            },
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              reasonController.dispose();
              Navigator.pop(dialogContext);

              context.read<PurchaseBloc>().add(
                purchase_event.CancelPurchase(
                  purchaseId: purchase.id,
                  cancelledBy: userId,
                  cancellationReason: reason.isEmpty ? null : reason,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancelar Compra'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Compra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseDetail,
          ),
        ],
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
          } else if (state is PurchaseReceived) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            _loadPurchaseDetail();
          } else if (state is PurchaseCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            _loadPurchaseDetail();
          } else if (state is PurchaseDetailLoaded) {
            _lastDetail = state.purchaseWithItems;
          }
        },
        buildWhen: (previous, current) {
          if (current is PurchaseError && _lastDetail != null) {
            return false; // evitar parpadeo mostrando error con datos previos
          }
          return true;
        },
        builder: (context, state) {
          if (state is PurchaseDetailLoading || state is PurchaseReceiving) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PurchaseDetailLoaded) {
            final purchaseWithItems = state.purchaseWithItems;
            final purchase = purchaseWithItems.purchase;
            final items = purchaseWithItems.items;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con información general
                  _buildHeaderCard(purchase, dateFormat),

                  // Lista de ítems
                  _buildItemsList(items, currencyFormat),

                  // Resumen de totales
                  _buildTotalsCard(purchase, currencyFormat),

                  // Información adicional
                  if (purchase.notes != null)
                    _buildNotesCard(purchase.notes!),

                  const SizedBox(height: 80), // Espacio para los botones
                ],
              ),
            );
          }

          // Si hay detalle previo, mostrarlo aunque haya error transitorio
          if (_lastDetail != null) {
            final purchase = _lastDetail!.purchase;
            final items = _lastDetail!.items;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(purchase, dateFormat),
                  _buildItemsList(items, currencyFormat),
                  _buildTotalsCard(purchase, currencyFormat),
                  if (purchase.notes != null) _buildNotesCard(purchase.notes!),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }

          // Estado transitorio: evitar parpadeo mostrando loader hasta obtener datos o error persistente
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BlocBuilder<PurchaseBloc, PurchaseState>(
        builder: (context, purchaseState) {
          if (purchaseState is! PurchaseDetailLoaded) {
            return const SizedBox();
          }

          final purchase = purchaseState.purchaseWithItems.purchase;

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) return const SizedBox();

              final userId = authState.user.id;

              // Solo mostrar botones si la compra está pendiente
              if (purchase.status != PurchaseStatus.pending) {
                return const SizedBox();
              }

              return Container(
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
                child: Row(
                  children: [
                    // Botón de cancelar
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelPurchase(purchase, userId),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón de recibir
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _receivePurchase(purchase, userId),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Recibir Compra'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Purchase purchase, DateFormat dateFormat) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'PENDIENTE';
        break;
      case PurchaseStatus.received:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'RECIBIDA';
        break;
      case PurchaseStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'CANCELADA';
        break;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchase.purchaseNumber ?? 'SIN NÚMERO',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Proveedor
            _buildInfoRow(
              Icons.business,
              'Proveedor',
              purchase.supplierName,
            ),
            const SizedBox(height: 8),

            // Fecha
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              dateFormat.format(purchase.purchaseDate),
            ),

            // Fecha de recepción (si aplica)
            if (purchase.receivedAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.check_circle_outline,
                'Recibida',
                dateFormat.format(purchase.receivedAt!),
              ),
            ],

            // Fecha de cancelación (si aplica)
            if (purchase.cancelledAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.info_outline,
                'Cancelada',
                dateFormat.format(purchase.cancelledAt!),
              ),
            ],

            // Motivo de cancelación
            if (purchase.cancellationReason != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.description,
                'Motivo',
                purchase.cancellationReason!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List items, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                Text(
                  '${items.length} ítem${items.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No hay productos en esta compra'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return PurchaseItemTile(
                    item: items[index],
                    currencyFormat: currencyFormat,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard(Purchase purchase, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal:', purchase.subtotal, currencyFormat),
            const SizedBox(height: 8),
            _buildTotalRow('IVA:', purchase.tax, currencyFormat),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            _buildTotalRow(
              'TOTAL:',
              purchase.total,
              currencyFormat,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    NumberFormat currencyFormat, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.blue : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
