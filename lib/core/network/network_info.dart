import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../core/utils/app_logger.dart';

/// Interfaz para verificar el estado de la red
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementación de NetworkInfo usando connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final InternetConnection internetConnection;

  NetworkInfoImpl({
    required this.connectivity,
    required this.internetConnection,
  });

  @override
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      // Si no hay conectividad, retornar false
      if (connectivityResult.contains(ConnectivityResult.none)) {
        AppLogger.debug('🔍 NetworkInfo: No hay conectividad');
        return false;
      }

      AppLogger.debug('🔍 NetworkInfo: Conectividad detectada: $connectivityResult');
      
      // Para desarrollo, ser más permisivo con la verificación de internet
      // En producción, descomenta la línea siguiente:
      // return await internetConnection.hasInternetAccess;
      
      // Para desarrollo: asumir que hay internet si hay conectividad
      return true;
    } catch (e) {
      AppLogger.error('⚠️ NetworkInfo: Error verificando conectividad: $e');
      // En caso de error, asumir que hay conexión para desarrollo
      return true;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return internetConnection.onStatusChange.map((status) {
      return status == InternetStatus.connected;
    });
  }
}
