import 'user.dart';

/// Usuario enriquecido con información adicional de ubicación
class EnrichedUser {
  final User user;
  final String? assignedLocationName;

  EnrichedUser({
    required this.user,
    this.assignedLocationName,
  });

  // Delegar propiedades del usuario
  String get id => user.id;
  String get email => user.email;
  String get name => user.name;
  String get role => user.role;
  String? get assignedLocationId => user.assignedLocationId;
  String? get assignedLocationType => user.assignedLocationType;
  bool get isActive => user.isActive;
  DateTime get createdAt => user.createdAt;
  DateTime get updatedAt => user.updatedAt;
  bool get isAdmin => user.isAdmin;
  bool get isStoreManager => user.isStoreManager;
  bool get isWarehouseManager => user.isWarehouseManager;
  bool get isCustomer => user.isCustomer;
  bool get hasAssignedLocation => user.hasAssignedLocation;

  /// Crear desde usuario y servicio de nombres
  factory EnrichedUser.fromUser(User user, String? locationName) {
    return EnrichedUser(
      user: user,
      assignedLocationName: locationName,
    );
  }
}





















