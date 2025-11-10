# 🛒 Munani - E-commerce de Barritas Nutritivas

Sistema E-commerce completo de barritas nutritivas implementado con **arquitectura limpia** y patrón **BLoC** para gestión de estado reactivo offline-first con sincronización bidireccional de **Isar** a **Supabase** y viceversa para backend y autenticación.

## 🚀 Características

- ✅ Arquitectura Clean Architecture + BLoC
- ✅ Offline-First con Isar (base de datos local)
- ✅ Sincronización bidireccional automática con Supabase
- ✅ Autenticación con roles (Admin, Store Manager, Warehouse Manager)
- ✅ Row Level Security (RLS) basado en OWASP
- ✅ Sistema de auditoría completo
- ✅ 12 módulos completos de gestión empresarial
- ✅ Más de 42,000 líneas de código

## 📱 Módulos Implementados

1. **Autenticación** - Login, registro, recuperación de contraseña
2. **Productos** - CRUD de productos y variantes
3. **Ubicaciones** - Tiendas y almacenes
4. **Inventario** - Control de stock por ubicación
5. **Transferencias** - Solicitudes entre ubicaciones
6. **Compras** - Proveedores y órdenes de compra
7. **Empleados** - Administradores, empleados de tienda y almacén
8. **Ventas** - Gestión de ventas con items
9. **Clientes** - CRUD de clientes
10. **Usuarios** - Gestión de usuarios del sistema
11. **Sincronización** - Cola de sincronización y estado
12. **Reportes** - Ventas, compras, transferencias

## 🛠️ Stack Tecnológico

- **Framework:** Flutter 3.5.0+
- **Estado:** BLoC (flutter_bloc 8.1.6)
- **Base de datos local:** Isar 3.1.0+1
- **Backend:** Supabase (PostgreSQL)
- **Inyección de dependencias:** GetIt 8.0.0
- **Red:** Dio 5.7.0, connectivity_plus 6.0.5

## 📦 Instalación

1. Clonar el repositorio
2. Instalar dependencias: `flutter pub get`
3. Configurar variables de entorno en `.env`:
   ```
   SUPABASE_URL=tu_url_supabase
   SUPABASE_ANON_KEY=tu_anon_key
   ```
4. Ejecutar scripts SQL en Supabase (ver `sql/README.md`)
5. Ejecutar la app: `flutter run`

## 📚 Documentación

- Ver `ScopeProject.md` para estructura del proyecto
- Ver `sql/README.md` para configuración de base de datos
- Ver `docs/` para capturas de pantalla y documentación adicional
# munani_app_v2
