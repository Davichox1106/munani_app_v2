/// Constantes de texto de la aplicación
class AppStrings {
  AppStrings._(); // Constructor privado

  // General
  static const String appName = 'Munani';
  static const String appDescription = 'E-commerce de Barritas Nutritivas';

  // Autenticación
  static const String login = 'Iniciar Sesión';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String rememberMe = 'Recordarme';

  // Validaciones
  static const String emailRequired = 'El correo es requerido';
  static const String emailInvalid = 'Correo inválido';
  static const String passwordRequired = 'La contraseña es requerida';
  static const String passwordTooShort = 'Mínimo 8 caracteres';
  static const String fieldRequired = 'Este campo es requerido';

  // Navegación
  static const String dashboard = 'Dashboard';
  static const String products = 'Productos';
  static const String inventory = 'Inventario';
  static const String sales = 'Ventas';
  static const String purchases = 'Compras';
  static const String transfers = 'Transferencias';
  static const String reports = 'Reportes';
  static const String settings = 'Configuración';

  // Acciones
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String search = 'Buscar';
  static const String filter = 'Filtrar';
  static const String add = 'Agregar';
  static const String confirm = 'Confirmar';

  // Sincronización
  static const String syncing = 'Sincronizando...';
  static const String synced = 'Sincronizado';
  static const String offline = 'Sin conexión';
  static const String pendingSync = 'Pendiente de sincronizar';

  // Errores
  static const String errorGeneric = 'Ha ocurrido un error';
  static const String errorNetwork = 'Error de conexión';
  static const String errorAuth = 'Error de autenticación';
  static const String errorNotFound = 'No encontrado';
  static const String errorServerError = 'Error del servidor';
}
