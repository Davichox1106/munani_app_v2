-- ============================================================================
-- TEST_PURCHASE_RLS_FIX.sql
-- Script de prueba para verificar que el fix de RLS funciona correctamente
-- ============================================================================
-- OBJETIVO: Verificar que las compras se pueden sincronizar sin errores RLS
-- ============================================================================

\echo '🧪 INICIANDO PRUEBAS DEL FIX RLS DE COMPRAS'
\echo '=========================================='

-- ============================================================================
-- PRUEBA 1: Verificar estado de usuarios y JWT
-- ============================================================================
\echo ''
\echo '🧪 PRUEBA 1/5: Verificando usuarios y JWT...'

SELECT 
    'Usuarios con JWT completo' as prueba,
    COUNT(*) as total_usuarios,
    COUNT(CASE 
        WHEN au.raw_app_meta_data->>'user_role' IS NOT NULL
             AND au.raw_app_meta_data->>'assigned_location_id' IS NOT NULL
             AND au.raw_app_meta_data->>'assigned_location_type' IS NOT NULL
        THEN 1 
    END) as con_jwt_completo,
    COUNT(CASE 
        WHEN au.raw_app_meta_data->>'user_role' IS NULL
             OR au.raw_app_meta_data->>'assigned_location_id' IS NULL
             OR au.raw_app_meta_data->>'assigned_location_type' IS NULL
        THEN 1 
    END) as con_jwt_incompleto
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- ============================================================================
-- PRUEBA 2: Verificar sincronización JWT vs BD
-- ============================================================================
\echo ''
\echo '🧪 PRUEBA 2/5: Verificando sincronización JWT vs BD...'

SELECT 
    'Sincronización JWT vs BD' as prueba,
    COUNT(*) as total,
    COUNT(CASE 
        WHEN au.raw_app_meta_data->>'user_role' = pu.role
             AND au.raw_app_meta_data->>'assigned_location_id' = pu.assigned_location_id::text
             AND au.raw_app_meta_data->>'assigned_location_type' = pu.assigned_location_type
        THEN 1 
    END) as sincronizados,
    COUNT(CASE 
        WHEN au.raw_app_meta_data->>'user_role' != pu.role
             OR au.raw_app_meta_data->>'assigned_location_id' != pu.assigned_location_id::text
             OR au.raw_app_meta_data->>'assigned_location_type' != pu.assigned_location_type
        THEN 1 
    END) as desincronizados
FROM auth.users au
JOIN public.users pu ON au.id = pu.id;

-- ============================================================================
-- PRUEBA 3: Verificar compras pendientes
-- ============================================================================
\echo ''
\echo '🧪 PRUEBA 3/5: Verificando compras pendientes...'

WITH purchase_rls_check AS (
    SELECT 
        p.id,
        p.location_id,
        p.location_type,
        p.status,
        p.created_by,
        u.assigned_location_id,
        u.assigned_location_type,
        u.role,
        u.email,
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
    'Compras pendientes RLS' as prueba,
    COUNT(*) as total_purchases,
    COUNT(CASE WHEN should_pass_rls THEN 1 END) as should_pass,
    COUNT(CASE WHEN NOT should_pass_rls THEN 1 END) as should_fail,
    CASE 
        WHEN COUNT(CASE WHEN NOT should_pass_rls THEN 1 END) = 0 THEN '✅ TODAS PASAN RLS'
        ELSE '❌ HAY COMPRAS QUE FALLAN RLS'
    END as resultado
FROM purchase_rls_check;

-- Mostrar compras que aún fallan RLS (si las hay)
WITH purchase_rls_check AS (
    SELECT 
        p.id,
        p.location_id,
        p.location_type,
        p.status,
        p.created_by,
        u.assigned_location_id,
        u.assigned_location_type,
        u.role,
        u.email,
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
    'Compras que fallan RLS' as detalle,
    id,
    location_id,
    location_type,
    created_by,
    email,
    assigned_location_id,
    assigned_location_type,
    role
FROM purchase_rls_check
WHERE NOT should_pass_rls
ORDER BY created_at DESC;

-- ============================================================================
-- PRUEBA 4: Simular verificación RLS para diferentes usuarios
-- ============================================================================
\echo ''
\echo '🧪 PRUEBA 4/5: Simulando verificación RLS...'

-- Crear función temporal para simular RLS
CREATE OR REPLACE FUNCTION simulate_rls_check(
    p_user_id UUID,
    p_location_id UUID
) RETURNS TABLE(
    user_email TEXT,
    user_role TEXT,
    assigned_location_id UUID,
    test_location_id UUID,
    is_admin BOOLEAN,
    is_manager BOOLEAN,
    location_match BOOLEAN,
    rls_would_pass BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.email::TEXT,
        u.role::TEXT,
        u.assigned_location_id,
        p_location_id,
        public.is_admin(),
        public.is_admin_or_manager(),
        (p_location_id = u.assigned_location_id),
        (public.is_admin() OR (
            public.is_admin_or_manager() AND 
            p_location_id = u.assigned_location_id
        ))
    FROM public.users u
    WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Probar con algunos usuarios
SELECT 
    'Simulación RLS' as prueba,
    simulate_rls_check(u.id, u.assigned_location_id).*
FROM public.users u
WHERE u.assigned_location_id IS NOT NULL
LIMIT 5;

-- Limpiar función temporal
DROP FUNCTION simulate_rls_check(UUID, UUID);

-- ============================================================================
-- PRUEBA 5: Verificar políticas RLS activas
-- ============================================================================
\echo ''
\echo '🧪 PRUEBA 5/5: Verificando políticas RLS...'

-- Verificar que RLS esté habilitado
SELECT 
    'RLS habilitado' as prueba,
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
    'Políticas RLS' as prueba,
    tablename,
    COUNT(*) as total_policies,
    STRING_AGG(policyname, ', ') as policies
FROM pg_policies 
WHERE tablename IN ('purchases', 'purchase_items')
GROUP BY tablename;

-- ============================================================================
-- RESUMEN DE PRUEBAS
-- ============================================================================
\echo ''
\echo '📊 RESUMEN DE PRUEBAS:'
\echo '======================'
\echo '1. ✅ Usuarios con JWT completo verificado'
\echo '2. ✅ Sincronización JWT vs BD verificada'
\echo '3. ✅ Compras pendientes verificadas'
\echo '4. ✅ Simulación RLS completada'
\echo '5. ✅ Políticas RLS verificadas'
\echo ''
\echo '🎯 RESULTADO ESPERADO:'
\echo '- Todas las compras pendientes deberían pasar RLS'
\echo '- No deberían aparecer errores 42501 en la sincronización'
\echo '- Los usuarios deberían tener JWT completo y sincronizado'
\echo ''
\echo '🔧 SI HAY PROBLEMAS:'
\echo '1. Revisar las compras que fallan RLS (mostradas arriba)'
\echo '2. Verificar que los usuarios tengan assigned_location_id correcto'
\echo '3. Aplicar fixes adicionales si es necesario'













