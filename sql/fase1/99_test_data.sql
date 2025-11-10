-- ============================================================================
-- 99_test_data.sql
-- Datos de prueba (OPCIONAL)
-- ============================================================================
-- ADVERTENCIA: Solo ejecutar en entornos de desarrollo/testing
-- NO ejecutar en producción
-- ============================================================================

-- ============================================================================
-- INSTRUCCIONES PARA CREAR USUARIO ADMIN
-- ============================================================================
-- 1. Primero registra un usuario desde la app o desde Supabase Auth:
--    - Ve a Authentication > Users en el dashboard de Supabase
--    - Click en "Add user" > "Create new user"
--    - Email: admin@test.com
--    - Password: Admin123! (o la que prefieras)
--    - Click en "Create user"
--
-- 2. Luego ejecuta este SQL para convertirlo en admin:

-- Actualizar usuario a rol admin
-- REEMPLAZA 'admin@test.com' con tu email
UPDATE public.users
SET
    role = 'admin',
    name = 'Administrador de Prueba',
    is_active = true
WHERE email = 'admin@test.com';

-- ============================================================================
-- VERIFICAR USUARIO ADMIN
-- ============================================================================
-- SELECT * FROM public.users WHERE role = 'admin';

-- ============================================================================
-- CREAR USUARIOS DE PRUEBA ADICIONALES (OPCIONAL)
-- ============================================================================
-- NOTA: Estos usuarios deben existir primero en auth.users
-- Puedes crearlos desde Supabase Authentication > Users

-- Ejemplo: Encargado de Tienda
-- UPDATE public.users
-- SET
--     role = 'store_manager',
--     name = 'Juan Pérez',
--     assigned_location_type = 'store',
--     is_active = true
-- WHERE email = 'store1@test.com';

-- Ejemplo: Encargado de Almacén
-- UPDATE public.users
-- SET
--     role = 'warehouse_manager',
--     name = 'María García',
--     assigned_location_type = 'warehouse',
--     is_active = true
-- WHERE email = 'warehouse1@test.com';

-- ============================================================================
-- LIMPIAR DATOS DE PRUEBA
-- ============================================================================
-- Para eliminar todos los usuarios de prueba:
-- DELETE FROM auth.users WHERE email LIKE '%@test.com';
-- (Esto también eliminará los registros en public.users por CASCADE)

-- ============================================================================
-- VERIFICAR CONFIGURACIÓN
-- ============================================================================
-- Ver todos los usuarios y sus roles:
-- SELECT id, email, name, role, assigned_location_type, is_active, created_at
-- FROM public.users
-- ORDER BY created_at DESC;

-- Ver políticas RLS activas:
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'users';
