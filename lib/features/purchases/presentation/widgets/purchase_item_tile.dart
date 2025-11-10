import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/purchase_item.dart';

/// Widget para mostrar un ítem de compra en forma de tile
class PurchaseItemTile extends StatelessWidget {
  final PurchaseItem item;
  final NumberFormat currencyFormat;
  final VoidCallback? onTap;

  const PurchaseItemTile({
    super.key,
    required this.item,
    required this.currencyFormat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        child: Text(
          '${item.quantity}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      title: Text(
        item.productName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.variantName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Costo unitario: ${currencyFormat.format(item.unitCost)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFormat.format(item.subtotal),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            '${item.quantity} × ${currencyFormat.format(item.unitCost)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
