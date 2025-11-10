-- ============================================================================
-- FIX_PURCHASE_RLS_COMPLETE.sql
-- Script maestro para corregir completamente el error RLS en compras
-- ============================================================================
-- PROBLEMA: Error 42501 - new row violates row-level security policy for table "purchases"
-- SOLUCIÓN COMPLETA: Aplicar todos los fixes necesarios en orden
-- COMPATIBLE: Supabase Dashboard SQL Editor
-- ============================================================================

DO $$ BEGIN
    RAISE NOTICE '🚀 INICIANDO FIX COMPLETO PARA ERROR RLS DE COMPRAS';
    RAISE NOTICE '==================================================';
END $$;

-- ============================================================================
-- PASO 1: DIAGNÓSTICO INICIAL
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 PASO 1/6: Diagnóstico inicial...';
END $$;

-- Verificar estado actual
SELECT
    '🔍 Estado inicial' as fase,
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN au.raw_app_meta_data->>'assigned_location_id' IS NOT NULL THEN 1 END) as con_jwt_location,
    COUNT(CASE WHEN pu.assigned_location_id IS NOT NULL THEN 1 END) as con_bd_location
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- ============================================================================
-- PASO 2: FIX JWT METADATA
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PASO 2/6: Aplicando fix de JWT metadata...';
END $$;

-- Actualizar JWT metadata para TODOS los usuarios
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
    au.raw_app_meta_data->>'user_role' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_id' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_type' IS NULL
    OR au.raw_app_meta_data->>'user_role' != pu.role
    OR au.raw_app_meta_data->>'assigned_location_id' != pu.assigned_location_id::text
    OR au.raw_app_meta_data->>'assigned_location_type' != pu.assigned_location_type
  );

-- ============================================================================
-- PASO 3: ASIGNAR UBICACIONES POR DEFECTO
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PASO 3/6: Asignando ubicaciones por defecto...';
END $$;

-- Asignar ubicación por defecto a usuarios sin ubicación
WITH default_location AS (
    SELECT id, 'store' as type
    FROM stores 
    WHERE is_active = true
    ORDER BY created_at
    LIMIT 1
)
UPDATE public.users 
SET 
    assigned_location_id = dl.id,
    assigned_location_type = dl.type,
    updated_at = NOW()
FROM default_location dl
WHERE assigned_location_id IS NULL
  AND role IN ('store_manager', 'warehouse_manager');

-- ============================================================================
-- PASO 4: ACTUALIZAR JWT PARA USUARIOS ACTUALIZADOS
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PASO 4/6: Actualizando JWT para usuarios actualizados...';
END $$;

-- Actualizar JWT para usuarios que recibieron ubicación
UPDATE auth.users au
SET raw_app_meta_data = COALESCE(au.raw_app_meta_data, '{}'::jsonb) ||
  jsonb_build_object(
    'user_role', pu.role,
    'assigned_location_id', pu.assigned_location_id::text,
    'assigned_location_type', pu.assigned_location_type
  )
FROM public.users pu
WHERE au.id = pu.id
  AND pu.assigned_location_id IS NOT NULL
  AND (
    au.raw_app_meta_data->>'assigned_location_id' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_id' != pu.assigned_location_id::text
  );

-- ============================================================================
-- PASO 5: CORREGIR LOCATION_ID DE COMPRAS
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PASO 5/6: Corrigiendo location_id de compras...';
END $$;

-- Actualizar compras para que coincidan con assigned_location_id del creador
UPDATE purchases p
SET 
    location_id = u.assigned_location_id,
    location_type = u.assigned_location_type,
    updated_at = NOW()
FROM public.users u
WHERE p.created_by = u.id
  AND u.assigned_location_id IS NOT NULL
  AND p.location_id != u.assigned_location_id
  AND p.status = 'pending';

-- ============================================================================
-- PASO 6: VERIFICACIÓN FINAL
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '✅ PASO 6/6: Verificación final...';
END $$;

-- Verificar estado final
SELECT
    '📊 Estado final' as fase,
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN au.raw_app_meta_data->>'assigned_location_id' IS NOT NULL THEN 1 END) as con_jwt_location,
    COUNT(CASE WHEN pu.assigned_location_id IS NOT NULL THEN 1 END) as con_bd_location
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- Verificar sincronización JWT vs BD
SELECT
    '🔄 Sincronización JWT vs BD' as info,
    COUNT(*) as total,
    COUNT(CASE 
        WHEN au.raw_app_meta_data->>'assigned_location_id' = pu.assigned_location_id::text
             AND au.raw_app_meta_data->>'assigned_location_type' = pu.assigned_location_type
        THEN 1 
    END) as sincronizados,
    COUNT(CASE 
        WHEN au.raw_app_meta_data->>'assigned_location_id' != pu.assigned_location_id::text
             OR au.raw_app_meta_data->>'assigned_location_type' != pu.assigned_location_type
        THEN 1 
    END) as desincronizados
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- Verificar compras que aún podrían tener problemas
WITH problem_purchases AS (
    SELECT 
        p.id,
        p.location_id,
        p.location_type,
        p.created_by,
        u.assigned_location_id,
        u.assigned_location_type,
        u.role,
        CASE 
            WHEN u.role = 'admin' THEN true
            WHEN u.assigned_location_id = p.location_id THEN true
            ELSE false
        END as should_pass_rls
    FROM purchases p
    JOIN public.users u ON p.created_by = u.id
    WHERE p.status = 'pending'
)
SELECT
    '🛒 Compras pendientes' as info,
    COUNT(*) as total,
    COUNT(CASE WHEN should_pass_rls THEN 1 END) as should_pass,
    COUNT(CASE WHEN NOT should_pass_rls THEN 1 END) as should_fail
FROM problem_purchases;

-- ============================================================================
-- RESUMEN FINAL
-- ============================================================================
DO $$ BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 FIX COMPLETO APLICADO';
    RAISE NOTICE '========================';
    RAISE NOTICE '✅ JWT metadata actualizado para todos los usuarios';
    RAISE NOTICE '✅ Ubicaciones asignadas a usuarios sin ubicación';
    RAISE NOTICE '✅ JWT actualizado para usuarios con nueva ubicación';
    RAISE NOTICE '✅ Location_id de compras corregido';
    RAISE NOTICE '✅ Verificación final completada';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 PRÓXIMOS PASOS:';
    RAISE NOTICE '1. Cerrar sesión en la app Flutter';
    RAISE NOTICE '2. Iniciar sesión nuevamente para obtener JWT actualizado';
    RAISE NOTICE '3. Probar la sincronización de compras';
    RAISE NOTICE '4. Verificar que no aparezcan más errores RLS';
END $$;













