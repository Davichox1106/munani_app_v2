import 'package:equatable/equatable.dart';
import '../../domain/entities/product_variant.dart';

/// Eventos del VariantBloc
abstract class VariantEvent extends Equatable {
  const VariantEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar variantes por producto
class LoadVariantsByProduct extends VariantEvent {
  final String productId;

  const LoadVariantsByProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Crear variante
class CreateVariantEvent extends VariantEvent {
  final String productId;
  final String sku;
  final String? variantName;
  final Map<String, dynamic>? variantAttributes;
  final double priceSell;
  final double priceBuy;

  const CreateVariantEvent({
    required this.productId,
    required this.sku,
    this.variantName,
    this.variantAttributes,
    required this.priceSell,
    required this.priceBuy,
  });

  @override
  List<Object?> get props => [productId, sku, variantName, variantAttributes, priceSell, priceBuy];
}

/// Actualizar variante
class UpdateVariantEvent extends VariantEvent {
  final ProductVariant variant;

  const UpdateVariantEvent(this.variant);

  @override
  List<Object?> get props => [variant];
}

/// Eliminar variante
class DeleteVariantEvent extends VariantEvent {
  final String id;

  const DeleteVariantEvent(this.id);

  @override
  List<Object?> get props => [id];
}
