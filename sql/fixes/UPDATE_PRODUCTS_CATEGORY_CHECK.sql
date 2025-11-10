-- ==========================================================================
-- FIX: Actualizar constraint de categorías para productos
-- ==========================================================================
-- Objetivo: Cambiar las categorías permitidas a la nueva temática de
--           barritas nutritivas, manteniendo el control de integridad.
-- ==========================================================================

DO $$
BEGIN
  -- Eliminar constraint previa si existe
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_schema = 'public'
      AND table_name = 'products'
      AND constraint_name = 'products_category_check'
  ) THEN
    ALTER TABLE public.products
      DROP CONSTRAINT products_category_check;
  END IF;

  -- Crear constraint con la nueva lista de categorías
  ALTER TABLE public.products
    ADD CONSTRAINT products_category_check
    CHECK (category IN (
      'barritas_nutritivas',
      'barritas_proteicas',
      'barritas_dieteticas',
      'otros'
    ));
END $$;

-- ==========================================================================
-- FIN DEL SCRIPT
-- ==========================================================================









