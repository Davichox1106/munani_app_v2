import '../entities/customer.dart';

abstract class CustomerRepository {
  // Streams
  Stream<List<Customer>> watchAllCustomers();

  // Queries
  Future<Customer?> getById(String id);
  Future<Customer?> getByCi(String ci);
  Future<List<Customer>> search(String query);

  // Mutations
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);

  // Sync
  Future<void> syncCustomers();
}
