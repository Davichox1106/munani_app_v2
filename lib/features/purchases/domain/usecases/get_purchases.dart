import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// UseCase: Obtener compras
class GetPurchases {
  final PurchaseRepository repository;

  GetPurchases(this.repository);

  /// Obtener stream de todas las compras
  Stream<List<Purchase>> call() {
    return repository.watchAllPurchases();
  }

  /// Obtener stream de compras por ubicación
  Stream<List<Purchase>> byLocation(String locationId) {
    return repository.watchPurchasesByLocation(locationId);
  }

  /// Obtener stream de compras por estado
  Stream<List<Purchase>> byStatus(PurchaseStatus status) {
    return repository.watchPurchasesByStatus(status);
  }

  /// Buscar compras
  Future<List<Purchase>> search(String query) {
    return repository.searchPurchases(query);
  }
}
