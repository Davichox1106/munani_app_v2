-- ============================================================================
-- MIGRACIÓN: Permitir a clientes ver su propio perfil
-- ============================================================================
-- PROBLEMA: Los clientes no podían leer su propio registro de la tabla customers
--           porque no existía una política RLS para SELECT.
--           Esto causaba que _ensureCustomerExists fallara al verificar si el
--           cliente ya existe en Supabase.
-- SOLUCIÓN: Agregar política SELECT para que clientes vean su propio perfil
-- ============================================================================
-- Fecha: 2025-01-09
-- Autor: Sistema
-- Ticket: FIX-CUSTOMER-CART-SYNC
-- ============================================================================

-- Agregar política para que clientes puedan ver su propio perfil
CREATE POLICY IF NOT EXISTS "customers_select_own_profile" ON public.customers
FOR SELECT USING (
  id = auth.uid()
);

COMMENT ON POLICY "customers_select_own_profile" ON public.customers
IS 'Clientes pueden ver su propio perfil';

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
WHERE tablename = 'customers'
ORDER BY policyname;

-- ============================================================================
-- TESTING (OPCIONAL)
-- ============================================================================
-- Para probar que funciona como cliente:
-- 1. Inicia sesión como cliente en la app
-- 2. Agrega items al carrito
-- 3. Verifica que el carrito se sincronice correctamente a Supabase
--
-- También puedes probar manualmente desde SQL (reemplaza el UUID con tu ID):
-- SET request.jwt.claims = '{"sub": "856f379b-4a63-42ed-9f77-1da0aaf08b79"}';
-- SELECT * FROM customers WHERE id = '856f379b-4a63-42ed-9f77-1da0aaf08b79'::uuid;
-- -- Debería retornar el registro del cliente
-- ============================================================================

-- ============================================================================
-- ROLLBACK (si es necesario)
-- ============================================================================
-- Para revertir esta migración:
-- DROP POLICY IF EXISTS "customers_select_own_profile" ON public.customers;
-- ============================================================================
