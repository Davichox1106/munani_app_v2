# CHECKLIST PENDIENTE - PROYECTO FINAL
## Seguridad en Aplicaciones Web y Móviles Full Stack

---

## 📋 RESUMEN DEL PROYECTO

**Sistema:** Munani E-Commerce - Sistema de Gestión de Barritas Nutritivas
**Tecnología:** Flutter + Supabase (PostgreSQL)
**Arquitectura:** Offline-First con Sincronización Bidireccional

---

## ✅ REQUISITOS COMPLETADOS

### 1. Nombre y Descripción del Sistema ✅
- [x] Sistema E-commerce Full Stack para barritas nutritivas
- [x] Arquitectura Offline-First con Isar (local) + Supabase (remoto)
- [x] Módulos: Productos, Inventario, Ventas, Compras, Transferencias, Usuarios, Clientes, Carrito
- [x] 12 módulos con sincronización reactiva bidireccional

### 2. Descripción de Tecnología ✅
- [x] **Frontend:** Flutter 3.35.2 + Dart 3.9.0
- [x] **Backend:** Supabase (PostgreSQL + Auth + Storage + Realtime)
- [x] **Base de datos local:** Isar 3.1.0 (NoSQL embedded)
- [x] **Estado:** Flutter Bloc 8.1.6
- [x] **Networking:** Dio 5.7.0 + Connectivity Plus
- [x] **Seguridad:** Row Level Security (RLS), JWT, Argon2

---

## ❌ REQUISITOS PENDIENTES

### 3.1 Gestión de Usuarios - A07: Fallas de Identificación ⚠️

#### ✅ **IMPLEMENTADO:**
- [x] User ID formato UUID (no secuencial)
- [x] ABM de usuarios (altas, bajas, modificaciones)
- [x] Registro de usuarios con validación
- [x] Roles: admin, store_manager, warehouse_manager, customer

#### ❌ **PENDIENTE:**
- [ ] **Documento:** Captura de pantalla del código de ABM de usuarios
- [ ] **Documento:** Diagrama de flujo de creación de usuarios
- [ ] **Video:** Demostración de crear, editar y desactivar usuarios

**Archivos relevantes:**
- `lib/features/users/presentation/bloc/user_management_bloc.dart`
- `lib/features/auth/presentation/pages/customer_signup_page.dart`
- `sql/fase1/04_functions.sql` (función `handle_new_user`)

---

### 3.2 Gestión de Contraseñas - A07: Fallas de Autenticación ⚠️

#### ✅ **IMPLEMENTADO (ACTUALIZADO):**
- [x] Contraseñas Argon2 (Supabase Auth) y longitud mínima 8 caracteres.
- [x] `PasswordValidator` con reglas NIST/OWASP (mayúsculas, minúsculas, números, símbolos, blacklist, patrones).
- [x] `PasswordStrengthIndicator` en registro de cliente y formulario admin “Nuevo Usuario”.
- [x] `RateLimiterService`: 5 intentos fallidos → bloqueo exponencial (5, 10, 20, 60 min) + logging.
- [x] Login sanitiza entradas, informa intentos restantes y bloqueos en cada fallo.
- [x] “Olvidé mi contraseña” sanitiza email y valida entradas antes de enviar el reset.
- [x] Registro de clientes inicia sesión temporalmente para insertar en `public.customers`.
- [x] Autenticación JWT y refresh tokens (vigente).

#### ⚠️ **PENDIENTE:**
- [ ] Capturas de validación (signup cliente, creación admin, indicador de fuerza).
- [ ] Evidencia del bloqueo por intentos fallidos (captura/log).
- [ ] Video demostrativo (login fallido, bloqueo, registro con indicador).
- [ ] (Opcional) Configurar y documentar MFA (TOTP/SMS) en Supabase.

**Archivos actualizados:**
- `lib/core/utils/password_validator.dart`
- `lib/core/widgets/password_strength_indicator.dart`
- `lib/core/services/rate_limiter_service.dart`
- `lib/features/auth/presentation/pages/customer_signup_page.dart`
- `lib/features/users/presentation/pages/user_form_page.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/core/di/injection_container.dart`
- `pubspec.yaml` (shared_preferences)

---

### 3.3 Gestión de Roles - A01: Pérdida de Control de Acceso ⚠️

#### ✅ **IMPLEMENTADO:**
- [x] Sistema de roles: admin, store_manager, warehouse_manager, customer
- [x] RLS (Row Level Security) en PostgreSQL
- [x] Funciones helper: `is_admin()`, `is_store_manager()`, `is_warehouse_manager()`
- [x] Matriz de permisos en base de datos

#### ❌ **PENDIENTE:**
- [ ] **Documento:** Tabla/Matriz completa de roles y permisos por módulo
- [ ] **Documento:** Capturas de código de políticas RLS
- [ ] **Documento:** Diagrama de arquitectura de seguridad
- [ ] **Video:** Demostración de acceso por roles (admin vs cliente)

**Matriz de roles a documentar:**

| Módulo | Admin | Store Manager | Warehouse Manager | Customer |
|--------|-------|---------------|-------------------|----------|
| Productos | CRUD | R | R | R |
| Inventario | CRUD | R (solo tienda) | R (solo almacén) | R (catálogo) |
| Transferencias | CRUD | CRUD (tienda) | CRUD (almacén) | - |
| Ventas | CRUD | CRUD (su tienda) | R | - |
| Compras | CRUD | R | CRUD (su almacén) | - |
| Usuarios | CRUD | - | - | - |
| Carrito | R | R | R | CRUD (propio) |
| Clientes | CRUD | R (su tienda) | R (su almacén) | R (propio) |

**Archivos relevantes:**
- `sql/fase2/05_functions.sql` - Funciones RLS
- `sql/fase4/05_rls_policies.sql` - Políticas de inventario
- `sql/fase9/02_policies.sql` - Políticas de clientes
- `sql/fase10/02_rls.sql` - Políticas de carrito

---

### 3.4 Criptografía - A02: Fallas Criptográficas ✅

#### ✅ **IMPLEMENTADO:**
- [x] Argon2 para contraseñas (Supabase Auth)
- [x] TLS 1.3 en todas las comunicaciones (Supabase)
- [x] JWT con firma HMAC-SHA256
- [x] Variables de entorno cifradas (.env)
- [x] Tokens de sesión seguros

#### ❌ **PENDIENTE:**
- [ ] **Documento:** Captura de configuración de TLS en Supabase
- [ ] **Documento:** Captura de código de manejo de .env
- [ ] **Documento:** Diagrama de flujo de autenticación con JWT
- [ ] **Video:** Demostración de login y verificación de token

**Archivos relevantes:**
- `.env` - Variables de entorno
- `lib/core/config/supabase_config.dart`
- `sql/fase1/04_functions.sql` - JWT metadata

---

### 3.5 Principios de Diseño y Desarrollo Seguro ⚠️

#### ✅ **IMPLEMENTADO:**
- [x] Clean Architecture (separación de capas)
- [x] Validación de entrada en todos los formularios
- [x] Fail Secure (errores seguros, no exponen información)
- [x] Principio de menor privilegio (RLS)
- [x] Separación de entornos (dev/prod)

#### ❌ **PENDIENTE:**
- [ ] **Documento:** Diagrama de arquitectura Clean Architecture
- [ ] **Documento:** Capturas de validación de formularios
- [ ] **Documento:** Ejemplos de manejo de errores seguro
- [ ] **Documento:** Threat Modeling (STRIDE/DREAD)

**Archivos para documentar:**
- `lib/core/error/failures.dart` - Manejo de errores
- `lib/features/*/presentation/pages/*.dart` - Validaciones de formularios
- `lib/core/utils/app_logger.dart` - Logging seguro

---

### 3.6 Checklist OWASP Top 10 - Seleccionar 2 de: A03, A04, A05, A06, A08, A09, A10 ❌

#### **OPCIÓN RECOMENDADA 1: A03 - Inyección de Código** ⚠️

##### ✅ **IMPLEMENTADO:**
- [x] Uso de prepared statements (Supabase) y filtros tipados en Isar.
- [x] Validaciones en formularios + políticas de contraseña reforzada.
- [x] Utilidad `InputSanitizer` para limpiar entradas (texto libre, email, CI, teléfono, direcciones).
- [x] Sanitización aplicada en formularios sensibles (`customer_signup_page.dart`, `user_form_page.dart`) y antes de persistir (`CustomerRepositoryImpl`).
- [x] Detección de patrones peligrosos (`InputSanitizer.isSafeText`) con mensajes preventivos.

##### ⚠️ **PENDIENTE:**
- [ ] Capturas/ evidencias de sanitización (formularios, logs).
- [ ] Documentar snippet de `InputSanitizer` en el PDF.
- [ ] (Opcional) Añadir pruebas unitarias específicas para sanitización.
- [ ] Actualizar video demostrativo mostrando entradas maliciosas bloqueadas.

**Archivos a documentar:**
- `lib/features/products/data/repositories/product_repository_impl.dart` - Queries seguras
- `lib/features/customers/presentation/pages/customer_form_page.dart` - Validaciones

---

#### **OPCIÓN RECOMENDADA 2: A09 - Fallas en Registro y Monitoreo** ✅

##### ✅ **IMPLEMENTADO (ACTUALIZADO):**
- [x] Logging con `AppLogger` personalizado
- [x] Logs estructurados con niveles (debug, info, warning, error, fatal)
- [x] **Logs en formato JSON estructurado para eventos de seguridad**
- [x] **Almacenamiento persistente en archivos** (`security_YYYY-MM-DD.log` y `general_YYYY-MM-DD.log`)
- [x] **Retención automática de logs (30 días)** con limpieza automática
- [x] **Redacción automática de datos sensibles** (contraseñas, tokens, API keys, JWT, emails)
- [x] **Logging de eventos de seguridad** con `SecurityEventType` enum
- [x] **Niveles de severidad** (LOW, MEDIUM, HIGH, CRITICAL)
- [x] **Integración con AuthBloc**: login exitoso/fallido, bloqueos por rate limiting, logout
- [x] **Integración con UserManagementBloc**: creación, modificación y desactivación de usuarios
- [x] Trazabilidad de operaciones (createdBy, updatedAt)
- [x] Logs de sincronización
- [x] Métodos de exportación (`getSecurityLogs()`, `exportSecurityLogs()`)

##### ⚠️ **PENDIENTE (DOCUMENTACIÓN):**
- [ ] **Documento:** Capturas de logs estructurados (archivos JSON)
- [ ] **Documento:** Captura de redacción de datos sensibles
- [ ] **Documento:** Tabla de eventos de seguridad implementados
- [ ] **Video:** Demostración de auditoría de eventos (login, creación de usuario, logs generados)
- [ ] (Opcional) Dashboard de monitoreo visual
- [ ] (Opcional) Alertas en tiempo real

**Eventos de seguridad implementados:**
- ✅ `loginAttempt` - Login exitoso/fallido con metadata (intentos, rol)
- ✅ `loginBlocked` - Bloqueo por rate limiting con tiempo restante
- ✅ `logout` - Cierre de sesión
- ✅ `userCreation` - Creación de usuario con rol y ubicación
- ✅ `userModification` - Modificación de usuario (nombre, rol, permisos)
- ✅ `userDeletion` - Desactivación de usuario
- ⏳ `permissionChange` - Cambio de permisos (futuro)
- ⏳ `accessDenied` - Acceso denegado 403/401 (futuro)
- ⏳ `sensitiveOperation` - Operaciones sensibles (futuro)
- ⏳ `dataExport` - Exportación de datos (futuro)

**Archivos modificados:**
- ✅ `lib/core/utils/app_logger.dart` - Sistema completo de logging con JSON y redacción
- ✅ `lib/features/auth/presentation/bloc/auth_bloc.dart` - Logs de autenticación
- ✅ `lib/features/users/presentation/bloc/user_management_bloc.dart` - Logs de gestión de usuarios
- ✅ `lib/main.dart` - Inicialización del sistema de logging

**Ejemplo de log JSON generado:**
```json
{
  "timestamp": "2025-01-10T10:30:45.123Z",
  "eventType": "loginAttempt",
  "severity": "MEDIUM",
  "userId": "uuid-123",
  "userEmail": "adm***@munani.com",
  "success": true,
  "details": "Login exitoso - Rol: admin",
  "metadata": {
    "role": "admin",
    "userName": "Admin User"
  }
}
```

**Ubicación de logs:**
```
{app_documents_directory}/logs/
  ├── security_2025-01-10.log (JSON estructurado)
  └── general_2025-01-10.log (Logs generales)
```

---

#### **OPCIÓN ALTERNATIVA: A05 - Configuración de Seguridad Incorrecta** ⚠️

##### ✅ **IMPLEMENTADO:**
- [x] Separación de entornos (.env)
- [x] CORS configurado en Supabase
- [x] Deshabilitación de debug mode en producción
- [x] Validación de certificados SSL

##### ❌ **PENDIENTE:**
- [ ] **Implementar:** Headers de seguridad (CSP, X-Frame-Options, HSTS)
- [ ] **Implementar:** Configuración de CORS estricta (solo dominios permitidos)
- [ ] **Implementar:** Deshabilitación de stack traces en producción
- [ ] **Documento:** Capturas de configuración de seguridad
- [ ] **Documento:** Checklist de hardening de servidor
- [ ] **Video:** Verificación de headers de seguridad

**TODO - Configurar en Supabase:**
```sql
-- Agregar headers de seguridad en Supabase Edge Functions
CREATE OR REPLACE FUNCTION add_security_headers()
RETURNS trigger AS $$
BEGIN
  PERFORM set_config('response.headers',
    'X-Frame-Options: DENY, X-Content-Type-Options: nosniff, X-XSS-Protection: 1; mode=block',
    true);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## 📦 ENTREGABLES PENDIENTES

### 1. Documento PDF ❌
**Nombre:** `EF-DavidChoqueCalle.pdf`

**Contenido:**
- [ ] Portada con nombre del proyecto
- [ ] 1. Descripción del sistema (1-2 páginas)
  - [ ] Objetivo del sistema
  - [ ] Módulos y funcionalidades (lista con capturas)
  - [ ] Arquitectura general (diagrama)
- [ ] 2. Tecnologías utilizadas (1 página)
  - [ ] Stack tecnológico
  - [ ] Justificación de elección
  - [ ] Versiones de librerías
- [ ] 3.1 Gestión de usuarios (2-3 páginas)
  - [ ] Capturas de código ABM
  - [ ] Capturas de pantalla de funcionalidad
  - [ ] Diagrama de flujo
- [ ] 3.2 Gestión de contraseñas (2-3 páginas)
  - [ ] Capturas de políticas implementadas
  - [ ] Capturas de código de validación
  - [ ] Configuración de MFA
- [ ] 3.3 Gestión de roles (2-3 páginas)
  - [ ] Matriz de roles y permisos (tabla completa)
  - [ ] Capturas de código RLS
  - [ ] Capturas de funcionalidad por rol
- [ ] 3.4 Criptografía (2 páginas)
  - [ ] Capturas de configuración TLS
  - [ ] Código de manejo de secrets
  - [ ] Diagrama de autenticación JWT
- [ ] 3.5 Principios de diseño seguro (2 páginas)
  - [ ] Diagrama de Clean Architecture
  - [ ] Capturas de validaciones
  - [ ] Ejemplos de fail secure
- [ ] 3.6 Checklist OWASP (4-6 páginas)
  - [ ] A03 Inyección: Capturas de queries seguras
  - [ ] A09 Logging: Capturas de logs estructurados
  - [ ] Código de implementación
  - [ ] Pruebas de seguridad

---

### 2. Video Demostración ❌
**Duración:** Máximo 10 minutos
**Plataforma:** YouTube/Google Drive

**Contenido a demostrar:**
- [ ] Minuto 0-1: Introducción al sistema
- [ ] Minuto 1-2: Login y autenticación (admin y cliente)
- [ ] Minuto 2-3: Gestión de usuarios (crear, editar, desactivar)
- [ ] Minuto 3-4: Gestión de roles (acceso admin vs cliente)
- [ ] Minuto 4-5: Operaciones CRUD por rol
- [ ] Minuto 5-6: Sincronización offline-first
- [ ] Minuto 6-7: Logging y auditoría
- [ ] Minuto 7-8: Prevención de inyección SQL
- [ ] Minuto 8-9: Manejo de errores seguro
- [ ] Minuto 9-10: Conclusiones

**TODO:**
- [ ] Grabar video con OBS Studio o similar
- [ ] Subir a YouTube (no listado) o Google Drive
- [ ] Agregar enlace en el documento PDF

---

### 3. Recursos en la Nube ❌

#### **Código fuente:**
- [ ] Subir a GitHub (público o privado con acceso)
- [ ] Incluir README.md con instrucciones
- [ ] Agregar enlace en documento

#### **APK Release:**
- [ ] Generar APK release firmado
- [ ] Subir a Google Drive/Dropbox
- [ ] Agregar enlace de descarga en documento

**Comando para generar APK:**
```bash
flutter build apk --release
```

**Ubicación del APK:**
```
build/app/outputs/flutter-apk/app-release.apk
```

#### **Base de datos:**
- [ ] Exportar schema de PostgreSQL (Supabase)
- [ ] Exportar schema de Isar
- [ ] Crear diagrama ERD
- [ ] Subir scripts SQL a repositorio

**Script para exportar schema:**
```bash
# En Supabase SQL Editor
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

#### **Credenciales de prueba:**
- [ ] Crear usuarios de prueba en Supabase
- [ ] Documentar credenciales en el PDF

**Usuarios sugeridos:**
```
Admin:
  Email: admin@munani.com
  Password: Admin@2025

Store Manager:
  Email: manager@munani.com
  Password: Manager@2025

Cliente:
  Email: cliente@munani.com
  Password: Cliente@2025
```

#### **Enlaces a incluir en documento:**
- [ ] GitHub: https://github.com/tu-usuario/munani_app_v2
- [ ] APK: https://drive.google.com/file/d/...
- [ ] Video: https://youtu.be/...
- [ ] Documentación adicional: https://...

---

## 🚀 PLAN DE ACCIÓN RECOMENDADO

### **Semana 1: Implementaciones Pendientes**
1. ✅ Agregar políticas RLS faltantes (ya hecho)
2. ❌ Implementar validación de complejidad de contraseñas
3. ❌ Agregar rate limiting para login
4. ❌ Implementar logging de seguridad estructurado
5. ❌ Agregar sanitización de input

### **Semana 2: Documentación**
1. ❌ Crear matriz de roles y permisos
2. ❌ Documentar arquitectura de seguridad
3. ❌ Capturar pantallas de código relevante
4. ❌ Crear diagramas (ERD, arquitectura, flujos)
5. ❌ Redactar documento PDF completo

### **Semana 3: Video y Entregables**
1. ❌ Generar APK release
2. ❌ Grabar video de demostración
3. ❌ Subir recursos a la nube
4. ❌ Revisar checklist completo
5. ❌ Entrega final

---

## 📌 NOTAS IMPORTANTES

1. **Prioridad Alta:**
   - Implementar validación de contraseñas complejas
   - Agregar logging de eventos de seguridad
   - Completar matriz de roles
   - Generar APK release

2. **Prioridad Media:**
   - Implementar MFA (opcional pero recomendado)
   - Configurar headers de seguridad
   - Mejorar documentación de código

3. **Prioridad Baja:**
   - Dashboard de monitoreo
   - Alertas automáticas
   - Pruebas de penetración

---

## 📊 PROGRESO ACTUAL

| Sección | Completado | Pendiente | Progreso |
|---------|-----------|-----------|----------|
| 3.1 Gestión de usuarios | 70% | Documentación | 🟡 |
| 3.2 Gestión de contraseñas | 40% | MFA + Validación | 🔴 |
| 3.3 Gestión de roles | 80% | Documentación | 🟢 |
| 3.4 Criptografía | 90% | Documentación | 🟢 |
| 3.5 Diseño seguro | 80% | Documentación | 🟢 |
| 3.6 A03 Inyección | 60% | Sanitización | 🟡 |
| 3.6 A09 Logging | 95% | Documentación | 🟢 |
| Documento PDF | 0% | Todo | 🔴 |
| Video | 0% | Todo | 🔴 |
| APK + Recursos | 0% | Todo | 🔴 |

**Leyenda:**
- 🟢 Verde: 80-100% completo
- 🟡 Amarillo: 50-79% completo
- 🔴 Rojo: 0-49% completo

---

## ✅ CHECKLIST FINAL ANTES DE ENTREGAR

- [ ] Documento PDF nombrado correctamente: `EF-DavidChoqueCalle.pdf`
- [ ] Todas las capturas de pantalla incluidas y legibles
- [ ] Código fuente en GitHub con README
- [ ] APK release generado y subido
- [ ] Video grabado y enlace funcional
- [ ] Credenciales de prueba documentadas
- [ ] Todos los enlaces verificados y funcionales
- [ ] Revisión de ortografía y formato
- [ ] Verificación de checklist OWASP completo
- [ ] Backup de todos los archivos

---

**Generado:** 2025-01-09
**Autor:** Sistema de Análisis
**Proyecto:** Munani E-Commerce App
