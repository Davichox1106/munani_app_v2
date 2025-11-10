import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/warehouse.dart';
import '../repositories/location_repository.dart';

/// UseCase: Crear un nuevo almacén
class CreateWarehouse {
  final LocationRepository repository;

  CreateWarehouse(this.repository);

  Future<Either<Failure, Warehouse>> call({
    required String name,
    required String address,
    String? phone,
    String? managerId,
    String? paymentQrUrl,
    String? paymentQrDescription,
  }) async {
    return await repository.createWarehouse(
      name: name,
      address: address,
      phone: phone,
      managerId: managerId,
      paymentQrUrl: paymentQrUrl,
      paymentQrDescription: paymentQrDescription,
    );
  }
}
