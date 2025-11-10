-- ============================================================================
-- 02_tables.sql - FASE 2
-- Tablas: stores, warehouses, products, product_variants
-- ============================================================================

-- ============================================================================
-- TABLA: stores (Tiendas)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL,
    phone TEXT,
    payment_qr_url TEXT,
    payment_qr_description TEXT,
    manager_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT stores_name_not_empty CHECK (length(trim(name)) > 0),
    CONSTRAINT stores_address_not_empty CHECK (length(trim(address)) > 0)
);

COMMENT ON TABLE public.stores IS 'Tiendas físicas donde se realizan ventas';
COMMENT ON COLUMN public.stores.manager_id IS 'UUID del encargado (role: store_manager)';
COMMENT ON COLUMN public.stores.payment_qr_url IS 'URL del código QR para pagos en tienda';
COMMENT ON COLUMN public.stores.payment_qr_description IS 'Descripción/instrucciones del pago por QR';
COMMENT ON COLUMN public.stores.name IS 'Nombre único de la tienda';

-- ============================================================================
-- TABLA: warehouses (Almacenes)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL,
    phone TEXT,
    payment_qr_url TEXT,
    payment_qr_description TEXT,
    manager_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT warehouses_name_not_empty CHECK (length(trim(name)) > 0),
    CONSTRAINT warehouses_address_not_empty CHECK (length(trim(address)) > 0)
);

COMMENT ON TABLE public.warehouses IS 'Almacenes donde se guarda inventario';
COMMENT ON COLUMN public.warehouses.manager_id IS 'UUID del encargado (role: warehouse_manager)';
COMMENT ON COLUMN public.warehouses.payment_qr_url IS 'URL del código QR para pagos en almacén';
COMMENT ON COLUMN public.warehouses.payment_qr_description IS 'Descripción/instrucciones del pago por QR';
COMMENT ON COLUMN public.warehouses.name IS 'Nombre único del almacén';

-- ============================================================================
-- TABLA: products (Productos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('barritas_nutritivas', 'barritas_proteicas', 'barritas_dieteticas', 'otros')),
    base_price_sell DECIMAL(10,2) NOT NULL CHECK (base_price_sell >= 0),
    base_price_buy DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (base_price_buy >= 0),
    has_variants BOOLEAN DEFAULT false,
    image_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_by UUID NOT NULL REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT products_name_not_empty CHECK (length(trim(name)) > 0),
    CONSTRAINT products_base_price_sell_positive CHECK (base_price_sell > 0),
    CONSTRAINT products_base_price_buy_positive CHECK (base_price_buy >= 0)
);

COMMENT ON TABLE public.products IS 'Productos base del inventario - OWASP A09: Auditoría con created_by';
COMMENT ON COLUMN public.products.category IS 'barritas_nutritivas, barritas_proteicas, barritas_dieteticas, otros';
COMMENT ON COLUMN public.products.base_price_sell IS 'Precio de venta base del producto';
COMMENT ON COLUMN public.products.base_price_buy IS 'Precio de compra base del producto';
COMMENT ON COLUMN public.products.has_variants IS 'Si tiene variantes (colores, tamaños, etc.)';
COMMENT ON COLUMN public.products.image_urls IS 'Listado de imágenes asociadas (URLs o rutas)';
COMMENT ON COLUMN public.products.created_by IS 'Auditoría: quién creó (OWASP A09)';
COMMENT ON COLUMN public.products.name IS 'Nombre único del producto';

-- ============================================================================
-- TABLA: product_variants (Variantes de Productos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    sku TEXT NOT NULL UNIQUE,
    variant_name TEXT NOT NULL,
    variant_attributes JSONB DEFAULT '{}',
    price_sell DECIMAL(10,2) NOT NULL CHECK (price_sell >= 0),
    price_buy DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (price_buy >= 0),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT product_variants_sku_not_empty CHECK (length(trim(sku)) > 0),
    CONSTRAINT product_variants_name_not_empty CHECK (length(trim(variant_name)) > 0),
    CONSTRAINT product_variants_price_sell_positive CHECK (price_sell > 0),
    CONSTRAINT product_variants_price_buy_positive CHECK (price_buy >= 0)
);

COMMENT ON TABLE public.product_variants IS 'Variantes con SKU único - OWASP A03: Validación de datos';
COMMENT ON COLUMN public.product_variants.sku IS 'Stock Keeping Unit (único)';
COMMENT ON COLUMN public.product_variants.variant_attributes IS 'JSON: {color: "rojo", size: "2x3m"}';
COMMENT ON COLUMN public.product_variants.variant_name IS 'Nombre descriptivo de la variante';
COMMENT ON COLUMN public.product_variants.price_sell IS 'Precio de venta de la variante';
COMMENT ON COLUMN public.product_variants.price_buy IS 'Precio de compra de la variante';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
