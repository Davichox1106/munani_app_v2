import 'package:equatable/equatable.dart';

/// Entidad de dominio para item en la cola de sincronización
///
/// Representa una operación pendiente de sincronizar con el backend.
/// Implementa patrón Queue para procesar operaciones en orden FIFO.
class SyncQueueItem extends Equatable {
  final String id; // UUID
  final SyncEntityType entityType; // Tipo de entidad (sale, purchase, product, etc.)
  final String entityId; // UUID de la entidad
  final SyncOperation operation; // create, update, delete
  final Map<String, dynamic> data; // Datos JSON de la operación
  final int attempts; // Número de intentos de sincronización
  final DateTime? lastAttempt; // Fecha del último intento
  final String? errorMessage; // Mensaje de error si falló
  final DateTime createdAt; // Fecha de creación del item
  final SyncPriority priority; // Prioridad de sincronización

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    this.attempts = 0,
    this.lastAttempt,
    this.errorMessage,
    required this.createdAt,
    this.priority = SyncPriority.normal,
  });

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        operation,
        data,
        attempts,
        lastAttempt,
        errorMessage,
        createdAt,
        priority,
      ];

  /// Copia del item con campos actualizados
  SyncQueueItem copyWith({
    String? id,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperation? operation,
    Map<String, dynamic>? data,
    int? attempts,
    DateTime? lastAttempt,
    String? errorMessage,
    DateTime? createdAt,
    SyncPriority? priority,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      attempts: attempts ?? this.attempts,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  /// Incrementar contador de intentos
  SyncQueueItem incrementAttempts({String? error}) {
    return copyWith(
      attempts: attempts + 1,
      lastAttempt: DateTime.now(),
      errorMessage: error,
    );
  }

  /// Verificar si debe reintentar (máximo 5 intentos)
  bool shouldRetry() {
    return attempts < 5;
  }

  /// Verificar si ha excedido el número de intentos
  bool get hasFailedPermanently => attempts >= 5;
}

/// Tipos de entidades que se pueden sincronizar
enum SyncEntityType {
  product,
  productVariant,
  sale,
  purchase,
  transfer,
  inventory,
  store,
  warehouse,
  user, // Gestión de usuarios
}

/// Operaciones de sincronización
enum SyncOperation {
  create,
  update,
  delete,
}

/// Prioridad de sincronización
enum SyncPriority {
  low,
  normal,
  high,
  critical,
}

/// Extensiones para convertir enums a String y viceversa
extension SyncEntityTypeExtension on SyncEntityType {
  String get value {
    return toString().split('.').last;
  }

  static SyncEntityType fromString(String value) {
    return SyncEntityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncEntityType.product,
    );
  }
}

extension SyncOperationExtension on SyncOperation {
  String get value {
    return toString().split('.').last;
  }

  static SyncOperation fromString(String value) {
    return SyncOperation.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncOperation.create,
    );
  }
}

extension SyncPriorityExtension on SyncPriority {
  String get value {
    return toString().split('.').last;
  }

  int get numericValue {
    switch (this) {
      case SyncPriority.critical:
        return 3;
      case SyncPriority.high:
        return 2;
      case SyncPriority.normal:
        return 1;
      case SyncPriority.low:
        return 0;
    }
  }

  static SyncPriority fromString(String value) {
    return SyncPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncPriority.normal,
    );
  }
}
