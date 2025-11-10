import '../entities/administrator.dart';

/// Repositorio para gestionar administradores
abstract class AdministratorRepository {
  /// Obtiene todos los administradores activos
  Stream<List<Administrator>> getAll();

  /// Obtiene todos los administradores (activos e inactivos)
  Stream<List<Administrator>> getAllIncludingInactive();

  /// Busca administradores por nombre o email
  Future<List<Administrator>> search(String query);

  /// Obtiene un administrador por email
  Future<Administrator?> getByEmail(String email);

  /// Crea un nuevo administrador
  Future<Administrator> create({
    required String name,
    String? contactName,
    String? phone,
    required String email,
    String? ci,
    String? address,
    String? notes,
    required String createdBy,
  });

  /// Actualiza un administrador
  Future<Administrator> update(Administrator administrator, String updatedBy);

  /// Desactiva un administrador
  Future<void> deactivate(String administratorId);

  /// Activa un administrador
  Future<void> activate(String administratorId);

  /// Verificar si existe un CI (excluyendo opcionalmente un ID específico)
  Future<bool> existsCi(String ci, {String? excludeId});

  /// Sincronizar administradores con backend
  Future<void> syncAdministrators();
}
