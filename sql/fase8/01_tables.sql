-- FASE 8 - TABLAS DE VENTAS

CREATE TABLE IF NOT EXISTS public.sales (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_number text UNIQUE,
    location_id uuid NOT NULL,
    location_type text NOT NULL CHECK (location_type IN ('store','warehouse')),
    customer_name text,
    subtotal numeric(12,2) NOT NULL DEFAULT 0.00,
    tax numeric(12,2) NOT NULL DEFAULT 0.00,
    total numeric(12,2) NOT NULL DEFAULT 0.00,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','completed','cancelled')),
    notes text,
    sale_date timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid NOT NULL REFERENCES auth.users(id)
);

COMMENT ON TABLE public.sales IS 'Encabezado de ventas';

CREATE TABLE IF NOT EXISTS public.sale_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id uuid NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
    product_variant_id uuid NOT NULL REFERENCES public.product_variants(id),
    product_name text NOT NULL,
    variant_name text,
    quantity int NOT NULL CHECK (quantity > 0),
    unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    subtotal numeric(12,2) NOT NULL DEFAULT 0.00,
    created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.sale_items IS 'Ítems de ventas';

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_sales_location ON public.sales(location_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale ON public.sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_variant ON public.sale_items(product_variant_id);
