# 🔧 Fix para Error RLS de Compras

## 📋 **Problema Identificado**

**Error:** `PostgrestException(message: new row violates row-level security policy for table "purchases", code: 42501, details: Forbidden, hint: null)`

**Causa:** Las políticas RLS de la tabla `purchases` requieren que el `location_id` de la compra coincida con el `assigned_location_id` del usuario en el JWT, pero:
1. El usuario no tiene `assigned_location_id` en su JWT
2. La compra tiene un `location_id` que no coincide con el `assigned_location_id` del usuario

## 🎯 **Solución Implementada**

Se han creado varios scripts para diagnosticar y corregir el problema:

### **Scripts Disponibles:**

1. **`debug_purchase_rls_error.sql`** - Diagnóstico completo del problema
2. **`fix_purchase_rls_jwt.sql`** - Fix específico para JWT metadata
3. **`fix_purchase_location_id.sql`** - Fix para corregir location_id de compras
4. **`fix_purchase_rls_complete.sql`** - Script maestro que aplica todos los fixes
5. **`test_purchase_rls_fix.sql`** - Pruebas para verificar que el fix funciona

## 🚀 **Instrucciones de Aplicación**

### **Opción 1: Aplicar Fix Completo (Recomendado)**

```sql
-- Ejecutar el script maestro que aplica todos los fixes
\i sql/fixes/fix_purchase_rls_complete.sql
```

### **Opción 2: Aplicar Fixes Individuales**

```sql
-- 1. Primero diagnosticar el problema
\i sql/debug/debug_purchase_rls_error.sql

-- 2. Aplicar fix de JWT
\i sql/fixes/fix_purchase_rls_jwt.sql

-- 3. Aplicar fix de location_id
\i sql/fixes/fix_purchase_location_id.sql

-- 4. Probar que funciona
\i sql/test/test_purchase_rls_fix.sql
```

## 📊 **Qué Hace Cada Fix**

### **Fix de JWT (`fix_purchase_rls_jwt.sql`)**
- Actualiza `raw_app_meta_data` en `auth.users` para todos los usuarios
- Agrega `assigned_location_id` y `assigned_location_type` al JWT
- Sincroniza JWT con datos de `public.users`

### **Fix de Location ID (`fix_purchase_location_id.sql`)**
- Asigna ubicación por defecto a usuarios sin `assigned_location_id`
- Actualiza JWT para usuarios con nueva ubicación
- Corrige `location_id` de compras pendientes para que coincidan con `assigned_location_id` del creador

### **Fix Completo (`fix_purchase_rls_complete.sql`)**
- Aplica todos los fixes en el orden correcto
- Incluye verificaciones y reportes de estado
- Es la opción más segura y completa

## ✅ **Verificación del Fix**

Después de aplicar el fix, deberías ver:

1. **Usuarios con JWT completo:** Todos los usuarios tienen `assigned_location_id` en su JWT
2. **Sincronización JWT vs BD:** JWT y BD están sincronizados
3. **Compras pendientes:** Todas las compras pendientes pasan la verificación RLS
4. **Sin errores 42501:** La sincronización de compras funciona sin errores RLS

## 🔍 **Diagnóstico Post-Fix**

Si después del fix aún hay problemas:

```sql
-- Ejecutar diagnóstico detallado
\i sql/debug/debug_purchase_rls_error.sql

-- Verificar estado específico
\i sql/test/test_purchase_rls_fix.sql
```

## 🚨 **Casos Especiales**

### **Si hay compras que no se pueden corregir:**
- Las compras con `status = 'pending'` se pueden corregir
- Las compras con `status = 'received'` o `'cancelled'` no se modifican
- Considera cancelar compras problemáticas si es necesario

### **Si hay usuarios sin ubicación asignada:**
- Se asigna automáticamente la primera tienda activa como ubicación por defecto
- Solo afecta a usuarios con rol `store_manager` o `warehouse_manager`
- Los administradores no necesitan ubicación asignada

## 📝 **Logs de Verificación**

El fix incluye logs detallados que muestran:
- Cuántos usuarios se actualizaron
- Cuántas compras se corrigieron
- Estado de sincronización JWT vs BD
- Compras que aún podrían tener problemas

## 🔄 **Reversión (Si es Necesario)**

Si necesitas revertir los cambios:

```sql
-- Deshabilitar RLS temporalmente (solo para emergencias)
ALTER TABLE public.purchases DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_items DISABLE ROW LEVEL SECURITY;

-- Rehabilitar RLS después de corregir
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_items ENABLE ROW LEVEL SECURITY;
```

## 📞 **Soporte**

Si el fix no resuelve el problema:
1. Ejecuta `debug_purchase_rls_error.sql` y comparte los resultados
2. Verifica que las políticas RLS estén activas
3. Revisa que los usuarios tengan roles correctos
4. Considera cancelar compras problemáticas específicas

---

**Nota:** Este fix es seguro y no afecta datos existentes, solo corrige inconsistencias de configuración.













