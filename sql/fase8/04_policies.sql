-- FASE 8 - RLS POLICIES VENTAS

-- Habilitar RLS
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;

-- Limpiar políticas previas
DROP POLICY IF EXISTS admins_all_sales ON public.sales;
DROP POLICY IF EXISTS managers_select_own_sales ON public.sales;
DROP POLICY IF EXISTS managers_insert_own_sales ON public.sales;
DROP POLICY IF EXISTS managers_complete_own_sales ON public.sales;
DROP POLICY IF EXISTS managers_delete_own_sales ON public.sales;
DROP POLICY IF EXISTS admins_all_sale_items ON public.sale_items;
DROP POLICY IF EXISTS managers_select_own_sale_items ON public.sale_items;
DROP POLICY IF EXISTS managers_insert_own_sale_items ON public.sale_items;
DROP POLICY IF EXISTS managers_update_own_sale_items ON public.sale_items;
DROP POLICY IF EXISTS managers_delete_own_sale_items ON public.sale_items;

-- =====================
-- POLÍTICAS PARA SALES
-- =====================

-- Admin: CRUD completo
CREATE POLICY admins_all_sales ON public.sales
FOR ALL USING (public.is_admin());

-- Managers: ver ventas de su ubicación
CREATE POLICY managers_select_own_sales ON public.sales
FOR SELECT USING (
  public.is_admin_or_manager()
  AND location_id = COALESCE(
    (auth.jwt()->>'assigned_location_id')::uuid,
    (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
  )
);

-- Managers: pueden CREAR ventas en su ubicación asignada
CREATE POLICY managers_insert_own_sales ON public.sales
FOR INSERT
WITH CHECK (
  public.is_admin_or_manager()
  AND location_id = COALESCE(
    (auth.jwt()->>'assigned_location_id')::uuid,
    (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
  )
  AND created_by = auth.uid()
);

-- Managers: pueden ACTUALIZAR (completar/cancelar) ventas de su ubicación
CREATE POLICY managers_complete_own_sales ON public.sales
FOR UPDATE
USING (
  public.is_admin_or_manager()
  AND location_id = COALESCE(
    (auth.jwt()->>'assigned_location_id')::uuid,
    (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
  )
)
WITH CHECK (
  public.is_admin_or_manager()
  AND location_id = COALESCE(
    (auth.jwt()->>'assigned_location_id')::uuid,
    (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
  )
);

-- Managers: pueden ELIMINAR (cancelar) ventas de su ubicación
CREATE POLICY managers_delete_own_sales ON public.sales
FOR DELETE
USING (
  public.is_admin_or_manager()
  AND location_id = COALESCE(
    (auth.jwt()->>'assigned_location_id')::uuid,
    (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
  )
);

-- ==========================
-- POLÍTICAS PARA SALE_ITEMS
-- ==========================

-- Admin: CRUD completo
CREATE POLICY admins_all_sale_items ON public.sale_items
FOR ALL USING (public.is_admin());

-- Managers: ver items de ventas de su ubicación
CREATE POLICY managers_select_own_sale_items ON public.sale_items
FOR SELECT USING (
  public.is_admin_or_manager()
  AND EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND s.location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
      )
  )
);

-- Managers: pueden CREAR items en ventas de su ubicación
CREATE POLICY managers_insert_own_sale_items ON public.sale_items
FOR INSERT
WITH CHECK (
  public.is_admin_or_manager()
  AND EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND s.location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
      )
  )
);

-- Managers: pueden ACTUALIZAR items de ventas de su ubicación
CREATE POLICY managers_update_own_sale_items ON public.sale_items
FOR UPDATE
USING (
  public.is_admin_or_manager()
  AND EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND s.location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
      )
  )
)
WITH CHECK (
  public.is_admin_or_manager()
  AND EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND s.location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
      )
  )
);

-- Managers: pueden ELIMINAR items de ventas de su ubicación
CREATE POLICY managers_delete_own_sale_items ON public.sale_items
FOR DELETE
USING (
  public.is_admin_or_manager()
  AND EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND s.location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
      )
  )
);
