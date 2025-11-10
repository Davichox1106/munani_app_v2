-- ============================================================================
-- 00_run_all.sql
-- Script maestro que ejecuta TODOS los scripts en orden
-- ============================================================================
-- INSTRUCCIONES:
-- 1. Copia TODO el contenido de este archivo
-- 2. Pégalo en SQL Editor de Supabase
-- 3. Ejecuta (Run o Ctrl+Enter)
-- 4. Verifica que no haya errores
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONES
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 2. TABLA USERS
-- ============================================================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'store_manager', 'warehouse_manager', 'customer')),
    assigned_location_id UUID,
    assigned_location_type VARCHAR(20) CHECK (assigned_location_type IN ('store', 'warehouse')),
    assigned_location_name TEXT, -- Nombre de la ubicación asignada (tienda o almacén)
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.users IS 'Usuarios del sistema con roles y ubicaciones asignadas';

-- Usuario especial del sistema (usado para auditoría cuando no hay auth.uid)
INSERT INTO public.users (
    id,
    email,
    name,
    role,
    is_active,
    created_at,
    updated_at
)
VALUES (
    '00000000-0000-0000-0000-000000000000',
    'system@munani.app',
    'Sistema (Automático)',
    'admin',
    false,
    NOW(),
    NOW()
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 3. ÍNDICES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_assigned_location ON public.users(assigned_location_id);
CREATE INDEX IF NOT EXISTS idx_users_location_type ON public.users(assigned_location_id, assigned_location_type);
CREATE INDEX IF NOT EXISTS idx_users_active ON public.users(is_active) WHERE is_active = true;

-- ============================================================================
-- 4. FUNCIONES
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  user_role TEXT;
  user_assigned_location_id TEXT;
  user_assigned_location_type TEXT;
BEGIN
  -- Obtener datos del metadata
  user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'store_manager');
  user_assigned_location_id := NEW.raw_user_meta_data->>'assigned_location_id';
  user_assigned_location_type := NEW.raw_user_meta_data->>'assigned_location_type';

  -- Insertar en public.users
  INSERT INTO public.users (
    id,
    email,
    name,
    role,
    assigned_location_id,
    assigned_location_type
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Usuario'),
    user_role,
    CASE WHEN user_assigned_location_id IS NOT NULL THEN user_assigned_location_id::uuid ELSE NULL END,
    user_assigned_location_type
  );

  -- Agregar rol Y assigned_location_id al app_metadata para JWT
  -- Esto permite que las políticas RLS de transfers funcionen correctamente
  NEW.raw_app_meta_data :=
    COALESCE(NEW.raw_app_meta_data, '{}'::jsonb) ||
    jsonb_build_object(
      'user_role', user_role,
      'assigned_location_id', user_assigned_location_id,
      'assigned_location_type', user_assigned_location_type
    );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS VARCHAR(50) AS $$
DECLARE
    user_role VARCHAR(50);
BEGIN
    SELECT role INTO user_role
    FROM public.users
    WHERE id = user_id;
    RETURN user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role'
    ) = 'admin';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.update_user_assigned_location_name()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se actualiza assigned_location_id o assigned_location_type
    IF (TG_OP = 'UPDATE' AND (
        OLD.assigned_location_id IS DISTINCT FROM NEW.assigned_location_id OR
        OLD.assigned_location_type IS DISTINCT FROM NEW.assigned_location_type
    )) THEN
        -- Actualizar con el nombre de la nueva ubicación
        IF NEW.assigned_location_type = 'store' THEN
            SELECT name INTO NEW.assigned_location_name
            FROM public.stores
            WHERE id = NEW.assigned_location_id;
        ELSIF NEW.assigned_location_type = 'warehouse' THEN
            SELECT name INTO NEW.assigned_location_name
            FROM public.warehouses
            WHERE id = NEW.assigned_location_id;
        ELSE
            NEW.assigned_location_name = NULL;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 5. TRIGGERS
-- ============================================================================
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_assigned_location_name
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_assigned_location_name();

-- ============================================================================
-- 6. ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Usuarios ven su propia información
CREATE POLICY "users_select_own"
ON public.users FOR SELECT
USING (auth.uid() = id);

-- Admins ven todo (usa JWT, sin recursión)
CREATE POLICY "admins_select_all"
ON public.users FOR SELECT
USING (public.is_admin());

-- Solo admins pueden crear usuarios manualmente (usa JWT, sin recursión)
CREATE POLICY "admins_insert_users"
ON public.users FOR INSERT
WITH CHECK (public.is_admin());

-- Permitir inserción desde trigger
CREATE POLICY "auth_users_insert"
ON public.users FOR INSERT
WITH CHECK (true);

-- Usuarios actualizan su propia info
CREATE POLICY "users_update_own"
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- Admins actualizan cualquier usuario (usa JWT, sin recursión)
CREATE POLICY "admins_update_all"
ON public.users FOR UPDATE
USING (public.is_admin());

-- Solo admins eliminan usuarios (usa JWT, sin recursión)
CREATE POLICY "admins_delete_users"
ON public.users FOR DELETE
USING (public.is_admin());

-- ============================================================================
-- ✅ CONFIGURACIÓN COMPLETADA
-- ============================================================================
-- Verificar que todo está correcto:
SELECT 'Tabla users creada' AS status;
SELECT 'RLS habilitado en users' AS status WHERE (SELECT rowsecurity FROM pg_tables WHERE tablename = 'users') = true;
SELECT COUNT(*) || ' políticas RLS creadas' AS status FROM pg_policies WHERE tablename = 'users';
SELECT COUNT(*) || ' índices creados' AS status FROM pg_indexes WHERE tablename = 'users';
SELECT COUNT(*) || ' triggers creados' AS status FROM pg_trigger WHERE tgrelid = 'public.users'::regclass;
SELECT COUNT(*) || ' funciones creadas' AS status FROM pg_proc WHERE proname IN ('update_updated_at_column', 'handle_new_user', 'get_user_role', 'is_admin', 'update_user_assigned_location_name');
