-- ============================================================================
-- FIX_PURCHASE_RLS_JWT.sql
-- Fix para corregir el error RLS en compras actualizando JWT metadata
-- ============================================================================
-- PROBLEMA: Error 42501 - new row violates row-level security policy for table "purchases"
-- CAUSA: assigned_location_id no está presente o es incorrecto en el JWT
-- SOLUCIÓN: Actualizar raw_app_meta_data en auth.users
-- ============================================================================

-- ============================================================================
-- PASO 1: Verificar estado actual antes del fix
-- ============================================================================
\echo '🔍 PASO 1: Estado actual antes del fix...'

SELECT 
    'ANTES DEL FIX' as status,
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN au.raw_app_meta_data->>'assigned_location_id' IS NOT NULL THEN 1 END) as con_assigned_location_id,
    COUNT(CASE WHEN au.raw_app_meta_data->>'assigned_location_id' IS NULL THEN 1 END) as sin_assigned_location_id
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- ============================================================================
-- PASO 2: Actualizar JWT metadata para TODOS los usuarios
-- ============================================================================
\echo '🔧 PASO 2: Actualizando JWT metadata...'

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
    -- Solo actualizar si falta alguno de estos campos o están desincronizados
    au.raw_app_meta_data->>'user_role' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_id' IS NULL
    OR au.raw_app_meta_data->>'assigned_location_type' IS NULL
    OR au.raw_app_meta_data->>'user_role' != pu.role
    OR au.raw_app_meta_data->>'assigned_location_id' != pu.assigned_location_id::text
    OR au.raw_app_meta_data->>'assigned_location_type' != pu.assigned_location_type
  );

-- Mostrar cuántos usuarios se actualizaron
SELECT 
    'Usuarios actualizados' as status,
    ROW_COUNT() as cantidad;

-- ============================================================================
-- PASO 3: Verificar estado después del fix
-- ============================================================================
\echo '✅ PASO 3: Estado después del fix...'

SELECT 
    'DESPUÉS DEL FIX' as status,
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN au.raw_app_meta_data->>'assigned_location_id' IS NOT NULL THEN 1 END) as con_assigned_location_id,
    COUNT(CASE WHEN au.raw_app_meta_data->>'assigned_location_id' IS NULL THEN 1 END) as sin_assigned_location_id
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- ============================================================================
-- PASO 4: Verificar sincronización JWT vs BD pública
-- ============================================================================
\echo '🔍 PASO 4: Verificando sincronización...'

SELECT 
    'Sincronización JWT vs BD' as info,
    au.email,
    au.raw_app_meta_data->>'user_role' as role_jwt,
    pu.role as role_public,
    au.raw_app_meta_data->>'assigned_location_id' as location_id_jwt,
    pu.assigned_location_id::text as location_id_public,
    au.raw_app_meta_data->>'assigned_location_type' as location_type_jwt,
    pu.assigned_location_type as location_type_public,
    CASE 
        WHEN au.raw_app_meta_data->>'user_role' = pu.role
             AND au.raw_app_meta_data->>'assigned_location_id' = pu.assigned_location_id::text
             AND au.raw_app_meta_data->>'assigned_location_type' = pu.assigned_location_type
        THEN '✅ Sincronizado'
        ELSE '❌ Desincronizado'
    END as estado
FROM auth.users au
JOIN public.users pu ON au.id = pu.id
ORDER BY au.email;

-- ============================================================================
-- PASO 5: Verificar que las políticas RLS funcionen correctamente
-- ============================================================================
\echo '🔍 PASO 5: Verificando políticas RLS...'

-- Verificar que RLS esté habilitado
SELECT 
    'RLS Status' as info,
    tablename,
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity THEN '✅ Habilitado'
        ELSE '❌ Deshabilitado'
    END as status
FROM pg_tables 
WHERE tablename IN ('purchases', 'purchase_items');

-- Contar políticas RLS
SELECT 
    'Políticas RLS' as info,
    tablename,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename IN ('purchases', 'purchase_items')
GROUP BY tablename;

-- ============================================================================
-- PASO 6: Crear función de prueba para verificar RLS
-- ============================================================================
\echo '🧪 PASO 6: Creando función de prueba RLS...'

CREATE OR REPLACE FUNCTION test_purchase_rls(
    p_location_id UUID,
    p_user_id UUID
) RETURNS TABLE(
    test_name TEXT,
    result BOOLEAN,
    details TEXT
) AS $$
BEGIN
    -- Test 1: Verificar si el usuario es admin
    RETURN QUERY
    SELECT 
        'is_admin'::TEXT,
        public.is_admin(),
        CASE 
            WHEN public.is_admin() THEN 'Usuario es admin'
            ELSE 'Usuario no es admin'
        END::TEXT;
    
    -- Test 2: Verificar si el usuario es manager
    RETURN QUERY
    SELECT 
        'is_manager'::TEXT,
        public.is_admin_or_manager(),
        CASE 
            WHEN public.is_admin_or_manager() THEN 'Usuario es manager'
            ELSE 'Usuario no es manager'
        END::TEXT;
    
    -- Test 3: Verificar assigned_location_id en JWT
    RETURN QUERY
    SELECT 
        'jwt_location_id'::TEXT,
        (auth.jwt()->>'assigned_location_id') IS NOT NULL,
        COALESCE(
            'JWT assigned_location_id: ' || (auth.jwt()->>'assigned_location_id'),
            'JWT assigned_location_id: NULL'
        )::TEXT;
    
    -- Test 4: Verificar coincidencia de location_id
    RETURN QUERY
    SELECT 
        'location_match'::TEXT,
        (p_location_id = COALESCE(
            (auth.jwt()->>'assigned_location_id')::uuid,
            (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
        )),
        CASE 
            WHEN p_location_id = COALESCE(
                (auth.jwt()->>'assigned_location_id')::uuid,
                (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
            ) THEN 'Location ID coincide'
            ELSE 'Location ID NO coincide'
        END::TEXT;
    
    -- Test 5: Verificar si RLS permitiría la operación
    RETURN QUERY
    SELECT 
        'rls_allows'::TEXT,
        (public.is_admin() OR (
            public.is_admin_or_manager() AND 
            p_location_id = COALESCE(
                (auth.jwt()->>'assigned_location_id')::uuid,
                (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
            )
        )),
        CASE 
            WHEN (public.is_admin() OR (
                public.is_admin_or_manager() AND 
                p_location_id = COALESCE(
                    (auth.jwt()->>'assigned_location_id')::uuid,
                    (SELECT assigned_location_id FROM public.users WHERE id = p_user_id)
                )
            )) THEN 'RLS permitiría la operación'
            ELSE 'RLS NO permitiría la operación'
        END::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- RESUMEN Y PRÓXIMOS PASOS
-- ============================================================================
\echo '📊 RESUMEN DEL FIX:'
\echo '1. ✅ JWT metadata actualizado para todos los usuarios'
\echo '2. ✅ Verificación de sincronización completada'
\echo '3. ✅ Políticas RLS verificadas'
\echo '4. ✅ Función de prueba creada'
\echo ''
\echo '🔧 PRÓXIMOS PASOS:'
\echo '1. Probar la sincronización de compras nuevamente'
\echo '2. Si persiste el error, usar la función test_purchase_rls() para diagnosticar'
\echo '3. Verificar que el location_id de la compra coincida con assigned_location_id del usuario'













