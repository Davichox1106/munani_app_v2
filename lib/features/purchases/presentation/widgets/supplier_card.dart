import 'package:flutter/material.dart';
import '../../domain/entities/supplier.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: supplier.isActive ? Colors.blue : Colors.grey,
          child: Text(
            supplier.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.rucNit != null)
              Text('RUC/NIT: ${supplier.rucNit}'),
            if (supplier.phone != null)
              Text('Tel: ${supplier.phone}'),
            if (!supplier.isActive)
              const Text(
                'INACTIVO',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
