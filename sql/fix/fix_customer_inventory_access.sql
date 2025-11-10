-- ============================================================================
-- MIGRACIÓN: Permitir a clientes ver inventario
-- ============================================================================
-- PROBLEMA: Los clientes no podían sincronizar datos de inventario al iniciar
--           sesión porque las políticas RLS bloqueaban su acceso.
-- SOLUCIÓN: Agregar política SELECT para el rol 'customer'
-- ============================================================================
-- Fecha: 2025-01-09
-- Autor: Sistema
-- Ticket: FIX-CUSTOMER-SYNC
-- ============================================================================

-- Agregar política para que clientes puedan ver todo el inventario
-- Esto es necesario para que puedan ver el catálogo de productos disponibles
CREATE POLICY IF NOT EXISTS "customers_select_all_inventory" ON public.inventory
FOR SELECT USING (
    (current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role') = 'customer'
);

COMMENT ON POLICY "customers_select_all_inventory" ON public.inventory
IS 'Clientes pueden ver todo el inventario para catálogo de productos';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
-- Verificar que la política se creó correctamente
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'inventory'
ORDER BY policyname;

-- ============================================================================
-- TESTING (OPCIONAL)
-- ============================================================================
-- Para probar que funciona:
-- 1. Inicia sesión como cliente en la app
-- 2. Ejecuta la sincronización inicial
-- 3. Verifica que el inventario se sincronice correctamente
--
-- También puedes probar manualmente desde SQL:
-- SET request.jwt.claims = '{"app_metadata": {"user_role": "customer"}}';
-- SELECT * FROM inventory; -- Debería retornar datos
-- ============================================================================

-- ============================================================================
-- ROLLBACK (si es necesario)
-- ============================================================================
-- Para revertir esta migración:
-- DROP POLICY IF EXISTS "customers_select_all_inventory" ON public.inventory;
-- ============================================================================
