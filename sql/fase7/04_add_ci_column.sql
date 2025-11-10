-- =====================================================
-- Migración: Agregar columna CI (Cédula de Identidad)
-- =====================================================
-- Agrega la columna CI a las tablas de empleados y administradores

-- Tabla administrators
-- Primero agregar la columna como nullable
ALTER TABLE public.administrators
ADD COLUMN IF NOT EXISTS ci TEXT UNIQUE;

COMMENT ON COLUMN public.administrators.ci IS 'Cédula de Identidad del administrador (único y obligatorio)';

-- Índice para búsquedas rápidas por CI
CREATE INDEX IF NOT EXISTS idx_administrators_ci ON public.administrators(ci);

-- IMPORTANTE: Si hay datos existentes, debes asignar valores de CI antes de ejecutar:
-- ALTER TABLE public.administrators ALTER COLUMN ci SET NOT NULL;

-- Tabla employees_store
ALTER TABLE public.employees_store
ADD COLUMN IF NOT EXISTS ci TEXT UNIQUE;

COMMENT ON COLUMN public.employees_store.ci IS 'Cédula de Identidad del empleado de tienda (único y obligatorio)';

CREATE INDEX IF NOT EXISTS idx_employees_store_ci ON public.employees_store(ci);

-- IMPORTANTE: Si hay datos existentes, debes asignar valores de CI antes de ejecutar:
-- ALTER TABLE public.employees_store ALTER COLUMN ci SET NOT NULL;

-- Tabla employees_warehouse
ALTER TABLE public.employees_warehouse
ADD COLUMN IF NOT EXISTS ci TEXT UNIQUE;

COMMENT ON COLUMN public.employees_warehouse.ci IS 'Cédula de Identidad del empleado de almacén (único y obligatorio)';

CREATE INDEX IF NOT EXISTS idx_employees_warehouse_ci ON public.employees_warehouse(ci);

-- IMPORTANTE: Si hay datos existentes, debes asignar valores de CI antes de ejecutar:
-- ALTER TABLE public.employees_warehouse ALTER COLUMN ci SET NOT NULL;

-- Mensaje de éxito
DO $$
BEGIN
    RAISE NOTICE '✅ Columna CI agregada exitosamente a todas las tablas de empleados';
END $$;
