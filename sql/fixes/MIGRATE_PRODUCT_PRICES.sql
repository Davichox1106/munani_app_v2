-- ============================================================================
-- MIGRATE_PRODUCT_PRICES.sql
-- Migración completa de columnas de precio en productos
-- ============================================================================
-- Este script migra las columnas de precio existentes y actualiza los datos
-- ============================================================================

-- ============================================================================
-- PASO 1: Verificar estado actual de las tablas
-- ============================================================================

-- Verificar si existen las columnas actuales
SELECT 
    'Estado actual de product_variants:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'product_variants' 
AND column_name IN ('price', 'price_sell', 'price_buy')
ORDER BY column_name;

SELECT 
    'Estado actual de products:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'products' 
AND column_name IN ('base_price', 'base_price_sell', 'base_price_buy')
ORDER BY column_name;

-- ============================================================================
-- PASO 2: Deshabilitar triggers de auditoría temporalmente
-- ============================================================================

-- Deshabilitar triggers de auditoría para evitar errores durante la migración
ALTER TABLE public.products DISABLE TRIGGER trg_audit_products;
ALTER TABLE public.product_variants DISABLE TRIGGER trg_audit_product_variants;

-- ============================================================================
-- PASO 3: Migrar tabla product_variants
-- ============================================================================

-- Verificar si existe columna 'price' y migrar
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'product_variants' 
        AND column_name = 'price'
    ) THEN
        -- Renombrar 'price' a 'price_sell'
        ALTER TABLE public.product_variants 
        RENAME COLUMN price TO price_sell;
        
        RAISE NOTICE 'Columna price renombrada a price_sell en product_variants';
    END IF;
    
    -- Agregar columna 'price_buy' si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'product_variants' 
        AND column_name = 'price_buy'
    ) THEN
        ALTER TABLE public.product_variants 
        ADD COLUMN price_buy DECIMAL(10,2) NOT NULL DEFAULT 0.00;
        
        RAISE NOTICE 'Columna price_buy agregada a product_variants';
    END IF;
    
    -- Agregar constraint para price_buy
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_name = 'product_variants_price_buy_positive'
    ) THEN
        ALTER TABLE public.product_variants 
        ADD CONSTRAINT product_variants_price_buy_positive CHECK (price_buy >= 0);
        
        RAISE NOTICE 'Constraint agregado para price_buy en product_variants';
    END IF;
END $$;

-- ============================================================================
-- PASO 4: Migrar tabla products
-- ============================================================================

-- Verificar si existe columna 'base_price' y migrar
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'products' 
        AND column_name = 'base_price'
    ) THEN
        -- Renombrar 'base_price' a 'base_price_sell'
        ALTER TABLE public.products 
        RENAME COLUMN base_price TO base_price_sell;
        
        RAISE NOTICE 'Columna base_price renombrada a base_price_sell en products';
    END IF;
    
    -- Agregar columna 'base_price_buy' si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'products' 
        AND column_name = 'base_price_buy'
    ) THEN
        ALTER TABLE public.products 
        ADD COLUMN base_price_buy DECIMAL(10,2) NOT NULL DEFAULT 0.00;
        
        RAISE NOTICE 'Columna base_price_buy agregada a products';
    END IF;
    
    -- Agregar constraint para base_price_buy
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_name = 'products_base_price_buy_positive'
    ) THEN
        ALTER TABLE public.products 
        ADD CONSTRAINT products_base_price_buy_positive CHECK (base_price_buy >= 0);
        
        RAISE NOTICE 'Constraint agregado para base_price_buy en products';
    END IF;
END $$;

-- ============================================================================
-- PASO 5: Rehabilitar triggers de auditoría
-- ============================================================================

-- Rehabilitar triggers de auditoría
ALTER TABLE public.products ENABLE TRIGGER trg_audit_products;
ALTER TABLE public.product_variants ENABLE TRIGGER trg_audit_product_variants;

-- ============================================================================
-- PASO 6: Actualizar comentarios
-- ============================================================================

-- Comentarios para product_variants
COMMENT ON COLUMN public.product_variants.price_sell IS 'Precio de venta de la variante';
COMMENT ON COLUMN public.product_variants.price_buy IS 'Precio de compra de la variante';

-- Comentarios para products
COMMENT ON COLUMN public.products.base_price_sell IS 'Precio de venta base del producto';
COMMENT ON COLUMN public.products.base_price_buy IS 'Precio de compra base del producto';

-- ============================================================================
-- PASO 7: Actualizar datos existentes (opcional)
-- ============================================================================

-- Establecer price_buy = price_sell * 0.7 (30% de margen por defecto)
-- Solo si price_buy es 0 (valor por defecto)
UPDATE public.product_variants 
SET price_buy = ROUND(price_sell * 0.7, 2)
WHERE price_buy = 0.00 AND price_sell > 0;

UPDATE public.products 
SET base_price_buy = ROUND(base_price_sell * 0.7, 2)
WHERE base_price_buy = 0.00 AND base_price_sell > 0;

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================

-- Verificar estructura final de product_variants
SELECT 
    '✅ product_variants - Estructura final:' as status,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'product_variants' 
AND column_name IN ('price_sell', 'price_buy')
ORDER BY column_name;

-- Verificar estructura final de products
SELECT 
    '✅ products - Estructura final:' as status,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'products' 
AND column_name IN ('base_price_sell', 'base_price_buy')
ORDER BY column_name;

-- Mostrar algunos datos de ejemplo
SELECT 
    '📊 Ejemplo de datos en product_variants:' as info,
    sku,
    variant_name,
    price_sell,
    price_buy,
    ROUND((price_sell - price_buy) / price_sell * 100, 2) as margen_porcentaje
FROM public.product_variants 
LIMIT 5;

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================

-- Mostrar resumen final
SELECT 
    '🎉 Migración completada exitosamente!' as resultado,
    'price → price_sell (en product_variants)' as cambio_1,
    'base_price → base_price_sell (en products)' as cambio_2,
    'Agregada columna price_buy (en product_variants)' as cambio_3,
    'Agregada columna base_price_buy (en products)' as cambio_4,
    'Datos actualizados con margen del 30%' as cambio_5;
