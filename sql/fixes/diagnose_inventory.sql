-- =============================================================================
-- DIAGNÓSTICO: Tabla public.inventory
-- =============================================================================
-- Objetivo: inspeccionar estructura y datos actuales antes de migrar a costos
-- =============================================================================

-- DIAGNÓSTICO INVENTARIO: ESTRUCTURA Y DATOS

-- 1) Estructura actual
SELECT 'columns' AS section,
       column_name,
       data_type,
       is_nullable,
       column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'inventory'
ORDER BY ordinal_position;

-- 2) Conteo general y por ubicación
SELECT 'counts' AS section,
       COUNT(*) AS total_rows,
       SUM(quantity) AS total_units
FROM public.inventory;

SELECT 'by_location_type' AS section,
       location_type,
       COUNT(*) AS rows,
       SUM(quantity) AS units
FROM public.inventory
GROUP BY location_type
ORDER BY location_type;

-- 3) Top productos por cantidad
SELECT 'top_products' AS section,
       pv.sku,
       pv.variant_name,
       COALESCE(st.name, w.name) AS location_name,
       i.location_type,
       i.quantity,
       i.last_updated
FROM public.inventory i
JOIN public.product_variants pv ON pv.id = i.product_variant_id
LEFT JOIN public.stores st ON st.id = i.location_id AND i.location_type = 'store'
LEFT JOIN public.warehouses w ON w.id = i.location_id AND i.location_type = 'warehouse'
ORDER BY i.quantity DESC, i.last_updated DESC
LIMIT 25;

-- 4) Registros potencialmente problemáticos (cantidades negativas u otras anomalías)
SELECT 'anomalies' AS section,
       i.*
FROM public.inventory i
WHERE i.quantity < 0
OR i.product_variant_id IS NULL
OR i.location_id IS NULL;

-- 5) ¿Existen columnas de costo ya creadas?
SELECT 'has_cost_columns' AS section,
       EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema='public' AND table_name='inventory' AND column_name='unit_cost'
       ) AS has_unit_cost,
       EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema='public' AND table_name='inventory' AND column_name='total_cost'
       ) AS has_total_cost,
       EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema='public' AND table_name='inventory' AND column_name='last_cost'
       ) AS has_last_cost,
       EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema='public' AND table_name='inventory' AND column_name='cost_updated_at'
       ) AS has_cost_updated_at;

-- 6) Relación con productos (precio base de compra)
SELECT 'product_buy_price' AS section,
       pv.id AS product_variant_id,
       pv.sku,
       pv.variant_name,
       p.base_price_buy
FROM public.product_variants pv
JOIN public.products p ON p.id = pv.product_id
ORDER BY p.base_price_buy DESC NULLS LAST, pv.sku
LIMIT 25;

-- 7) Relación con compras recibidas (costo real por ubicación)
SELECT 'received_purchases_costs' AS section,
       i.product_variant_id,
       COALESCE(st.name, w.name) AS location_name,
       i.location_type,
       COUNT(*) FILTER (WHERE p.status='received') AS received_purchase_items,
       AVG(pi.unit_cost) FILTER (WHERE p.status='received') AS avg_unit_cost,
       MAX(pi.unit_cost) FILTER (WHERE p.status='received') AS last_unit_cost
FROM public.inventory i
LEFT JOIN public.purchase_items pi ON pi.product_variant_id = i.product_variant_id
LEFT JOIN public.purchases p ON p.id = pi.purchase_id AND p.location_id = i.location_id AND p.location_type = i.location_type
LEFT JOIN public.stores st ON st.id = i.location_id AND i.location_type = 'store'
LEFT JOIN public.warehouses w ON w.id = i.location_id AND i.location_type = 'warehouse'
GROUP BY i.product_variant_id, i.location_type, COALESCE(st.name, w.name)
ORDER BY avg_unit_cost DESC NULLS LAST
LIMIT 50;

-- ✅ DIAGNÓSTICO COMPLETADO


