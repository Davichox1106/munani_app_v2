import 'package:isar/isar.dart';
import '../../domain/entities/purchase_item.dart';

part 'purchase_item_local_model.g.dart';

@collection
class PurchaseItemLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String purchaseId;

  late String productVariantId;
  late String productName;
  late String variantName;
  late int quantity;
  late double unitCost;
  late double subtotal;
  late DateTime createdAt;

  PurchaseItemLocalModel();

  /// Convierte de entidad a modelo local
  factory PurchaseItemLocalModel.fromEntity(PurchaseItem entity) {
    return PurchaseItemLocalModel()
      ..uuid = entity.id
      ..purchaseId = entity.purchaseId
      ..productVariantId = entity.productVariantId
      ..productName = entity.productName
      ..variantName = entity.variantName
      ..quantity = entity.quantity
      ..unitCost = entity.unitCost
      ..subtotal = entity.subtotal
      ..createdAt = entity.createdAt;
  }

  /// Convierte de modelo local a entidad
  PurchaseItem toEntity() {
    return PurchaseItem(
      id: uuid,
      purchaseId: purchaseId,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      quantity: quantity,
      unitCost: unitCost,
      subtotal: subtotal,
      createdAt: createdAt,
    );
  }
}
