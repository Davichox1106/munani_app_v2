-- ==========================================================================
-- FIX: Agregar columna assigned_location_name a public.customers
-- ==========================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'customers'
      AND column_name = 'assigned_location_name'
  ) THEN
    ALTER TABLE public.customers
      ADD COLUMN assigned_location_name TEXT;
  END IF;
END $$;

COMMENT ON COLUMN public.customers.assigned_location_name IS 'Nombre legible de la ubicación asignada (tienda o almacén)';
-- ==========================================================================








