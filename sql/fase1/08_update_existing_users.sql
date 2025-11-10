-- ============================================================================
-- 07_update_existing_users.sql
-- Actualiza usuarios existentes para agregar user_role al JWT
-- ============================================================================
-- INSTRUCCIONES:
-- Este script SOLO se ejecuta UNA VEZ después de aplicar las correcciones
-- de RLS. Actualiza los usuarios que ya existen en auth.users para que
-- tengan el rol en su JWT (raw_app_meta_data).
-- ============================================================================

-- ============================================================================
-- FUNCIÓN TEMPORAL: Actualiza app_metadata de usuarios existentes
-- ============================================================================
CREATE OR REPLACE FUNCTION update_existing_users_metadata()
RETURNS void AS $$
DECLARE
    user_record RECORD;
BEGIN
    -- Iterar sobre todos los usuarios en public.users
    FOR user_record IN
        SELECT u.id, u.role
        FROM public.users u
    LOOP
        -- Actualizar raw_app_meta_data en auth.users
        UPDATE auth.users
        SET raw_app_meta_data =
            COALESCE(raw_app_meta_data, '{}'::jsonb) ||
            jsonb_build_object('user_role', user_record.role)
        WHERE id = user_record.id;

        RAISE NOTICE 'Usuario % actualizado con rol %', user_record.id, user_record.role;
    END LOOP;

    RAISE NOTICE 'Todos los usuarios han sido actualizados';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- EJECUTAR ACTUALIZACIÓN
-- ============================================================================
SELECT update_existing_users_metadata();

-- ============================================================================
-- LIMPIAR FUNCIÓN TEMPORAL
-- ============================================================================
DROP FUNCTION update_existing_users_metadata();

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
-- Verificar que todos los usuarios tienen user_role en app_metadata
SELECT
    id,
    email,
    raw_app_meta_data->>'user_role' as jwt_role,
    (SELECT role FROM public.users WHERE id = auth.users.id) as db_role
FROM auth.users;

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================
-- 1. Este script solo se ejecuta UNA VEZ después de la migración
-- 2. Los nuevos usuarios ya tendrán el rol en JWT gracias al trigger actualizado
-- 3. Si tienes usuarios inactivos, también se actualizarán (es correcto)
-- 4. Los usuarios deben cerrar sesión y volver a iniciar para obtener el nuevo JWT
