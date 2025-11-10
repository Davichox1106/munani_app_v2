-- ============================================================================
-- 05_rls_policies.sql - FASE 5
-- Row Level Security (RLS) para transfers
-- ============================================================================
-- OWASP A01:2021 - Broken Access Control
-- Políticas RLS para controlar acceso a transferencias por rol y ubicación
-- ============================================================================
-- NOTA: Este script usa funciones creadas en Fase 1 y Fase 2:
--   - public.is_admin()
--   - public.is_store_manager()
--   - public.is_warehouse_manager()
--   - public.is_admin_or_manager()
-- ============================================================================

-- ============================================================================
-- HABILITAR RLS EN TABLA TRANSFERS
-- ============================================================================
ALTER TABLE public.transfers ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- POLÍTICAS RLS: transfers
-- ============================================================================

-- Eliminar políticas existentes si las hay (para re-ejecución segura)
DROP POLICY IF EXISTS "admins_select_all_transfers" ON public.transfers;
DROP POLICY IF EXISTS "store_managers_select_own_transfers" ON public.transfers;
DROP POLICY IF EXISTS "warehouse_managers_select_own_transfers" ON public.transfers;
DROP POLICY IF EXISTS "users_select_own_requested_transfers" ON public.transfers;
DROP POLICY IF EXISTS "admins_managers_insert_transfers" ON public.transfers;
DROP POLICY IF EXISTS "admins_managers_update_transfers" ON public.transfers;
DROP POLICY IF EXISTS "admins_delete_transfers" ON public.transfers;

-- ============================================================================
-- POLÍTICAS SELECT
-- ============================================================================

-- Admins: Ver todas las transferencias
CREATE POLICY "admins_select_all_transfers" ON public.transfers
FOR SELECT USING (public.is_admin());

COMMENT ON POLICY "admins_select_all_transfers" ON public.transfers IS 'Administradores ven todas las transferencias';

-- Store managers: Ver transferencias de su tienda (como origen o destino)
CREATE POLICY "store_managers_select_own_transfers" ON public.transfers
FOR SELECT USING (
    public.is_store_manager()
    AND (
        (from_location_type = 'store' AND from_location_id = (
            COALESCE(
                (auth.jwt() ->> 'assigned_location_id'),
                (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
            )
        )::uuid)
        OR (to_location_type = 'store' AND to_location_id = (
            COALESCE(
                (auth.jwt() ->> 'assigned_location_id'),
                (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
            )
        )::uuid)
    )
);

COMMENT ON POLICY "store_managers_select_own_transfers" ON public.transfers IS 'Store managers ven transferencias de su tienda (busca en JWT root y app_metadata)';

-- Warehouse managers: Ver transferencias de su almacén (como origen o destino)
CREATE POLICY "warehouse_managers_select_own_transfers" ON public.transfers
FOR SELECT USING (
    public.is_warehouse_manager()
    AND (
        (from_location_type = 'warehouse' AND from_location_id = (
            COALESCE(
                (auth.jwt() ->> 'assigned_location_id'),
                (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
            )
        )::uuid)
        OR (to_location_type = 'warehouse' AND to_location_id = (
            COALESCE(
                (auth.jwt() ->> 'assigned_location_id'),
                (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
            )
        )::uuid)
    )
);

COMMENT ON POLICY "warehouse_managers_select_own_transfers" ON public.transfers IS 'Warehouse managers ven transferencias de su almacén (busca en JWT root y app_metadata)';

-- Usuarios: Ver transferencias que ellos solicitaron
CREATE POLICY "users_select_own_requested_transfers" ON public.transfers
FOR SELECT USING (requested_by = auth.uid());

COMMENT ON POLICY "users_select_own_requested_transfers" ON public.transfers IS 'Usuarios ven transferencias que solicitaron';

-- ============================================================================
-- POLÍTICAS INSERT
-- ============================================================================

-- Solo admins y managers pueden CREAR transferencias
CREATE POLICY "admins_managers_insert_transfers" ON public.transfers
FOR INSERT WITH CHECK (public.is_admin_or_manager());

COMMENT ON POLICY "admins_managers_insert_transfers" ON public.transfers IS 'Admins y managers pueden crear transferencias';

-- ============================================================================
-- POLÍTICAS UPDATE
-- ============================================================================

-- Admins pueden actualizar cualquier transferencia
-- Managers solo pueden actualizar transferencias de su ubicación
CREATE POLICY "admins_managers_update_transfers" ON public.transfers
FOR UPDATE USING (
    public.is_admin()
    OR (
        public.is_store_manager()
        AND (
            (from_location_type = 'store' AND from_location_id = (
                COALESCE(
                    (auth.jwt() ->> 'assigned_location_id'),
                    (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
                )
            )::uuid)
            OR (to_location_type = 'store' AND to_location_id = (
                COALESCE(
                    (auth.jwt() ->> 'assigned_location_id'),
                    (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
                )
            )::uuid)
        )
    )
    OR (
        public.is_warehouse_manager()
        AND (
            (from_location_type = 'warehouse' AND from_location_id = (
                COALESCE(
                    (auth.jwt() ->> 'assigned_location_id'),
                    (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
                )
            )::uuid)
            OR (to_location_type = 'warehouse' AND to_location_id = (
                COALESCE(
                    (auth.jwt() ->> 'assigned_location_id'),
                    (auth.jwt() -> 'app_metadata' ->> 'assigned_location_id')
                )
            )::uuid)
        )
    )
);

COMMENT ON POLICY "admins_managers_update_transfers" ON public.transfers IS 'Admins actualizan todo, managers solo transferencias de su ubicación (busca en JWT root y app_metadata)';

-- ============================================================================
-- POLÍTICAS DELETE
-- ============================================================================

-- Solo admins pueden eliminar transferencias
CREATE POLICY "admins_delete_transfers" ON public.transfers
FOR DELETE USING (public.is_admin());

COMMENT ON POLICY "admins_delete_transfers" ON public.transfers IS 'Solo admins pueden eliminar transferencias';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
