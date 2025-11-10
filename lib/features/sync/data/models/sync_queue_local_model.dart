import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/sync_queue_item.dart';

part 'sync_queue_local_model.g.dart';

/// Modelo de Isar para cola de sincronización
///
/// Almacena operaciones pendientes de sincronizar con Supabase.
/// Implementa patrón Queue con reintentos y prioridades.
@collection
class SyncQueueLocalModel {
  /// ID local de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  /// UUID del item de sincronización
  @Index(unique: true)
  late String uuid;

  /// Tipo de entidad (product, sale, purchase, etc.)
  @Enumerated(EnumType.name)
  late SyncEntityType entityType;

  /// UUID de la entidad
  @Index()
  late String entityId;

  /// Operación a realizar (create, update, delete)
  @Enumerated(EnumType.name)
  late SyncOperation operation;

  /// Datos de la operación en formato JSON string
  late String dataJson;

  /// Número de intentos de sincronización
  late int attempts;

  /// Fecha del último intento
  DateTime? lastAttempt;

  /// Mensaje de error si falló
  String? errorMessage;

  /// Fecha de creación del item
  @Index()
  late DateTime createdAt;

  /// Prioridad de sincronización (mayor = más prioritario)
  @Enumerated(EnumType.name)
  late SyncPriority priority;

  /// Constructor vacío requerido por Isar
  SyncQueueLocalModel();

  /// Constructor desde entidad de dominio
  factory SyncQueueLocalModel.fromEntity(SyncQueueItem item) {
    return SyncQueueLocalModel()
      ..uuid = item.id
      ..entityType = item.entityType
      ..entityId = item.entityId
      ..operation = item.operation
      ..dataJson = jsonEncode(item.data)
      ..attempts = item.attempts
      ..lastAttempt = item.lastAttempt
      ..errorMessage = item.errorMessage
      ..createdAt = item.createdAt
      ..priority = item.priority;
  }

  /// Convertir a entidad de dominio
  SyncQueueItem toEntity() {
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(dataJson) as Map<String, dynamic>;
    } catch (e) {
      // Si hay error al decodificar, devolver mapa vacío
      data = {};
    }

    return SyncQueueItem(
      id: uuid,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      attempts: attempts,
      lastAttempt: lastAttempt,
      errorMessage: errorMessage,
      createdAt: createdAt,
      priority: priority,
    );
  }

  /// Incrementar contador de intentos
  void incrementAttempts({String? error}) {
    attempts++;
    lastAttempt = DateTime.now();
    if (error != null) {
      errorMessage = error;
    }
  }

  /// Verificar si debe reintentar
  bool shouldRetry() {
    return attempts < 5;
  }

  /// Verificar si ha excedido intentos
  bool get hasFailedPermanently => attempts >= 5;
}
