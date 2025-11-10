-- ============================================================================
-- FASE 10 - Carrito de Compras y Pagos
-- ============================================================================
-- Tablas:
--   - carts: Carrito asociado a un cliente y una ubicación
--   - cart_items: Productos seleccionados dentro del carrito
--   - payment_receipts: Comprobantes de pago cargados por el cliente
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (
        status IN (
            'pending',
            'awaiting_payment',
            'payment_submitted',
            'payment_rejected',
            'completed',
            'cancelled'
        )
    ),
    location_id UUID,
    location_type TEXT CHECK (location_type IN ('store', 'warehouse')),
    location_name TEXT,
    total_items INTEGER NOT NULL DEFAULT 0 CHECK (total_items >= 0),
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.carts IS 'Carritos de compra por cliente';
COMMENT ON COLUMN public.carts.status IS 'pending, awaiting_payment, payment_submitted, payment_rejected, completed, cancelled';
COMMENT ON COLUMN public.carts.location_id IS 'Ubicación (tienda/almacén) desde donde se atenderá el pedido';

-- ============================================================================

CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    inventory_id UUID NOT NULL REFERENCES public.inventory(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id),
    product_name TEXT,
    variant_name TEXT,
    image_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    available_quantity INTEGER NOT NULL CHECK (available_quantity >= 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS cart_items_cart_idx ON public.cart_items(cart_id);

COMMENT ON TABLE public.cart_items IS 'Productos incluidos en un carrito';
COMMENT ON COLUMN public.cart_items.available_quantity IS 'Cantidad disponible al momento de agregar (snapshot)';
COMMENT ON COLUMN public.cart_items.image_urls IS 'Imágenes snapshot del producto';

-- ============================================================================

CREATE TABLE IF NOT EXISTS public.payment_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES public.customers(id),
    storage_path TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'submitted' CHECK (
        status IN ('submitted', 'approved', 'rejected')
    ),
    notes TEXT,
    reviewed_by UUID REFERENCES public.users(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.payment_receipts IS 'Comprobantes de pago cargados por clientes';
COMMENT ON COLUMN public.payment_receipts.storage_path IS 'Ruta en Supabase Storage';
COMMENT ON COLUMN public.payment_receipts.status IS 'submitted, approved, rejected';

-- ============================================================================
-- FIN FASE 10
-- ============================================================================

