-- ============================================================================
-- 03_indexes.sql - FASE 2
-- Índices para optimizar queries
-- ============================================================================

-- ============================================================================
-- ÍNDICES: stores
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_stores_manager_id ON public.stores(manager_id);
CREATE INDEX IF NOT EXISTS idx_stores_is_active ON public.stores(is_active);
CREATE INDEX IF NOT EXISTS idx_stores_name ON public.stores USING gin(to_tsvector('spanish', name));
CREATE INDEX IF NOT EXISTS idx_stores_created_at ON public.stores(created_at DESC);

-- ============================================================================
-- ÍNDICES: warehouses
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_warehouses_manager_id ON public.warehouses(manager_id);
CREATE INDEX IF NOT EXISTS idx_warehouses_is_active ON public.warehouses(is_active);
CREATE INDEX IF NOT EXISTS idx_warehouses_name ON public.warehouses USING gin(to_tsvector('spanish', name));
CREATE INDEX IF NOT EXISTS idx_warehouses_created_at ON public.warehouses(created_at DESC);

-- ============================================================================
-- ÍNDICES: products
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);
CREATE INDEX IF NOT EXISTS idx_products_created_by ON public.products(created_by);
CREATE INDEX IF NOT EXISTS idx_products_name ON public.products USING gin(to_tsvector('spanish', name));
CREATE INDEX IF NOT EXISTS idx_products_has_variants ON public.products(has_variants);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON public.products(created_at DESC);

-- ============================================================================
-- ÍNDICES: product_variants
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON public.product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON public.product_variants(sku);
CREATE INDEX IF NOT EXISTS idx_product_variants_is_active ON public.product_variants(is_active);
CREATE INDEX IF NOT EXISTS idx_product_variants_attributes ON public.product_variants USING gin(variant_attributes);
CREATE INDEX IF NOT EXISTS idx_product_variants_created_at ON public.product_variants(created_at DESC);

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
