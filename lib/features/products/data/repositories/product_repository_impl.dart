import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../inventory/data/models/inventory_local_model.dart';
import '../../../products/data/models/product_variant_local_model.dart';
import '../../../sync/domain/entities/sync_queue_item.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_local_model.dart';

/// Implementación del repositorio de productos
///
/// Implementa el patrón Offline-First:
/// - Escrituras: Guardar local primero, luego encolar para sincronización
/// - Lecturas: Leer de local, sincronizar en background
///
/// OWASP A04:2021 - Insecure Design: Arquitectura Offline-First con validación
/// OWASP A08:2021 - Data Integrity: Control de versiones con timestamps
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncRepository syncRepository;
  final IsarDatabase isarDatabase;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncRepository,
    required this.isarDatabase,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      // 1. Leer de local PRIMERO (Offline-First)
      final localProducts = await localDataSource.getAllProducts();
      final products = localProducts.map((m) => m.toEntity()).toList();

      // 2. Sincronizar en background si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener productos: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final localProduct = await localDataSource.getProductByUuid(id);

      if (localProduct == null) {
        return const Left(CacheFailure('Producto no encontrado'));
      }

      return Right(localProduct.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener producto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(
      ProductCategory category) async {
    try {
      final localProducts = await localDataSource.getProductsByCategory(category);
      final products = localProducts.map((m) => m.toEntity()).toList();

      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener productos por categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final localProducts = await localDataSource.searchProducts(query);
      final products = localProducts.map((m) => m.toEntity()).toList();

      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al buscar productos: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String name,
    String? description,
    required ProductCategory category,
    required double basePriceSell,
    required double basePriceBuy,
    required bool hasVariants,
    required List<String> imageUrls,
    required String createdBy,
  }) async {
    try {
      // OWASP A03:2021 - Injection: Validación de entrada
      if (name.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre es requerido'));
      }

      if (basePriceSell < 0) {
        return const Left(ValidationFailure('El precio de venta debe ser mayor a 0'));
      }
      
      if (basePriceBuy < 0) {
        return const Left(ValidationFailure('El precio de compra debe ser mayor a 0'));
      }

      // Crear producto
      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final product = Product(
        id: uuid,
        name: name.trim(),
        description: description?.trim(),
        category: category,
        basePriceSell: basePriceSell,
        basePriceBuy: basePriceBuy,
        hasVariants: hasVariants,
        imageUrls: List<String>.from(imageUrls),
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
      );

      // 1. Guardar LOCAL primero (Offline-First)
      final localModel = ProductLocalModel.fromEntity(product);
      localModel.markForSync(); // Marcar para sincronización

      await localDataSource.saveProduct(localModel);

      AppLogger.info('✅ Producto creado localmente: ${product.name}');

      // 2. Agregar a cola de sincronización
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.product,
        entityId: product.id,
        operation: SyncOperation.create,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      // 3. Intentar sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      await _propagateProductImagesToInventory(product);

      return Right(product);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al crear producto: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      // OWASP A03:2021 - Injection: Validación
      if (product.name.trim().isEmpty) {
        return const Left(ValidationFailure('El nombre es requerido'));
      }

      if (product.basePriceSell < 0) {
        return const Left(ValidationFailure('El precio de venta debe ser mayor a 0'));
      }
      
      if (product.basePriceBuy < 0) {
        return const Left(ValidationFailure('El precio de compra debe ser mayor a 0'));
      }

      // Actualizar timestamp
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      // 1. Guardar LOCAL primero
      final localModel = ProductLocalModel.fromEntity(updatedProduct);
      localModel.markForSync();

      await localDataSource.saveProduct(localModel);

      AppLogger.info('✅ Producto actualizado localmente: ${product.name}');

      // 2. Agregar a cola de sincronización
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.product,
        entityId: product.id,
        operation: SyncOperation.update,
        data: localModel.toJson(),
        createdAt: DateTime.now(),
      );

      await syncRepository.addToQueue(syncItem);

      // 3. Intentar sincronizar si hay conexión
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      await _propagateProductImagesToInventory(updatedProduct);

      return Right(updatedProduct);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al actualizar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      // 1. Eliminar LOCAL primero
      await localDataSource.deleteProduct(id);

      AppLogger.info('✅ Producto eliminado localmente: $id');

      // 2. Agregar a cola de sincronización
      final syncItem = SyncQueueItem(
        id: const Uuid().v4(),
        entityType: SyncEntityType.product,
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
      return Left(CacheFailure('Error al eliminar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncFromRemote() async {
    try {
      // Verificar conexión
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No hay conexión a internet'));
      }

      // Obtener productos del servidor
      final remoteProducts = await remoteDataSource.getAllProducts();

      // Convertir a modelos locales
      final localModels = remoteProducts.map((remote) {
        return ProductLocalModel.fromRemote(
          id: remote.id,
          name: remote.name,
          description: remote.description,
          category: _stringToCategory(remote.category),
          basePriceSell: remote.basePriceSell,
          basePriceBuy: remote.basePriceBuy,
          hasVariants: remote.hasVariants,
          imageUrls: remote.imageUrls,
          createdBy: remote.createdBy,
          createdAt: remote.createdAt,
          updatedAt: remote.updatedAt,
        );
      }).toList();

      // Guardar en local
      await localDataSource.saveProducts(localModels);

      AppLogger.info('✅ Sincronizados ${localModels.length} productos desde el servidor');

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al sincronizar: $e'));
    }
  }

  @override
  Stream<List<Product>> watchAllProducts() {
    return localDataSource.watchAllProducts().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Stream<List<Product>> watchProductsByCategory(ProductCategory category) {
    return localDataSource.watchProductsByCategory(category).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  Future<void> _propagateProductImagesToInventory(Product product) async {
    try {
      final isar = await isarDatabase.database;
      final variants = await isar.productVariantLocalModels
          .filter()
          .productIdEqualTo(product.id)
          .findAll();

      if (variants.isEmpty) {
        return;
      }

      final now = DateTime.now();
      final queuePayloads = <Map<String, dynamic>>[];

      await isar.writeTxn(() async {
        for (final variant in variants) {
          final inventories = await isar.inventoryLocalModels
              .filter()
              .productVariantIdEqualTo(variant.uuid)
              .findAll();

          for (final inventory in inventories) {
            inventory
              ..imageUrls = List<String>.from(product.imageUrls)
              ..needsSync = true
              ..lastUpdated = now
              ..lastSyncedAt = null;

            await isar.inventoryLocalModels.put(inventory);
            queuePayloads.add(inventory.toJson());
          }
        }
      });

      if (queuePayloads.isEmpty) {
        return;
      }

      final uuid = const Uuid();
      for (final payload in queuePayloads) {
        final result = await syncRepository.addToQueue(
          SyncQueueItem(
            id: uuid.v4(),
            entityType: SyncEntityType.inventory,
            entityId: payload['id'] as String,
            operation: SyncOperation.update,
            data: payload,
            createdAt: DateTime.now(),
          ),
        );
        result.fold(
          (failure) => AppLogger.error(
            '❌ No se pudo encolar inventario para sincronización: ${failure.message}',
          ),
          (_) {},
        );
      }

      AppLogger.info(
        '🔁 Propagadas imágenes de producto "${product.name}" a ${queuePayloads.length} registros de inventario.',
      );
    } catch (e) {
      AppLogger.error('❌ No se pudieron propagar imágenes de producto a inventario: $e');
    }
  }

  /// Sincroniza en background (fire and forget)
  void _syncInBackground() {
    syncRepository.syncAll().then((result) {
      result.fold(
        (failure) => AppLogger.error('⚠️ Error en sincronización background: ${failure.message}'),
        (count) => AppLogger.info('✅ $count items sincronizados en background'),
      );
    });
  }

  /// Convierte string a ProductCategory
  ProductCategory _stringToCategory(String category) {
    return ProductCategory.values.firstWhere(
      (c) => c.value == category,
      orElse: () => ProductCategory.otros,
    );
  }
}
