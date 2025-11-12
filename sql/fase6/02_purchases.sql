-- ============================================================================
-- FASE 6: MÓDULO DE COMPRAS (PURCHASES)
-- ============================================================================
-- Tablas para almacenar compras a proveedores
-- Lógica: Compra → Aumenta inventario en ubicación destino
-- ============================================================================

-- ============================================================================
-- TABLA: purchases (Encabezado de compra)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relaciones
    supplier_id UUID NOT NULL REFERENCES public.suppliers(id),
    location_id UUID NOT NULL, -- Store o Warehouse donde llega la compra
    location_type TEXT NOT NULL CHECK (location_type IN ('store', 'warehouse')),

    -- Información de la compra
    purchase_number TEXT UNIQUE, -- Número de compra autogenerado
    invoice_number TEXT, -- Número de factura del proveedor
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Totales
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    tax NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total NUMERIC(12,2) NOT NULL DEFAULT 0.00,

    -- Estado
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'received', 'cancelled')),

    -- Observaciones
    notes TEXT,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES public.users(id),
    received_by UUID REFERENCES public.users(id),
    received_at TIMESTAMPTZ,

    -- Sincronización offline
    needs_sync BOOLEAN NOT NULL DEFAULT false,
    last_synced_at TIMESTAMPTZ
);

-- Comentarios
COMMENT ON TABLE public.purchases IS 'Encabezado de compras a proveedores';
COMMENT ON COLUMN public.purchases.purchase_number IS 'Número de compra autogenerado (ej: PUR-2024-0001)';
COMMENT ON COLUMN public.purchases.invoice_number IS 'Número de factura del proveedor';
COMMENT ON COLUMN public.purchases.location_id IS 'UUID de store o warehouse donde llega la compra';
COMMENT ON COLUMN public.purchases.status IS 'Estado: pending (creada), received (recibida y aplicada a inventario), cancelled (cancelada)';

-- ============================================================================
-- TABLA: purchase_items (Detalle de compra)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.purchase_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relaciones
    purchase_id UUID NOT NULL REFERENCES public.purchases(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id),

    -- Cantidades y precios
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0),
    subtotal NUMERIC(12,2) NOT NULL,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comentarios
COMMENT ON TABLE public.purchase_items IS 'Detalle de productos en cada compra';
COMMENT ON COLUMN public.purchase_items.quantity IS 'Cantidad comprada';
COMMENT ON COLUMN public.purchase_items.unit_cost IS 'Costo unitario de compra';
COMMENT ON COLUMN public.purchase_items.subtotal IS 'Subtotal del ítem (quantity * unit_cost)';

-- ============================================================================
-- ÍNDICES
-- ============================================================================

-- Índices para purchases
CREATE INDEX IF NOT EXISTS idx_purchases_supplier_id ON public.purchases(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchases_location ON public.purchases(location_id, location_type);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON public.purchases(status);
CREATE INDEX IF NOT EXISTS idx_purchases_purchase_date ON public.purchases(purchase_date DESC);
CREATE INDEX IF NOT EXISTS idx_purchases_created_by ON public.purchases(created_by);
CREATE INDEX IF NOT EXISTS idx_purchases_needs_sync ON public.purchases(needs_sync) WHERE needs_sync = true;

-- Índices para purchase_items
CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase_id ON public.purchase_items(purchase_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product_variant_id ON public.purchase_items(product_variant_id);

-- ============================================================================
-- FUNCIÓN: Generar número de compra automático
-- ============================================================================

CREATE OR REPLACE FUNCTION public.generate_purchase_number()
RETURNS TRIGGER AS $$
DECLARE
    next_number INTEGER;
    year_part TEXT;
BEGIN
    -- Si ya tiene número asignado, no hacer nada
    IF NEW.purchase_number IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- Obtener año actual
    year_part := TO_CHAR(CURRENT_DATE, 'YYYY');

    -- Obtener siguiente número secuencial del año
    SELECT COALESCE(MAX(
        CAST(SUBSTRING(purchase_number FROM 'PUR-\d{4}-(\d+)') AS INTEGER)
    ), 0) + 1
    INTO next_number
    FROM public.purchases
    WHERE purchase_number LIKE 'PUR-' || year_part || '-%';

    -- Generar número con formato PUR-YYYY-NNNN
    NEW.purchase_number := 'PUR-' || year_part || '-' || LPAD(next_number::TEXT, 4, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCIÓN: Actualizar totales de compra
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_purchase_totals()
RETURNS TRIGGER AS $$
DECLARE
    calculated_subtotal NUMERIC(12,2);
BEGIN
    -- Calcular subtotal desde los items
    SELECT COALESCE(SUM(subtotal), 0.00)
    INTO calculated_subtotal
    FROM public.purchase_items
    WHERE purchase_id = COALESCE(NEW.purchase_id, OLD.purchase_id);

    -- Actualizar totales en purchases
    UPDATE public.purchases
    SET
        subtotal = calculated_subtotal,
        tax = calculated_subtotal * 0.13, -- 13% IVA (ajustar según tu país)
        total = calculated_subtotal * 1.13,
        updated_at = NOW()
    WHERE id = COALESCE(NEW.purchase_id, OLD.purchase_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCIÓN: Aplicar compra al inventario
-- ============================================================================

CREATE OR REPLACE FUNCTION public.apply_purchase_to_inventory()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
    inv_id UUID;
    new_quantity INTEGER;
    new_unit_cost DECIMAL(10,2);
    new_total_cost DECIMAL(12,2);
BEGIN
    -- Solo aplicar cuando el estado cambia a 'received'
    IF NEW.status = 'received' AND OLD.status != 'received' THEN

        -- Registrar quién recibió y cuándo
        NEW.received_by := auth.uid();
        NEW.received_at := NOW();

        -- Recorrer todos los items de la compra
        FOR item IN
            SELECT product_variant_id, quantity, unit_cost
            FROM public.purchase_items
            WHERE purchase_id = NEW.id
        LOOP
            -- Verificar si ya existe inventario para este producto en esta ubicación
            SELECT id INTO inv_id
            FROM public.inventory
            WHERE product_variant_id = item.product_variant_id
              AND location_id = NEW.location_id
              AND location_type = NEW.location_type;

            IF inv_id IS NOT NULL THEN
                -- Calcular costo promedio ponderado
                SELECT 
                    (old_q * old_uc + item.quantity * item.unit_cost) / NULLIF((old_q + item.quantity), 0),
                    old_q + item.quantity
                INTO new_unit_cost, new_quantity
                FROM (
                    SELECT quantity AS old_q, unit_cost AS old_uc
                    FROM public.inventory
                    WHERE id = inv_id
                ) x;

                new_total_cost := new_quantity * new_unit_cost;

                UPDATE public.inventory
                SET
                    quantity = new_quantity,
                    unit_cost = COALESCE(new_unit_cost, unit_cost),
                    total_cost = COALESCE(new_total_cost, total_cost),
                    last_cost = item.unit_cost,
                    last_updated = NOW(),
                    cost_updated_at = NOW(),
                    updated_by = auth.uid()
                WHERE id = inv_id;
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
                    NOW(),
                    NOW(),
                    auth.uid()
                );
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger para generar número de compra automáticamente
DROP TRIGGER IF EXISTS trg_generate_purchase_number ON public.purchases;
CREATE TRIGGER trg_generate_purchase_number
    BEFORE INSERT ON public.purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_purchase_number();

-- Trigger para updated_at
DROP TRIGGER IF EXISTS trg_purchases_updated_at ON public.purchases;
CREATE TRIGGER trg_purchases_updated_at
    BEFORE UPDATE ON public.purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger para actualizar totales cuando se agregan/modifican/eliminan items
DROP TRIGGER IF EXISTS trg_update_purchase_totals_insert ON public.purchase_items;
CREATE TRIGGER trg_update_purchase_totals_insert
    AFTER INSERT ON public.purchase_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_purchase_totals();

DROP TRIGGER IF EXISTS trg_update_purchase_totals_update ON public.purchase_items;
CREATE TRIGGER trg_update_purchase_totals_update
    AFTER UPDATE ON public.purchase_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_purchase_totals();

DROP TRIGGER IF EXISTS trg_update_purchase_totals_delete ON public.purchase_items;
CREATE TRIGGER trg_update_purchase_totals_delete
    AFTER DELETE ON public.purchase_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_purchase_totals();

-- Trigger para aplicar compra al inventario cuando se marca como 'received'
DROP TRIGGER IF EXISTS trg_apply_purchase_to_inventory ON public.purchases;
CREATE TRIGGER trg_apply_purchase_to_inventory
    BEFORE UPDATE ON public.purchases
    FOR EACH ROW
    WHEN (NEW.status = 'received' AND OLD.status != 'received')
    EXECUTE FUNCTION public.apply_purchase_to_inventory();

-- Auditoría (historial de cambios)
-- NOTA: Los triggers de auditoría se crean en FASE 11
-- Ver: sql/fase11/01_sistema_de_auditoria.sql

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Habilitar RLS
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_items ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS: purchases
-- ============================================================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "admins_all_purchases" ON public.purchases;
DROP POLICY IF EXISTS "managers_select_own_location_purchases" ON public.purchases;
DROP POLICY IF EXISTS "managers_insert_own_location_purchases" ON public.purchases;
DROP POLICY IF EXISTS "managers_update_own_location_purchases" ON public.purchases;

-- Admins: CRUD completo
CREATE POLICY "admins_all_purchases" ON public.purchases
FOR ALL USING (public.is_admin());

COMMENT ON POLICY "admins_all_purchases" ON public.purchases IS 'Admins tienen acceso completo a todas las compras';

-- Managers: Ver compras de su ubicación
CREATE POLICY "managers_select_own_location_purchases" ON public.purchases
FOR SELECT USING (
    public.is_admin_or_manager()
    AND location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
    )
);

COMMENT ON POLICY "managers_select_own_location_purchases" ON public.purchases IS 'Managers ven compras de su ubicación';

-- NOTE: Solo admin puede crear compras. No se define política de INSERT para managers.

-- Managers: Pueden APROBAR/RECIBIR compras de su ubicación (cambiar estado a 'received')
DROP POLICY IF EXISTS "managers_receive_own_location_purchases" ON public.purchases;
CREATE POLICY "managers_receive_own_location_purchases" ON public.purchases
FOR UPDATE
USING (
    public.is_admin_or_manager()
    AND location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
    )
)
WITH CHECK (
    public.is_admin_or_manager()
    AND location_id = COALESCE(
        (auth.jwt()->>'assigned_location_id')::uuid,
        (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
    )
    AND status IN ('pending','received')
);

COMMENT ON POLICY "managers_receive_own_location_purchases" ON public.purchases IS 'Managers pueden marcar como recibidas compras de su ubicación';

-- ============================================================================
-- RLS: purchase_items
-- ============================================================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "admins_all_purchase_items" ON public.purchase_items;
DROP POLICY IF EXISTS "managers_select_own_purchase_items" ON public.purchase_items;
DROP POLICY IF EXISTS "managers_insert_own_purchase_items" ON public.purchase_items;
DROP POLICY IF EXISTS "managers_update_own_purchase_items" ON public.purchase_items;
DROP POLICY IF EXISTS "managers_delete_own_purchase_items" ON public.purchase_items;

-- Admins: CRUD completo
CREATE POLICY "admins_all_purchase_items" ON public.purchase_items
FOR ALL USING (public.is_admin());

COMMENT ON POLICY "admins_all_purchase_items" ON public.purchase_items IS 'Admins tienen acceso completo a todos los items';

-- Managers: Ver items de compras de su ubicación
CREATE POLICY "managers_select_own_purchase_items" ON public.purchase_items
FOR SELECT USING (
    public.is_admin_or_manager()
    AND EXISTS (
        SELECT 1 FROM public.purchases
        WHERE id = purchase_items.purchase_id
        AND location_id = COALESCE(
            (auth.jwt()->>'assigned_location_id')::uuid,
            (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
        )
    )
);

COMMENT ON POLICY "managers_select_own_purchase_items" ON public.purchase_items IS 'Managers ven items de compras de su ubicación';

-- NOTE: Solo admin puede insertar items. No se define política de INSERT para managers.

-- NOTE: Solo admin puede actualizar items. No se define política de UPDATE para managers.

-- Managers: Eliminar items de compras pendientes de su ubicación
CREATE POLICY "managers_delete_own_purchase_items" ON public.purchase_items
FOR DELETE USING (
    public.is_admin_or_manager()
    AND EXISTS (
        SELECT 1 FROM public.purchases
        WHERE id = purchase_items.purchase_id
        AND location_id = COALESCE(
            (auth.jwt()->>'assigned_location_id')::uuid,
            (SELECT assigned_location_id FROM public.users WHERE id = auth.uid())
        )
        AND status = 'pending'
    )
);

COMMENT ON POLICY "managers_delete_own_purchase_items" ON public.purchase_items IS 'Managers eliminan items de compras pendientes de su ubicación';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Verificar tablas creadas
SELECT
    '✅ Tabla purchases creada' as status,
    pg_size_pretty(pg_total_relation_size('public.purchases')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'purchases';

SELECT
    '✅ Tabla purchase_items creada' as status,
    pg_size_pretty(pg_total_relation_size('public.purchase_items')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'purchase_items';

-- Verificar RLS habilitado
SELECT
    '✅ RLS habilitado' as status,
    tablename,
    rowsecurity as habilitado
FROM pg_tables
WHERE schemaname = 'public' AND tablename IN ('purchases', 'purchase_items');

-- Contar políticas RLS
SELECT
    '✅ Políticas RLS creadas' as status,
    tablename,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public' AND tablename IN ('purchases', 'purchase_items')
GROUP BY tablename;

-- Verificar triggers
SELECT
    '✅ Triggers creados' as status,
    tgrelid::regclass AS tabla,
    tgname as trigger_name
FROM pg_trigger
WHERE tgname LIKE 'trg_%purchase%'
AND NOT tgisinternal
ORDER BY tabla, tgname;

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
