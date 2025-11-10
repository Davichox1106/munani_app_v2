import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/isar_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/inputs/cart_add_item_params.dart';
import '../models/cart_remote_model.dart';
import '../models/cart_item_local_model.dart';
import '../models/cart_local_model.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../customers/data/models/customer_remote_model.dart';

class CartRepositoryImpl implements CartRepository {
  static const _paymentReceiptsBucket = 'payment_receipts';

  final IsarDatabase isarDatabase;
  final NetworkInfo networkInfo;
  final SyncRepository syncRepository;
  final SupabaseClient supabaseClient;
  final CustomerRepository customerRepository;

  CartRepositoryImpl({
    required this.isarDatabase,
    required this.networkInfo,
    required this.syncRepository,
    required this.supabaseClient,
    required this.customerRepository,
  });

  @override
  Stream<Either<Failure, Cart?>> watchActiveCart({
    required String customerId,
  }) async* {
    final isar = await isarDatabase.database;
    final query = isar.cartLocalModels
        .filter()
        .customerIdEqualTo(customerId)
        .statusEqualTo(CartStatus.pending.value);

    yield* query.watch(fireImmediately: true).asyncMap((models) async {
      try {
        if (models.isEmpty) {
          return const Right<Failure, Cart?>(null);
        }
        final cartModel = models.first;
        final items = await isar.cartItemLocalModels
            .filter()
            .cartIdEqualTo(cartModel.uuid)
            .findAll();
        return Right(_mapToEntity(cartModel, items));
      } catch (e) {
        return Left(CacheFailure('Error al observar carrito: $e'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<Cart>>> watchCustomerCartHistory({
    required String customerId,
    List<CartStatus>? statuses,
  }) async* {
    final isarFuture = isarDatabase.database;
    final allowedStatuses = (statuses ?? CartStatus.values.where((s) => s != CartStatus.pending))
        .map((status) => status.value)
        .toSet();

    final query = (await isarFuture)
        .cartLocalModels
        .filter()
        .customerIdEqualTo(customerId);

    yield* query.watch(fireImmediately: true).asyncMap((models) async {
      try {
        final isarInstance = await isarFuture;
        final filtered = models
            .where((model) => allowedStatuses.contains(model.status))
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        final carts = <Cart>[];
        for (final cartModel in filtered) {
          final items = await isarInstance.cartItemLocalModels
              .filter()
              .cartIdEqualTo(cartModel.uuid)
              .findAll();
          carts.add(_mapToEntity(cartModel, items));
        }

        return Right<Failure, List<Cart>>(carts);
      } catch (e) {
        return Left(CacheFailure('Error al observar historial de carritos: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, Cart>> addItem({
    required String customerId,
    required CartAddItemParams item,
    required int quantity,
  }) async {
    final now = DateTime.now();

    final cartResult = await _addItemInternal(
      customerId: customerId,
      item: item,
      quantity: quantity,
      now: now,
      isSync: false,
    );

    return cartResult;
  }

  @override
  Future<Either<Failure, Cart>> updateItemQuantity({
    required String customerId,
    required String cartItemId,
    required int quantity,
    required int availableQuantity,
  }) async {
    final now = DateTime.now();

    final result = await _updateItemQuantityInternal(
      customerId: customerId,
      cartItemId: cartItemId,
      quantity: quantity,
      availableQuantity: availableQuantity,
      now: now,
      isSync: false,
    );

    return result;
  }

  @override
  Future<Either<Failure, Cart>> removeItem({
    required String customerId,
    required String cartItemId,
  }) async {
    final now = DateTime.now();

    final result = await _removeItemInternal(
      customerId: customerId,
      cartItemId: cartItemId,
      now: now,
      isSync: false,
    );

    return result;
  }

  @override
  Future<Either<Failure, Cart>> clearCart({
    required String customerId,
  }) async {
    final now = DateTime.now();

    final result = await _clearCartInternal(
      customerId: customerId,
      now: now,
      isSync: false,
    );

    return result;
  }
  Future<Either<Failure, Cart>> _addItemInternal({
    required String customerId,
    required CartAddItemParams item,
    required int quantity,
    required DateTime now,
    bool isSync = false,
  }) async {
    final isar = await isarDatabase.database;
    String? cartIdForSync;

    try {
      Cart? result;
      await isar.writeTxn(() async {
        final cartModel = await _getOrCreateCart(
          isar: isar,
          customerId: customerId,
          now: now,
          item: item,
        );

        final existingItem = await isar.cartItemLocalModels
            .filter()
            .cartIdEqualTo(cartModel.uuid)
            .inventoryIdEqualTo(item.inventoryId)
            .findFirst();

        final maxQuantity = item.availableQuantity;
        final initialQuantity = existingItem?.quantity ?? 0;
        var updatedQuantity = initialQuantity + quantity;

        if (!isSync) {
          if (updatedQuantity <= 0) {
            throw ValidationException('La cantidad debe ser mayor a cero');
          }

          if (updatedQuantity > maxQuantity) {
            updatedQuantity = maxQuantity;
            if (initialQuantity == maxQuantity) {
              throw ValidationException(
                  'No hay más stock disponible para este producto');
            }
          }
        }

        final cartItem = existingItem ?? CartItemLocalModel()
          ..uuid = const Uuid().v4()
          ..cartId = cartModel.uuid
          ..inventoryId = item.inventoryId
          ..productVariantId = item.productVariantId
          ..productName = item.productName
          ..variantName = item.variantName
          ..imageUrls = List<String>.from(item.imageUrls)
          ..availableQuantity = item.availableQuantity
          ..unitPrice = item.unitPrice
          ..createdAt = now;

        cartItem
          ..quantity = updatedQuantity
          ..availableQuantity = item.availableQuantity
          ..subtotal = cartItem.unitPrice * updatedQuantity
          ..updatedAt = now;

        await isar.cartItemLocalModels.put(cartItem);

        await _recalculateCart(isar: isar, cart: cartModel, now: now);
        final items = await isar.cartItemLocalModels
            .filter()
            .cartIdEqualTo(cartModel.uuid)
            .findAll();
        result = _mapToEntity(cartModel, items);
        cartIdForSync = cartModel.uuid;
      });

      if (!isSync && cartIdForSync != null) {
        await _syncCartIfPossible(cartIdForSync!);
      }

      return Right(result!);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al agregar al carrito: $e'));
    }
  }

  Future<Either<Failure, Cart>> _updateItemQuantityInternal({
    required String customerId,
    required String cartItemId,
    required int quantity,
    required int availableQuantity,
    required DateTime now,
    bool isSync = false,
  }) async {
    final isar = await isarDatabase.database;
    String? cartIdForSync;

    try {
      Cart? result;
      await isar.writeTxn(() async {
        final cartModel = await isar.cartLocalModels
            .filter()
            .customerIdEqualTo(customerId)
            .statusEqualTo(CartStatus.pending.value)
            .findFirst();

        if (cartModel == null) {
          throw ValidationException('No hay un carrito activo');
        }

        final cartItem = await isar.cartItemLocalModels
            .filter()
            .uuidEqualTo(cartItemId)
            .findFirst();

        if (cartItem == null) {
          throw ValidationException('El producto no existe en el carrito');
        }

        if (!isSync) {
          if (quantity <= 0) {
            throw ValidationException('La cantidad debe ser mayor a cero');
          }

          if (quantity > availableQuantity) {
            throw ValidationException(
                'No puedes agregar más de la cantidad disponible');
          }
        }

        cartItem
          ..quantity = quantity
          ..availableQuantity = availableQuantity
          ..subtotal = cartItem.unitPrice * quantity
          ..updatedAt = now;

        await isar.cartItemLocalModels.put(cartItem);
        await _recalculateCart(isar: isar, cart: cartModel, now: now);

        final items = await isar.cartItemLocalModels
            .filter()
            .cartIdEqualTo(cartModel.uuid)
            .findAll();
        result = _mapToEntity(cartModel, items);
        cartIdForSync = cartModel.uuid;
      });

      if (!isSync && cartIdForSync != null) {
        await _syncCartIfPossible(cartIdForSync!);
      }

      return Right(result!);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al actualizar el carrito: $e'));
    }
  }

  Future<Either<Failure, Cart>> _removeItemInternal({
    required String customerId,
    required String cartItemId,
    required DateTime now,
    bool isSync = false,
  }) async {
    final isar = await isarDatabase.database;
    String? cartIdForSync;

    try {
      Cart? result;
      await isar.writeTxn(() async {
        final cartModel = await isar.cartLocalModels
            .filter()
            .customerIdEqualTo(customerId)
            .statusEqualTo(CartStatus.pending.value)
            .findFirst();

        if (cartModel == null) {
          throw ValidationException('No hay un carrito activo');
        }

        final deleted = await isar.cartItemLocalModels
            .filter()
            .uuidEqualTo(cartItemId)
            .deleteFirst();

        if (!deleted && !isSync) {
          throw ValidationException('El producto no existe en el carrito');
        }

        await _recalculateCart(isar: isar, cart: cartModel, now: now);

        final items = await isar.cartItemLocalModels
            .filter()
            .cartIdEqualTo(cartModel.uuid)
            .findAll();

        result = _mapToEntity(cartModel, items);
        cartIdForSync = cartModel.uuid;
      });

      if (!isSync && cartIdForSync != null) {
        await _syncCartIfPossible(cartIdForSync!);
      }

      return Right(result!);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al eliminar del carrito: $e'));
    }
  }

  Future<Either<Failure, Cart>> _clearCartInternal({
    required String customerId,
    required DateTime now,
    bool isSync = false,
  }) async {
    final isar = await isarDatabase.database;
    String? cartIdForSync;

    try {
      Cart? result;
      await isar.writeTxn(() async {
        final cartModel = await isar.cartLocalModels
            .filter()
            .customerIdEqualTo(customerId)
            .statusEqualTo(CartStatus.pending.value)
            .findFirst();

        if (cartModel == null) {
          throw ValidationException('No hay un carrito activo');
        }

        final items = await isar.cartItemLocalModels
            .filter()
            .cartIdEqualTo(cartModel.uuid)
            .findAll();

        for (final item in items) {
          await isar.cartItemLocalModels.delete(item.id);
        }

        cartModel
          ..totalItems = 0
          ..subtotal = 0
          ..locationId = null
          ..locationType = null
          ..locationName = null
          ..updatedAt = now
          ..needsSync = true
          ..pendingDelete = false;

        await isar.cartLocalModels.put(cartModel);
        result = _mapToEntity(cartModel, const []);
        cartIdForSync = cartModel.uuid;
      });

      if (!isSync && cartIdForSync != null) {
        await _syncCartIfPossible(cartIdForSync!);
      }

      return Right(result!);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al limpiar el carrito: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateStatus({
    required String customerId,
    required String cartId,
    required CartStatus status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'Necesitas conexión a internet para actualizar el estado del pedido',
      ));
    }

    final isar = await isarDatabase.database;
    final cartModel = await isar.cartLocalModels
        .filter()
        .uuidEqualTo(cartId)
        .findFirst();

    if (cartModel != null && cartModel.customerId != customerId) {
      return const Left(
        ValidationFailure('No tienes permisos para modificar este carrito'),
      );
    }

    final now = DateTime.now();

    try {
      await supabaseClient.from('carts').update({
        'status': status.value,
        'updated_at': now.toIso8601String(),
      }).eq('id', cartId);
    } catch (e) {
      return Left(ServerFailure('No se pudo actualizar el estado: $e'));
    }

    Cart? updatedCart;

    if (cartModel != null) {
      await isar.writeTxn(() async {
        cartModel
          ..status = status.value
          ..updatedAt = now;
        await isar.cartLocalModels.put(cartModel);
      });

      final items = await isar.cartItemLocalModels
          .filter()
          .cartIdEqualTo(cartId)
          .findAll();

      updatedCart = _mapToEntity(cartModel, items);
    } else {
      try {
        updatedCart = await _fetchRemoteCart(cartId);
      } catch (e) {
        return Left(ServerFailure('No se pudo obtener el carrito actualizado: $e'));
      }
    }

    return Right(updatedCart);
  }

  @override
  Future<Either<Failure, Cart>> submitPaymentReceipt({
    required String customerId,
    required String cartId,
    required String filePath,
    String? originalFileName,
    String? notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'Debes estar conectado a internet para enviar el comprobante',
      ));
    }

    final file = File(filePath);
    if (!await file.exists()) {
      return Left(ValidationFailure('No se encontró el archivo seleccionado'));
    }

    final isar = await isarDatabase.database;
    final cartModel = await isar.cartLocalModels
        .filter()
        .uuidEqualTo(cartId)
        .findFirst();

    if (cartModel == null) {
      return const Left(ValidationFailure('Carrito no encontrado'));
    }

    if (cartModel.customerId != customerId) {
      return const Left(
        ValidationFailure('No tienes permisos para enviar comprobantes de este carrito'),
      );
    }

    if (CartStatusX.fromValue(cartModel.status).isFinal) {
      return const Left(
        ValidationFailure('El carrito ya fue procesado, no es posible enviar comprobantes'),
      );
    }

    final sanitizedName = _sanitizeFileName(
      originalFileName ?? p.basename(file.path),
    );
    final extension = p.extension(sanitizedName);
    final storagePath =
        'cart_receipts/$cartId/${DateTime.now().millisecondsSinceEpoch}$extension';
    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType(sanitizedName) ?? 'application/octet-stream';

    try {
      await supabaseClient.storage
          .from(_paymentReceiptsBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: false,
            ),
          );
    } catch (e) {
      return Left(ServerFailure('No se pudo subir el comprobante: $e'));
    }

    try {
      await supabaseClient.from('payment_receipts').insert({
        'cart_id': cartId,
        'uploaded_by': customerId,
        'storage_path': storagePath,
        'notes': notes,
      });
    } catch (e) {
      return Left(ServerFailure('No se pudo registrar el comprobante: $e'));
    }

    final statusResult = await updateStatus(
      customerId: customerId,
      cartId: cartId,
      status: CartStatus.paymentSubmitted,
    );

    return statusResult;
  }

  @override
  Future<Either<Failure, List<Cart>>> fetchCartsByStatus({
    required CartStatus status,
    String? locationId,
    String? locationType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      PostgrestFilterBuilder query = supabaseClient
          .from('carts')
          .select(
              '*, cart_items(*), payment_receipts(*), customers:customers(name,email)')
          .eq('status', status.value);

      if (locationId != null) {
        query = query.eq('location_id', locationId);
      }

      if (locationType != null) {
        query = query.eq('location_type', locationType);
      }

      final response = await query.order('created_at');
      final carts = _mapRemoteCarts(response);
      return Right(carts);
    } catch (e) {
      return Left(ServerFailure('Error al obtener pedidos: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> getCartById(String cartId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final cart = await _fetchRemoteCart(cartId);
      return Right(cart);
    } catch (e) {
      return Left(ServerFailure('Error al obtener carrito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentReceiptsStatus({
    required String cartId,
    required String reviewerId,
    required String status,
    String? notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final payload = <String, dynamic>{
        'status': status,
        'reviewed_by': reviewerId,
        'reviewed_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        payload['notes'] = notes;
      }

      await supabaseClient
          .from('payment_receipts')
          .update(payload)
          .eq('cart_id', cartId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar comprobante: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createReceiptDownloadUrl({
    required String storagePath,
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await supabaseClient.storage
          .from(_paymentReceiptsBucket)
          .createSignedUrl(storagePath, expiresIn.inSeconds);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('No se pudo generar enlace del comprobante: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> syncManagerCarts({
    String? locationId,
    String? locationType,
    List<CartStatus> statuses = const [
      CartStatus.awaitingPayment,
      CartStatus.paymentSubmitted,
      CartStatus.paymentRejected,
    ],
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final statusValues = statuses.map((status) => status.value).toList();

      PostgrestFilterBuilder<dynamic> query = supabaseClient
          .from('carts')
          .select(
            '''
              *,
              cart_items(*),
              payment_receipts(*),
              customers:customers(name,email)
            ''',
          )
          .inFilter('status', statusValues);

      if (locationId != null && locationId.isNotEmpty) {
        query = query.eq('location_id', locationId);
      }

      if (locationType != null && locationType.isNotEmpty) {
        query = query.eq('location_type', locationType);
      }

      final isar = await isarDatabase.database;
      final statusesForPush = <String>{
        ...statusValues,
        CartStatus.pending.value,
      }.toList();

      await _syncPendingCarts(isar, statusesForPush);

      final response = await query.order('updated_at', ascending: false);
      final carts = _mapRemoteCarts(response);
      final remoteIds = carts.map((cart) => cart.id).toSet();

      await isar.writeTxn(() async {
        for (final statusValue in statusValues) {
          final existingByStatus = await isar.cartLocalModels
              .filter()
              .statusEqualTo(statusValue)
              .findAll();

          for (final cartModel in existingByStatus) {
            if (!remoteIds.contains(cartModel.uuid)) {
              await isar.cartItemLocalModels
                  .filter()
                  .cartIdEqualTo(cartModel.uuid)
                  .deleteAll();
              await isar.cartLocalModels.delete(cartModel.id);
            }
          }
        }

        for (final cart in carts) {
          final existing = await isar.cartLocalModels
              .filter()
              .uuidEqualTo(cart.id)
              .findFirst();

          final cartModel = existing ?? CartLocalModel();
          cartModel
            ..uuid = cart.id
            ..customerId = cart.customerId
            ..status = cart.status.value
            ..locationId = cart.locationId
            ..locationType = cart.locationType
            ..locationName = cart.locationName
            ..totalItems = cart.items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            )
            ..subtotal = cart.items.fold<double>(
              0,
              (sum, item) => sum + item.subtotal,
            )
            ..createdAt = cart.createdAt
            ..updatedAt = cart.updatedAt
            ..needsSync = false
            ..pendingDelete = false
            ..lastSyncedAt = DateTime.now();

          await isar.cartLocalModels.put(cartModel);

          await isar.cartItemLocalModels
              .filter()
              .cartIdEqualTo(cart.id)
              .deleteAll();

          for (final item in cart.items) {
            final itemModel = CartItemLocalModel.fromEntity(item);
            await isar.cartItemLocalModels.put(itemModel);
          }
        }
      });

      return Right(carts.length);
    } catch (e) {
      return Left(ServerFailure('Error al sincronizar pedidos: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> syncCustomerCarts({
    required String customerId,
    List<CartStatus>? statuses,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    final statusList = statuses ?? CartStatus.values.where((s) => s != CartStatus.pending).toList();
    final statusValues = statusList.map((status) => status.value).toList();

    try {
      PostgrestFilterBuilder<dynamic> query = supabaseClient
          .from('carts')
          .select(
            '''
              *,
              cart_items(*),
              payment_receipts(*),
              customers:customers(name,email)
            ''',
          )
          .eq('customer_id', customerId);

      if (statusValues.isNotEmpty) {
        query = query.inFilter('status', statusValues);
      }

      final response = await query.order('updated_at', ascending: false);
      final carts = _mapRemoteCarts(response);
      final remoteIds = carts.map((cart) => cart.id).toSet();

      final allowedStatuses = statusValues.isNotEmpty
          ? statusValues.toSet()
          : CartStatus.values
              .where((s) => s != CartStatus.pending)
              .map((s) => s.value)
              .toSet();

      final isar = await isarDatabase.database;

      await isar.writeTxn(() async {
        final existing = await isar.cartLocalModels
            .filter()
            .customerIdEqualTo(customerId)
            .findAll();

        for (final model in existing) {
          if (!allowedStatuses.contains(model.status)) {
            continue;
          }

          if (!remoteIds.contains(model.uuid)) {
            await isar.cartItemLocalModels
                .filter()
                .cartIdEqualTo(model.uuid)
                .deleteAll();
            await isar.cartLocalModels.delete(model.id);
          }
        }

        for (final cart in carts) {
          final existingModel = await isar.cartLocalModels
              .filter()
              .uuidEqualTo(cart.id)
              .findFirst();

          final cartModel = existingModel ?? CartLocalModel();
          cartModel
            ..uuid = cart.id
            ..customerId = cart.customerId
            ..status = cart.status.value
            ..locationId = cart.locationId
            ..locationType = cart.locationType
            ..locationName = cart.locationName
            ..totalItems = cart.totalItems
            ..subtotal = cart.subtotal
            ..createdAt = cart.createdAt
            ..updatedAt = cart.updatedAt
            ..needsSync = false
            ..pendingDelete = false
            ..lastSyncedAt = DateTime.now();

          await isar.cartLocalModels.put(cartModel);

          await isar.cartItemLocalModels
              .filter()
              .cartIdEqualTo(cart.id)
              .deleteAll();

          for (final item in cart.items) {
            final itemModel = CartItemLocalModel.fromEntity(item);
            await isar.cartItemLocalModels.put(itemModel);
          }
        }
      });

      return Right(carts.length);
    } catch (e) {
      return Left(ServerFailure('Error al sincronizar historial de carritos: $e'));
    }
  }

  Future<CartLocalModel> _getOrCreateCart({
    required Isar isar,
    required String customerId,
    required DateTime now,
    required CartAddItemParams item,
  }) async {
    final existingCart = await isar.cartLocalModels
        .filter()
        .customerIdEqualTo(customerId)
        .statusEqualTo(CartStatus.pending.value)
        .findFirst();

    if (existingCart != null) {
      if (existingCart.locationId != null &&
          existingCart.locationId != item.locationId) {
        throw ValidationException(
            'El carrito solo puede contener productos de una misma ubicación');
      }

      if (existingCart.locationId == null) {
        existingCart
          ..locationId = item.locationId
          ..locationType = item.locationType
          ..locationName = item.locationName
          ..updatedAt = now;
        await isar.cartLocalModels.put(existingCart);
      }

      existingCart
        ..needsSync = true
        ..pendingDelete = false;

      return existingCart;
    }

    final cart = CartLocalModel()
      ..uuid = const Uuid().v4()
      ..customerId = customerId
      ..status = CartStatus.pending.value
      ..locationId = item.locationId
      ..locationType = item.locationType
      ..locationName = item.locationName
      ..totalItems = 0
      ..subtotal = 0
      ..createdAt = now
      ..updatedAt = now
      ..needsSync = true
      ..pendingDelete = false
      ..lastSyncedAt = null;

    await isar.cartLocalModels.put(cart);
    return cart;
  }

  Future<void> _recalculateCart({
    required Isar isar,
    required CartLocalModel cart,
    required DateTime now,
  }) async {
    final items = await isar.cartItemLocalModels
        .filter()
        .cartIdEqualTo(cart.uuid)
        .findAll();

    cart
      ..totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity)
      ..subtotal =
          items.fold<double>(0, (sum, item) => sum + item.subtotal).toDouble()
      ..updatedAt = now
      ..needsSync = true
      ..pendingDelete = false;

    await isar.cartLocalModels.put(cart);
  }

  Cart _mapToEntity(
    CartLocalModel cart,
    List<CartItemLocalModel> items,
  ) {
    return cart.toEntity(items);
  }

  Future<void> _syncPendingCarts(Isar isar, List<String> statusFilter) async {
    if (!await networkInfo.isConnected) {
      return;
    }

    final allowedStatuses = statusFilter.isEmpty
        ? null
        : statusFilter.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();

    final pendingCarts = await isar.cartLocalModels
        .filter()
        .needsSyncEqualTo(true)
        .findAll();

    for (final cart in pendingCarts) {
      if (allowedStatuses != null && allowedStatuses.isNotEmpty) {
        if (!allowedStatuses.contains(cart.status)) {
          continue;
        }
      }

      try {
        await _pushCartToSupabase(cart);
        await isar.writeTxn(() async {
          cart
            ..needsSync = false
            ..pendingDelete = false
            ..lastSyncedAt = DateTime.now();
          await isar.cartLocalModels.put(cart);
        });
        AppLogger.debug('✅ Carrito sincronizado (${cart.uuid})');
      } catch (e) {
        AppLogger.error('❌ Error al sincronizar carrito ${cart.uuid}: $e');
      }
    }
  }

  Future<void> _syncCartIfPossible(String cartId) async {
    if (!await networkInfo.isConnected) return;

    final isar = await isarDatabase.database;
    final cartModel = await isar.cartLocalModels
        .filter()
        .uuidEqualTo(cartId)
        .findFirst();

    if (cartModel == null) return;

    try {
      await _pushCartToSupabase(cartModel);
      await isar.writeTxn(() async {
        cartModel
          ..needsSync = false
          ..pendingDelete = false
          ..lastSyncedAt = DateTime.now();
        await isar.cartLocalModels.put(cartModel);
      });
      AppLogger.debug('✅ Carrito sincronizado inmediatamente ($cartId)');
    } catch (e) {
      AppLogger.error('❌ Error sincronizando carrito $cartId: $e');
    }
  }

  Future<void> _pushCartToSupabase(CartLocalModel cartModel) async {
    await _ensureCustomerExists(cartModel.customerId);

    final isar = await isarDatabase.database;
    final items = await isar.cartItemLocalModels
        .filter()
        .cartIdEqualTo(cartModel.uuid)
        .findAll();

    final cartPayload = {
      'id': cartModel.uuid,
      'customer_id': cartModel.customerId,
      'status': cartModel.status,
      'location_id': cartModel.locationId,
      'location_type': cartModel.locationType,
      'location_name': cartModel.locationName,
      'total_items': cartModel.totalItems,
      'subtotal': cartModel.subtotal,
      'created_at': cartModel.createdAt.toIso8601String(),
      'updated_at': cartModel.updatedAt.toIso8601String(),
    };

    await supabaseClient.from('carts').upsert(cartPayload);

    await supabaseClient.from('cart_items').delete().eq('cart_id', cartModel.uuid);

    if (items.isNotEmpty) {
      final itemPayloads = items
          .map((item) => {
                'id': item.uuid,
                'cart_id': cartModel.uuid,
                'inventory_id': item.inventoryId,
                'product_variant_id': item.productVariantId,
                'product_name': item.productName,
                'variant_name': item.variantName,
                'image_urls': item.imageUrls,
                'quantity': item.quantity,
                'available_quantity': item.availableQuantity,
                'unit_price': item.unitPrice,
                'subtotal': item.subtotal,
                'created_at': item.createdAt.toIso8601String(),
                'updated_at': item.updatedAt.toIso8601String(),
              })
          .toList();

      await supabaseClient.from('cart_items').insert(itemPayloads);
    }
  }

  Future<void> _ensureCustomerExists(String customerId) async {
    if (customerId.isEmpty) {
      throw Exception('El carrito no tiene un cliente asignado');
    }

    // Verificar si el cliente ya existe en Supabase
    final existing = await supabaseClient
        .from('customers')
        .select('id')
        .eq('id', customerId)
        .maybeSingle();

    if (existing != null) {
      AppLogger.debug('✅ Cliente $customerId ya existe en Supabase');
      return;
    }

    // El cliente no existe en Supabase, intentar obtenerlo localmente
    AppLogger.debug('📤 Cliente $customerId no existe en Supabase, intentando sincronizarlo...');

    final customer = await customerRepository.getById(customerId);
    if (customer == null) {
      // El cliente no existe localmente, esto indica un problema grave
      AppLogger.error('❌ El cliente $customerId no existe ni local ni remotamente');
      throw Exception(
        'El cliente $customerId no existe localmente. Sincroniza clientes antes de enviar el carrito.',
      );
    }

    // Intentar crear el cliente en Supabase
    try {
      final remoteModel = CustomerRemoteModel.fromEntity(customer);
      await supabaseClient.from('customers').upsert(remoteModel.toJson());
      AppLogger.info('✅ Cliente $customerId sincronizado a Supabase exitosamente');
    } catch (e) {
      AppLogger.error('❌ Error al sincronizar cliente $customerId a Supabase: $e');
      throw Exception('Error al sincronizar cliente a Supabase: $e');
    }
  }

  String _sanitizeFileName(String name) {
    final base = p.basenameWithoutExtension(name);
    final ext = p.extension(name);

    final sanitizedBase =
        base.replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    String sanitizedExt = ext.replaceAll(RegExp(r'[^A-Za-z0-9.]'), '');

    final fallbackBase = sanitizedBase.isEmpty ? 'receipt' : sanitizedBase;
    if (sanitizedExt.isEmpty || sanitizedExt == '.') {
      sanitizedExt = '.jpg';
    } else if (!sanitizedExt.startsWith('.')) {
      sanitizedExt = '.$sanitizedExt';
    }

    return '$fallbackBase$sanitizedExt';
  }

  List<Cart> _mapRemoteCarts(dynamic response) {
    if (response == null) return [];
    if (response is List) {
      final data = response
          // ignore: unnecessary_cast
          .map((entry) => (entry as Map).cast<String, dynamic>())
          .toList();

      return data
          .map(CartRemoteModel.fromJson)
          .map((model) => model.toEntity())
          .toList();
    }
    return [];
  }

  Future<Cart> _fetchRemoteCart(String cartId) async {
    final response = await supabaseClient
        .from('carts')
        .select(
            '*, cart_items(*), payment_receipts(*), customers:customers(name,email)')
        .eq('id', cartId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Carrito no encontrado');
    }

    final map = (response as Map).cast<String, dynamic>();
    return CartRemoteModel.fromJson(map).toEntity();
  }
}

