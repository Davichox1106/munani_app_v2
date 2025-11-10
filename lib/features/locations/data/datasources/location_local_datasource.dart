import '../models/store_local_model.dart';
import '../models/warehouse_local_model.dart';
import 'store_local_datasource.dart';
import 'warehouse_local_datasource.dart';

/// Local datasource that combines stores and warehouses for unified location access
abstract class LocationLocalDataSource {
  Future<StoreLocalModel?> getStoreById(String id);
  Future<WarehouseLocalModel?> getWarehouseById(String id);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final StoreLocalDataSource storeLocalDataSource;
  final WarehouseLocalDataSource warehouseLocalDataSource;

  LocationLocalDataSourceImpl({
    required this.storeLocalDataSource,
    required this.warehouseLocalDataSource,
  });

  @override
  Future<StoreLocalModel?> getStoreById(String id) async {
    return await storeLocalDataSource.getStoreByUuid(id);
  }

  @override
  Future<WarehouseLocalModel?> getWarehouseById(String id) async {
    return await warehouseLocalDataSource.getWarehouseByUuid(id);
  }
}






