-- ============================================================================
-- 07_setup_first_admin.sql
-- Configuración inicial del primer usuario administrador
-- ============================================================================
-- INSTRUCCIONES:
-- Este script se ejecuta UNA SOLA VEZ después de crear manualmente el
-- primer usuario admin en Supabase Authentication.
-- ============================================================================

-- ============================================================================
-- PASO 1: Obtener el ID del usuario admin de auth.users
-- ============================================================================
-- Ejecuta esto primero para obtener el ID:
-- SELECT id, email FROM auth.users WHERE email = 'TU_EMAIL_ADMIN';
-- Copia el ID y úsalo en los siguientes pasos

-- ============================================================================
-- PASO 2: Crear el registro en public.users
-- ============================================================================
-- REEMPLAZA:
-- - 'UUID_DEL_USUARIO' con el ID obtenido en el paso 1
-- - 'admin@example.com' con el email del admin
-- - 'Nombre Admin' con el nombre deseado

INSERT INTO public.users (id, email, name, role)
VALUES (
    'UUID_DEL_USUARIO',  -- ⚠️ REEMPLAZAR con el ID del paso 1
    'admin@example.com',  -- ⚠️ REEMPLAZAR con el email
    'Nombre Admin',       -- ⚠️ REEMPLAZAR con el nombre
    'admin'              -- Rol: admin, store_manager o warehouse_manager
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- PASO 3: Actualizar el JWT con el rol
-- ============================================================================
UPDATE auth.users
SET raw_app_meta_data =
    COALESCE(raw_app_meta_data, '{}'::jsonb) ||
    jsonb_build_object('user_role', 'admin')
WHERE id = 'UUID_DEL_USUARIO';  -- ⚠️ REEMPLAZAR con el mismo ID

-- ============================================================================
-- PASO 4: Verificar que funcionó correctamente
-- ============================================================================
SELECT
    id,
    email,
    raw_app_meta_data->>'user_role' as jwt_role,
    (SELECT role FROM public.users WHERE id = auth.users.id) as db_role
FROM auth.users
WHERE id = 'UUID_DEL_USUARIO';  -- ⚠️ REEMPLAZAR con el mismo ID

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- jwt_role = 'admin'
-- db_role  = 'admin'

-- ============================================================================
-- EJEMPLO COMPLETO CON DATOS REALES:
-- ============================================================================
-- EJEMPLO: Configurar admin@test.com como primer administrador
--
-- INSERT INTO public.users (id, email, name, role)
-- VALUES (
--     'd84a4d7d-5ed6-4808-83ce-c0b58fce3c5c',
--     'admin@test.com',
--     'Administrador Principal',
--     'admin'
-- )
-- ON CONFLICT (id) DO NOTHING;
--
-- UPDATE auth.users
-- SET raw_app_meta_data =
--     COALESCE(raw_app_meta_data, '{}'::jsonb) ||
--     jsonb_build_object('user_role', 'admin')
-- WHERE id = 'd84a4d7d-5ed6-4808-83ce-c0b58fce3c5c';

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================
-- 1. Este script SOLO es necesario para el primer admin creado manualmente
-- 2. Los usuarios registrados desde la app NO necesitan esto (el trigger lo hace)
-- 3. Ejecuta este script DESPUÉS de crear el usuario en Supabase Authentication
-- 4. Después de ejecutarlo, el usuario debe cerrar sesión y volver a entrar
-- 5. Para siguientes admins, créalos desde la app (ya tendrá el trigger funcionando)
