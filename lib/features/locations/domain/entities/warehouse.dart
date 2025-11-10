import 'package:equatable/equatable.dart';

/// Entidad de dominio para Almacén
///
/// Representa un almacén de la empresa donde se almacena inventario.
/// Cada almacén tiene un encargado asignado y su propio inventario.
class Warehouse extends Equatable {
  final String id; // UUID
  final String name;
  final String address;
  final String? phone;
  final String? managerId; // UUID del encargado de almacén
  final bool isActive;
  final String? paymentQrUrl;
  final String? paymentQrDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Warehouse({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.managerId,
    this.isActive = true,
    this.paymentQrUrl,
    this.paymentQrDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        managerId,
        isActive,
        paymentQrUrl,
        paymentQrDescription,
        createdAt,
        updatedAt,
      ];

  /// Copia del almacén con campos actualizados
  Warehouse copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? managerId,
    bool? isActive,
    String? paymentQrUrl,
    String? paymentQrDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      managerId: managerId ?? this.managerId,
      isActive: isActive ?? this.isActive,
      paymentQrUrl: paymentQrUrl ?? this.paymentQrUrl,
      paymentQrDescription: paymentQrDescription ?? this.paymentQrDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si tiene encargado asignado
  bool get hasManager => managerId != null && managerId!.isNotEmpty;

  /// Indica si el almacén tiene QR configurado para pagos
  bool get hasPaymentQr =>
      paymentQrUrl != null && paymentQrUrl!.trim().isNotEmpty;
}
