class CartAddItemParams {
  final String inventoryId;
  final String productVariantId;
  final String? productName;
  final String? variantName;
  final List<String> imageUrls;
  final String locationId;
  final String locationType;
  final String? locationName;
  final double unitPrice;
  final int availableQuantity;

  const CartAddItemParams({
    required this.inventoryId,
    required this.productVariantId,
    this.productName,
    this.variantName,
    this.imageUrls = const [],
    required this.locationId,
    required this.locationType,
    this.locationName,
    required this.unitPrice,
    required this.availableQuantity,
  });
}








