import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/location_repository.dart';

/// UseCase: Obtener todas las tiendas
class GetAllStores {
  final LocationRepository repository;

  GetAllStores(this.repository);

  Future<Either<Failure, List<Store>>> call() async {
    return await repository.getAllStores();
  }

  Stream<List<Store>> watch() {
    return repository.watchAllStores();
  }
}
