import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/usecases/get_variants_by_product.dart';
import '../../domain/usecases/create_variant.dart';
import '../../domain/usecases/update_variant.dart';
import '../../domain/usecases/delete_variant.dart';
import 'variant_event.dart';
import 'variant_state.dart';

/// BLoC de Variantes de Producto
class VariantBloc extends Bloc<VariantEvent, VariantState> {
  final GetVariantsByProduct getVariantsByProduct;
  final CreateVariant createVariant;
  final UpdateVariant updateVariant;
  final DeleteVariant deleteVariant;

  VariantBloc({
    required this.getVariantsByProduct,
    required this.createVariant,
    required this.updateVariant,
    required this.deleteVariant,
  }) : super(const VariantInitial()) {
    on<LoadVariantsByProduct>(_onLoadVariantsByProduct);
    on<CreateVariantEvent>(_onCreateVariant);
    on<UpdateVariantEvent>(_onUpdateVariant);
    on<DeleteVariantEvent>(_onDeleteVariant);
  }

  /// Cargar variantes por producto
  Future<void> _onLoadVariantsByProduct(
    LoadVariantsByProduct event,
    Emitter<VariantState> emit,
  ) async {
    emit(const VariantLoading());

    await emit.forEach<Either<Failure, List<ProductVariant>>>(
      getVariantsByProduct(event.productId),
      onData: (result) {
        return result.fold(
          (failure) => VariantError(failure.message),
          (variants) => VariantsLoaded(
            variants: variants,
            productId: event.productId,
          ),
        );
      },
    );
  }

  /// Crear variante
  Future<void> _onCreateVariant(
    CreateVariantEvent event,
    Emitter<VariantState> emit,
  ) async {
    final result = await createVariant(
      productId: event.productId,
      sku: event.sku,
      variantName: event.variantName,
      variantAttributes: event.variantAttributes,
      priceSell: event.priceSell,
      priceBuy: event.priceBuy,
    );

    result.fold(
      (failure) => emit(VariantError(failure.message)),
      (variant) {
        emit(VariantCreated(variant: variant));
        // Recargar lista
        add(LoadVariantsByProduct(event.productId));
      },
    );
  }

  /// Actualizar variante
  Future<void> _onUpdateVariant(
    UpdateVariantEvent event,
    Emitter<VariantState> emit,
  ) async {
    final result = await updateVariant(event.variant);

    result.fold(
      (failure) => emit(VariantError(failure.message)),
      (variant) {
        emit(VariantUpdated(variant: variant));
        // Recargar lista
        add(LoadVariantsByProduct(variant.productId));
      },
    );
  }

  /// Eliminar variante
  Future<void> _onDeleteVariant(
    DeleteVariantEvent event,
    Emitter<VariantState> emit,
  ) async {
    final result = await deleteVariant(event.id);

    result.fold(
      (failure) => emit(VariantError(failure.message)),
      (_) {
        emit(const VariantDeleted());
        // Nota: Necesitamos el productId para recargar, pero no lo tenemos aquí
        // La UI deberá manejar esto
      },
    );
  }
}
