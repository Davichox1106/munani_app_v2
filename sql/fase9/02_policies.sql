-- FASE 9 - RLS PARA CLIENTES

ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Limpieza
DROP POLICY IF EXISTS admins_all_customers ON public.customers;
DROP POLICY IF EXISTS managers_select_own_customers ON public.customers;
DROP POLICY IF EXISTS customers_select_own_profile ON public.customers;
DROP POLICY IF EXISTS users_insert_customers ON public.customers;
DROP POLICY IF EXISTS users_update_customers ON public.customers;

-- Admin: acceso total
CREATE POLICY admins_all_customers ON public.customers
FOR ALL USING (public.is_admin());

-- Managers/Admin: SELECT por ubicación (o sin ubicación asignada)
CREATE POLICY managers_select_own_customers ON public.customers
FOR SELECT USING (
  public.is_admin_or_manager()
  AND (
    assigned_location_id IS NULL OR
    assigned_location_id = COALESCE(
      (auth.jwt()->>'assigned_location_id')::uuid,
      (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
    )
  )
);

-- Clientes: Ver su propio perfil
CREATE POLICY customers_select_own_profile ON public.customers
FOR SELECT USING (
  id = auth.uid()
);

-- Todos los usuarios autenticados: INSERT
CREATE POLICY users_insert_customers ON public.customers
FOR INSERT TO authenticated
WITH CHECK (
  true
);

-- Todos los usuarios autenticados: UPDATE (solo fila propia por created_by, opcional)
CREATE POLICY users_update_customers ON public.customers
FOR UPDATE TO authenticated
USING (
  created_by = auth.uid() OR public.is_admin()
)
WITH CHECK (
  created_by = auth.uid() OR public.is_admin()
);
