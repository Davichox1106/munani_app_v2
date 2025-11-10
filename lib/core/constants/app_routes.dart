/// Rutas de navegación de la aplicación
class AppRoutes {
  AppRoutes._(); // Constructor privado

  // Autenticación
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Principal
  static const String dashboard = '/dashboard';
  static const String home = '/';

  // Productos
  static const String productList = '/products';
  static const String productDetail = '/products/detail';
  static const String productForm = '/products/form';

  // Inventario
  static const String inventory = '/inventory';
  static const String inventoryByStore = '/inventory/store';
  static const String inventoryByWarehouse = '/inventory/warehouse';

  // Ventas
  static const String salesList = '/sales';
  static const String salesForm = '/sales/form';
  static const String pos = '/pos';
  static const String saleDetail = '/sales/detail';

  // Compras
  static const String purchasesList = '/purchases';
  static const String purchaseForm = '/purchases/form';
  static const String purchaseDetail = '/purchases/detail';

  // Proveedores
  static const String suppliersList = '/suppliers';
  static const String supplierForm = '/suppliers/form';

  // Transferencias
  static const String transfersList = '/transfers';
  static const String transferForm = '/transfers/form';
  static const String transferDetail = '/transfers/detail';

  // Reportes
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String purchasesReport = '/reports/purchases';
  static const String transfersReport = '/reports/transfers';
  static const String dailySalesReport = '/reports/daily-sales';

  // Empleados y Administradores
  static const String administrators = '/administrators';
  static const String employeesStore = '/employees/store';
  static const String employeesWarehouse = '/employees/warehouse';

  // Configuración
  static const String settings = '/settings';
  static const String profile = '/profile';
}
