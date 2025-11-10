-- ============================================================================
-- FASE 6: MÓDULO DE PROVEEDORES (SUPPLIERS)
-- ============================================================================
-- Tabla para almacenar información de proveedores
-- Los proveedores NO tienen acceso a la app, solo son registros de datos
-- ============================================================================

-- ============================================================================
-- TABLA: suppliers
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Información básica
    name TEXT NOT NULL,
    contact_name TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,

    -- Información tributaria
    ruc_nit TEXT UNIQUE,

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
COMMENT ON TABLE public.suppliers IS 'Proveedores de productos - No tienen acceso a la app';
COMMENT ON COLUMN public.suppliers.name IS 'Nombre comercial del proveedor';
COMMENT ON COLUMN public.suppliers.contact_name IS 'Nombre de la persona de contacto';
COMMENT ON COLUMN public.suppliers.ruc_nit IS 'RUC o NIT del proveedor (único)';
COMMENT ON COLUMN public.suppliers.is_active IS 'Estado del proveedor (activo/inactivo)';

-- ============================================================================
-- ÍNDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_suppliers_name ON public.suppliers(name);
CREATE INDEX IF NOT EXISTS idx_suppliers_ruc_nit ON public.suppliers(ruc_nit);
CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON public.suppliers(is_active);
CREATE INDEX IF NOT EXISTS idx_suppliers_created_by ON public.suppliers(created_by);

-- ============================================================================
-- TRIGGER PARA updated_at
-- ============================================================================

CREATE TRIGGER suppliers_updated_at
    BEFORE UPDATE ON public.suppliers
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- AUDITORÍA (LOG DE CAMBIOS)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_audit_suppliers ON public.suppliers;
CREATE TRIGGER trg_audit_suppliers
    AFTER INSERT OR UPDATE OR DELETE ON public.suppliers
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_all_suppliers" ON public.suppliers;
DROP POLICY IF EXISTS "managers_select_suppliers" ON public.suppliers;

-- Admins: CRUD completo
CREATE POLICY "admins_all_suppliers" ON public.suppliers
FOR ALL USING (public.is_admin());

COMMENT ON POLICY "admins_all_suppliers" ON public.suppliers IS 'Admins tienen acceso completo a proveedores';

-- Store/Warehouse Managers: Solo lectura (para ver proveedores al hacer compras)
CREATE POLICY "managers_select_suppliers" ON public.suppliers
FOR SELECT USING (
    public.is_admin_or_manager()
    AND is_active = true
);

COMMENT ON POLICY "managers_select_suppliers" ON public.suppliers IS 'Managers pueden ver proveedores activos';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar que la tabla fue creada
SELECT
    '✅ Tabla suppliers creada' as status,
    pg_size_pretty(pg_total_relation_size('public.suppliers')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'suppliers';

-- Verificar que RLS está habilitado
SELECT
    '✅ RLS habilitado en suppliers' as status,
    rowsecurity as habilitado
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'suppliers';

-- Contar políticas RLS
SELECT
    '✅ Políticas RLS en suppliers' as status,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'suppliers';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
