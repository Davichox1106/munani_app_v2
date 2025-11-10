# 🔧 Carpeta FIXES - Scripts de Corrección

Esta carpeta contiene scripts para **ACTUALIZAR** bases de datos existentes que fueron creadas con versiones anteriores de los scripts.

---

## ✅ **ARCHIVOS DISPONIBLES**

### 1. **`FIX_JWT_ASSIGNED_LOCATION.sql`**

**Propósito:** Agregar `assigned_location_id` al JWT de usuarios existentes

**Cuándo ejecutar:**
- Si ya tienes usuarios en la base de datos
- Si las transferencias NO se están sincronizando
- Si los usuarios fueron creados ANTES de actualizar `handle_new_user()`

**Qué hace:**
- Actualiza `raw_app_meta_data` en `auth.users`
- Agrega `assigned_location_id` y `assigned_location_type` al JWT
- Sincroniza datos de `public.users` con `auth.users`

**Cómo ejecutar:**
1. Abrir Supabase Dashboard → SQL Editor
2. Copiar y pegar TODO el contenido del archivo
3. Ejecutar (Run)
4. Verificar que todos los usuarios muestran `✅ CORRECTO`
5. Reiniciar la app Flutter y hacer login nuevamente

---

### 2. **`AGREGAR_LOCATION_NAME_INVENTORY.sql`**

**Propósito:** Agregar campo `location_name` a tabla `inventory` existente

**Cuándo ejecutar:**
- Si ya tienes registros en la tabla `inventory`
- Si `location_name` está vacío o NULL en la app
- Si creaste la tabla ANTES de la versión que incluye este campo

**Qué hace:**
- Agrega columna `location_name` si no existe
- Actualiza registros existentes con nombres de stores/warehouses
- Verifica que todos los registros tengan nombre

**Cómo ejecutar:**
1. Abrir Supabase Dashboard → SQL Editor
2. Copiar y pegar TODO el contenido del archivo
3. Ejecutar (Run)
4. Verificar los resultados del SELECT final

---

## ⚠️ **IMPORTANTE**

### Para bases de datos NUEVAS:
**NO EJECUTAR ESTOS FIXES**

Si estás instalando desde cero, estos fixes ya están integrados en:
- `sql/fase1/00_run_all.sql` (ya incluye assigned_location_id en JWT)
- `sql/fase4/02_tables.sql` (ya incluye location_name en inventory)

### Para bases de datos EXISTENTES:
**EJECUTAR SOLO SI APLICAN**

1. Revisa si necesitas cada fix antes de ejecutarlo
2. Ejecuta en el orden listado arriba
3. Verifica los resultados después de cada fix

---

## 📊 **ARCHIVOS ELIMINADOS (Obsoletos)**

Los siguientes archivos fueron **BORRADOS** porque ya no son necesarios:

- ❌ `FIX_RLS_FUNCTIONS.sql` - Las funciones RLS ya funcionan correctamente
- ❌ `ACTUALIZAR_AUDITORIA_TRANSFERS.sql` - Ya incluido en fase5
- ❌ `ACTUALIZAR_AUDITORIA_TODAS_TABLAS.sql` - Reemplazado por fase5/06_sistema_de_auditoria.sql
- ❌ `DEBUG_TRANSFERS_RLS.sql` - Solo era para debug temporal
- ❌ `TEST_RLS_CONTEXT.sql` - Solo era para testing
- ❌ `TEST_RLS_WITH_MOCK_JWT.sql` - Solo era para testing
- ❌ `DEBUG_IS_STORE_MANAGER.sql` - Solo era para debug temporal

Si necesitas estos archivos por alguna razón, puedes recuperarlos del historial de git.

---

## 🎯 **ORDEN DE EJECUCIÓN COMPLETO**

### Base de datos NUEVA (instalación completa):
```bash
1. sql/fase1/00_run_all.sql
2. sql/fase2/00_run_all.sql
3. sql/fase4/00_run_all.sql
4. sql/fase5/00_run_all.sql                    # ✅ Incluye transfers + auditoría
# NO ejecutar ningún fix de esta carpeta
```

### Base de datos EXISTENTE (actualización):
```bash
# Primero actualiza los scripts principales si es necesario
# Luego ejecuta los fixes que apliquen:

1. sql/fixes/FIX_JWT_ASSIGNED_LOCATION.sql          # ✅ Si ya tienes usuarios
2. sql/fixes/AGREGAR_LOCATION_NAME_INVENTORY.sql    # ✅ Si la tabla inventory existe
3. sql/fase5/06_sistema_de_auditoria.sql            # ✅ Para agregar auditoría completa
```

---

## 📝 **Verificación Post-Fix**

Después de ejecutar los fixes, verifica:

```sql
-- 1. Verificar JWT de usuarios
SELECT
  email,
  raw_app_meta_data->>'user_role' as role,
  raw_app_meta_data->>'assigned_location_id' as location_id
FROM auth.users;

-- 2. Verificar location_name en inventory
SELECT
  location_type,
  location_name,
  COUNT(*)
FROM inventory
GROUP BY location_type, location_name;

-- 3. Verificar que transfers se descargan
-- (Desde la app Flutter, ir a módulo Transferencias)
```

---

**Última actualización:** 26 de Octubre 2024
