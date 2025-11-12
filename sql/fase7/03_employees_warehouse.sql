-- ============================================================================
-- FASE 7: MÓDULO DE EMPLEADOS DE ALMACENES
-- ============================================================================
-- Tabla para almacenar información de empleados de almacenes
-- Los empleados están registrados aquí ANTES de crear su usuario
-- Sirve como "pool" de empleados pre-aprobados para almacenes
-- ============================================================================

-- ============================================================================
-- TABLA: employees_warehouse
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.employees_warehouse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Información básica
    name TEXT NOT NULL,
    contact_name TEXT,
    phone TEXT,
    email TEXT UNIQUE NOT NULL,
    ci TEXT UNIQUE NOT NULL,  -- Cédula de Identidad (obligatorio)
    address TEXT,

    -- Información laboral
    position TEXT, -- Cargo: Almacenista, Jefe de Almacén, Operador de Montacargas, etc.
    department TEXT, -- Departamento: Recepción, Despacho, Control de Inventario, etc.

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
COMMENT ON TABLE public.employees_warehouse IS 'Empleados de almacenes pre-registrados - Pool para crear usuarios con rol warehouse_manager';
COMMENT ON COLUMN public.employees_warehouse.name IS 'Nombre completo del empleado';
COMMENT ON COLUMN public.employees_warehouse.email IS 'Email único del empleado - usado para crear usuario';
COMMENT ON COLUMN public.employees_warehouse.ci IS 'Cédula de Identidad única del empleado';
COMMENT ON COLUMN public.employees_warehouse.position IS 'Cargo del empleado (Almacenista, Jefe de Almacén, etc.)';
COMMENT ON COLUMN public.employees_warehouse.department IS 'Departamento (Recepción, Despacho, etc.)';
COMMENT ON COLUMN public.employees_warehouse.is_active IS 'Estado del empleado (activo/inactivo)';

-- ============================================================================
-- ÍNDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_employees_warehouse_name ON public.employees_warehouse(name);
CREATE INDEX IF NOT EXISTS idx_employees_warehouse_email ON public.employees_warehouse(email);
CREATE INDEX IF NOT EXISTS idx_employees_warehouse_ci ON public.employees_warehouse(ci);
CREATE INDEX IF NOT EXISTS idx_employees_warehouse_is_active ON public.employees_warehouse(is_active);
CREATE INDEX IF NOT EXISTS idx_employees_warehouse_position ON public.employees_warehouse(position);
CREATE INDEX IF NOT EXISTS idx_employees_warehouse_created_by ON public.employees_warehouse(created_by);

-- ============================================================================
-- TRIGGER PARA updated_at
-- ============================================================================

CREATE TRIGGER employees_warehouse_updated_at
    BEFORE UPDATE ON public.employees_warehouse
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

ALTER TABLE public.employees_warehouse ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_all_employees_warehouse" ON public.employees_warehouse;
DROP POLICY IF EXISTS "managers_select_employees_warehouse" ON public.employees_warehouse;

-- Admins: CRUD completo
CREATE POLICY "admins_all_employees_warehouse" ON public.employees_warehouse
FOR ALL USING (public.is_admin());

COMMENT ON POLICY "admins_all_employees_warehouse" ON public.employees_warehouse IS 'Solo admins tienen acceso completo a empleados de almacenes';

-- Warehouse Managers: Solo lectura (para ver compañeros de trabajo)
CREATE POLICY "managers_select_employees_warehouse" ON public.employees_warehouse
FOR SELECT USING (
    public.is_admin_or_manager()
    AND is_active = true
);

COMMENT ON POLICY "managers_select_employees_warehouse" ON public.employees_warehouse IS 'Managers pueden ver empleados activos de almacenes';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar que la tabla fue creada
SELECT
    '✅ Tabla employees_warehouse creada' as status,
    pg_size_pretty(pg_total_relation_size('public.employees_warehouse')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'employees_warehouse';

-- Verificar que RLS está habilitado
SELECT
    '✅ RLS habilitado en employees_warehouse' as status,
    rowsecurity as habilitado
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'employees_warehouse';

-- Contar políticas RLS
SELECT
    '✅ Políticas RLS en employees_warehouse' as status,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'employees_warehouse';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
