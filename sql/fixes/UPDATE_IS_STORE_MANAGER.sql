-- ==========================================================================
-- FIX: Permitir que administradores pasen validación is_store_manager
-- ==========================================================================
-- Objetivo: actualizar la función RLS para que usuarios con rol 'admin' tengan
--           las mismas capacidades que 'store_manager'.
-- ==========================================================================

CREATE OR REPLACE FUNCTION public.is_store_manager()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role'
    ) IN ('store_manager', 'admin');
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION public.is_store_manager() IS 'Verifica si el usuario autenticado es store_manager o admin (lee de app_metadata - SEGURO)';

-- ==========================================================================
-- FIN DEL SCRIPT
-- ==========================================================================









