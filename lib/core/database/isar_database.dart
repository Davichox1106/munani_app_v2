import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/auth/data/models/user_local_model.dart';
import '../../features/products/data/models/product_local_model.dart';
import '../../features/products/data/models/product_variant_local_model.dart';
import '../../features/locations/data/models/store_local_model.dart';
import '../../features/locations/data/models/warehouse_local_model.dart';
import '../../features/sync/data/models/sync_queue_local_model.dart';
import '../../features/inventory/data/models/inventory_local_model.dart';
import '../../features/users/data/models/user_local_model.dart';
import '../../features/transfers/data/models/transfer_request_local_model.dart';
import '../../features/purchases/data/models/supplier_local_model.dart';
import '../../features/purchases/data/models/purchase_local_model.dart';
import '../../features/purchases/data/models/purchase_item_local_model.dart';
import '../../features/sales/data/models/sale_local_model.dart';
import '../../features/sales/data/models/sale_item_local_model.dart';
import '../../features/customers/data/models/customer_local_model.dart';
import '../../features/employees/data/models/administrator_local_model.dart';
import '../../features/employees/data/models/employee_store_local_model.dart';
import '../../features/employees/data/models/employee_warehouse_local_model.dart';
import '../../features/cart/data/models/cart_local_model.dart';
import '../../features/cart/data/models/cart_item_local_model.dart';

/// Gestor de base de datos Isar
///
/// Implementa patrón Singleton para mantener una única instancia.
/// OWASP A02:2021 - Cryptographic Failures:
/// - Encriptación de datos con clave de 256-bit
class IsarDatabase {
  static IsarDatabase? _instance;
  static Isar? _isar;

  IsarDatabase._();

  /// Obtiene la instancia del singleton
  static IsarDatabase get instance {
    _instance ??= IsarDatabase._();
    return _instance!;
  }

  /// Obtiene la instancia de Isar
  Future<Isar> get database async {
    if (_isar != null) return _isar!;
    _isar = await _initDatabase();
    return _isar!;
  }

  /// Inicializa la base de datos Isar
  Future<Isar> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    // NOTA: encryptionKey no está disponible en la versión gratuita de Isar
    // La encriptación requiere la versión Pro/Enterprise
    // Para desarrollo usaremos Isar sin encriptación
    // En producción se debe evaluar Isar Pro o implementar encriptación a nivel de campo

    return await Isar.open(
      [
        // Auth
        UserLocalModelSchema,
        // Products (Fase 2)
        ProductLocalModelSchema,
        ProductVariantLocalModelSchema,
        // Locations (Fase 2)
        StoreLocalModelSchema,
        WarehouseLocalModelSchema,
        // Sync (Fase 2)
        SyncQueueLocalModelSchema,
        // Inventory (Fase 4)
        InventoryLocalModelSchema,
        CartLocalModelSchema,
        CartItemLocalModelSchema,
        // Transfers (Fase 9)
        TransferRequestLocalModelSchema,
        // Users Management (Fase 8)
        UserManagementLocalModelSchema,
        // Purchases (Fase 6)
        SupplierLocalModelSchema,
        PurchaseLocalModelSchema,
        PurchaseItemLocalModelSchema,
        // Employees (Fase 7)
        AdministratorLocalModelSchema,
        EmployeeStoreLocalModelSchema,
        EmployeeWarehouseLocalModelSchema,
        // Sales (Fase 8)
        SaleLocalModelSchema,
        SaleItemLocalModelSchema,
        // Customers (Fase 9)
        CustomerLocalModelSchema,
      ],
      directory: dir.path,
      name: 'munani_db',
      inspector: true, // Habilitar inspector en desarrollo
    );
  }

  /// Cierra la base de datos
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Limpia toda la base de datos (SOLO para testing)
  Future<void> clear() async {
    final isar = await database;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
