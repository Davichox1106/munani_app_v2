import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

/// Use case: Eliminar tienda
class DeleteStore {
  final LocationRepository repository;

  DeleteStore(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteStore(id);
  }
}






























