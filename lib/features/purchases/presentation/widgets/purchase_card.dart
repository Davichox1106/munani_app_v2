import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/purchase.dart';

class PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onTap;

  const PurchaseCard({
    super.key,
    required this.purchase,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        return Colors.orange;
      case PurchaseStatus.received:
        return Colors.green;
      case PurchaseStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        return Icons.hourglass_empty;
      case PurchaseStatus.received:
        return Icons.check_circle;
      case PurchaseStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: Número y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Número de compra
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            purchase.purchaseNumber ?? 'SIN NÚMERO',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          purchase.statusText.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Proveedor
              Row(
                children: [
                  Icon(
                    Icons.business,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      purchase.supplierName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ubicación
              Row(
                children: [
                  Icon(
                    purchase.locationType == 'store' 
                        ? Icons.store 
                        : Icons.warehouse,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      purchase.locationName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fecha
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(purchase.purchaseDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    currencyFormat.format(purchase.total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              // Información adicional para recibidas
              if (purchase.status == PurchaseStatus.received &&
                  purchase.receivedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recibida el ${dateFormat.format(purchase.receivedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Información adicional para canceladas
              if (purchase.status == PurchaseStatus.cancelled &&
                  purchase.cancelledAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cancelada el ${dateFormat.format(purchase.cancelledAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Indicador de sincronización pendiente
              if (purchase.needsSync)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync,
                        color: Colors.amber[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pendiente de sincronización',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
