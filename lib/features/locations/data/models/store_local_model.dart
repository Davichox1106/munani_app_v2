import 'package:isar/isar.dart';
import '../../domain/entities/store.dart';

part 'store_local_model.g.dart';

/// Modelo de Isar para Store (Base de datos local)
///
/// Almacena información de tiendas para acceso offline.
@collection
class StoreLocalModel {
  /// ID local de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  /// UUID de la tienda (sincronización con Supabase)
  @Index(unique: true)
  late String uuid;

  /// Nombre de la tienda
  @Index(type: IndexType.value)
  late String name;

  /// Dirección de la tienda
  late String address;

  /// Teléfono de contacto
  String? phone;

  /// UUID del encargado de la tienda
  @Index()
  String? managerId;

  /// Indica si la tienda está activa
  late bool isActive;

  /// URL del código QR de pagos
  String? paymentQrUrl;

  /// Descripción asociada al QR de pagos
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
  StoreLocalModel();

  /// Constructor desde entidad de dominio
  factory StoreLocalModel.fromEntity(Store store) {
    return StoreLocalModel()
      ..uuid = store.id
      ..name = store.name
      ..address = store.address
      ..phone = store.phone
      ..managerId = store.managerId
      ..isActive = store.isActive
      ..paymentQrUrl = store.paymentQrUrl
      ..paymentQrDescription = store.paymentQrDescription
      ..createdAt = store.createdAt
      ..updatedAt = store.updatedAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Constructor desde modelo remoto (para sincronización)
  factory StoreLocalModel.fromRemote({
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
    return StoreLocalModel()
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
  Store toEntity() {
    return Store(
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
