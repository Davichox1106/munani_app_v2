import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../sync/domain/entities/sync_queue_item.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_variant_repository.dart';
import '../datasources/product_variant_local_datasource.dart';
import '../datasources/product_variant_remote_datasource.dart';
import '../models/product_variant_local_model.dart';
import '../../../../core/utils/app_logger.dart';

/// Implementación del repositorio de variantes de productos
///
/// Implementa el patrón Offline-First:
/// - Escrituras: Guardar local primero, luego encolar para sincronización
/// - Lecturas: Leer de local, sincronizar en background
class ProductVariantRepositoryImpl implements ProductVariantRepository {
  final ProductVariantLocalDataSource localDataSource;
  final ProductVariantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncRepository syncRepository;

  ProductVariantRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncRepository,
  });

  @override
  Future<Either<Failure, List<ProductVariant>>> getAllVariants() async {
    try {
      // 1. Leer de local PRIMERO (Offline-First)
      final localVariants = await localDataSource.getAllVariants();
      final variants = localVariants.map((m) => m.toEntity()).toList();

      // 2. Sincronizar en background si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(variants);
    } on CacheException catch (e) {
      // Auto-recuperación: limpiar caché corrupta y reconstruir desde remoto si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await localDataSource.clearAllVariants();
          final remote = await remoteDataSource.getAllVariants();
          final locals = remote
              .map((r) => ProductVariantLocalModel.fromRemote(
                    id: r.id,
                    productId: r.productId,
                    sku: r.sku,
                    variantName: r.variantName,
                    variantAttributes: r.variantAttributes,
                    priceSell: r.priceSell,
                    priceBuy: r.priceBuy,
                    isActive: r.isActive,
                    createdAt: r.createdAt,
                  ))
              .toList();
          await localDataSource.saveVariants(locals);
          return Right(locals.map((m) => m.toEntity()).toList());
        } catch (rebuildError) {
          return Left(CacheFailure('Cache dañada (variantes). Intento de reconstrucción falló: $rebuildError'));
        }
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener variantes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductVariant>>> getVariantsByProduct(String productId) async {
    try {
      // 1. Leer de local PRIMERO (Offline-First)
      final localVariants = await localDataSource.getVariantsByProduct(productId);
      final variants = localVariants.map((m) => m.toEntity()).toList();

      // 2. Sincronizar en background si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(variants);
    } on CacheException catch (e) {
      if (await networkInfo.isConnected) {
        try {
          // Reconstruir solo las variantes desde remoto
          await localDataSource.clearAllVariants();
          final remote = await remoteDataSource.getAllVariants();
          final locals = remote
              .map((r) => ProductVariantLocalModel.fromRemote(
                    id: r.id,
                    productId: r.productId,
                    sku: r.sku,
                    variantName: r.variantName,
                    variantAttributes: r.variantAttributes,
                    priceSell: r.priceSell,
                    priceBuy: r.priceBuy,
                    isActive: r.isActive,
                    createdAt: r.createdAt,
                  ))
              .toList();
          await localDataSource.saveVariants(locals);
          final filtered = locals.where((m) => m.productId == productId).map((m) => m.toEntity()).toList();
          return Right(filtered);
        } catch (rebuildError) {
          return Left(CacheFailure('Cache dañada (variantes por producto). Intento de reconstrucción falló: $rebuildError'));
        }
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener variantes por producto: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductVariant>> getVariantById(String id) async {
    try {
      final localVariant = await localDataSource.getVariantById(id);
      if (localVariant == null) {
        return const Left(CacheFailure('Variante no encontrada'));
      }

      // Sincronizar en background si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(localVariant.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener variante: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductVariant>> createVariant({
    required String productId,
    required String sku,
    String? variantName,
    Map<String, dynamic>? variantAttributes,
    required double priceSell,
    required double priceBuy,
    required bool isActive,
  }) async {
    try {
      // Validaciones
      if (sku.trim().isEmpty) {
        return const Left(ValidationFailure('El SKU es requerido'));
      }

      if (priceSell < 0) {
        return const Left(ValidationFailure('El precio de venta debe ser mayor a 0'));
      }
      
      if (priceBuy < 0) {
        return const Left(ValidationFailure('El precio de compra debe ser mayor a 0'));
      }

      // Crear variante
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final variant = ProductVariant(
        id: uuid,
        productId: productId,
        sku: sku.trim(),
        variantName: variantName?.trim(),
        variantAttributes: variantAttributes,
        priceSell: priceSell,
        priceBuy: priceBuy,
        isActive: isActive,
        createdAt: now,
      );

      // 1. Guardar LOCAL primero (Offline-First)
      final localModel = ProductVariantLocalModel.fromEntity(variant);
      localModel.markForSync(); // Marcar para sincronización

      await localDataSource.saveVariant(localModel);

      AppLogger.info('✅ Variante creada localmente: ${variant.sku}');

      // 2. Agregar a cola de sincronización
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.productVariant,
        entityId: variant.id,
        operation: SyncOperation.create,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      // 3. Intentar sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(variant);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al crear variante: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductVariant>> updateVariant(ProductVariant variant) async {
    try {
      // 1. Guardar LOCAL primero (Offline-First)
      final localModel = ProductVariantLocalModel.fromEntity(variant);
      localModel.markForSync(); // Marcar para sincronización

      await localDataSource.updateVariant(localModel);

      AppLogger.info('✅ Variante actualizada localmente: ${variant.sku}');

      // 2. Agregar a cola de sincronización
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.productVariant,
        entityId: variant.id,
        operation: SyncOperation.update,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      // 3. Intentar sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(variant);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al actualizar variante: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVariant(String id) async {
    try {
      // 1. Eliminar LOCAL primero (Offline-First)
      await localDataSource.deleteVariant(id);

      AppLogger.info('✅ Variante eliminada localmente: $id');

      // 2. Agregar a cola de sincronización
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.productVariant,
        entityId: id,
        operation: SyncOperation.delete,
        data: {'id': id},
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      // 3. Intentar sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al eliminar variante: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncFromRemote() async {
    try {
      // Verificar conexión
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No hay conexión a internet'));
      }

      AppLogger.debug('🔍 ProductVariantRepository: Obteniendo variantes desde Supabase...');

      // Obtener variantes del servidor
      final remoteVariants = await remoteDataSource.getAllVariants();

      AppLogger.info('📥 ProductVariantRepository: Descargadas ${remoteVariants.length} variantes de Supabase');

      // Convertir a modelos locales
      final localModels = remoteVariants.map((remote) {
        return ProductVariantLocalModel.fromRemote(
          id: remote.id,
          productId: remote.productId,
          sku: remote.sku,
          variantName: remote.variantName,
          variantAttributes: remote.variantAttributes,
          priceSell: remote.priceSell,
          priceBuy: remote.priceBuy,
          isActive: remote.isActive,
          createdAt: remote.createdAt,
        );
      }).toList();

      // Guardar en local (recuperación si falla Isar)
      try {
        await localDataSource.saveVariants(localModels);
      } on CacheException {
        await localDataSource.clearAllVariants();
        await localDataSource.saveVariants(localModels);
      }

      AppLogger.info('✅ Sincronizadas ${localModels.length} variantes desde el servidor');

      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('❌ ProductVariantRepository: Error del servidor - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('❌ ProductVariantRepository: Error inesperado - $e');
      return Left(ServerFailure('Error al sincronizar variantes: $e'));
    }
  }

  @override
  Stream<List<ProductVariant>> watchAllVariants() {
    return localDataSource.watchAllVariants().map((models) {
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Stream<List<ProductVariant>> watchVariantsByProduct(String productId) {
    return localDataSource.watchVariantsByProduct(productId).map((models) {
      return models.map((m) => m.toEntity()).toList();
    });
  }

  /// Sincronizar en background (no bloquea la UI)
  void _syncInBackground() {
    // La sincronización se maneja por el SyncBloc
    // No implementar aquí para evitar duplicación
  }
}