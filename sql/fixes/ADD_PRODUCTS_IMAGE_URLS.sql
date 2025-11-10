-- ==========================================================================
-- FIX: Agregar columna image_urls a public.products
-- ==========================================================================
-- Objetivo: almacenar la lista de imágenes (urls o rutas locales) para cada
--           producto y mantener compatibilidad con sincronización Offline-First.
-- 
-- Pasos:
--   1. Deshabilitar triggers de auditoría durante la migración
--   2. Crear columna si no existe, con default array vacío
--   3. Asegurar que filas existentes no queden con NULL
--   4. Agregar comentario descriptivo
--   5. Rehabilitar triggers
-- ==========================================================================

DO $$
DECLARE
  _has_column BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'products'
      AND column_name = 'image_urls'
  ) INTO _has_column;

  -- 1) Deshabilitar trigger de auditoría si existe
  IF EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'trg_audit_products'
      AND tgrelid = 'public.products'::regclass
  ) THEN
    ALTER TABLE public.products DISABLE TRIGGER trg_audit_products;
  END IF;

  -- 2) Crear columna solo si no existe
  IF NOT _has_column THEN
    ALTER TABLE public.products
      ADD COLUMN image_urls TEXT[] DEFAULT ARRAY[]::TEXT[];
  END IF;

  -- 3) Asegurar default y datos existentes
  ALTER TABLE public.products
    ALTER COLUMN image_urls SET DEFAULT ARRAY[]::TEXT[];

  UPDATE public.products
  SET image_urls = ARRAY[]::TEXT[]
  WHERE image_urls IS NULL;

  -- 4) Comentario descriptivo
  COMMENT ON COLUMN public.products.image_urls IS 'Listado de imágenes asociadas (URLs o rutas)';

  -- 5) Rehabilitar trigger si estaba presente
  IF EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'trg_audit_products'
      AND tgrelid = 'public.products'::regclass
  ) THEN
    ALTER TABLE public.products ENABLE TRIGGER trg_audit_products;
  END IF;
END $$;

-- ==========================================================================
-- FIN DEL SCRIPT
-- ==========================================================================















