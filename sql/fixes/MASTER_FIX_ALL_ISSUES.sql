-- ============================================================================
-- MASTER FIX: Resolver todos los problemas del sistema
-- ============================================================================
-- Este script resuelve TODOS los problemas identificados:
-- 1. Campo assigned_location_name en usuarios
-- 2. Error de duplicados en compras
-- 3. Error de unit_cost en trigger de inventario
-- 4. Campos de costo en inventario
-- 5. Aplicar compras recibidas existentes al inventario
-- ============================================================================

\echo '============================================================================'
\echo 'INICIANDO CORRECCIÓN MAESTRA DEL SISTEMA'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Agregar campo assigned_location_name a usuarios
-- ============================================================================
\echo ''
\echo '📋 Paso 1/8: Agregando campo assigned_location_name a usuarios...'

-- Agregar columna si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'assigned_location_name'
    ) THEN
        ALTER TABLE public.users 
        ADD COLUMN assigned_location_name TEXT;
        
        RAISE NOTICE '✅ Columna assigned_location_name agregada';
    ELSE
        RAISE NOTICE 'ℹ️  Columna assigned_location_name ya existe';
    END IF;
END $$;

-- Actualizar usuarios existentes con nombres de ubicación
UPDATE public.users 
SET assigned_location_name = s.name
FROM public.stores s
WHERE users.assigned_location_id = s.id 
AND users.assigned_location_type = 'store'
AND users.assigned_location_name IS NULL;

UPDATE public.users 
SET assigned_location_name = w.name
FROM public.warehouses w
WHERE users.assigned_location_id = w.id 
AND users.assigned_location_type = 'warehouse'
AND users.assigned_location_name IS NULL;

-- Crear función para mantener assigned_location_name actualizado
CREATE OR REPLACE FUNCTION public.update_user_assigned_location_name()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND (
        OLD.assigned_location_id IS DISTINCT FROM NEW.assigned_location_id OR
        OLD.assigned_location_type IS DISTINCT FROM NEW.assigned_location_type
    )) THEN
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

-- Crear trigger
DROP TRIGGER IF EXISTS update_user_assigned_location_name ON public.users;
CREATE TRIGGER update_user_assigned_location_name
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_assigned_location_name();

-- ============================================================================
-- PASO 2: Agregar campos de costo al inventario
-- ============================================================================
\echo ''
\echo '📋 Paso 2/8: Agregando campos de costo al inventario...'

-- Agregar columnas de costo
ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS unit_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (unit_cost >= 0);

ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS total_cost DECIMAL(12,2) DEFAULT 0.00 CHECK (total_cost >= 0);

ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS last_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (last_cost >= 0);

ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS cost_updated_at TIMESTAMPTZ DEFAULT NOW();

-- Agregar comentarios
COMMENT ON COLUMN public.inventory.unit_cost IS 'Costo unitario promedio del inventario';
COMMENT ON COLUMN public.inventory.total_cost IS 'Costo total del inventario (quantity * unit_cost)';
COMMENT ON COLUMN public.inventory.last_cost IS 'Último costo de compra registrado';
COMMENT ON COLUMN public.inventory.cost_updated_at IS 'Fecha de última actualización de costos';

-- ============================================================================
-- PASO 3: Crear función para actualizar costos automáticamente
-- ============================================================================
\echo ''
\echo '📋 Paso 3/8: Creando función para actualizar costos automáticamente...'

CREATE OR REPLACE FUNCTION public.update_inventory_costs()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.quantity IS DISTINCT FROM NEW.quantity OR OLD.unit_cost IS DISTINCT FROM NEW.unit_cost THEN
        NEW.total_cost = NEW.quantity * NEW.unit_cost;
        NEW.cost_updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para actualizar costos
DROP TRIGGER IF EXISTS update_inventory_costs ON public.inventory;
CREATE TRIGGER update_inventory_costs
    BEFORE UPDATE ON public.inventory
    FOR EACH ROW
    EXECUTE FUNCTION public.update_inventory_costs();

-- ============================================================================
-- PASO 4: Corregir trigger de compras para incluir costos
-- ============================================================================
\echo ''
\echo '📋 Paso 4/8: Corrigiendo trigger de compras para incluir costos...'

CREATE OR REPLACE FUNCTION public.apply_purchase_to_inventory()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
    existing_inventory_id UUID;
    new_quantity INTEGER;
    new_unit_cost DECIMAL(10,2);
    new_total_cost DECIMAL(12,2);
BEGIN
    IF NEW.status = 'received' AND OLD.status != 'received' THEN
        NEW.received_by := auth.uid();
        NEW.received_at := NOW();

        FOR item IN
            SELECT product_variant_id, quantity, unit_cost
            FROM public.purchase_items
            WHERE purchase_id = NEW.id
        LOOP
            SELECT id INTO existing_inventory_id
            FROM public.inventory
            WHERE product_variant_id = item.product_variant_id
              AND location_id = NEW.location_id
              AND location_type = NEW.location_type;
            
            IF existing_inventory_id IS NOT NULL THEN
                -- Calcular costo promedio ponderado
                SELECT 
                    (old_quantity * old_unit_cost + item.quantity * item.unit_cost) / (old_quantity + item.quantity),
                    old_quantity + item.quantity
                INTO new_unit_cost, new_quantity
                FROM (
                    SELECT quantity as old_quantity, unit_cost as old_unit_cost
                    FROM public.inventory
                    WHERE id = existing_inventory_id
                ) old_inventory;
                
                new_total_cost := new_quantity * new_unit_cost;
                
                UPDATE public.inventory
                SET
                    quantity = new_quantity,
                    unit_cost = new_unit_cost,
                    total_cost = new_total_cost,
                    last_cost = item.unit_cost,
                    last_updated = NOW(),
                    cost_updated_at = NOW(),
                    updated_by = auth.uid()
                WHERE id = existing_inventory_id;
            ELSE
                new_quantity := item.quantity;
                new_unit_cost := item.unit_cost;
                new_total_cost := new_quantity * new_unit_cost;
                
                INSERT INTO public.inventory (
                    product_variant_id,
                    location_id,
                    location_type,
                    quantity,
                    unit_cost,
                    total_cost,
                    last_cost,
                    min_stock,
                    max_stock,
                    last_updated,
                    cost_updated_at,
                    updated_by
                ) VALUES (
                    item.product_variant_id,
                    NEW.location_id,
                    NEW.location_type,
                    new_quantity,
                    new_unit_cost,
                    new_total_cost,
                    item.unit_cost,
                    5,
                    1000,
                    NOW(),
                    NOW(),
                    auth.uid()
                );
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recrear trigger
DROP TRIGGER IF EXISTS apply_purchase_to_inventory ON public.purchases;
CREATE TRIGGER apply_purchase_to_inventory
    AFTER UPDATE ON public.purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.apply_purchase_to_inventory();

-- ============================================================================
-- PASO 5: Aplicar compras recibidas existentes al inventario
-- ============================================================================
\echo ''
\echo '📋 Paso 5/8: Aplicando compras recibidas existentes al inventario...'

DO $$
DECLARE
    purchase_record RECORD;
    item_record RECORD;
    existing_inventory_id UUID;
    new_quantity INTEGER;
    new_unit_cost DECIMAL(10,2);
    new_total_cost DECIMAL(12,2);
    processed_count INTEGER := 0;
BEGIN
    FOR purchase_record IN
        SELECT id, location_id, location_type, purchase_number
        FROM public.purchases
        WHERE status = 'received'
        ORDER BY received_at ASC
    LOOP
        processed_count := processed_count + 1;
        RAISE NOTICE 'Procesando compra %: %', processed_count, purchase_record.purchase_number;
        
        FOR item_record IN
            SELECT product_variant_id, quantity, unit_cost
            FROM public.purchase_items
            WHERE purchase_id = purchase_record.id
        LOOP
            SELECT id INTO existing_inventory_id
            FROM public.inventory
            WHERE product_variant_id = item_record.product_variant_id
              AND location_id = purchase_record.location_id
              AND location_type = purchase_record.location_type;
            
            IF existing_inventory_id IS NOT NULL THEN
                -- Calcular costo promedio ponderado
                SELECT 
                    (old_quantity * old_unit_cost + item_record.quantity * item_record.unit_cost) / (old_quantity + item_record.quantity),
                    old_quantity + item_record.quantity
                INTO new_unit_cost, new_quantity
                FROM (
                    SELECT quantity as old_quantity, unit_cost as old_unit_cost
                    FROM public.inventory
                    WHERE id = existing_inventory_id
                ) old_inventory;
                
                new_total_cost := new_quantity * new_unit_cost;
                
                UPDATE public.inventory
                SET
                    quantity = new_quantity,
                    unit_cost = new_unit_cost,
                    total_cost = new_total_cost,
                    last_cost = item_record.unit_cost,
                    last_updated = NOW(),
                    cost_updated_at = NOW(),
                    updated_by = (SELECT id FROM public.users WHERE email = 'davidhuguexr11@gmail.com' LIMIT 1)
                WHERE id = existing_inventory_id;
            ELSE
                new_quantity := item_record.quantity;
                new_unit_cost := item_record.unit_cost;
                new_total_cost := new_quantity * new_unit_cost;
                
                INSERT INTO public.inventory (
                    product_variant_id,
                    location_id,
                    location_type,
                    quantity,
                    unit_cost,
                    total_cost,
                    last_cost,
                    min_stock,
                    max_stock,
                    last_updated,
                    cost_updated_at,
                    updated_by
                ) VALUES (
                    item_record.product_variant_id,
                    purchase_record.location_id,
                    purchase_record.location_type,
                    new_quantity,
                    new_unit_cost,
                    new_total_cost,
                    item_record.unit_cost,
                    5,
                    1000,
                    NOW(),
                    NOW(),
                    (SELECT id FROM public.users WHERE email = 'davidhuguexr11@gmail.com' LIMIT 1)
                );
            END IF;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE '✅ Procesadas % compras recibidas', processed_count;
END $$;

-- ============================================================================
-- PASO 6: Crear función para inventario manual con costos
-- ============================================================================
\echo ''
\echo '📋 Paso 6/8: Creando función para inventario manual con costos...'

CREATE OR REPLACE FUNCTION public.create_manual_inventory(
    p_product_variant_id UUID,
    p_location_id UUID,
    p_location_type TEXT,
    p_quantity INTEGER,
    p_unit_cost DECIMAL(10,2),
    p_reason TEXT DEFAULT 'Inventario manual'
)
RETURNS UUID AS $$
DECLARE
    inventory_id UUID;
    total_cost DECIMAL(12,2);
    new_quantity INTEGER;
    new_unit_cost DECIMAL(10,2);
    new_total_cost DECIMAL(12,2);
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a 0';
    END IF;
    
    IF p_unit_cost < 0 THEN
        RAISE EXCEPTION 'El costo unitario no puede ser negativo';
    END IF;
    
    IF p_location_type NOT IN ('store', 'warehouse') THEN
        RAISE EXCEPTION 'El tipo de ubicación debe ser store o warehouse';
    END IF;
    
    SELECT id INTO inventory_id
    FROM public.inventory
    WHERE product_variant_id = p_product_variant_id
      AND location_id = p_location_id
      AND location_type = p_location_type;
    
    IF inventory_id IS NOT NULL THEN
        -- Calcular costo promedio ponderado
        SELECT 
            (old_quantity * old_unit_cost + p_quantity * p_unit_cost) / (old_quantity + p_quantity),
            old_quantity + p_quantity
        INTO new_unit_cost, new_quantity
        FROM (
            SELECT quantity as old_quantity, unit_cost as old_unit_cost
            FROM public.inventory
            WHERE id = inventory_id
        ) old_inventory;
        
        new_total_cost := new_quantity * new_unit_cost;
        
        UPDATE public.inventory
        SET
            quantity = new_quantity,
            unit_cost = new_unit_cost,
            total_cost = new_total_cost,
            last_cost = p_unit_cost,
            last_updated = NOW(),
            cost_updated_at = NOW(),
            updated_by = auth.uid()
        WHERE id = inventory_id;
        
        RETURN inventory_id;
    ELSE
        inventory_id := gen_random_uuid();
        total_cost := p_quantity * p_unit_cost;
        
        INSERT INTO public.inventory (
            id,
            product_variant_id,
            location_id,
            location_type,
            quantity,
            unit_cost,
            total_cost,
            last_cost,
            min_stock,
            max_stock,
            last_updated,
            cost_updated_at,
            updated_by
        ) VALUES (
            inventory_id,
            p_product_variant_id,
            p_location_id,
            p_location_type,
            p_quantity,
            p_unit_cost,
            total_cost,
            p_unit_cost,
            5,
            1000,
            NOW(),
            NOW(),
            auth.uid()
        );
        
        RETURN inventory_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PASO 7: Crear función para consultar inventario con costos
-- ============================================================================
\echo ''
\echo '📋 Paso 7/8: Creando función para consultar inventario con costos...'

CREATE OR REPLACE FUNCTION public.get_inventory_with_costs(
    p_location_id UUID DEFAULT NULL,
    p_location_type TEXT DEFAULT NULL
)
RETURNS TABLE (
    inventory_id UUID,
    sku TEXT,
    variant_name TEXT,
    product_name TEXT,
    quantity INTEGER,
    unit_cost DECIMAL(10,2),
    total_cost DECIMAL(12,2),
    last_cost DECIMAL(10,2),
    location_name TEXT,
    location_type TEXT,
    cost_updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        pv.sku,
        pv.variant_name,
        p.name,
        i.quantity,
        i.unit_cost,
        i.total_cost,
        i.last_cost,
        COALESCE(st.name, w.name),
        i.location_type,
        i.cost_updated_at
    FROM public.inventory i
    JOIN public.product_variants pv ON pv.id = i.product_variant_id
    JOIN public.products p ON p.id = pv.product_id
    LEFT JOIN public.stores st ON st.id = i.location_id AND i.location_type = 'store'
    LEFT JOIN public.warehouses w ON w.id = i.location_id AND i.location_type = 'warehouse'
    WHERE (p_location_id IS NULL OR i.location_id = p_location_id)
      AND (p_location_type IS NULL OR i.location_type = p_location_type)
    ORDER BY i.cost_updated_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PASO 8: Verificación final
-- ============================================================================
\echo ''
\echo '📋 Paso 8/8: Verificación final...'

-- Verificar usuarios con assigned_location_name
SELECT 
    '✅ Usuarios con ubicación' as check_type,
    COUNT(*) as total_usuarios,
    COUNT(assigned_location_name) as con_nombre_ubicacion
FROM public.users
WHERE assigned_location_id IS NOT NULL;

-- Verificar inventario con costos
SELECT 
    '✅ Inventario con costos' as check_type,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN unit_cost > 0 THEN 1 END) as con_costo,
    SUM(quantity) as cantidad_total,
    SUM(total_cost) as costo_total
FROM public.inventory;

-- Mostrar inventario actual
SELECT 
    '📦 Inventario actual' as check_type,
    pv.sku,
    pv.variant_name,
    i.quantity,
    i.unit_cost,
    i.total_cost,
    COALESCE(st.name, w.name) as ubicacion,
    i.cost_updated_at
FROM public.inventory i
JOIN public.product_variants pv ON pv.id = i.product_variant_id
LEFT JOIN public.stores st ON st.id = i.location_id AND i.location_type = 'store'
LEFT JOIN public.warehouses w ON w.id = i.location_id AND i.location_type = 'warehouse'
ORDER BY i.cost_updated_at DESC
LIMIT 5;

-- ============================================================================
-- RESUMEN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ CORRECCIÓN MAESTRA COMPLETADA'
\echo '============================================================================'
\echo ''
\echo '📊 Problemas resueltos:'
\echo '  ✅ Campo assigned_location_name agregado a usuarios'
\echo '  ✅ Campos de costo agregados al inventario'
\echo '  ✅ Trigger de compras corregido'
\echo '  ✅ Compras recibidas aplicadas al inventario'
\echo '  ✅ Función para inventario manual con costos'
\echo '  ✅ Función para consultar inventario con costos'
\echo ''
\echo '📝 Funciones disponibles:'
\echo '  - create_manual_inventory() - Crear inventario manual con costos'
\echo '  - get_inventory_with_costs() - Consultar inventario con costos'
\echo ''
\echo '🎯 Próximos pasos:'
\echo '  1. Reiniciar la aplicación Flutter'
\echo '  2. Probar funcionalidad "Recibir compra"'
\echo '  3. Verificar que se muestre "Los Marmol" en lugar de "Tienda"'
\echo '  4. El inventario ahora incluye costos automáticamente'
\echo '============================================================================'


