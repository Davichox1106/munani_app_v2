-- ============================================================================
-- FASE 7: MÓDULO DE ADMINISTRADORES
-- ============================================================================
-- Tabla para almacenar información de administradores
-- Los administradores están registrados aquí ANTES de crear su usuario
-- Sirve como "pool" de administradores pre-aprobados
-- ============================================================================

-- ============================================================================
-- TABLA: administrators
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.administrators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Información básica
    name TEXT NOT NULL,
    contact_name TEXT,
    phone TEXT,
    email TEXT UNIQUE NOT NULL,
    ci TEXT UNIQUE NOT NULL,  -- Cédula de Identidad (obligatorio)
    address TEXT,

    -- Información adicional
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_by UUID REFERENCES public.users(id)
);

-- Comentarios
COMMENT ON TABLE public.administrators IS 'Administradores pre-registrados - Pool para crear usuarios con rol admin';
COMMENT ON COLUMN public.administrators.name IS 'Nombre completo del administrador';
COMMENT ON COLUMN public.administrators.email IS 'Email único del administrador - usado para crear usuario';
COMMENT ON COLUMN public.administrators.ci IS 'Cédula de Identidad única del administrador';
COMMENT ON COLUMN public.administrators.is_active IS 'Estado del administrador (activo/inactivo)';

-- ============================================================================
-- ÍNDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_administrators_name ON public.administrators(name);
CREATE INDEX IF NOT EXISTS idx_administrators_email ON public.administrators(email);
CREATE INDEX IF NOT EXISTS idx_administrators_ci ON public.administrators(ci);
CREATE INDEX IF NOT EXISTS idx_administrators_is_active ON public.administrators(is_active);
CREATE INDEX IF NOT EXISTS idx_administrators_created_by ON public.administrators(created_by);

-- ============================================================================
-- TRIGGER PARA updated_at
-- ============================================================================

CREATE TRIGGER administrators_updated_at
    BEFORE UPDATE ON public.administrators
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- AUDITORÍA (LOG DE CAMBIOS)
-- ============================================================================
-- NOTA: Los triggers de auditoría se crean en FASE 11
-- Ver: sql/fase11/01_sistema_de_auditoria.sql

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.administrators ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_all_administrators" ON public.administrators;

-- Admins: CRUD completo
CREATE POLICY "admins_all_administrators" ON public.administrators
FOR ALL USING (public.is_admin());

COMMENT ON POLICY "admins_all_administrators" ON public.administrators IS 'Solo admins tienen acceso completo a administradores';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar que la tabla fue creada
SELECT
    '✅ Tabla administrators creada' as status,
    pg_size_pretty(pg_total_relation_size('public.administrators')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'administrators';

-- Verificar que RLS está habilitado
SELECT
    '✅ RLS habilitado en administrators' as status,
    rowsecurity as habilitado
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'administrators';

-- Contar políticas RLS
SELECT
    '✅ Políticas RLS en administrators' as status,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'administrators';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
