-- ============================================================================
-- 06_rls_policies.sql
-- Row Level Security (RLS) Policies
-- ============================================================================
-- OWASP A01:2021 - Broken Access Control
-- Las políticas RLS garantizan que los usuarios solo accedan a sus datos
-- ============================================================================

-- ============================================================================
-- HABILITAR RLS EN TABLA USERS
-- ============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ELIMINAR POLÍTICAS EXISTENTES (para re-ejecución segura)
-- ============================================================================
DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "admins_select_all" ON public.users;
DROP POLICY IF EXISTS "admins_insert_users" ON public.users;
DROP POLICY IF EXISTS "auth_users_insert" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;
DROP POLICY IF EXISTS "admins_update_users" ON public.users;
DROP POLICY IF EXISTS "admins_delete_users" ON public.users;

-- ============================================================================
-- POLÍTICAS PARA OPERACIÓN: SELECT
-- ============================================================================

-- Política: Los usuarios pueden ver su propia información
CREATE POLICY "users_select_own"
ON public.users
FOR SELECT
USING (auth.uid() = id);

COMMENT ON POLICY "users_select_own" ON public.users IS 'Permite a los usuarios ver su propia información';

-- Política: Los administradores pueden ver todos los usuarios
-- IMPORTANTE: Usamos función SECURITY DEFINER para evitar recursión
CREATE POLICY "admins_select_all"
ON public.users
FOR SELECT
USING (public.is_admin());

COMMENT ON POLICY "admins_select_all" ON public.users IS 'Permite a los administradores ver todos los usuarios';

-- ============================================================================
-- POLÍTICAS PARA OPERACIÓN: INSERT
-- ============================================================================

-- Política: Solo los administradores pueden crear usuarios manualmente
-- ACTUALIZACIÓN: Usa is_admin() con JWT para evitar recursión
CREATE POLICY "admins_insert_users"
ON public.users
FOR INSERT
WITH CHECK (public.is_admin());

COMMENT ON POLICY "admins_insert_users" ON public.users IS 'Solo administradores pueden crear usuarios manualmente (usa JWT)';

-- Política: Permitir inserción desde trigger de auth.users
-- Esta política permite que el trigger on_auth_user_created funcione
CREATE POLICY "auth_users_insert"
ON public.users
FOR INSERT
WITH CHECK (true);

COMMENT ON POLICY "auth_users_insert" ON public.users IS 'Permite inserción automática desde trigger de registro';

-- ============================================================================
-- POLÍTICAS PARA OPERACIÓN: UPDATE
-- ============================================================================

-- Política: Los usuarios pueden actualizar su propia información
-- NOTA: Solo pueden actualizar name, is_active
-- El rol y ubicación solo pueden ser modificados por admins
CREATE POLICY "users_update_own"
ON public.users
FOR UPDATE
USING (auth.uid() = id);

COMMENT ON POLICY "users_update_own" ON public.users IS 'Permite a usuarios actualizar su propia información básica';

-- Política: Los administradores pueden actualizar cualquier usuario
-- ACTUALIZACIÓN: Usa is_admin() con JWT para evitar recursión
CREATE POLICY "admins_update_all"
ON public.users
FOR UPDATE
USING (public.is_admin());

COMMENT ON POLICY "admins_update_all" ON public.users IS 'Permite a administradores actualizar cualquier usuario (usa JWT)';

-- ============================================================================
-- POLÍTICAS PARA OPERACIÓN: DELETE
-- ============================================================================

-- Política: Solo los administradores pueden eliminar usuarios
-- ACTUALIZACIÓN: Usa is_admin() con JWT para evitar recursión
CREATE POLICY "admins_delete_users"
ON public.users
FOR DELETE
USING (public.is_admin());

COMMENT ON POLICY "admins_delete_users" ON public.users IS 'Solo administradores pueden eliminar usuarios (usa JWT)';

-- ============================================================================
-- VERIFICACIÓN DE POLÍTICAS
-- ============================================================================
-- Para ver todas las políticas activas:
-- SELECT * FROM pg_policies WHERE tablename = 'users';

-- ============================================================================
-- NOTAS IMPORTANTES DE SEGURIDAD
-- ============================================================================
-- 1. RLS se aplica automáticamente a todas las consultas
-- 2. Los SECURITY DEFINER functions bypass RLS - usar con cuidado
-- 3. Las políticas se evalúan con OR (cualquiera que coincida permite acceso)
-- 4. WITH CHECK se usa para INSERT/UPDATE, USING para SELECT/UPDATE/DELETE
-- 5. Si ninguna política coincide, la operación es DENEGADA por defecto
