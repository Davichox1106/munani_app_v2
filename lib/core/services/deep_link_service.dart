import 'package:flutter/material.dart';

/// Servicio para manejar deep links de la aplicación
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  /// Manejar deep link de recuperación de contraseña
  static void handlePasswordResetLink(
    BuildContext context,
    String url,
  ) {
    try {
      // Parsear la URL para extraer parámetros
      final uri = Uri.parse(url);
      
      // Verificar si es un enlace de recuperación de contraseña
      if (uri.scheme == 'com.munani.app' &&
          uri.host == 'login-callback') {
        
        // Extraer tokens de la URL
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];
        final type = uri.queryParameters['type'];
        
        if (type == 'recovery' && accessToken != null) {
          // Navegar a la página de restablecer contraseña
          Navigator.of(context).pushNamed(
            '/reset-password',
            arguments: {
              'access_token': accessToken,
              'refresh_token': refreshToken ?? '',
            },
          );
        } else {
          // Enlace inválido
          _showErrorDialog(context, 'Enlace de recuperación inválido');
        }
      } else {
        // Enlace no reconocido
        _showErrorDialog(context, 'Enlace no válido');
      }
    } catch (e) {
      // Error al procesar el enlace
      _showErrorDialog(context, 'Error al procesar el enlace: $e');
    }
  }

  /// Mostrar diálogo de error
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Manejar cualquier deep link
  static void handleDeepLink(BuildContext context, String url) {
    if (url.contains('login-callback')) {
      handlePasswordResetLink(context, url);
    } else {
      // Otros tipos de deep links
      _showErrorDialog(context, 'Enlace no soportado');
    }
  }
}
