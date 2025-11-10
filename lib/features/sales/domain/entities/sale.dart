import 'package:equatable/equatable.dart';

enum SaleStatus { pending, completed, cancelled }

class Sale extends Equatable {
  final String id;
  final String locationId;
  final String locationType; // 'store' | 'warehouse'
  final String? saleNumber;
  final String? customerName;
  final DateTime saleDate;
  final double subtotal;
  final double tax;
  final double total;
  final SaleStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Sale({
    required this.id,
    required this.locationId,
    required this.locationType,
    this.saleNumber,
    this.customerName,
    required this.saleDate,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Sale copyWith({
    String? id,
    String? locationId,
    String? locationType,
    String? saleNumber,
    String? customerName,
    DateTime? saleDate,
    double? subtotal,
    double? tax,
    double? total,
    SaleStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Sale(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      saleNumber: saleNumber ?? this.saleNumber,
      customerName: customerName ?? this.customerName,
      saleDate: saleDate ?? this.saleDate,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        locationId,
        locationType,
        saleNumber,
        customerName,
        saleDate,
        subtotal,
        tax,
        total,
        status,
        notes,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
