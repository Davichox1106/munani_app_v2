-- ============================================================================
-- FIX_PURCHASE_LOCATION_ID.sql
-- Fix para corregir location_id de compras que no coinciden con assigned_location_id
-- ============================================================================
-- PROBLEMA: Compras con location_id que no coincide con assigned_location_id del usuario
-- CAUSA: Compras creadas con location_id incorrecto o usuario sin assigned_location_id
-- SOLUCIÓN: Actualizar location_id de compras problemáticas
-- ============================================================================

-- ============================================================================
-- PASO 1: Identificar compras problemáticas
-- ============================================================================
\echo '🔍 PASO 1: Identificando compras problemáticas...'

-- Buscar compras que podrían tener problemas de RLS
WITH problem_purchases AS (
    SELECT 
        p.id,
        p.supplier_id,
        p.location_id,
        p.location_type,
        p.status,
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
    WHERE p.status = 'pending'  -- Solo compras pendientes
)
SELECT 
    'Compras problemáticas' as info,
    id,
    location_id,
    location_type,
    created_by,
    assigned_location_id,
    assigned_location_type,
    role,
    should_pass_rls,
    CASE 
        WHEN should_pass_rls THEN '✅ OK'
        ELSE '❌ PROBLEMA'
    END as status
FROM problem_purchases
WHERE NOT should_pass_rls
ORDER BY created_at DESC;

-- ============================================================================
-- PASO 2: Verificar usuarios sin assigned_location_id
-- ============================================================================
\echo '🔍 PASO 2: Verificando usuarios sin assigned_location_id...'

SELECT 
    'Usuarios sin ubicación' as info,
    u.id,
    u.email,
    u.role,
    u.assigned_location_id,
    u.assigned_location_type,
    COUNT(p.id) as compras_creadas
FROM public.users u
LEFT JOIN purchases p ON u.id = p.created_by
WHERE u.assigned_location_id IS NULL
GROUP BY u.id, u.email, u.role, u.assigned_location_id, u.assigned_location_type
ORDER BY compras_creadas DESC;

-- ============================================================================
-- PASO 3: Asignar ubicación por defecto a usuarios sin ubicación
-- ============================================================================
\echo '🔧 PASO 3: Asignando ubicación por defecto...'

-- Obtener la primera tienda disponible como ubicación por defecto
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

-- Mostrar usuarios actualizados
SELECT 
    'Usuarios actualizados' as status,
    ROW_COUNT() as cantidad;

-- ============================================================================
-- PASO 4: Actualizar JWT metadata para usuarios actualizados
-- ============================================================================
\echo '🔧 PASO 4: Actualizando JWT para usuarios actualizados...'

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

-- Mostrar usuarios JWT actualizados
SELECT 
    'JWT actualizados' as status,
    ROW_COUNT() as cantidad;

-- ============================================================================
-- PASO 5: Corregir location_id de compras problemáticas
-- ============================================================================
\echo '🔧 PASO 5: Corrigiendo location_id de compras...'

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
  AND p.status = 'pending';  -- Solo compras pendientes

-- Mostrar compras actualizadas
SELECT 
    'Compras actualizadas' as status,
    ROW_COUNT() as cantidad;

-- ============================================================================
-- PASO 6: Verificar correcciones aplicadas
-- ============================================================================
\echo '✅ PASO 6: Verificando correcciones...'

-- Verificar que todas las compras pendientes ahora pasen RLS
WITH corrected_purchases AS (
    SELECT 
        p.id,
        p.supplier_id,
        p.location_id,
        p.location_type,
        p.status,
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
    'Verificación final' as info,
    COUNT(*) as total_purchases,
    COUNT(CASE WHEN should_pass_rls THEN 1 END) as should_pass,
    COUNT(CASE WHEN NOT should_pass_rls THEN 1 END) as should_fail,
    CASE 
        WHEN COUNT(CASE WHEN NOT should_pass_rls THEN 1 END) = 0 THEN '✅ TODAS CORREGIDAS'
        ELSE '❌ AÚN HAY PROBLEMAS'
    END as status
FROM corrected_purchases;

-- ============================================================================
-- PASO 7: Mostrar compras que aún podrían tener problemas
-- ============================================================================
\echo '🔍 PASO 7: Compras que aún podrían tener problemas...'

WITH remaining_problems AS (
    SELECT 
        p.id,
        p.supplier_id,
        p.location_id,
        p.location_type,
        p.status,
        p.created_by,
        u.assigned_location_id,
        u.assigned_location_type,
        u.role,
        u.email
    FROM purchases p
    JOIN public.users u ON p.created_by = u.id
    WHERE p.status = 'pending'
      AND u.role != 'admin'
      AND (u.assigned_location_id IS NULL OR u.assigned_location_id != p.location_id)
)
SELECT 
    'Compras problemáticas restantes' as info,
    id,
    location_id,
    location_type,
    created_by,
    email,
    assigned_location_id,
    assigned_location_type,
    role
FROM remaining_problems
ORDER BY created_at DESC;

-- ============================================================================
-- RESUMEN Y PRÓXIMOS PASOS
-- ============================================================================
\echo '📊 RESUMEN DEL FIX:'
\echo '1. ✅ Identificadas compras problemáticas'
\echo '2. ✅ Asignada ubicación por defecto a usuarios sin ubicación'
\echo '3. ✅ Actualizado JWT metadata'
\echo '4. ✅ Corregido location_id de compras'
\echo '5. ✅ Verificadas correcciones aplicadas'
\echo ''
\echo '🔧 PRÓXIMOS PASOS:'
\echo '1. Probar la sincronización de compras nuevamente'
\echo '2. Si persiste el error, revisar las compras problemáticas restantes'
\echo '3. Considerar cancelar compras que no se pueden corregir'













