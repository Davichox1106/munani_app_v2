-- ============================================================================
-- FASE 10 - RLS para Carrito y Pagos
-- ============================================================================

-- ============================================================================
-- POLÍTICAS: carts
-- ============================================================================

ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS carts_select_policy ON public.carts;
DROP POLICY IF EXISTS carts_modify_policy ON public.carts;
DROP POLICY IF EXISTS carts_admin_policy ON public.carts;

-- Clientes: ver y modificar solo su carrito
CREATE POLICY carts_select_policy ON public.carts
FOR SELECT USING (
  customer_id = auth.uid()
  OR public.is_admin()
  OR (
    public.is_store_manager() AND location_type = 'store' AND EXISTS (
      SELECT 1 FROM public.stores s
      WHERE s.id = location_id
        AND s.manager_id = auth.uid()
    )
  )
  OR (
    public.is_warehouse_manager() AND location_type = 'warehouse' AND EXISTS (
      SELECT 1 FROM public.warehouses w
      WHERE w.id = location_id
        AND w.manager_id = auth.uid()
    )
  )
);

CREATE POLICY carts_modify_policy ON public.carts
FOR ALL USING (customer_id = auth.uid())
WITH CHECK (customer_id = auth.uid());

CREATE POLICY carts_admin_policy ON public.carts
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ============================================================================
-- POLÍTICAS: cart_items
-- ============================================================================

ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS cart_items_select_policy ON public.cart_items;
DROP POLICY IF EXISTS cart_items_modify_policy ON public.cart_items;
DROP POLICY IF EXISTS cart_items_admin_policy ON public.cart_items;

CREATE POLICY cart_items_select_policy ON public.cart_items
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.carts c
    WHERE c.id = cart_id
      AND (
        c.customer_id = auth.uid()
        OR public.is_admin()
        OR (
          public.is_store_manager() AND c.location_type = 'store' AND EXISTS (
            SELECT 1 FROM public.stores s
            WHERE s.id = c.location_id
              AND s.manager_id = auth.uid()
          )
        )
        OR (
          public.is_warehouse_manager() AND c.location_type = 'warehouse' AND EXISTS (
            SELECT 1 FROM public.warehouses w
            WHERE w.id = c.location_id
              AND w.manager_id = auth.uid()
          )
        )
      )
  )
);

CREATE POLICY cart_items_modify_policy ON public.cart_items
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.carts c
    WHERE c.id = cart_id
      AND c.customer_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.carts c
    WHERE c.id = cart_id
      AND c.customer_id = auth.uid()
  )
);

CREATE POLICY cart_items_admin_policy ON public.cart_items
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ============================================================================
-- POLÍTICAS: payment_receipts
-- ============================================================================

ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payment_receipts_select_policy ON public.payment_receipts;
DROP POLICY IF EXISTS payment_receipts_modify_policy ON public.payment_receipts;
DROP POLICY IF EXISTS payment_receipts_admin_policy ON public.payment_receipts;

CREATE POLICY payment_receipts_select_policy ON public.payment_receipts
FOR SELECT USING (
  uploaded_by = auth.uid()
  OR public.is_admin()
  OR EXISTS (
    SELECT 1 FROM public.carts c
    WHERE c.id = cart_id
      AND (
        (public.is_store_manager() AND c.location_type = 'store' AND EXISTS (
          SELECT 1 FROM public.stores s
          WHERE s.id = c.location_id
            AND s.manager_id = auth.uid()
        ))
        OR
        (public.is_warehouse_manager() AND c.location_type = 'warehouse' AND EXISTS (
          SELECT 1 FROM public.warehouses w
          WHERE w.id = c.location_id
            AND w.manager_id = auth.uid()
        ))
        OR c.customer_id = auth.uid()
      )
  )
);

CREATE POLICY payment_receipts_modify_policy ON public.payment_receipts
FOR ALL USING (uploaded_by = auth.uid())
WITH CHECK (uploaded_by = auth.uid());

CREATE POLICY payment_receipts_admin_policy ON public.payment_receipts
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ============================================================================
-- POLÍTICAS: storage bucket payment-qr
-- ============================================================================

DROP POLICY IF EXISTS "qr insert" ON storage.objects;
DROP POLICY IF EXISTS "qr update" ON storage.objects;
DROP POLICY IF EXISTS "qr select" ON storage.objects;

CREATE POLICY "qr insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'payment-qr' AND auth.role() = 'authenticated');

CREATE POLICY "qr update"
ON storage.objects FOR UPDATE
USING (bucket_id = 'payment-qr' AND auth.role() = 'authenticated')
WITH CHECK (bucket_id = 'payment-qr' AND auth.role() = 'authenticated');

CREATE POLICY "qr select"
ON storage.objects FOR SELECT
USING (bucket_id = 'payment-qr' AND auth.role() = 'authenticated');

-- ============================================================================
-- POLÍTICAS: storage bucket payment_receipts
-- ============================================================================

DROP POLICY IF EXISTS "payment receipts insert" ON storage.objects;
DROP POLICY IF EXISTS "payment receipts update" ON storage.objects;
DROP POLICY IF EXISTS "payment receipts select" ON storage.objects;

CREATE POLICY "payment receipts insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'payment_receipts' AND auth.role() = 'authenticated');

CREATE POLICY "payment receipts update"
ON storage.objects FOR UPDATE
USING (bucket_id = 'payment_receipts' AND auth.role() = 'authenticated')
WITH CHECK (bucket_id = 'payment_receipts' AND auth.role() = 'authenticated');

CREATE POLICY "payment receipts select"
ON storage.objects FOR SELECT
USING (bucket_id = 'payment_receipts' AND auth.role() = 'authenticated');

-- ============================================================================
-- POLÍTICAS: storage.objects (Bucket 'product-images')
-- ============================================================================

DROP POLICY IF EXISTS "product images insert" ON storage.objects;
DROP POLICY IF EXISTS "product images update" ON storage.objects;
DROP POLICY IF EXISTS "product images select" ON storage.objects;

CREATE POLICY "product images insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');

CREATE POLICY "product images update"
ON storage.objects FOR UPDATE
USING (bucket_id = 'product-images' AND auth.role() = 'authenticated')
WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');

CREATE POLICY "product images select"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images' AND auth.role() = 'authenticated');

-- ============================================================================
-- FIN RLS FASE 10
-- ============================================================================

