import 'package:equatable/equatable.dart';

/// Entidad de dominio para Tienda
///
/// Representa una tienda física de la empresa donde se realizan ventas.
/// Cada tienda tiene un encargado asignado y su propio inventario.
class Store extends Equatable {
  final String id; // UUID
  final String name;
  final String address;
  final String? phone;
  final String? managerId; // UUID del encargado de tienda
  final bool isActive;
  final String? paymentQrUrl; // URL del QR de pagos (puede ser imagen pública)
  final String? paymentQrDescription; // Texto descriptivo para el QR
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
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

  /// Copia de la tienda con campos actualizados
  Store copyWith({
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
    return Store(
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

  /// Indica si la tienda tiene un QR configurado para pagos
  bool get hasPaymentQr =>
      paymentQrUrl != null && paymentQrUrl!.trim().isNotEmpty;
}
