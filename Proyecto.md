
# Trabajo Final - Móvil Avanzado
## Sistema Offline-First para Gestión de Inventario
### Rivas Gutiérrez David Hugo

---

## 📋 Índice

1. [Descripción del Proyecto](#descripción-del-proyecto)
2. [Objetivos Cumplidos](#objetivos-cumplidos)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
5. [Estructura de Directorios](#estructura-de-directorios)
6. [Módulos Implementados](#módulos-implementados)
7. [Base de Datos](#base-de-datos)
8. [Usuarios de Prueba](#usuarios-de-prueba)
9. [Funcionalidades Principales](#funcionalidades-principales)
10. [Características Offline-First](#características-offline-first)
11. [Seguridad](#seguridad)
12. [Instalación y Ejecución](#instalación-y-ejecución)

---

## 📱 Descripción del Proyecto

**Munani App V2** es una solución móvil **offline-first** diseñada para las tiendas “Barritas”, una marca que comercializa barritas nutritivas y productos complementarios. La aplicación atiende tanto a personal interno (administradores, encargados de tienda o almacén) como a clientes finales que compran desde el catálogo.

El sistema cubre:
- **Catálogo y productos**: gestión de productos y variantes con imágenes alojadas en Supabase Storage.
- **Inventario**: control por tienda y almacén, recálculo en cascada tras compras, ventas o transferencias.
- **Pedidos y carrito**: flujo completo para clientes, incluso en modo offline, con sincronización posterior.
- **Pagos con QR**: administración de códigos QR por tienda/almacén y recepción de comprobantes digitales.
- **Reportes y sincronización**: módulo de reportes para personal interno y sincronización automática/m anual de datos.

### Contexto de negocio
- **Tiendas físicas** que requieren operación sin internet de forma intermitente.
- **Almacenes** que abastecen a las tiendas y registran transferencias.
- **Clientes finales** que necesitan ver catálogo, generar pedidos y subir comprobantes de pago.
- **Seguridad** basada en roles (admin, customer, store_manager, warehouse_manager) y políticas RLS en Supabase.

---

## ✅ Objetivos Alcanzados

✔️ **Operación offline-first**: uso de Isar para trabajar sin internet y sincronizar con Supabase al reconectar.  
✔️ **Control de inventario unificado**: productos, variantes y existencias por ubicación con actualización automática.  
✔️ **Pedidos de clientes**: carrito sincronizado, historial de pedidos y gestión de comprobantes de pago.  
✔️ **Flujos administrativos**: creación/edición de productos, transferencias, compras y reportes desde perfil administrador.  
✔️ **Pagos digitales**: almacenamiento seguro de QR por tienda y generación de enlaces firmados.  
✔️ **Seguridad por roles**: RLS en Supabase, validaciones en cliente y repositorios, autenticación con JWT Argon2.  
✔️ **Visibilidad de datos**: reportes para personal interno y notificaciones visuales de sincronización.

---

## 🛠️ Stack Tecnológico

### Frontend (Cliente)
- **Flutter** 3.24.x – framework multiplataforma
- **Dart** 3.x – lenguaje de programación

### Gestión de Estado
- **flutter_bloc** ^8.1.6 – patrón BLoC
- **bloc** ^8.1.4
- **equatable** ^2.0.5

### Base de Datos Local (Offline)
- **Isar** 3.1.0+1 – base NoSQL embebida
- **isar_flutter_libs** 3.1.0+1
- **path_provider** ^2.1.4 – acceso a filesystem (Descargas/Documentos)

### Backend / BaaS
- **Supabase Flutter** ^2.5.11
  - PostgreSQL (datos remotos)
  - Auth (Argon2, JWT, refresh tokens)
  - Row Level Security (RLS)
  - Storage (buckets `product-images`, `payment-qr`, `payment_receipts`)
  - Realtime subscriptions

### Networking & Conectividad
- **dio** ^5.7.0 – cliente HTTP
- **connectivity_plus** ^6.0.5 – conectividad general
- **internet_connection_checker_plus** ^2.5.2 – verificación real

### Utilidades
- **intl** ^0.19.0 (formatos), **uuid** ^4.5.0, **dartz** ^0.10.1
- **get_it** ^8.0.0, **flutter_dotenv** ^5.1.0, **logger** ^2.4.0

### UI/UX
- **cached_network_image** ^3.4.1, **flutter_svg** ^2.0.10+1
- **shimmer** ^3.0.0, **fl_chart** ^0.69.0

### DevDependencies
- **flutter_lints** ^5.0.0, **isar_generator** ^3.1.0+1
- **build_runner** ^2.4.13, **mocktail** ^1.0.4
- **flutter_launcher_icons** ^0.13.1

---

## 🏗️ Arquitectura del Proyecto

### Clean Architecture + BLoC Pattern

El proyecto sigue los principios de **Clean Architecture** con separación clara de responsabilidades:

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION                        │
│  (BLoC + Pages + Widgets)                           │
│  ↓ Events                        ↑ States           │
└─────────────────────────────────────────────────────┘
                     ↓ ↑
┌─────────────────────────────────────────────────────┐
│                    DOMAIN                            │
│  (Entities + Use Cases + Repositories)              │
│  Lógica de negocio pura                             │
└─────────────────────────────────────────────────────┘
                     ↓ ↑
┌─────────────────────────────────────────────────────┐
│                     DATA                             │
│  (Models + Data Sources + Repository Impl)          │
│  ├── Local (Isar)                                   │
│  └── Remote (Supabase)                              │
└─────────────────────────────────────────────────────┘
```

### Capas:

#### 1. **Presentation Layer** (UI)
- **BLoC**: Gestión de estados y eventos
- **Pages**: Pantallas de la aplicación
- **Widgets**: Componentes reutilizables

#### 2. **Domain Layer** (Lógica de Negocio)
- **Entities**: Modelos de dominio puros
- **Use Cases**: Casos de uso específicos
- **Repositories**: Interfaces (contratos)

#### 3. **Data Layer** (Datos)
- **Models**: Modelos de datos (Local y Remote)
- **Data Sources**: Fuentes de datos
  - Local: Isar Database
  - Remote: Supabase
- **Repository Implementations**: Implementación de interfaces

#### 4. **Core** (Compartido)
- Constants
- DI (Dependency Injection)
- Errors & Exceptions
- Network Info
- Services
- Theme
- Utils
- Widgets compartidos

---

## 📁 Estructura de Directorios

```
lib/
├── core/
│   ├── constants/          # Constantes (colores, rutas, strings, estilos)
│   ├── database/           # Configuración de Isar
│   ├── di/                 # Inyección de dependencias (GetIt)
│   ├── errors/             # Excepciones y Failures
│   ├── network/            # Network info y conectividad
│   ├── permissions/        # Manejo de permisos
│   ├── services/           # Servicios globales
│   │   ├── auth_service.dart
│   │   ├── auto_sync_service.dart
│   │   ├── deep_link_service.dart
│   │   └── full_sync_service.dart
│   ├── theme/              # Tema de la aplicación
│   ├── utils/              # Utilidades (logger, validators, formatters)
│   └── widgets/            # Widgets compartidos
│
├── features/               # Módulos por característica
│   ├── auth/              # Autenticación
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │
│   ├── customers/         # Gestión de clientes
│   ├── employees/         # Gestión de empleados (Admin, Tienda, Almacén)
│   ├── inventory/         # Gestión de inventario
│   ├── locations/         # Tiendas y Almacenes
│   ├── products/          # Productos y Variantes
│   ├── purchases/         # Compras y Proveedores
│   ├── reports/           # Reportes
│   ├── sales/             # Ventas
│   ├── sync/              # Sincronización
│   ├── transfers/         # Transferencias
│   └── users/             # Gestión de usuarios
│
└── main.dart              # Punto de entrada
```

### Patrón de cada Feature:

```
feature_name/
├── data/
│   ├── datasources/
│   │   ├── feature_local_datasource.dart    # Isar
│   │   └── feature_remote_datasource.dart   # Supabase
│   ├── models/
│   │   ├── feature_local_model.dart         # Modelo Isar
│   │   ├── feature_local_model.g.dart       # Generated
│   │   └── feature_remote_model.dart        # Modelo Supabase
│   └── repositories/
│       └── feature_repository_impl.dart     # Implementación
│
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart              # Entidad pura
│   ├── repositories/
│   │   └── feature_repository.dart          # Interface
│   └── usecases/
│       ├── get_feature.dart
│       ├── create_feature.dart
│       └── update_feature.dart
│
└── presentation/
    ├── bloc/
    │   ├── feature_bloc.dart
    │   ├── feature_event.dart
    │   └── feature_state.dart
    ├── pages/
    │   ├── feature_list_page.dart
    │   └── feature_form_page.dart
    └── widgets/
        └── feature_card.dart
```

---

## 🔧 Módulos Implementados

### 1. Autenticación & Onboarding
- Login/logout con Supabase Auth.
- Registro de clientes (captura de datos obligatorios para `customers`).
- Recuperación de contraseña y mantenimiento de sesión.
- Determinación de rol y ubicación asignada para auto-sync.

### 2. Dashboard
- Tarjetas dinámicas según rol.
- Para clientes: acceso directo a catálogo e historial de pedidos.
- Para administradores: atajos a inventario, productos, reportes, sincronización.

### 3. Catálogo y Productos
- CRUD de productos y variantes.
- Carga de imágenes al bucket `product-images` y previsualización con URLs firmadas.
- Cambios en productos actualizan inventario y listas automáticamente.

### 4. Inventario
- Vista consolidada por tienda o almacén.
- Ajustes y recálculo posterior a compras, ventas o transferencias.
- Indicadores de stock (mínimo, disponible, imágenes sincronizadas).

### 5. Ubicaciones (Tiendas/Almacenes)
- Formularios para crear/editar ubicaciones.
- Gestión de QR de pago (subida al bucket `payment-qr`).
- Generación de URL firmada para mostrar QR en checkout.

### 6. Carrito & Checkout
- Carrito persistente en Isar, con flags `needsSync`, `pendingDelete`.
- Sincronización bidireccional con Supabase (`carts` y `cart_items`).
- Descarga del QR de pago a carpeta Descargas (Android) o Documentos (iOS).
- Subida de comprobantes al bucket `payment_receipts` y estados de revisión.

### 7. Historial de pedidos (cliente)
- `CartHistoryCubit` descarga estados ≠ `pending`.
- Detalle del pedido, botones para reabrir checkout o descargar QR.
- Información de comprobantes asociados.

### 8. Compras / Ventas / Transferencias (staff)
- Procesos internos para personal autorizado.
- Estados y validaciones por ubicación asignada.
- Ajuste automático de inventario.

### 9. Reportes
- Reportes de inventario, ventas, compras y transferencias.
- Uso de `fl_chart` para gráficas.
- Filtros por fechas y ubicaciones.

### 10. Sincronización
- `AutoSyncService`: sincronización inicial, periódica y al reanudar.
- `FullSyncService`: sincronización manual con desglose de módulos.
- Indicadores de estado en UI.

### 11. Seguridad y Logging
- RLS en Supabase (inventario, carritos, comprobantes, clientes).
- `AppLogger` con niveles (debug/info/warning/error) y plan para logs estructurados.
- Validaciones en formularios y repositorios (sanitización en progreso).

---

## 🗄️ Base de Datos

El esquema se divide en una persistencia local (Isar) para operación offline y una base remota en Supabase (PostgreSQL) con políticas de seguridad.

### 1. Base local – Isar

Colecciones principales:

1. **UserLocalModel** – usuario autenticado y metadatos locales.  
2. **ProductLocalModel** / **ProductVariantLocalModel** – catálogo y variantes con índices para búsqueda.  
3. **InventoryLocalModel** – stock por ubicación, incluye flags `needsSync`.  
4. **StoreLocalModel** / **WarehouseLocalModel** – ubicaciones con QR asociado.  
5. **CartLocalModel** / **CartItemLocalModel** – carritos offline con historial y fechas de sincronización.  
6. **CustomerLocalModel** – datos del cliente (cuando aplica).  
7. **SyncQueueLocalModel** – cola de sincronización (operaciones pendientes).  
8. **PurchaseLocalModel**, **SaleLocalModel**, **TransferRequestLocalModel** (para staff).

Características:
- Consultas reactivas (`watch()`) conectadas a los BLoC.  
- Transacciones ACID.  
- Generación automática de código con `build_runner`.  
- Persistencia de paths de imágenes/QR para reconstrucción offline.

Archivo clave: `lib/core/database/isar_database.dart`.

### 2. Base remota – Supabase (PostgreSQL)

Tablas relevantes:

- `auth.users` (Supabase Auth) y `public.users` (perfil con rol, ubicación asignada).  
- `public.products`, `public.product_variants`, `public.inventory`.  
- `public.stores`, `public.warehouses` (con ruta del QR en Storage).  
- `public.customers`.  
- `public.carts`, `public.cart_items`, `public.payment_receipts`.  
- `public.purchases`, `public.purchase_items`; `public.sales`, `public.sale_items`.  
- `public.transfer_requests`, `public.transfer_items`.  
- `public.suppliers` (para compras internas).

Buckets de Storage:
- `product-images` – imágenes del catálogo.  
- `payment-qr` – QR por tienda/almacén.  
- `payment_receipts` – comprobantes subidos por clientes.

Políticas RLS (fragmentos en `sql/fase10/02_rls.sql`, `sql/fase2/05_functions.sql`):
- Clientes solo leen/escriben sus carritos y comprobantes.  
- Administradores visualizan todos los datos.  
- Managers restringidos por `assigned_location_id`.  
- Políticas específicas para cada bucket de Storage (insert/update/select).

Sincronización:
- `CartRepositoryImpl` asegura que cada carrito en Isar se refleje en `public.carts`.  
- `FullSyncService` descarga módulos según rol (clientes vs staff).  
- `AutoSyncService` coordina sincronización periódica y al reanudar app.

### 3. Diagrama ER (resumen textual)

```
auth.users ──1:1── public.users (role, location)
public.users ──< public.customers ──< public.carts ──< public.cart_items
                                      └── public.payment_receipts
products ──< product_variants ──< inventory (location_id/location_type)
stores / warehouses ──< inventory
purchases/sales/transfers ──< *_items
```

> Se mantiene un diagrama visual actualizado en `docs/diagramas/erd_munani.png`.

---

## 👥 Usuarios de Prueba

### 🔑 Credenciales de Acceso

| Rol | Email | Contraseña | Notas |
| --- | --- | --- | --- |
| Administrador | `davicho981@gmail.com` | `Npng@06Nov25!X@5` | Asociado a la tienda **TheFriends**. Acceso completo a módulos internos. |
| Cliente | `davidhugor11@gmail.com` | `subzero180818` | Perfil de cliente con acceso a catálogo, carrito, historial y subida de comprobantes. |

> Se pueden crear usuarios adicionales en Supabase para demos (store_manager / warehouse_manager) según se requiera.

### Diferencias por Rol (resumen)

| Funcionalidad | Administrador | Cliente |
| --- | --- | --- |
| Inventario global | ✅ | 🔒 Solo lectura de catálogo |
| Gestión de productos | ✅ | 🔒 |
| Gestión de ubicaciones y QR | ✅ | 🔒 |
| Carrito e historial propio | 🔒 | ✅ |
| Revisar comprobantes | ✅ | 🔒 |
| Reportes y sincronización manual | ✅ | 🔒 |

---

## ⚡ Funcionalidades Principales

### 1. Dashboard según rol
- `CustomerCartPage` y tarjetas de acceso rápido para clientes.
- Vistas administrativas con métricas, sincronización y atajos.
- Implementado en `lib/features/auth/presentation/pages/home_page.dart`.

### 2. Carrito offline con sincronización
- Carrito se guarda en Isar y se marca `needsSync`.
- `CartRepositoryImpl` sincroniza con Supabase cuando hay conectividad.
- Historial de pedidos disponible mediante `CartHistoryCubit`.

### 3. Checkout con QR y comprobantes
- `CartCheckoutPage` genera URL firmada del QR de pago y permite descargarlo a `Download/`.
- Subida de comprobantes a `payment_receipts` con validación.
- Manejo de errores y fallback si el plugin de compartir no está disponible.

### 4. Gestión de productos e inventario
- Formularios con subida de imágenes a `product-images`.
- Actualización de inventario tras cambios en productos (`product_repository_impl.dart`).
- Búsqueda con filtros y watchers de Isar.

### 5. Sincronización automática y manual
- `AutoSyncService` dispara auto-sync al iniciar, cada 5 minutos y al reanudar.
- `FullSyncService` recibe `userRole` y `customerId` para descargar módulos específicos.
- Indicadores visuales de sincronización en UI (`SyncBloc`).

### 6. Seguridad y RLS
- Validaciones de rol en repositorios antes de realizar operaciones sensibles.
- Políticas SQL para limitar accesos (`sql/fase10/02_rls.sql`).
- Logging centralizado (`AppLogger`) con niveles y plan de logs estructurados.

### 7. Reportes y analítica
- Reportes de inventario/ventas/compras/transferencias con `fl_chart`.
- Filtros por fecha, ubicación y estado, orientados al rol administrador.

---

## 🔌 Características Offline-First

### 1. **Detección de Conectividad**

```dart
class NetworkInfo {
  final InternetConnection internetConnection;

  Future<bool> get isConnected async {
    final result = await internetConnection.hasInternetAccess;
    return result;
  }

  Stream<InternetStatus> get onStatusChange =>
      internetConnection.onStatusChange;
}
```

**Código:** `lib/core/network/network_info.dart`

### 2. **Cola de Sincronización**

- Todas las operaciones se guardan localmente primero
- Se marcan como `isSynced: false`
- Auto-sync intenta sincronizar en background
- UI muestra indicador de estado de sincronización

### 3. **Operación Offline Completa**

✅ Crear productos offline
✅ Registrar ventas offline
✅ Solicitar transferencias offline
✅ Ver reportes con datos locales
✅ Búsqueda y filtrado offline

### 4. **Sincronización al Reconectar**

```dart
// Listener de conectividad
networkInfo.onStatusChange.listen((status) {
  if (status == InternetStatus.connected) {
    AppLogger.info('Conexión restaurada, iniciando sync');
    fullSyncService.syncAll();
  }
});
```

### 5. **Indicadores UI**

- Banner de "Sin conexión"
- Ícono de estado de sincronización
- Badges en items no sincronizados
- Progress indicators durante sync

---

## 🔒 Seguridad

### 1. Autenticación
- Supabase Auth (Argon2 + JWT + refresh tokens).
- Sesión persistente encriptada (`Supabase.initialize`).
- Validación de credenciales y mensajes genéricos en UI.

### 2. Control de acceso (RLS)
- Políticas para `inventory`, `carts`, `cart_items`, `payment_receipts`, `customers`, etc.
- Funciones helper `is_admin()`, `is_store_manager()`, `is_customer()` en SQL.
- Roles: `admin`, `store_manager`, `warehouse_manager`, `customer`.

### 3. Storage seguro
- Buckets privados: `product-images`, `payment-qr`, `payment_receipts`.
- Políticas `insert/update/select` por rol (ver `sql/fase10/02_rls.sql`).
- URLs firmadas generadas desde la app (`PaymentQrStorageService`, `ProductImageStorageService`).

### 4. Validación y sanitización
- Validaciones de formularios (`lib/core/utils/validators.dart`, `customer_signup_page.dart`).
- Sanitización adicional planificada para entradas sensibles (A03 OWASP).
- Políticas de contraseña reforzadas en checklist de seguridad.

### 5. Manejo de errores y logging
- Jerarquía de `Failure` (`lib/core/errors/failures.dart`).
- `AppLogger` central con niveles; se planea JSON estructurado para checklist A09.
- Mensajes seguros (sin revelar información sensible).

### 6. Variables de entorno
- `.env` con Supabase URL/Anon Key y nombres de buckets.
- Acceso a través de `flutter_dotenv`; no se versiona.

---

## 📊 Diagramas de Base de Datos

- **ERD actualizado** (`docs/diagramas/erd_munani.png`): muestra relaciones entre usuarios, clientes, carritos, inventario y módulos de compras/ventas/transferencias.
- **Diagrama de flujo de autenticación** (`docs/diagramas/flujo_auth_jwt.png`): login → token → refresh.
- **Diagrama de sincronización** (`docs/diagramas/flujo_sync.png`): colas locales, auto-sync, full-sync según rol.

> Los diagramas originales de la versión “constructora” fueron reemplazados por estos recursos específicos de Munani App V2.

---

## 🚀 Instalación y Ejecución

### Prerrequisitos

- Flutter SDK 3.24.x
- Dart 3.x
- Android Studio / VS Code
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd munani_app_v2
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar variables de entorno**

Crear archivo `.env` en la raíz:
```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
PAYMENT_QR_BUCKET=payment-qr
PRODUCT_IMAGES_BUCKET=product-images
PAYMENT_RECEIPTS_BUCKET=payment_receipts
```

4. **Generar código Isar**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Ejecutar la aplicación**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

### Compilar APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs por arquitectura (más ligero)
flutter build apk --split-per-abi
```

El APK se generará en: `build/app/outputs/flutter-apk/`

---

## 📱 Características de la UI

### Tema y Colores

```dart
class AppColors {
  static const Color primary = Color(0xFFFF6B35);    // Naranja
  static const Color secondary = Color(0xFF004E89);  // Azul oscuro
  static const Color success = Color(0xFF28A745);    // Verde
  static const Color error = Color(0xFFDC3545);      // Rojo
  static const Color warning = Color(0xFFFFC107);    // Amarillo
  static const Color info = Color(0xFF17A2B8);       // Celeste
}
```

**Código:** `lib/core/constants/app_colors.dart`

### Widgets Personalizados

1. **CustomButton**: Botón reutilizable con loading state
2. **CustomTextField**: Campo de texto con validación
3. **CustomerCard**: Tarjeta para mostrar clientes
4. **ProductCard**: Tarjeta para mostrar productos
5. **InventoryCard**: Tarjeta para mostrar inventario
6. **SaleCard**: Tarjeta para mostrar ventas
7. **PurchaseCard**: Tarjeta para mostrar compras

**Código:** `lib/core/widgets/` y `lib/features/*/presentation/widgets/`

### Navegación

```dart
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String sales = '/sales';
  static const String purchases = '/purchases';
  static const String transfers = '/transfers';
  static const String reports = '/reports';
  // ... más rutas
}
```

**Código:** `lib/core/constants/app_routes.dart`

---

## 🧪 Testing

### Tests Implementados

- Unit Tests para Use Cases
- Widget Tests para UI
- Mock Tests con Mocktail

**Ejemplo:**
```dart
test('should get user from repository', () async {
  // Arrange
  when(() => mockRepository.getCurrentUser())
      .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await usecase();

  // Assert
  expect(result, Right(tUser));
  verify(() => mockRepository.getCurrentUser());
});
```

---

## 📝 Notas Adicionales

### Mejoras Futuras Sugeridas

1. ✨ **Notificaciones Push**: Alertas de bajo stock
2. ✨ **Escaneo de códigos de barras**: Para búsqueda rápida
3. ✨ **Firma digital**: Para aprobaciones
4. ✨ **Exportar reportes**: PDF, Excel
5. ✨ **Dashboard analytics**: Métricas avanzadas
6. ✨ **Modo oscuro**: Theme switcher
7. ✨ **Multiidioma**: i18n completo

### Problemas Conocidos

- ⚠️ La sincronización puede tardar con conexiones lentas
- ⚠️ Los reportes con muchos datos pueden ser lentos en móviles antiguos

### Optimizaciones Realizadas

- ✅ Lazy loading de listas
- ✅ Caché de imágenes
- ✅ Índices en queries Isar
- ✅ Debounce en búsquedas
- ✅ Pagination en listas grandes
- ✅ Shimmer effects para loading states

---

## 👨‍💻 Autor

**David Hugo Rivas Gutiérrez**

- Email: davicho981@gmail.com
- Maestría: Full Stack Development
- Materia: Desarrollo Avanzado de Aplicaciones Móviles

---

## 📄 Licencia

Este proyecto fue desarrollado como trabajo final para la materia de Desarrollo Avanzado de Aplicaciones Móviles.

---

## 🙏 Agradecimientos

- Profesor de la materia por la guía
- Comunidad de Flutter
- Documentación de Supabase e Isar
- Stack Overflow y GitHub

---

**Fecha de Entrega**: Octubre 2025
**Versión**: 1.0.0
**Estado**: ✅ Completado

---

_Documento generado automáticamente con documentación del código fuente_
