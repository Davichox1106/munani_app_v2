import '../../features/auth/domain/entities/user.dart';

/// Helper para manejar permisos de usuarios
/// 
/// Centraliza toda la lógica de permisos del sistema
class PermissionHelper {
  
  /// Verifica si el usuario puede crear tiendas
  static bool canCreateStores(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede editar una tienda específica
  static bool canEditStore(User user, String storeId) {
    if (user.isAdmin) return true;
    if (user.isStoreManager && user.assignedLocationId == storeId) return true;
    return false;
  }
  
  /// Verifica si el usuario puede eliminar tiendas
  static bool canDeleteStores(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede crear almacenes
  static bool canCreateWarehouses(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede editar un almacén específico
  static bool canEditWarehouse(User user, String warehouseId) {
    if (user.isAdmin) return true;
    if (user.isWarehouseManager && user.assignedLocationId == warehouseId) return true;
    return false;
  }
  
  /// Verifica si el usuario puede eliminar almacenes
  static bool canDeleteWarehouses(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede ver todas las tiendas
  static bool canViewAllStores(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede ver todas las tiendas
  static bool canViewAllWarehouses(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede editar inventario de una ubicación específica
  /// - Admins pueden editar cualquier ubicación
  /// - Gerentes solo pueden editar inventario de SU ubicación asignada
  static bool canEditInventoryAtLocation(User user, String locationId, String locationType) {
    // Admins pueden editar cualquier inventario
    if (user.isAdmin) return true;

    // Gerentes solo pueden editar inventario de su ubicación asignada
    if (!user.hasAssignedLocation) return false;

    return user.assignedLocationId == locationId &&
           user.assignedLocationType == locationType;
  }
  
  /// Verifica si el usuario puede ver inventario de una ubicación específica
  /// TODOS los gerentes y admins pueden VER inventario de cualquier ubicación
  /// Esto permite que gerentes de tienda vean almacenes y viceversa
  static bool canViewInventoryAtLocation(User user, String locationId, String locationType) {
    // Admins pueden ver cualquier inventario
    if (user.isAdmin) return true;

    // Gerentes de tienda y almacén pueden ver cualquier inventario
    if (user.isStoreManager || user.isWarehouseManager) {
      return true;
    }

    return false;
  }
  
  /// Obtiene la ubicación asignada del usuario (si tiene una)
  static String? getUserAssignedLocationId(User user) {
    return user.assignedLocationId;
  }
  
  /// Obtiene el tipo de ubicación asignada del usuario (si tiene una)
  static String? getUserAssignedLocationType(User user) {
    return user.assignedLocationType;
  }
  
  /// Verifica si el usuario tiene una ubicación asignada
  static bool hasAssignedLocation(User user) {
    return user.hasAssignedLocation;
  }
  
  /// Verifica si el usuario puede crear productos
  static bool canCreateProducts(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede editar productos
  static bool canEditProducts(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede eliminar productos
  static bool canDeleteProducts(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede crear variantes de productos
  static bool canCreateProductVariants(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede editar variantes de productos
  static bool canEditProductVariants(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede eliminar variantes de productos
  static bool canDeleteProductVariants(User user) {
    return user.isAdmin;
  }
  
  /// Verifica si el usuario puede solicitar transferencias
  static bool canRequestTransfers(User user) {
    return user.isAdmin || user.isStoreManager || user.isWarehouseManager;
  }
  
  /// Verifica si el usuario puede aprobar transferencias
  /// ADMINISTRADORES, GERENTES DE ALMACÉN y GERENTES DE TIENDA pueden aprobar transferencias
  static bool canApproveTransfers(User user) {
    return user.isAdmin || user.isWarehouseManager || user.isStoreManager;
  }
  
  /// Verifica si el usuario puede aprobar una transferencia específica
  /// NO puedes aprobar transferencias de tu propia ubicación
  static bool canApproveSpecificTransfer(User user, String transferToLocationId, String transferToLocationType) {
    // Solo admins pueden aprobar cualquier transferencia
    if (user.isAdmin) return true;
    
    // Gerentes NO pueden aprobar transferencias hacia su propia ubicación
    if (user.hasAssignedLocation && 
        user.assignedLocationId == transferToLocationId && 
        user.assignedLocationType == transferToLocationType) {
      return false;
    }
    
    // Gerentes pueden aprobar transferencias hacia otras ubicaciones
    return user.isWarehouseManager || user.isStoreManager;
  }
  
  /// Verifica si el usuario puede ver transferencias de su ubicación
  static bool canViewTransfersForLocation(User user, String locationId, String locationType) {
    if (user.isAdmin) return true;
    
    // Gerente de tienda puede ver transferencias de su tienda
    if (user.isStoreManager && 
        user.assignedLocationType == 'store' && 
        user.assignedLocationId == locationId && 
        locationType == 'store') {
      return true;
    }
    
    // Gerente de almacén puede ver transferencias de su almacén
    if (user.isWarehouseManager && 
        user.assignedLocationType == 'warehouse' && 
        user.assignedLocationId == locationId && 
        locationType == 'warehouse') {
      return true;
    }
    
    return false;
  }
  
  /// Verifica si el usuario puede gestionar proveedores y compras
  static bool canManageSuppliers(User user) {
    return user.isAdmin || user.isStoreManager || user.isWarehouseManager;
  }
  
  /// Verifica si el usuario puede crear compras
  static bool canCreatePurchases(User user) {
    return user.isAdmin || user.isStoreManager || user.isWarehouseManager;
  }
}
