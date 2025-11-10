-- ============================================================================
-- FIX: ADD_INVENTORY_IMAGE_URLS.sql
-- Agrega la columna image_urls a la tabla inventory
-- ============================================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'inventory'
          AND column_name = 'image_urls'
    ) THEN
        ALTER TABLE public.inventory
            ADD COLUMN image_urls TEXT[] DEFAULT ARRAY[]::TEXT[];

        COMMENT ON COLUMN public.inventory.image_urls IS 'Listado de imágenes asociadas al producto/variante';
    END IF;
END $$;








