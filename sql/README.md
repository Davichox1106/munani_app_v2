# 📊 Scripts SQL - Base de Datos

Esta carpeta contiene todos los scripts SQL para configurar la base de datos de Supabase.

---

## 📁 **ESTRUCTURA DE CARPETAS**

```
sql/
├── fase1/          # Usuarios y Autenticación
├── fase2/          # Stores, Warehouses, Products
├── fase4/          # Inventory
├── fase5/          # Transfers + Sistema de Auditoría
└── fixes/          # Scripts de corrección para BD existentes
```

---

## 🚀 **INSTALACIÓN DESDE CERO**

### Orden de ejecución para una base de datos NUEVA:

```bash
1. sql/fase1/00_run_all.sql      # Usuarios, roles, autenticación
2. sql/fase2/00_run_all.sql      # Tiendas, almacenes, productos
3. sql/fase4/00_run_all.sql      # Inventario
4. sql/fase5/00_run_all.sql      # Transferencias + Auditoría completa
```

### ¿Cómo ejecutar?

**Opción A: Usar archivos individuales** (recomendado para desarrollo)
1. Abrir Supabase Dashboard → SQL Editor
2. Ir a cada carpeta `faseX/` en orden
3. Ejecutar los archivos en orden numérico (01, 02, 03...)

**Opción B: Usar `00_run_all.sql`** (recomendado para producción)
1. Abrir Supabase Dashboard → SQL Editor
2. Copiar y pegar el contenido de cada `00_run_all.sql` en orden
3. Ejecutar cada uno completo antes de pasar al siguiente

---

## 🔧 **ACTUALIZACIÓN DE BASE DE DATOS EXISTENTE**

Si ya tienes una base de datos y necesitas actualizarla:

1. **Revisar qué fixes necesitas:**
   - Ver `sql/fixes/README.md` para detalles

2. **Ejecutar solo lo necesario:**
   ```bash
   # Solo si aplica a tu caso:
   sql/fixes/FIX_JWT_ASSIGNED_LOCATION.sql          # Usuarios existentes
   sql/fixes/AGREGAR_LOCATION_NAME_INVENTORY.sql    # Tabla inventory existente
   sql/fase5/06_sistema_de_auditoria.sql            # Agregar auditoría
   ```

---

## 📋 **DESCRIPCIÓN DE CADA FASE**

### **FASE 1 - Usuarios y Autenticación**
**Ubicación:** `sql/fase1/`

**Qué incluye:**
- Tabla `users` con roles (admin, store_manager, warehouse_manager, customer)
- Funciones RLS: `is_admin()`, `is_store_manager()`, etc.
- Trigger `handle_new_user()` para sincronizar `auth.users` con `public.users`
- Políticas RLS para proteger datos de usuarios
- Scripts de setup inicial de admin

**Archivos principales:**
- `00_run_all.sql` - Script maestro ✅ **CORREGIDO**
- `04_functions.sql` - Funciones importantes
- `06_rls_policies.sql` - Políticas de seguridad

---

### **FASE 2 - Stores, Warehouses, Products**
**Ubicación:** `sql/fase2/`

**Qué incluye:**
- Tabla `stores` (tiendas)
- Tabla `warehouses` (almacenes)
- Tabla `products` (productos base)
- Tabla `product_variants` (variantes con SKU)
- Funciones RLS adicionales
- Políticas RLS por rol

**Archivos principales:**
- `00_run_all.sql` - Script maestro
- `02_tables.sql` - Definición de tablas
- `06_rls_policies.sql` - Políticas de seguridad

---

### **FASE 4 - Inventory**
**Ubicación:** `sql/fase4/`

**Qué incluye:**
- Tabla `inventory` con control de stock
- Alertas de stock mínimo/máximo
- Campos de auditoría (`updated_by`, `last_updated`)
- Políticas RLS por ubicación

**Archivos principales:**
- `00_run_all.sql` - Script maestro
- `02_tables.sql` - Definición de tabla inventory
- `04_triggers.sql` - Validaciones automáticas
- `05_rls_policies.sql` - Políticas de seguridad

---

### **FASE 5 - Transfers + Sistema de Auditoría**
**Ubicación:** `sql/fase5/`

**Qué incluye:**
- Tabla `transfers` con flujo completo de aprobación
- Auditoría completa (requested_by, approved_by, rejected_by, etc.)
- **Sistema de Auditoría Completo:**
  - Tabla `audit_log` para historial de TODOS los cambios
  - Triggers automáticos en todas las tablas
  - Funciones de consulta: `get_record_history()`, `get_user_activity()`
  - RLS en audit_log (seguridad por rol)
- Políticas RLS con COALESCE para JWT

**Archivos principales:**
- `00_run_all.sql` - Script maestro (transfers + auditoría)
- `02_tables.sql` - Tabla transfers
- `05_rls_policies.sql` - Políticas RLS con COALESCE ✅ **CORREGIDO**
- `06_sistema_de_auditoria.sql` - Sistema completo de auditoría ✅ **CORREGIDO**

**Características del Sistema de Auditoría:**
- ✅ Registra INSERT, UPDATE, DELETE en todas las tablas
- ✅ Guarda valores anteriores y nuevos en JSON
- ✅ Identifica quién hizo cada cambio
- ✅ RLS habilitado (cada rol ve solo lo que le corresponde)
- ✅ Sin conflictos con triggers existentes
- ✅ Compatible con políticas RLS actuales

---

## 🔒 **SEGURIDAD (RLS - Row Level Security)**

Todas las tablas tienen **RLS habilitado** con políticas por rol:

### **Roles disponibles:**
- `admin` - Acceso completo a todo
- `store_manager` - Acceso a su tienda asignada
- `warehouse_manager` - Acceso a su almacén asignado
- `customer` - Acceso limitado (solo lectura de productos)

### **Cómo funciona:**
1. El rol se almacena en `public.users.role`
2. Se copia al JWT en `app_metadata.user_role`
3. Las funciones RLS leen del JWT (no de la BD)
4. Las políticas filtran automáticamente los datos

### **Ejemplo:**
Un `store_manager` con `assigned_location_id = "uuid-tienda-1"`:
- ✅ Puede ver inventario de su tienda
- ✅ Puede ver transferencias hacia/desde su tienda
- ❌ NO puede ver inventario de otras tiendas
- ❌ NO puede ver transferencias de otros

---

## 📊 **SISTEMA DE AUDITORÍA**

### **¿Qué registra?**
- **Quién:** Usuario que hizo el cambio
- **Qué:** Tabla y registro modificado
- **Cuándo:** Timestamp preciso
- **Cómo:** Operación (INSERT/UPDATE/DELETE)
- **Antes/Después:** Valores antiguos y nuevos en JSON

### **¿Dónde se guarda?**
Tabla `audit_log` con las siguientes columnas:
- `id` - UUID único
- `table_name` - Nombre de la tabla
- `record_id` - UUID del registro
- `operation` - INSERT, UPDATE o DELETE
- `old_values` - JSON con valores anteriores
- `new_values` - JSON con valores nuevos
- `changed_by` - UUID del usuario
- `changed_by_name` - Nombre del usuario
- `changed_at` - Timestamp

### **¿Cómo consultarlo?**
```sql
-- Ver historial de un producto
SELECT * FROM get_record_history('products', 'uuid-del-producto');

-- Ver actividad de un usuario en los últimos 7 días
SELECT * FROM get_user_activity('uuid-del-usuario', 7);

-- Ver todos los cambios recientes (solo verás los permitidos por RLS)
SELECT * FROM audit_log ORDER BY changed_at DESC LIMIT 50;
```

---

## 🛠️ **FIXES DISPONIBLES**

Ver `sql/fixes/README.md` para lista completa de fixes disponibles.

**Fixes importantes:**
- `FIX_JWT_ASSIGNED_LOCATION.sql` - Actualizar JWT de usuarios existentes
- `AGREGAR_LOCATION_NAME_INVENTORY.sql` - Agregar campo faltante

---

## ✅ **VERIFICACIÓN POST-INSTALACIÓN**

Después de ejecutar todos los scripts, verifica:

```sql
-- 1. Verificar que todas las tablas existen
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. Verificar que RLS está habilitado
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- 3. Contar políticas RLS por tabla
SELECT tablename, COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- 4. Verificar triggers de auditoría
SELECT tgrelid::regclass AS tabla, COUNT(*) as triggers
FROM pg_trigger
WHERE tgname LIKE 'trg_audit_%'
GROUP BY tgrelid
ORDER BY tabla;

-- 5. Verificar funciones RLS
SELECT proname FROM pg_proc
WHERE proname IN ('is_admin', 'is_store_manager', 'is_warehouse_manager', 'is_admin_or_manager');
```

**Resultados esperados:**
- 9 tablas: users, stores, warehouses, products, product_variants, inventory, transfers, audit_log
- RLS habilitado en todas
- ~30-40 políticas RLS en total
- 7 triggers de auditoría (trg_audit_*)
- 4 funciones RLS

---

## 🐛 **SOLUCIÓN DE PROBLEMAS**

### Problema: "No se descargan las transferencias"
**Solución:** Ejecutar `sql/fixes/FIX_JWT_ASSIGNED_LOCATION.sql`

### Problema: "location_name aparece vacío en inventory"
**Solución:** Ejecutar `sql/fixes/AGREGAR_LOCATION_NAME_INVENTORY.sql`

### Problema: "Permission denied for table X"
**Solución:** Verificar que RLS está habilitado y que el usuario tiene el rol correcto en JWT

### Problema: "Function is_admin() does not exist"
**Solución:** Ejecutar `sql/fase1/04_functions.sql` y `sql/fase2/05_functions.sql`

---

## 📚 **DOCUMENTACIÓN ADICIONAL**

- **Arquitectura general:** Ver comentarios en cada archivo SQL
- **RLS Policies:** Ver archivos `*_rls_policies.sql` en cada fase
- **Sistema de Auditoría:** Ver `sql/fase5/06_sistema_de_auditoria.sql`
- **Fixes disponibles:** Ver `sql/fixes/README.md`

---

## 🎯 **PRÓXIMOS PASOS**

Después de ejecutar los scripts:

1. **Crear primer usuario admin:**
   - Usar Supabase Dashboard → Authentication → Add User
   - Ejecutar `sql/fase1/08_setup_first_admin.sql`

2. **Crear tiendas y almacenes:**
   - Desde la app Flutter con usuario admin

3. **Asignar usuarios a ubicaciones:**
   - Editar usuarios y asignar `assigned_location_id`

4. **Probar la app:**
   - Login con diferentes roles
   - Verificar que cada rol ve solo sus datos

---

**Última actualización:** 26 de Octubre 2024
**Versión:** 1.0 (Con sistema de auditoría integrado)
