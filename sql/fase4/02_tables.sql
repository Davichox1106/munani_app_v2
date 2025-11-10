-- ============================================================================
-- 02_tables.sql - FASE 4
-- Tabla: inventory (Inventario)
-- ============================================================================
-- DESCRIPCIÓN:
-- Tabla para gestionar el inventario de productos por ubicación (tienda/almacén)
-- Incluye control de stock mínimo/máximo y auditoría
-- ============================================================================

-- ============================================================================
-- TABLA: inventory
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relaciones
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    location_id UUID NOT NULL,
    location_type TEXT NOT NULL CHECK (location_type IN ('store', 'warehouse')),
    location_name TEXT, -- Nombre de la ubicación para facilitar consultas
    
    -- Cantidades
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    min_stock INTEGER NOT NULL DEFAULT 5,
    max_stock INTEGER NOT NULL DEFAULT 1000,
    
    -- Costos (opcional, para gestión financiera)
    unit_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (unit_cost >= 0),
    total_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (total_cost >= 0),
    last_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (last_cost >= 0),
    cost_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Imágenes asociadas al producto
    image_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Auditoría
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID NOT NULL REFERENCES public.users(id),

    -- Constraints
    CONSTRAINT inventory_unique_location UNIQUE (product_variant_id, location_id, location_type),
    CONSTRAINT inventory_min_less_than_max CHECK (min_stock < max_stock)
);

-- ============================================================================
-- COMENTARIOS
-- ============================================================================
COMMENT ON TABLE public.inventory IS 'Inventario de productos por ubicación - OWASP A09: Auditoría con updated_by';
COMMENT ON COLUMN public.inventory.product_variant_id IS 'Variante del producto';
COMMENT ON COLUMN public.inventory.location_id IS 'ID de store o warehouse';
COMMENT ON COLUMN public.inventory.location_type IS 'store o warehouse';
COMMENT ON COLUMN public.inventory.location_name IS 'Nombre de la ubicación para facilitar consultas';
COMMENT ON COLUMN public.inventory.quantity IS 'Cantidad disponible (no negativa)';
COMMENT ON COLUMN public.inventory.min_stock IS 'Stock mínimo para alertas';
COMMENT ON COLUMN public.inventory.max_stock IS 'Stock máximo permitido';
COMMENT ON COLUMN public.inventory.unit_cost IS 'Costo unitario promedio del inventario';
COMMENT ON COLUMN public.inventory.total_cost IS 'Costo total del inventario (quantity * unit_cost)';
COMMENT ON COLUMN public.inventory.last_cost IS 'Último costo de compra registrado';
COMMENT ON COLUMN public.inventory.cost_updated_at IS 'Fecha de última actualización de costos';
COMMENT ON COLUMN public.inventory.image_urls IS 'Listado de imágenes asociadas al producto/variante';
COMMENT ON COLUMN public.inventory.updated_by IS 'Último usuario que modificó (auditoría)';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================

