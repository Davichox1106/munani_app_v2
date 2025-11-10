-- ============================================================================
-- 03_indexes.sql - FASE 4
-- Índices para optimizar queries de inventario
-- ============================================================================

-- Índice por product_variant_id (búsquedas frecuentes)
CREATE INDEX IF NOT EXISTS idx_inventory_product_variant 
ON public.inventory(product_variant_id);

-- Índice por location_id (filtrar por ubicación)
CREATE INDEX IF NOT EXISTS idx_inventory_location 
ON public.inventory(location_id);

-- Índice por location_type (filtrar por tipo)
CREATE INDEX IF NOT EXISTS idx_inventory_location_type 
ON public.inventory(location_type);

-- Índice compuesto para búsquedas por ubicación completa
CREATE INDEX IF NOT EXISTS idx_inventory_location_full 
ON public.inventory(location_id, location_type);

-- Índice para stock bajo (alertas)
CREATE INDEX IF NOT EXISTS idx_inventory_low_stock 
ON public.inventory(quantity) 
WHERE quantity <= min_stock;

-- Índice por updated_by (auditoría)
CREATE INDEX IF NOT EXISTS idx_inventory_updated_by 
ON public.inventory(updated_by);

-- Índice por last_updated (ordenar por recientes)
CREATE INDEX IF NOT EXISTS idx_inventory_last_updated 
ON public.inventory(last_updated DESC);

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================

