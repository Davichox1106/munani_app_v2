-- ============================================================================
-- 00_DIAGNOSTICO.sql
-- Script de diagnóstico para verificar permisos y estado de la tabla users
-- ============================================================================
-- Ejecuta este script PRIMERO para entender qué está pasando
-- ============================================================================

-- 1. Verificar tu rol actual
SELECT 
    'Tu rol actual:' AS info,
    current_user AS rol_actual,
    session_user AS rol_sesion;

-- 2. Verificar si la tabla users existe
SELECT 
    '¿Existe la tabla users?' AS pregunta,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables 
                    WHERE table_schema = 'public' AND table_name = 'users')
        THEN '✅ SÍ existe'
        ELSE '❌ NO existe'
    END AS respuesta;

-- 3. Ver quién es el dueño (owner) de la tabla users
SELECT 
    'Dueño de la tabla users:' AS info,
    schemaname AS esquema,
    tablename AS tabla,
    tableowner AS dueño,
    CASE 
        WHEN tableowner = current_user THEN '✅ TÚ eres el dueño'
        ELSE '❌ NO eres el dueño (dueño: ' || tableowner || ')'
    END AS estado
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'users';

-- 4. Verificar tus permisos en la tabla users
SELECT 
    'Tus permisos en users:' AS info,
    grantee AS usuario,
    privilege_type AS permiso
FROM information_schema.role_table_grants
WHERE table_schema = 'public' 
    AND table_name = 'users'
    AND grantee = current_user;

-- 5. Verificar si las funciones necesarias existen
SELECT 
    'Funciones necesarias:' AS info,
    proname AS nombre_funcion,
    CASE 
        WHEN proname IN ('update_updated_at_column', 'handle_new_user', 'update_user_assigned_location_name')
        THEN '✅ Existe'
        ELSE '❌ No existe'
    END AS estado
FROM pg_proc
WHERE proname IN ('update_updated_at_column', 'handle_new_user', 'update_user_assigned_location_name')
    AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- 6. Verificar triggers existentes
SELECT 
    'Triggers existentes en users:' AS info,
    tgname AS nombre_trigger,
    CASE WHEN tgenabled = 'O' THEN '✅ Habilitado' ELSE '❌ Deshabilitado' END AS estado
FROM pg_trigger
WHERE tgrelid = 'public.users'::regclass
    AND tgisinternal = false
ORDER BY tgname;

-- 7. Intentar cambiar el owner (si no eres el dueño)
-- Descomenta estas líneas si el dueño NO es postgres:
/*
ALTER TABLE public.users OWNER TO postgres;
*/

-- 8. Resumen final
SELECT 
    '📊 RESUMEN:' AS titulo,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users' AND tableowner = current_user)
        THEN '✅ Puedes crear triggers (eres el dueño)'
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users')
        THEN '⚠️ La tabla existe pero NO eres el dueño. Ejecuta: ALTER TABLE public.users OWNER TO postgres;'
        ELSE '❌ La tabla users NO existe. Ejecuta primero 02_tables.sql'
    END AS conclusion;

