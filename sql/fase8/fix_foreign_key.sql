-- CORRECCIÓN: Agregar clave foránea faltante en sale_items
-- Este script corrige el error: "Could not find a relationship between 'sale_items' and 'product_variants'"

-- Agregar la clave foránea a product_variants si no existe
DO $$
BEGIN
    -- Verificar si la constraint ya existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'sale_items_product_variant_id_fkey'
        AND table_name = 'sale_items'
    ) THEN
        -- Agregar la clave foránea
        ALTER TABLE public.sale_items
        ADD CONSTRAINT sale_items_product_variant_id_fkey
        FOREIGN KEY (product_variant_id)
        REFERENCES public.product_variants(id);

        RAISE NOTICE 'Clave foránea agregada exitosamente';
    ELSE
        RAISE NOTICE 'La clave foránea ya existe';
    END IF;
END $$;

-- Crear índice para mejorar el rendimiento de los JOINs
CREATE INDEX IF NOT EXISTS idx_sale_items_product_variant
ON public.sale_items(product_variant_id);

-- Verificar que la relación se creó correctamente
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'sale_items'
    AND kcu.column_name = 'product_variant_id';
