-- ============================================================================
-- 05_triggers.sql
-- Triggers automáticos
-- ============================================================================
-- Los triggers ejecutan funciones automáticamente ante eventos
-- 
-- ⚠️ IMPORTANTE: Si tienes error "must be owner of relation users":
-- 
-- OPCIÓN 1 (Recomendada): Usa el archivo 05_triggers_WITH_PERMISSIONS.sql
--    que incluye la solución de permisos automática
--
-- OPCIÓN 2: Ejecuta este script como service_role en Supabase:
--    1. Ve a SQL Editor
--    2. Cambia el rol a "service_role" (dropdown arriba)
--    3. Ejecuta este script
--
-- OPCIÓN 3: Ejecuta primero estos comandos (requiere permisos):
--    GRANT ALL ON TABLE public.users TO postgres;
--    ALTER TABLE public.users OWNER TO postgres;
-- ============================================================================

-- ============================================================================
-- TRIGGER: update_users_updated_at
-- Descripción: Actualiza el campo updated_at automáticamente en users
-- Ejecuta: BEFORE UPDATE en cada fila
-- ============================================================================
DO $$
BEGIN
    -- Eliminar si existe
    DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
    
    -- Crear trigger
    CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON public.users
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
    
    COMMENT ON TRIGGER update_users_updated_at ON public.users IS 'Actualiza updated_at automáticamente en cada actualización';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error al crear trigger update_users_updated_at: %', SQLERRM;
    -- Continuar con el siguiente trigger aunque este falle
END $$;



-- ============================================================================
-- TRIGGER: update_user_assigned_location_name
-- Descripción: Actualiza automáticamente assigned_location_name cuando cambia
--              assigned_location_id o assigned_location_type
-- Ejecuta: BEFORE UPDATE en cada fila
-- ============================================================================
DO $$
BEGIN
    -- Eliminar si existe
    DROP TRIGGER IF EXISTS update_user_assigned_location_name ON public.users;
    
    -- Crear trigger
    CREATE TRIGGER update_user_assigned_location_name
        BEFORE UPDATE ON public.users
        FOR EACH ROW
        EXECUTE FUNCTION public.update_user_assigned_location_name();
    
    COMMENT ON TRIGGER update_user_assigned_location_name ON public.users IS 'Actualiza assigned_location_name automáticamente cuando cambia la ubicación asignada';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error al crear trigger update_user_assigned_location_name: %', SQLERRM;
    -- Continuar aunque este falle
END $$;



-- ============================================================================
-- TRIGGER: on_auth_user_created
-- Descripción: Crea automáticamente un registro en public.users cuando
--              un usuario se registra en auth.users
-- OWASP A07:2021 - Authentication
-- Asegura sincronización entre auth.users y public.users
-- NOTA: Este trigger requiere permisos de superusuario o service_role
-- ============================================================================
DO $$
BEGIN
    -- Eliminar si existe
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    
    -- Crear trigger
    CREATE TRIGGER on_auth_user_created
        AFTER INSERT ON auth.users
        FOR EACH ROW
        EXECUTE FUNCTION public.handle_new_user();
        
EXCEPTION 
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'No se pudo crear trigger en auth.users (requiere permisos de superusuario). Esto es normal.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al crear trigger on_auth_user_created: %', SQLERRM;
        -- Continuar con el siguiente trigger aunque este falle
END $$;



-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
SELECT 
    '📊 Triggers creados:' AS info,
    tgname AS trigger_name,
    tgrelid::regclass AS tabla,
    CASE WHEN tgenabled = 'O' THEN '✅ Habilitado' ELSE '❌ Deshabilitado' END AS estado
FROM pg_trigger
WHERE (tgrelid = 'public.users'::regclass 
    AND tgname IN ('update_users_updated_at', 'update_user_assigned_location_name'))
    OR (tgrelid = 'auth.users'::regclass 
    AND tgname = 'on_auth_user_created')
ORDER BY tabla, tgname;
-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================
-- 1. El trigger on_auth_user_created se ejecuta en la tabla auth.users
--    que es gestionada por Supabase Auth
-- 2. Los triggers BEFORE UPDATE son más eficientes que AFTER UPDATE
--    para modificar la misma fila
-- 3. Para deshabilitar un trigger temporalmente:
--    ALTER TABLE public.users DISABLE TRIGGER update_users_updated_at;
-- 4. Para volver a habilitarlo:
--    ALTER TABLE public.users ENABLE TRIGGER update_users_updated_at;
-- 5. Si un trigger falla, el script continúa con los siguientes gracias a
--    los bloques DO $$ con manejo de excepciones
