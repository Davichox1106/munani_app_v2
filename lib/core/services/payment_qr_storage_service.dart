import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_logger.dart';

/// Tipos de ubicación válidos para almacenar QR de pagos.
enum PaymentQrLocationType { store, warehouse }

extension PaymentQrLocationTypeX on PaymentQrLocationType {
  String get storageFolder {
    switch (this) {
      case PaymentQrLocationType.store:
        return 'stores';
      case PaymentQrLocationType.warehouse:
        return 'warehouses';
    }
  }
}

/// Excepción específica para errores al subir QR de pago.
class PaymentQrStorageException implements Exception {
  final String message;
  final Object? cause;

  PaymentQrStorageException(this.message, [this.cause]);

  @override
  String toString() => 'PaymentQrStorageException: $message${cause != null ? ' - $cause' : ''}';
}

/// Servicio encargado de subir imágenes de QR de pago a Supabase Storage.
class PaymentQrStorageService {
  PaymentQrStorageService({
    required SupabaseClient supabaseClient,
    Uuid? uuid,
  })  : _supabaseClient = supabaseClient,
        _uuid = uuid ?? const Uuid();

  final SupabaseClient _supabaseClient;
  final Uuid _uuid;

  static const String _bucketName = 'payment-qr';

  /// Sube una imagen a Supabase Storage y devuelve la URL pública.
  ///
  /// [file] Debe existir y ser una imagen válida.
  /// [locationType] define la carpeta (`stores/` o `warehouses/`).
  /// [existingLocationId] permite reutilizar el ID de una tienda/almacén ya creado.
  Future<String> uploadPaymentQrImage(
    File file, {
    required PaymentQrLocationType locationType,
    String? existingLocationId,
  }) async {
    if (!file.existsSync()) {
      throw PaymentQrStorageException('El archivo seleccionado no existe.');
    }

    try {
      final storage = _supabaseClient.storage.from(_bucketName);
      final extension = _normalizeExtension(p.extension(file.path));
      final contentType = _inferContentType(extension);
      final locationId = existingLocationId?.trim().isNotEmpty == true ? existingLocationId!.trim() : _uuid.v4();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$locationId$extension';
      final storagePath = '${locationType.storageFolder}/$fileName';

      AppLogger.debug('📤 Subiendo QR a Supabase: bucket=$_bucketName path=$storagePath');

      await storage.upload(
        storagePath,
        file,
        fileOptions: FileOptions(
          upsert: true,
          contentType: contentType,
        ),
      );

      AppLogger.debug('✅ QR subido. Ruta almacenada: $storagePath');

      return storagePath;
    } on StorageException catch (e) {
      AppLogger.error('❌ Error subiendo QR a Supabase: ${e.message}');
      throw PaymentQrStorageException('No se pudo subir la imagen a Supabase.', e);
    } catch (e) {
      AppLogger.error('❌ Error inesperado subiendo QR: $e');
      throw PaymentQrStorageException('Error inesperado al subir la imagen.', e);
    }
  }

  String _normalizeExtension(String extension) {
    if (extension.isEmpty) {
      return '.png';
    }

    return extension.toLowerCase();
  }

  String _inferContentType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/png';
    }
  }

  Future<String?> ensureSignedUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return url;

    // Si ya es una URL firmada, refrescarla por si está próxima a expirar
    final path = _extractStoragePath(url);
    if (path == null) {
      return url;
    }

    try {
      final storage = _supabaseClient.storage.from(_bucketName);
      final signedUrl = await storage.createSignedUrl(
        path,
        60 * 60 * 24 * 365,
      );
      return signedUrl;
    } catch (e) {
      AppLogger.error('❌ No se pudo generar URL firmada: $e');
      AppLogger.debug('   URL original: $url');
      AppLogger.debug('   Ruta derivada: $path');
      return url;
    }
  }

  String? _extractStoragePath(String url) {
    const marker = '/object/';
    final index = url.indexOf(marker);
    String raw = url;
    if (index != -1) {
      raw = url.substring(index + marker.length);
    }

    var path = raw;

    // Eliminar query params si existen
    final queryIndex = path.indexOf('?');
    if (queryIndex != -1) {
      path = path.substring(0, queryIndex);
    }

    // Quitar slash inicial si existe
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (path.startsWith('public/')) {
      path = path.substring('public/'.length);
    } else if (path.startsWith('sign/')) {
      final parts = path.split('/');
      if (parts.length >= 2) {
        path = parts.sublist(1).join('/');
      } else {
        return null;
      }
    }

    if (path.startsWith('$_bucketName/')) {
      path = path.substring('$_bucketName/'.length);
    }

    return Uri.decodeComponent(path);
  }

  String normalizeReference(String value) {
    return _extractStoragePath(value) ?? value;
  }
}
