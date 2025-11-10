import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/location_repository.dart';

/// Use case: Actualizar tienda
class UpdateStore {
  final LocationRepository repository;

  UpdateStore(this.repository);

  Future<Either<Failure, Store>> call(Store store) async {
    return await repository.updateStore(store);
  }
}






























