-- ============================================================================
-- FASE 7: MÓDULO DE EMPLEADOS DE TIENDAS
-- ============================================================================
-- Tabla para almacenar información de empleados de tiendas
-- Los empleados están registrados aquí ANTES de crear su usuario
-- Sirve como "pool" de empleados pre-aprobados para tiendas
-- ============================================================================

-- ============================================================================
-- TABLA: employees_store
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.employees_store (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Información básica
    name TEXT NOT NULL,
    contact_name TEXT,
    phone TEXT,
    email TEXT UNIQUE NOT NULL,
    ci TEXT UNIQUE NOT NULL,  -- Cédula de Identidad (obligatorio)
    address TEXT,

    -- Información laboral
    position TEXT, -- Cargo: Vendedor, Cajero, Gerente de Tienda, etc.
    department TEXT, -- Departamento: Ventas, Caja, etc.

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
COMMENT ON TABLE public.employees_store IS 'Empleados de tiendas pre-registrados - Pool para crear usuarios con rol store_manager';
COMMENT ON COLUMN public.employees_store.name IS 'Nombre completo del empleado';
COMMENT ON COLUMN public.employees_store.email IS 'Email único del empleado - usado para crear usuario';
COMMENT ON COLUMN public.employees_store.ci IS 'Cédula de Identidad única del empleado';
COMMENT ON COLUMN public.employees_store.position IS 'Cargo del empleado (Vendedor, Cajero, etc.)';
COMMENT ON COLUMN public.employees_store.department IS 'Departamento (Ventas, Caja, etc.)';
COMMENT ON COLUMN public.employees_store.is_active IS 'Estado del empleado (activo/inactivo)';

-- ============================================================================
-- ÍNDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_employees_store_name ON public.employees_store(name);
CREATE INDEX IF NOT EXISTS idx_employees_store_email ON public.employees_store(email);
CREATE INDEX IF NOT EXISTS idx_employees_store_ci ON public.employees_store(ci);
CREATE INDEX IF NOT EXISTS idx_employees_store_is_active ON public.employees_store(is_active);
CREATE INDEX IF NOT EXISTS idx_employees_store_position ON public.employees_store(position);
CREATE INDEX IF NOT EXISTS idx_employees_store_created_by ON public.employees_store(created_by);

-- ============================================================================
-- TRIGGER PARA updated_at
-- ============================================================================

CREATE TRIGGER employees_store_updated_at
    BEFORE UPDATE ON public.employees_store
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- AUDITORÍA (LOG DE CAMBIOS)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_audit_employees_store ON public.employees_store;
CREATE TRIGGER trg_audit_employees_store
    AFTER INSERT OR UPDATE OR DELETE ON public.employees_store
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.employees_store ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_all_employees_store" ON public.employees_store;
DROP POLICY IF EXISTS "managers_select_employees_store" ON public.employees_store;

-- Admins: CRUD completo
CREATE POLICY "admins_all_employees_store" ON public.employees_store
FOR ALL USING (public.is_admin());

COMMENT ON POLICY "admins_all_employees_store" ON public.employees_store IS 'Solo admins tienen acceso completo a empleados de tiendas';

-- Store Managers: Solo lectura (para ver compañeros de trabajo)
CREATE POLICY "managers_select_employees_store" ON public.employees_store
FOR SELECT USING (
    public.is_admin_or_manager()
    AND is_active = true
);

COMMENT ON POLICY "managers_select_employees_store" ON public.employees_store IS 'Managers pueden ver empleados activos de tiendas';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar que la tabla fue creada
SELECT
    '✅ Tabla employees_store creada' as status,
    pg_size_pretty(pg_total_relation_size('public.employees_store')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'employees_store';

-- Verificar que RLS está habilitado
SELECT
    '✅ RLS habilitado en employees_store' as status,
    rowsecurity as habilitado
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'employees_store';

-- Contar políticas RLS
SELECT
    '✅ Políticas RLS en employees_store' as status,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'employees_store';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
