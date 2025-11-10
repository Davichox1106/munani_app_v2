-- ============================================================================
-- 05_rls_policies.sql - FASE 4
-- Row Level Security (RLS) para inventory
-- ============================================================================
-- OWASP A01:2021 - Broken Access Control
-- Políticas RLS para controlar acceso al inventario por rol y ubicación
-- ============================================================================
-- NOTA: Este script usa funciones creadas en Fase 1 y Fase 2:
--   - public.is_admin()
--   - public.is_store_manager()
--   - public.is_warehouse_manager()
--   - public.is_admin_or_manager()
-- ============================================================================

-- ============================================================================
-- HABILITAR RLS EN TABLA INVENTORY
-- ============================================================================
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- POLÍTICAS RLS: inventory
-- ============================================================================

-- Eliminar políticas existentes si las hay (para re-ejecución segura)
DROP POLICY IF EXISTS "admins_select_all_inventory" ON public.inventory;
DROP POLICY IF EXISTS "store_managers_select_own_inventory" ON public.inventory;
DROP POLICY IF EXISTS "warehouse_managers_select_own_inventory" ON public.inventory;
DROP POLICY IF EXISTS "customers_select_all_inventory" ON public.inventory;
DROP POLICY IF EXISTS "admins_managers_insert_inventory" ON public.inventory;
DROP POLICY IF EXISTS "admins_managers_update_inventory" ON public.inventory;
DROP POLICY IF EXISTS "admins_delete_inventory" ON public.inventory;

-- ============================================================================
-- POLÍTICAS SELECT
-- ============================================================================

-- Admins: Ver todo el inventario
CREATE POLICY "admins_select_all_inventory" ON public.inventory
FOR SELECT USING (public.is_admin());

COMMENT ON POLICY "admins_select_all_inventory" ON public.inventory IS 'Administradores ven todo el inventario';

-- Store managers: Solo ver inventario de tiendas
CREATE POLICY "store_managers_select_own_inventory" ON public.inventory
FOR SELECT USING (
    public.is_store_manager()
    AND location_type = 'store'
);

COMMENT ON POLICY "store_managers_select_own_inventory" ON public.inventory IS 'Store managers ven inventario de tiendas';

-- Warehouse managers: Solo ver inventario de almacenes
CREATE POLICY "warehouse_managers_select_own_inventory" ON public.inventory
FOR SELECT USING (
    public.is_warehouse_manager()
    AND location_type = 'warehouse'
);

COMMENT ON POLICY "warehouse_managers_select_own_inventory" ON public.inventory IS 'Warehouse managers ven inventario de almacenes';

-- Customers: Ver todo el inventario (para catálogo de productos disponibles)
CREATE POLICY "customers_select_all_inventory" ON public.inventory
FOR SELECT USING (
    (current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role') = 'customer'
);

COMMENT ON POLICY "customers_select_all_inventory" ON public.inventory IS 'Clientes pueden ver todo el inventario para catálogo de productos';

-- ============================================================================
-- POLÍTICAS INSERT
-- ============================================================================

-- Solo admins y managers pueden CREAR registros de inventario
CREATE POLICY "admins_managers_insert_inventory" ON public.inventory
FOR INSERT WITH CHECK (public.is_admin_or_manager());

COMMENT ON POLICY "admins_managers_insert_inventory" ON public.inventory IS 'Admins y managers pueden crear inventario';

-- ============================================================================
-- POLÍTICAS UPDATE
-- ============================================================================

-- Admins pueden actualizar cualquier inventario
-- Managers solo pueden actualizar inventario de su tipo de ubicación
CREATE POLICY "admins_managers_update_inventory" ON public.inventory
FOR UPDATE USING (
    public.is_admin()
    OR (public.is_store_manager() AND location_type = 'store')
    OR (public.is_warehouse_manager() AND location_type = 'warehouse')
);

COMMENT ON POLICY "admins_managers_update_inventory" ON public.inventory IS 'Admins actualizan todo, managers solo su tipo de ubicación';

-- ============================================================================
-- POLÍTICAS DELETE
-- ============================================================================

-- Solo admins pueden ELIMINAR registros de inventario
CREATE POLICY "admins_delete_inventory" ON public.inventory
FOR DELETE USING (public.is_admin());

COMMENT ON POLICY "admins_delete_inventory" ON public.inventory IS 'Solo administradores pueden eliminar inventario';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
-- Para verificar las políticas creadas:
-- SELECT policyname, cmd FROM pg_policies WHERE tablename = 'inventory';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
