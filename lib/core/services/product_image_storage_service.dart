import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_logger.dart';

class ProductImageStorageException implements Exception {
  final String message;
  final Object? cause;

  ProductImageStorageException(this.message, [this.cause]);

  @override
  String toString() => 'ProductImageStorageException: $message${cause != null ? ' - $cause' : ''}';
}

class ProductImageStorageService {
  ProductImageStorageService({
    required SupabaseClient supabaseClient,
    Uuid? uuid,
  })  : _supabaseClient = supabaseClient,
        _uuid = uuid ?? const Uuid();

  final SupabaseClient _supabaseClient;
  final Uuid _uuid;

  static const String _bucketName = 'product-images';

  Future<String> uploadProductImage(
    File file, {
    String? productId,
  }) async {
    if (!file.existsSync()) {
      throw ProductImageStorageException('El archivo seleccionado no existe.');
    }

    try {
      final storage = _supabaseClient.storage.from(_bucketName);
      final extension = _normalizeExtension(p.extension(file.path));
      final contentType = _inferContentType(extension);
      final folder = productId != null && productId.trim().isNotEmpty ? productId.trim() : _uuid.v4();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$extension';
      final storagePath = '$folder/$fileName';

      AppLogger.debug('📤 Subiendo imagen de producto: bucket=$_bucketName path=$storagePath');

      await storage.upload(
        storagePath,
        file,
        fileOptions: FileOptions(
          upsert: true,
          contentType: contentType,
        ),
      );

      final signedUrl = await storage.createSignedUrl(
        storagePath,
        60 * 60 * 24 * 365,
      );

      AppLogger.debug('✅ Imagen de producto subida correctamente.');

      return signedUrl;
    } on StorageException catch (e) {
      AppLogger.error('❌ Error subiendo imagen de producto: ${e.message}');
      throw ProductImageStorageException('No se pudo subir la imagen a Supabase.', e);
    } catch (e) {
      AppLogger.error('❌ Error inesperado subiendo imagen de producto: $e');
      throw ProductImageStorageException('Error inesperado al subir la imagen.', e);
    }
  }

  Future<String> ensureSignedUrl(String url) async {
    if (url.trim().isEmpty) return url;

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
      AppLogger.error('❌ No se pudo regenerar URL de imagen de producto: $e');
      AppLogger.debug('   URL original: $url');
      AppLogger.debug('   Ruta derivada: $path');
      return url;
    }
  }

  String normalizeReference(String value) {
    return _extractStoragePath(value) ?? value;
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

  String? _extractStoragePath(String url) {
    const marker = '/object/';
    final index = url.indexOf(marker);
    String raw = url;
    if (index != -1) {
      raw = url.substring(index + marker.length);
    }

    var path = raw;

    final queryIndex = path.indexOf('?');
    if (queryIndex != -1) {
      path = path.substring(0, queryIndex);
    }

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
}


