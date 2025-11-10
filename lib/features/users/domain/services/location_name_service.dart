import '../../../locations/domain/repositories/location_repository.dart';
import 'dart:async';
import '../../../../core/utils/app_logger.dart';

/// Servicio para obtener nombres de ubicaciones
class LocationNameService {
  final LocationRepository locationRepository;
  
  // Cache de ubicaciones
  Map<String, String> _storeNames = {};
  Map<String, String> _warehouseNames = {};
  bool _isInitialized = false;

  LocationNameService({
    required this.locationRepository,
  });

  /// Inicializar el servicio cargando todas las ubicaciones
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Cargar tiendas
      final storesResult = await locationRepository.getAllStores();
      storesResult.fold(
        (failure) => AppLogger.error('❌ Error cargando tiendas: ${failure.message}'),
        (stores) {
          _storeNames = {for (var store in stores) store.id: store.name};
          AppLogger.info('✅ Cargadas ${stores.length} tiendas');
        },
      );

      // Cargar almacenes
      final warehousesResult = await locationRepository.getAllWarehouses();
      warehousesResult.fold(
        (failure) => AppLogger.error('❌ Error cargando almacenes: ${failure.message}'),
        (warehouses) {
          _warehouseNames = {for (var warehouse in warehouses) warehouse.id: warehouse.name};
          AppLogger.info('✅ Cargados ${warehouses.length} almacenes');
        },
      );

      _isInitialized = true;
    } catch (e) {
      AppLogger.error('❌ Error inicializando LocationNameService: $e');
    }
  }

  /// Obtener nombre de ubicación por ID y tipo
  String? getLocationName(String? locationId, String? locationType) {
    AppLogger.debug('🔍 LocationNameService.getLocationName():');
    AppLogger.debug('   locationId: $locationId');
    AppLogger.debug('   locationType: $locationType');
    AppLogger.debug('   isInitialized: $_isInitialized');
    AppLogger.debug('   storeNames count: ${_storeNames.length}');
    AppLogger.debug('   warehouseNames count: ${_warehouseNames.length}');
    
    if (locationId == null || locationType == null) {
      AppLogger.error('❌ LocationId o locationType es null');
      return null;
    }
    
    if (locationType == 'store') {
      final name = _storeNames[locationId];
      AppLogger.debug('🔍 Buscando tienda $locationId: $name');
      return name;
    } else if (locationType == 'warehouse') {
      final name = _warehouseNames[locationId];
      AppLogger.debug('🔍 Buscando almacén $locationId: $name');
      return name;
    }
    
    AppLogger.error('❌ Tipo de ubicación no reconocido: $locationType');
    return null;
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _isInitialized;
}
