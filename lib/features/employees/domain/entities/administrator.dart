import 'package:equatable/equatable.dart';

/// Entidad que representa un administrador pre-registrado
class Administrator extends Equatable {
  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String email;
  final String? ci; // Cédula de Identidad
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const Administrator({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    required this.email,
    this.ci,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Crea una copia con nuevos valores
  Administrator copyWith({
    String? id,
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? ci,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Administrator(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      ci: ci ?? this.ci,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        contactName,
        phone,
        email,
        ci,
        address,
        notes,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
