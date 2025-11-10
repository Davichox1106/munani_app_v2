import 'package:equatable/equatable.dart';
import '../../domain/entities/product_variant.dart';

/// Estados del VariantBloc
abstract class VariantState extends Equatable {
  const VariantState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class VariantInitial extends VariantState {
  const VariantInitial();
}

/// Cargando variantes
class VariantLoading extends VariantState {
  const VariantLoading();
}

/// Variantes cargadas
class VariantsLoaded extends VariantState {
  final List<ProductVariant> variants;
  final String productId;

  const VariantsLoaded({
    required this.variants,
    required this.productId,
  });

  @override
  List<Object?> get props => [variants, productId];
}

/// Variante creada
class VariantCreated extends VariantState {
  final ProductVariant variant;
  final String message;

  const VariantCreated({
    required this.variant,
    this.message = 'Variante creada exitosamente',
  });

  @override
  List<Object?> get props => [variant, message];
}

/// Variante actualizada
class VariantUpdated extends VariantState {
  final ProductVariant variant;
  final String message;

  const VariantUpdated({
    required this.variant,
    this.message = 'Variante actualizada',
  });

  @override
  List<Object?> get props => [variant, message];
}

/// Variante eliminada
class VariantDeleted extends VariantState {
  final String message;

  const VariantDeleted({
    this.message = 'Variante eliminada',
  });

  @override
  List<Object?> get props => [message];
}

/// Error
class VariantError extends VariantState {
  final String message;

  const VariantError(this.message);

  @override
  List<Object?> get props => [message];
}
