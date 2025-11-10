import 'package:isar/isar.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import 'cart_item_local_model.dart';

part 'cart_local_model.g.dart';

@collection
class CartLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String customerId;

  @Index()
  late String status;

  String? locationId;
  String? locationType;
  String? locationName;
  int totalItems = 0;
  double subtotal = 0;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool needsSync = true;
  bool pendingDelete = false;
  DateTime? lastSyncedAt;

  CartLocalModel();

  CartLocalModel.fromEntity(Cart cart) {
    uuid = cart.id;
    customerId = cart.customerId;
    status = cart.status.value;
    locationId = cart.locationId;
    locationType = cart.locationType;
    locationName = cart.locationName;
    totalItems = cart.totalItems;
    subtotal = cart.subtotal;
    createdAt = cart.createdAt;
    updatedAt = cart.updatedAt;
    needsSync = false;
    pendingDelete = false;
    lastSyncedAt = DateTime.now();
  }

  Cart toEntity(List<CartItemLocalModel> items) {
    return Cart(
      id: uuid,
      customerId: customerId,
      status: CartStatusX.fromValue(status),
      customerName: null,
      customerEmail: null,
      locationId: locationId,
      locationType: locationType,
      locationName: locationName,
      totalItems: totalItems,
      subtotal: subtotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items.map((item) => item.toEntity()).toList(),
      receipts: const [],
    );
  }
}

