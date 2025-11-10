import 'package:equatable/equatable.dart';
import 'purchase.dart';
import 'purchase_item.dart';

/// Entidad que agrupa una compra con sus ítems
/// Útil para mostrar la compra completa con todo su detalle
class PurchaseWithItems extends Equatable {
  final Purchase purchase;
  final List<PurchaseItem> items;

  const PurchaseWithItems({
    required this.purchase,
    required this.items,
  });

  /// Crea una copia con nuevos valores
  PurchaseWithItems copyWith({
    Purchase? purchase,
    List<PurchaseItem>? items,
  }) {
    return PurchaseWithItems(
      purchase: purchase ?? this.purchase,
      items: items ?? this.items,
    );
  }

  /// Obtiene la cantidad total de productos (suma de todas las cantidades)
  int get totalItemsCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Obtiene la cantidad de líneas diferentes (cantidad de ítems)
  int get totalLinesCount {
    return items.length;
  }

  /// Verifica si la compra tiene ítems
  bool get hasItems {
    return items.isNotEmpty;
  }

  /// Verifica si la compra está vacía
  bool get isEmpty {
    return items.isEmpty;
  }

  @override
  List<Object?> get props => [purchase, items];
}
