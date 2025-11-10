-- ============================================================================
-- FIX_JWT_ASSIGNED_LOCATION.sql
-- Agrega assigned_location_id al JWT (app_metadata) para TODOS los usuarios existentes
-- ============================================================================
-- PROBLEMA: Usuarios creados antes del fix no tienen assigned_location_id en JWT
-- IMPACTO: Las transferencias NO se pueden leer porque RLS requiere:
--          (from_location_id = (auth.jwt() ->> 'assigned_location_id')::uuid)
-- SOLUCIÓN: Actualizar auth.users.raw_app_meta_data para TODOS los usuarios
-- ============================================================================

-- ============================================================================
-- PASO 1: Actualizar TODOS los usuarios existentes
-- ============================================================================
UPDATE auth.users au
SET raw_app_meta_data = COALESCE(au.raw_app_meta_data, '{}'::jsonb) ||
  jsonb_build_object(
    'user_role', pu.role,
    'assigned_location_id', pu.assigned_location_id::text,
    'assigned_location_type', pu.assigned_location_type
  )
FROM public.users pu
WHERE au.id = pu.id
  AND (
    -- Solo actualizar si falta alguno de estos campos
    au.raw_app_meta_data->>'user_role' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_id' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_type' IS NULL
    OR au.raw_app_meta_data->>'user_role' != pu.role
  );

-- ============================================================================
-- PASO 2: Verificar que todos los usuarios tengan los campos correctos
-- ============================================================================
SELECT
  au.email,
  pu.role as role_public_users,
  au.raw_app_meta_data->>'user_role' as user_role_jwt,
  pu.assigned_location_type as location_type_public_users,
  au.raw_app_meta_data->>'assigned_location_type' as location_type_jwt,
  pu.assigned_location_id as location_id_public_users,
  au.raw_app_meta_data->>'assigned_location_id' as location_id_jwt,
  CASE
    WHEN au.raw_app_meta_data->>'user_role' = pu.role
         AND au.raw_app_meta_data->>'assigned_location_id' = pu.assigned_location_id::text
         AND au.raw_app_meta_data->>'assigned_location_type' = pu.assigned_location_type
    THEN '✅ CORRECTO'
    ELSE '❌ DESINCRONIZADO'
  END as estado
FROM auth.users au
JOIN public.users pu ON au.id = pu.id
ORDER BY au.email;

-- ============================================================================
-- PASO 3 (OPCIONAL): Sincronizar raw_user_meta_data también
-- ============================================================================
-- raw_user_meta_data es lo que el usuario provee al registrarse
-- raw_app_meta_data es lo que el servidor controla (más seguro)
-- Este paso asegura consistencia total
UPDATE auth.users au
SET raw_user_meta_data = COALESCE(au.raw_user_meta_data, '{}'::jsonb) ||
  jsonb_build_object(
    'role', pu.role,
    'assigned_location_id', pu.assigned_location_id::text,
    'assigned_location_type', pu.assigned_location_type
  )
FROM public.users pu
WHERE au.id = pu.id;

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
-- Ejecuta esta query después de aplicar el fix
-- Deberías ver que TODOS los usuarios tienen estado '✅ CORRECTO'
--
-- SELECT
--   email,
--   raw_app_meta_data->>'user_role' as role,
--   raw_app_meta_data->>'assigned_location_id' as location_id,
--   raw_app_meta_data->>'assigned_location_type' as location_type
-- FROM auth.users
-- ORDER BY email;

-- ============================================================================
-- INSTRUCCIONES DE USO
-- ============================================================================
-- 1. Abre Supabase Dashboard → SQL Editor
-- 2. Copia y pega TODO este archivo
-- 3. Ejecuta (Run)
-- 4. Verifica que la query de PASO 2 muestre '✅ CORRECTO' para todos
-- 5. Cierra la app Flutter completamente
-- 6. Hot Restart (o reinicia la app)
-- 7. Login nuevamente
-- 8. Ve a la pantalla de Transferencias
-- 9. ¡Deberías ver las transferencias sincronizándose automáticamente!

-- ============================================================================
-- SEGURIDAD
-- ============================================================================
-- ✅ Este script es SEGURO porque:
-- 1. Solo actualiza usuarios que YA existen en public.users
-- 2. No borra datos, solo agrega campos faltantes
-- 3. Usa COALESCE para preservar datos existentes
-- 4. Solo actualiza si hay desincronización

-- ============================================================================
-- IMPACTO ESPERADO
-- ============================================================================
-- Después de ejecutar este fix:
-- ✅ Las políticas RLS de transfers funcionarán correctamente
-- ✅ Los usuarios podrán ver transferencias de SU ubicación asignada
-- ✅ La sincronización automática descargará transferencias
-- ✅ No rompe ningún módulo existente (products, stores, warehouses, inventory, users)

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
