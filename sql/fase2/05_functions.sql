-- ============================================================================
-- 01_5_functions.sql - FASE 2
-- Funciones auxiliares para RLS
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de 01_extensions.sql y ANTES de 05_rls_policies.sql
-- ============================================================================

-- ============================================================================
-- FUNCIÓN: is_store_manager
-- ============================================================================
-- SEGURIDAD: Lee de app_metadata (solo el servidor puede modificarlo)
-- PRODUCCIÓN: SECURITY DEFINER asegura permisos correctos
CREATE OR REPLACE FUNCTION public.is_store_manager()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role'
    ) IN ('store_manager', 'admin');
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION public.is_store_manager() IS 'Verifica si el usuario autenticado es store_manager o admin (lee de app_metadata - SEGURO)';

-- ============================================================================
-- FUNCIÓN: is_warehouse_manager
-- ============================================================================
-- SEGURIDAD: Lee de app_metadata (solo el servidor puede modificarlo)
-- PRODUCCIÓN: SECURITY DEFINER asegura permisos correctos
CREATE OR REPLACE FUNCTION public.is_warehouse_manager()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role'
    ) = 'warehouse_manager';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION public.is_warehouse_manager() IS 'Verifica si el usuario autenticado es warehouse_manager (lee de app_metadata - SEGURO)';

-- ============================================================================
-- FUNCIÓN: is_admin
-- ============================================================================
-- SEGURIDAD: Lee de app_metadata (solo el servidor puede modificarlo)
-- PRODUCCIÓN: SECURITY DEFINER asegura permisos correctos
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role'
    ) = 'admin';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION public.is_admin() IS 'Verifica si el usuario autenticado es admin (lee de app_metadata - SEGURO)';

-- ============================================================================
-- FUNCIÓN: is_admin_or_manager
-- ============================================================================
-- SEGURIDAD: Lee de app_metadata (solo el servidor puede modificarlo)
-- PRODUCCIÓN: SECURITY DEFINER asegura permisos correctos
CREATE OR REPLACE FUNCTION public.is_admin_or_manager()
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
BEGIN
    user_role := current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role';
    RETURN user_role IN ('admin', 'store_manager', 'warehouse_manager');
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION public.is_admin_or_manager() IS 'Verifica si el usuario autenticado es admin o manager (lee de app_metadata - SEGURO)';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
