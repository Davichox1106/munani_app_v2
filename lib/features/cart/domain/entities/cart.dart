import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'cart_status.dart';
import 'payment_receipt.dart';

class Cart extends Equatable {
  final String id;
  final String customerId;
  final CartStatus status;
  final String? customerName;
  final String? customerEmail;
  final String? locationId;
  final String? locationType;
  final String? locationName;
  final int totalItems;
  final double subtotal;
  final List<CartItem> items;
  final List<PaymentReceipt> receipts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.customerId,
    required this.status,
    this.customerName,
    this.customerEmail,
    this.locationId,
    this.locationType,
    this.locationName,
    this.totalItems = 0,
    this.subtotal = 0.0,
    this.items = const [],
    this.receipts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get total => subtotal;

  bool get isEmpty => items.isEmpty;
  PaymentReceipt? get latestReceipt {
    if (receipts.isEmpty) return null;
    final sorted = List<PaymentReceipt>.from(receipts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  Cart copyWith({
    String? id,
    String? customerId,
    CartStatus? status,
    String? customerName,
    String? customerEmail,
    String? locationId,
    String? locationType,
    String? locationName,
    int? totalItems,
    double? subtotal,
    List<CartItem>? items,
    List<PaymentReceipt>? receipts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      locationName: locationName ?? this.locationName,
      totalItems: totalItems ?? this.totalItems,
      subtotal: subtotal ?? this.subtotal,
      items: items ?? this.items,
      receipts: receipts ?? this.receipts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        status,
        customerName,
        customerEmail,
        locationId,
        locationType,
        locationName,
        totalItems,
        subtotal,
        items,
        receipts,
        createdAt,
        updatedAt,
      ];
}

