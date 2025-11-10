/// Excepciones de la capa de datos
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error del servidor']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Error de caché']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Error de red']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Error de autenticación']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Error de validación']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'No encontrado']);
}

class SyncException implements Exception {
  final String message;
  SyncException([this.message = 'Error de sincronización']);
}
