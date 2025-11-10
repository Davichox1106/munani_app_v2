import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../entities/warehouse.dart';

/// Repository interface for Location operations (Stores and Warehouses)
/// Implements offline-first strategy
abstract class LocationRepository {
  // ========== STORES ==========

  /// Get all stores
  Future<Either<Failure, List<Store>>> getAllStores();

  /// Get store by ID
  Future<Either<Failure, Store>> getStoreById(String id);

  /// Create new store
  Future<Either<Failure, Store>> createStore({
    required String name,
    required String address,
    String? phone,
    String? managerId,
    String? paymentQrUrl,
    String? paymentQrDescription,
  });

  /// Update existing store
  Future<Either<Failure, Store>> updateStore(Store store);

  /// Delete store
  Future<Either<Failure, void>> deleteStore(String id);

  /// Watch all stores (stream)
  Stream<List<Store>> watchAllStores();

  /// Search stores by name or address
  Future<Either<Failure, List<Store>>> searchStores(String query);

  // ========== WAREHOUSES ==========

  /// Get all warehouses
  Future<Either<Failure, List<Warehouse>>> getAllWarehouses();

  /// Get warehouse by ID
  Future<Either<Failure, Warehouse>> getWarehouseById(String id);

  /// Create new warehouse
  Future<Either<Failure, Warehouse>> createWarehouse({
    required String name,
    required String address,
    String? phone,
    String? managerId,
    String? paymentQrUrl,
    String? paymentQrDescription,
  });

  /// Update existing warehouse
  Future<Either<Failure, Warehouse>> updateWarehouse(Warehouse warehouse);

  /// Delete warehouse
  Future<Either<Failure, void>> deleteWarehouse(String id);

  /// Watch all warehouses (stream)
  Stream<List<Warehouse>> watchAllWarehouses();

  /// Search warehouses by name or address
  Future<Either<Failure, List<Warehouse>>> searchWarehouses(String query);

  // ========== SYNC ==========

  /// Sync stores from remote to local
  Future<Either<Failure, void>> syncStoresFromRemote();

  /// Sync warehouses from remote to local
  Future<Either<Failure, void>> syncWarehousesFromRemote();
}
