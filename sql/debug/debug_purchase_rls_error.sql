-- ============================================================================
-- DEBUG_PURCHASE_RLS_ERROR.sql
-- Script para diagnosticar el error RLS en la sincronización de compras
-- ============================================================================
-- PROBLEMA: Error 42501 - new row violates row-level security policy for table "purchases"
-- COMPRA ID: 58c0c2f5-7cb5-4a4f-a3da-e0aca3df252c
-- ============================================================================

-- ============================================================================
-- PASO 1: Verificar la compra problemática en la base de datos local
-- ============================================================================
\echo '🔍 PASO 1: Verificando compra problemática...'

-- Buscar la compra en la tabla local (si existe)
SELECT 
    'Compra encontrada en BD local' as status,
    id,
    supplier_id,
    location_id,
    location_type,
    status,
    created_by,
    created_at
FROM purchases 
WHERE id = '58c0c2f5-7cb5-4a4f-a3da-e0aca3df252c';

-- ============================================================================
-- PASO 2: Verificar usuarios y sus assigned_location_id
-- ============================================================================
\echo '🔍 PASO 2: Verificando usuarios y ubicaciones asignadas...'

SELECT 
    'Usuarios y ubicaciones' as info,
    u.id,
    u.email,
    u.role,
    u.assigned_location_id,
    u.assigned_location_type,
    CASE 
        WHEN u.assigned_location_type = 'store' THEN s.name
        WHEN u.assigned_location_type = 'warehouse' THEN w.name
        ELSE 'Sin ubicación'
    END as location_name
FROM public.users u
LEFT JOIN public.stores s ON u.assigned_location_id = s.id AND u.assigned_location_type = 'store'
LEFT JOIN public.warehouses w ON u.assigned_location_id = w.id AND u.assigned_location_type = 'warehouse'
ORDER BY u.email;

-- ============================================================================
-- PASO 3: Verificar JWT metadata de usuarios
-- ============================================================================
\echo '🔍 PASO 3: Verificando JWT metadata...'

SELECT 
    'JWT Metadata' as info,
    au.email,
    au.raw_app_meta_data->>'user_role' as user_role_jwt,
    au.raw_app_meta_data->>'assigned_location_id' as assigned_location_id_jwt,
    au.raw_app_meta_data->>'assigned_location_type' as assigned_location_type_jwt,
    pu.role as role_public,
    pu.assigned_location_id as assigned_location_id_public,
    pu.assigned_location_type as assigned_location_type_public,
    CASE 
        WHEN au.raw_app_meta_data->>'assigned_location_id' = pu.assigned_location_id::text
             AND au.raw_app_meta_data->>'assigned_location_type' = pu.assigned_location_type
        THEN '✅ Sincronizado'
        ELSE '❌ Desincronizado'
    END as jwt_sync_status
FROM auth.users au
JOIN public.users pu ON au.id = pu.id
ORDER BY au.email;

-- ============================================================================
-- PASO 4: Verificar políticas RLS de purchases
-- ============================================================================
\echo '🔍 PASO 4: Verificando políticas RLS...'

SELECT 
    'Políticas RLS de purchases' as info,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'purchases'
ORDER BY policyname;

-- ============================================================================
-- PASO 5: Verificar si RLS está habilitado
-- ============================================================================
\echo '🔍 PASO 5: Verificando estado de RLS...'

SELECT 
    'Estado RLS' as info,
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity THEN '✅ Habilitado'
        ELSE '❌ Deshabilitado'
    END as status
FROM pg_tables 
WHERE tablename = 'purchases';

-- ============================================================================
-- PASO 6: Simular la verificación RLS para la compra problemática
-- ============================================================================
\echo '🔍 PASO 6: Simulando verificación RLS...'

-- Crear una función temporal para simular la verificación RLS
CREATE OR REPLACE FUNCTION debug_rls_check(
    p_location_id UUID,
    p_user_id UUID
) RETURNS TABLE(
    is_admin BOOLEAN,
    is_manager BOOLEAN,
    user_assigned_location_id UUID,
    location_match BOOLEAN,
    rls_passes BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        public.is_admin() as is_admin,
        public.is_admin_or_manager() as is_manager,
        COALESCE(
            (auth.jwt()->>'assigned_location_id')::uuid,
            (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
        ) as user_assigned_location_id,
        (p_location_id = COALESCE(
            (auth.jwt()->>'assigned_location_id')::uuid,
            (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
        )) as location_match,
        (public.is_admin() OR (
            public.is_admin_or_manager() AND 
            p_location_id = COALESCE(
                (auth.jwt()->>'assigned_location_id')::uuid,
                (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
            )
        )) as rls_passes;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Probar con diferentes usuarios (simular)
SELECT 
    'Simulación RLS' as info,
    u.email,
    u.assigned_location_id,
    u.assigned_location_type,
    debug_rls_check(
        '58c0c2f5-7cb5-4a4f-a3da-e0aca3df252c'::uuid, -- Usar un location_id real
        u.id
    ).*
FROM public.users u
LIMIT 5;

-- Limpiar función temporal
DROP FUNCTION debug_rls_check(UUID, UUID);

-- ============================================================================
-- PASO 7: Verificar compras existentes y sus location_id
-- ============================================================================
\echo '🔍 PASO 7: Verificando compras existentes...'

SELECT 
    'Compras existentes' as info,
    id,
    supplier_id,
    location_id,
    location_type,
    status,
    created_by,
    created_at
FROM purchases 
ORDER BY created_at DESC 
LIMIT 10;

-- ============================================================================
-- RESUMEN DEL DIAGNÓSTICO
-- ============================================================================
\echo '📊 RESUMEN DEL DIAGNÓSTICO:'
\echo '1. Verificar si la compra existe en la BD local'
\echo '2. Verificar que los usuarios tengan assigned_location_id correcto'
\echo '3. Verificar que el JWT contenga assigned_location_id'
\echo '4. Verificar que las políticas RLS estén activas'
\echo '5. Verificar que el location_id de la compra coincida con assigned_location_id del usuario'













