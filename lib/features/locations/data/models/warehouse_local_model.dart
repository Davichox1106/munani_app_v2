import 'package:isar/isar.dart';
import '../../domain/entities/warehouse.dart';

part 'warehouse_local_model.g.dart';

/// Modelo de Isar para Warehouse (Base de datos local)
///
/// Almacena información de almacenes para acceso offline.
@collection
class WarehouseLocalModel {
  /// ID local de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  /// UUID del almacén (sincronización con Supabase)
  @Index(unique: true)
  late String uuid;

  /// Nombre del almacén
  @Index(type: IndexType.value)
  late String name;

  /// Dirección del almacén
  late String address;

  /// Teléfono de contacto
  String? phone;

  /// UUID del encargado del almacén
  @Index()
  String? managerId;

  /// Indica si el almacén está activo
  late bool isActive;

  /// URL del código QR de pagos
  String? paymentQrUrl;

  /// Descripción asociada al QR
  String? paymentQrDescription;

  /// Fecha de creación
  late DateTime createdAt;

  /// Fecha de última actualización
  late DateTime updatedAt;

  /// Control de sincronización
  late bool pendingSync;

  /// Fecha de última sincronización
  DateTime? syncedAt;

  /// Constructor vacío requerido por Isar
  WarehouseLocalModel();

  /// Constructor desde entidad de dominio
  factory WarehouseLocalModel.fromEntity(Warehouse warehouse) {
    return WarehouseLocalModel()
      ..uuid = warehouse.id
      ..name = warehouse.name
      ..address = warehouse.address
      ..phone = warehouse.phone
      ..managerId = warehouse.managerId
      ..isActive = warehouse.isActive
      ..paymentQrUrl = warehouse.paymentQrUrl
      ..paymentQrDescription = warehouse.paymentQrDescription
      ..createdAt = warehouse.createdAt
      ..updatedAt = warehouse.updatedAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Constructor desde modelo remoto (para sincronización)
  factory WarehouseLocalModel.fromRemote({
    required String id,
    required String name,
    required String address,
    String? phone,
    String? managerId,
    required bool isActive,
    String? paymentQrUrl,
    String? paymentQrDescription,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return WarehouseLocalModel()
      ..uuid = id
      ..name = name
      ..address = address
      ..phone = phone
      ..managerId = managerId
      ..isActive = isActive
      ..paymentQrUrl = paymentQrUrl
      ..paymentQrDescription = paymentQrDescription
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Convertir a entidad de dominio
  Warehouse toEntity() {
    return Warehouse(
      id: uuid,
      name: name,
      address: address,
      phone: phone,
      managerId: managerId,
      isActive: isActive,
      paymentQrUrl: paymentQrUrl,
      paymentQrDescription: paymentQrDescription,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertir a JSON para sincronización
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'address': address,
      'phone': phone,
      'manager_id': managerId,
      'is_active': isActive,
      'payment_qr_url': paymentQrUrl,
      'payment_qr_description': paymentQrDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Marcar como pendiente de sincronización
  void markForSync() {
    pendingSync = true;
    updatedAt = DateTime.now();
  }

  /// Marcar como sincronizado
  void markAsSynced() {
    pendingSync = false;
    syncedAt = DateTime.now();
  }
}
