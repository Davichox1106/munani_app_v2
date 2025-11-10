import 'package:equatable/equatable.dart';

/// Entidad que representa un proveedor
class Supplier extends Equatable {
  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? rucNit;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const Supplier({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.rucNit,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Crea una copia con nuevos valores
  Supplier copyWith({
    String? id,
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? rucNit,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      rucNit: rucNit ?? this.rucNit,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Verifica si el proveedor tiene información de contacto completa
  bool get hasCompleteContact {
    return phone != null || email != null;
  }

  /// Obtiene el contacto principal (teléfono o email)
  String? get primaryContact {
    if (phone != null && phone!.isNotEmpty) return phone;
    if (email != null && email!.isNotEmpty) return email;
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        contactName,
        phone,
        email,
        address,
        rucNit,
        notes,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
