import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/location_repository.dart';

/// UseCase: Crear una nueva tienda
class CreateStore {
  final LocationRepository repository;

  CreateStore(this.repository);

  Future<Either<Failure, Store>> call({
    required String name,
    required String address,
    String? phone,
    String? managerId,
    String? paymentQrUrl,
    String? paymentQrDescription,
  }) async {
    return await repository.createStore(
      name: name,
      address: address,
      phone: phone,
      managerId: managerId,
      paymentQrUrl: paymentQrUrl,
      paymentQrDescription: paymentQrDescription,
    );
  }
}
