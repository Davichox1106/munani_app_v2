-- ============================================================================
-- Script para agregar campo location_name a tabla inventory
-- ============================================================================
-- PROBLEMA: La tabla inventory no tiene el campo location_name, por eso
-- siempre aparece vacío o null en la app.
-- ============================================================================

-- 1. Agregar columna location_name a la tabla inventory
ALTER TABLE public.inventory
ADD COLUMN IF NOT EXISTS location_name TEXT;

-- 2. Actualizar los datos existentes con los nombres reales de las ubicaciones
-- Primero actualizar desde stores
UPDATE public.inventory inv
SET location_name = s.name
FROM public.stores s
WHERE inv.location_type = 'store'
  AND inv.location_id = s.id
  AND inv.location_name IS NULL;

-- Luego actualizar desde warehouses
UPDATE public.inventory inv
SET location_name = w.name
FROM public.warehouses w
WHERE inv.location_type = 'warehouse'
  AND inv.location_id = w.id
  AND inv.location_name IS NULL;

-- 3. Verificar que se hayan actualizado correctamente
SELECT
    location_type,
    location_name,
    COUNT(*) as total
FROM public.inventory
GROUP BY location_type, location_name
ORDER BY location_type, location_name;

-- ============================================================================
-- NOTAS:
-- - Este script es idempotente (se puede ejecutar múltiples veces)
-- - El campo location_name es opcional para mantener compatibilidad
-- - Los nuevos registros deberán incluir location_name al insertarse
-- ============================================================================
