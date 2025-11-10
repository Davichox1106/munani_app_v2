import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_item.dart';

/// Interfaz del repositorio de Inventory
///
/// Define el contrato para operaciones de inventario
/// Implementación en data layer (Offline-First)
abstract class InventoryRepository {
  /// Obtener todo el inventario (stream para actualizaciones en tiempo real)
  Stream<Either<Failure, List<InventoryItem>>> getAllInventory();

  /// Obtener inventario de una ubicación específica
  Stream<Either<Failure, List<InventoryItem>>> getInventoryByLocation({
    required String locationId,
    required String locationType,
  });

  /// Obtener inventario por tipo de ubicación (store/warehouse)
  Future<Either<Failure, List<InventoryItem>>> getInventoryByLocationType(
    String locationType,
  );

  /// Obtener inventario con stock bajo (alertas)
  Stream<Either<Failure, List<InventoryItem>>> getLowStockInventory();

  /// Obtener un ítem específico de inventario
  Future<Either<Failure, InventoryItem>> getInventoryItem(String id);

  /// Obtener inventario por variante de producto
  Future<Either<Failure, List<InventoryItem>>> getInventoryByVariant(
    String productVariantId,
  );

  /// Crear nuevo ítem de inventario
  Future<Either<Failure, InventoryItem>> createInventoryItem({
    required String productVariantId,
    required String locationId,
    required String locationType,
    required int quantity,
    required int minStock,
    required int maxStock,
    required String updatedBy,
    String? productName,
    String? variantName,
    String? locationName,
  });

  /// Actualizar cantidad de inventario
  Future<Either<Failure, InventoryItem>> updateInventoryQuantity({
    required String id,
    required int newQuantity,
    required String updatedBy,
  });

  /// Actualizar configuración de stock (min/max)
  Future<Either<Failure, InventoryItem>> updateStockLevels({
    required String id,
    required int minStock,
    required int maxStock,
    required String updatedBy,
  });

  /// Eliminar ítem de inventario
  Future<Either<Failure, void>> deleteInventoryItem(String id);

  /// Ajustar inventario (incrementar/decrementar)
  /// delta puede ser positivo (aumentar) o negativo (disminuir)
  Future<Either<Failure, InventoryItem>> adjustInventory({
    required String id,
    required int delta,
    required String updatedBy,
  });

  /// Buscar inventario por nombre de producto, variante o ubicación
  Future<Either<Failure, List<InventoryItem>>> searchInventory(String query);

  /// Sincronizar inventarios desde Supabase a Isar (descarga)
  Future<Either<Failure, void>> syncFromRemote();
}
