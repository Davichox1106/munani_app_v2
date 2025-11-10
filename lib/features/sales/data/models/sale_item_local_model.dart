import 'package:isar/isar.dart';
import '../../domain/entities/sale_item.dart';

part 'sale_item_local_model.g.dart';

@collection
class SaleItemLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String saleId;

  late String productVariantId;
  late String productName;
  String? variantName;
  late int quantity;
  late double unitPrice;
  late double subtotal;
  late DateTime createdAt;

  SaleItemLocalModel();

  factory SaleItemLocalModel.fromEntity(SaleItem entity) {
    return SaleItemLocalModel()
      ..uuid = entity.id
      ..saleId = entity.saleId
      ..productVariantId = entity.productVariantId
      ..productName = entity.productName
      ..variantName = entity.variantName
      ..quantity = entity.quantity
      ..unitPrice = entity.unitPrice
      ..subtotal = entity.subtotal
      ..createdAt = entity.createdAt;
  }

  SaleItem toEntity() {
    return SaleItem(
      id: uuid,
      saleId: saleId,
      productVariantId: productVariantId,
      productName: productName,
      variantName: variantName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      createdAt: createdAt,
    );
  }
}
