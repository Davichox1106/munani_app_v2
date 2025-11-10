-- =============================================================================
-- MIGRACIÓN: Agregar columnas de costos a inventory y poblar datos existentes
-- =============================================================================
-- Estrategia de poblamiento:
-- 1) Preferir costos de compras recibidas por (product_variant_id, location)
--    - unit_cost = promedio de purchase_items.unit_cost (solo compras 'received')
--    - last_cost = costo de la compra 'received' más reciente
-- 2) Si no hay compras, usar products.base_price_buy como fallback
-- 3) total_cost = quantity * unit_cost
-- =============================================================================

-- MIGRACIÓN INVENTARIO: AGREGAR COSTOS Y POBLAR DATOS

-- 1) Agregar columnas (idempotente)
ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS unit_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (unit_cost >= 0);

ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS total_cost DECIMAL(12,2) DEFAULT 0.00 CHECK (total_cost >= 0);

ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS last_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (last_cost >= 0);

ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS cost_updated_at TIMESTAMPTZ DEFAULT NOW();

COMMENT ON COLUMN public.inventory.unit_cost IS 'Costo unitario promedio del inventario';
COMMENT ON COLUMN public.inventory.total_cost IS 'Costo total del inventario (quantity * unit_cost)';
COMMENT ON COLUMN public.inventory.last_cost IS 'Último costo de compra registrado (received)';
COMMENT ON COLUMN public.inventory.cost_updated_at IS 'Fecha de última actualización de costos';

-- 2) Calcular costos desde compras recibidas por ubicación
WITH costs_from_received AS (
  SELECT 
    i.id AS inventory_id,
    AVG(pi.unit_cost) FILTER (WHERE p.status = 'received') AS avg_unit_cost,
    MAX(pi.unit_cost) FILTER (WHERE p.status = 'received') AS last_unit_cost
  FROM public.inventory i
  LEFT JOIN public.purchase_items pi ON pi.product_variant_id = i.product_variant_id
  LEFT JOIN public.purchases p ON p.id = pi.purchase_id
      AND p.location_id = i.location_id
      AND p.location_type = i.location_type
  GROUP BY i.id
)
UPDATE public.inventory AS inv
SET unit_cost = COALESCE(c.avg_unit_cost, inv.unit_cost),
    last_cost = COALESCE(c.last_unit_cost, inv.last_cost),
    total_cost = COALESCE(c.avg_unit_cost, inv.unit_cost) * inv.quantity,
    cost_updated_at = NOW()
FROM costs_from_received c
WHERE inv.id = c.inventory_id
  AND (c.avg_unit_cost IS NOT NULL OR c.last_unit_cost IS NOT NULL);

-- 3) Fallback con products.base_price_buy donde aún no hay costo
WITH product_buy AS (
  SELECT i.id AS inventory_id, p.base_price_buy
  FROM public.inventory i
  JOIN public.product_variants pv ON pv.id = i.product_variant_id
  JOIN public.products p ON p.id = pv.product_id
)
UPDATE public.inventory AS inv
SET unit_cost = COALESCE(inv.unit_cost, 0.00)::numeric(10,2) + 
                CASE WHEN inv.unit_cost = 0 THEN COALESCE(pb.base_price_buy, 0.00) ELSE 0 END,
    last_cost = CASE WHEN inv.last_cost = 0 THEN COALESCE(pb.base_price_buy, inv.last_cost) ELSE inv.last_cost END,
    total_cost = (CASE WHEN inv.unit_cost = 0 THEN COALESCE(pb.base_price_buy, 0.00) ELSE inv.unit_cost END) * inv.quantity,
    cost_updated_at = NOW()
FROM product_buy pb
WHERE inv.id = pb.inventory_id
  AND (inv.unit_cost = 0 OR inv.last_cost = 0 OR inv.total_cost = 0);

-- 4) Asegurar consistencia total_cost = quantity * unit_cost
UPDATE public.inventory
SET total_cost = quantity * unit_cost,
    cost_updated_at = NOW()
WHERE total_cost IS DISTINCT FROM (quantity * unit_cost)::numeric(12,2);

-- 5) Reporte final
SELECT 'summary' AS section,
       COUNT(*) AS rows,
        SUM(quantity) AS total_units,
        AVG(unit_cost) AS avg_unit_cost,
        SUM(total_cost) AS total_cost_value
FROM public.inventory;

SELECT 'sample' AS section,
       pv.sku,
       pv.variant_name,
       COALESCE(st.name, w.name) AS location_name,
       i.location_type,
       i.quantity,
       i.unit_cost,
       i.last_cost,
       i.total_cost,
       i.cost_updated_at
FROM public.inventory i
JOIN public.product_variants pv ON pv.id = i.product_variant_id
LEFT JOIN public.stores st ON st.id = i.location_id AND i.location_type = 'store'
LEFT JOIN public.warehouses w ON w.id = i.location_id AND i.location_type = 'warehouse'
ORDER BY i.cost_updated_at DESC
LIMIT 25;

-- ✅ MIGRACIÓN COMPLETADA: COSTOS AGREGADOS Y POBLADOS


