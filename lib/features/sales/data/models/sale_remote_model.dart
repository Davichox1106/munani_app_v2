import '../../domain/entities/sale.dart';

class SaleRemoteModel {
  final String id;
  final String locationId;
  final String locationType;
  final String? saleNumber;
  final String? customerName;
  final DateTime saleDate;
  final double subtotal;
  final double tax;
  final double total;
  final String status; // 'pending'|'completed'|'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  SaleRemoteModel({
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

  factory SaleRemoteModel.fromJson(Map<String, dynamic> json) {
    return SaleRemoteModel(
      id: json['id'] as String,
      locationId: json['location_id'] as String,
      locationType: json['location_type'] as String,
      saleNumber: json['sale_number'] as String?,
      customerName: json['customer_name'] as String?,
      saleDate: DateTime.parse(json['sale_date'] as String),
      subtotal: double.parse(json['subtotal'].toString()),
      tax: double.parse(json['tax'].toString()),
      total: double.parse(json['total'].toString()),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'location_type': locationType,
      'sale_number': saleNumber,
      'customer_name': customerName,
      'sale_date': saleDate.toIso8601String(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  Sale toEntity() {
    return Sale(
      id: id,
      locationId: locationId,
      locationType: locationType,
      saleNumber: saleNumber,
      customerName: customerName,
      saleDate: saleDate,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: _parseStatus(status),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }

  static SaleStatus _parseStatus(String s) {
    switch (s) {
      case 'pending':
        return SaleStatus.pending;
      case 'completed':
        return SaleStatus.completed;
      case 'cancelled':
        return SaleStatus.cancelled;
      default:
        return SaleStatus.pending;
    }
  }

  static SaleRemoteModel fromEntity(Sale e) => SaleRemoteModel(
        id: e.id,
        locationId: e.locationId,
        locationType: e.locationType,
        saleNumber: e.saleNumber,
        customerName: e.customerName,
        saleDate: e.saleDate,
        subtotal: e.subtotal,
        tax: e.tax,
        total: e.total,
        status: e.status.name,
        notes: e.notes,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        createdBy: e.createdBy,
      );
}
