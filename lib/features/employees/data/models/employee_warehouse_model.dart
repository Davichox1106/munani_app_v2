import '../../domain/entities/employee_warehouse.dart';

/// Modelo de datos para EmployeeWarehouse
class EmployeeWarehouseModel extends EmployeeWarehouse {
  const EmployeeWarehouseModel({
    required super.id,
    required super.name,
    super.contactName,
    super.phone,
    required super.email,
    super.ci,
    super.address,
    super.position,
    super.department,
    super.notes,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  /// Crea un modelo desde JSON
  factory EmployeeWarehouseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeWarehouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactName: json['contact_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      ci: json['ci'] as String?,
      address: json['address'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'ci': ci,
      'address': address,
      'position': position,
      'department': department,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  /// Crea un modelo desde una entidad
  factory EmployeeWarehouseModel.fromEntity(EmployeeWarehouse employee) {
    return EmployeeWarehouseModel(
      id: employee.id,
      name: employee.name,
      contactName: employee.contactName,
      phone: employee.phone,
      email: employee.email,
      ci: employee.ci,
      address: employee.address,
      position: employee.position,
      department: employee.department,
      notes: employee.notes,
      isActive: employee.isActive,
      createdAt: employee.createdAt,
      updatedAt: employee.updatedAt,
      createdBy: employee.createdBy,
      updatedBy: employee.updatedBy,
    );
  }
}
