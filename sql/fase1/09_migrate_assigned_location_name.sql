-- ============================================================================
-- 09_migrate_assigned_location_name.sql
-- Migración: Agregar campo assigned_location_name a instalaciones existentes
-- ============================================================================
-- Este script se ejecuta SOLO en instalaciones existentes que ya tienen
-- la tabla users sin el campo assigned_location_name
-- ============================================================================

-- ============================================================================
-- PASO 1: Verificar si el campo ya existe
-- ============================================================================
DO $$
BEGIN
    -- Verificar si la columna assigned_location_name ya existe
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'assigned_location_name'
    ) THEN
        -- Agregar la columna si no existe
        ALTER TABLE public.users 
        ADD COLUMN assigned_location_name TEXT;
        
        RAISE NOTICE '✅ Columna assigned_location_name agregada a la tabla users';
    ELSE
        RAISE NOTICE 'ℹ️  La columna assigned_location_name ya existe';
    END IF;
END $$;

-- ============================================================================
-- PASO 2: Agregar comentario a la columna
-- ============================================================================
COMMENT ON COLUMN public.users.assigned_location_name IS 'Nombre de la ubicación asignada (tienda o almacén)';

-- ============================================================================
-- PASO 3: Actualizar usuarios existentes con nombres de ubicación
-- ============================================================================

-- Actualizar usuarios con tiendas asignadas
UPDATE public.users 
SET assigned_location_name = s.name
FROM public.stores s
WHERE users.assigned_location_id = s.id 
AND users.assigned_location_type = 'store'
AND users.assigned_location_name IS NULL;

-- Actualizar usuarios con almacenes asignados
UPDATE public.users 
SET assigned_location_name = w.name
FROM public.warehouses w
WHERE users.assigned_location_id = w.id 
AND users.assigned_location_type = 'warehouse'
AND users.assigned_location_name IS NULL;

-- ============================================================================
-- PASO 4: Crear función para actualizar assigned_location_name
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_user_assigned_location_name()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se actualiza assigned_location_id o assigned_location_type
    IF (TG_OP = 'UPDATE' AND (
        OLD.assigned_location_id IS DISTINCT FROM NEW.assigned_location_id OR
        OLD.assigned_location_type IS DISTINCT FROM NEW.assigned_location_type
    )) THEN
        -- Actualizar con el nombre de la nueva ubicación
        IF NEW.assigned_location_type = 'store' THEN
            SELECT name INTO NEW.assigned_location_name
            FROM public.stores
            WHERE id = NEW.assigned_location_id;
        ELSIF NEW.assigned_location_type = 'warehouse' THEN
            SELECT name INTO NEW.assigned_location_name
            FROM public.warehouses
            WHERE id = NEW.assigned_location_id;
        ELSE
            NEW.assigned_location_name = NULL;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.update_user_assigned_location_name() IS 'Actualiza automáticamente assigned_location_name cuando cambia la ubicación asignada';

-- ============================================================================
-- PASO 5: Crear trigger para mantener el campo actualizado
-- ============================================================================
DROP TRIGGER IF EXISTS update_user_assigned_location_name ON public.users;
CREATE TRIGGER update_user_assigned_location_name
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_assigned_location_name();

COMMENT ON TRIGGER update_user_assigned_location_name ON public.users IS 'Actualiza assigned_location_name automáticamente cuando cambia la ubicación asignada';

-- ============================================================================
-- PASO 6: Verificar migración
-- ============================================================================
SELECT 
    '✅ Migración completada' as status,
    COUNT(*) as total_usuarios,
    COUNT(assigned_location_name) as usuarios_con_ubicacion_nombre,
    COUNT(*) - COUNT(assigned_location_name) as usuarios_sin_ubicacion_nombre
FROM public.users;

-- Mostrar usuarios con ubicación asignada
SELECT 
    '🔍 Usuarios con ubicación asignada' as check_type,
    u.email,
    u.name,
    u.role,
    u.assigned_location_type,
    u.assigned_location_name,
    CASE 
        WHEN u.assigned_location_type = 'store' THEN s.name
        WHEN u.assigned_location_type = 'warehouse' THEN w.name
        ELSE NULL
    END as actual_location_name,
    CASE 
        WHEN u.assigned_location_name IS NOT NULL THEN '✅ OK'
        ELSE '❌ FALTA'
    END as status
FROM public.users u
LEFT JOIN public.stores s ON s.id = u.assigned_location_id AND u.assigned_location_type = 'store'
LEFT JOIN public.warehouses w ON w.id = u.assigned_location_id AND u.assigned_location_type = 'warehouse'
WHERE u.assigned_location_id IS NOT NULL
ORDER BY u.email;

-- ============================================================================
-- INSTRUCCIONES FINALES
-- ============================================================================
-- 1. Este script es seguro de ejecutar múltiples veces
-- 2. Solo agrega la columna si no existe
-- 3. Actualiza usuarios existentes con nombres de ubicación
-- 4. Crea el trigger para mantener el campo actualizado automáticamente
-- 5. Después de ejecutar, reinicia la aplicación para que cargue los cambios
-- ============================================================================


