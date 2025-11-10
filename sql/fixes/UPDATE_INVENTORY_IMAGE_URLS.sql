-- ============================================================================
-- FIX: UPDATE_INVENTORY_IMAGE_URLS.sql
-- Copia las imágenes de productos/variantes a los ítems de inventario que las
-- tengan vacías.
-- ============================================================================

WITH inventory_with_images AS (
    SELECT
        i.id,
        COALESCE(p.image_urls, ARRAY[]::TEXT[]) AS product_images
    FROM public.inventory i
    JOIN public.product_variants pv ON pv.id = i.product_variant_id
    JOIN public.products p ON p.id = pv.product_id
    WHERE (i.image_urls IS NULL OR array_length(i.image_urls, 1) = 0)
      AND p.image_urls IS NOT NULL
      AND array_length(p.image_urls, 1) > 0
)
UPDATE public.inventory inv
SET image_urls = invw.product_images
FROM inventory_with_images invw
WHERE inv.id = invw.id;








