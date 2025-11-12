-- ============================================================================
-- SISTEMA DE AUDITORÍA SEGURO: COMPATIBLE CON RLS EXISTENTE
-- ============================================================================
-- Este script implementa auditoría SIN conflictos con políticas RLS existentes
-- ============================================================================

-- ============================================================================
-- PARTE 1: CAMPOS BÁSICOS DE AUDITORÍA
-- ============================================================================
-- NOTA: NO agregamos columnas created_by/updated_by porque:
--   1. La tabla 'products' ya tiene created_by
--   2. La tabla 'inventory' ya tiene updated_by
--   3. La tabla 'transfers' ya tiene auditoría completa
--   4. Las demás tablas no necesitan estos campos si no los usas en la app
--   5. El historial completo se registra en audit_log
--
-- Si en el futuro necesitas estos campos, la app Flutter debe:
--   - Enviar el user_id en los payloads de INSERT/UPDATE
--   - Agregar las columnas manualmente a las tablas que lo requieran
--
-- Por ahora, solo usamos la tabla audit_log para el historial completo.
-- ============================================================================

-- ============================================================================
-- PARTE 2: CREAR TABLA DE HISTORIAL (SIN RLS INICIAL)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Información de la tabla modificada
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    
    -- Información del cambio
    operation TEXT NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    
    -- Usuario y timestamp
    changed_by UUID NOT NULL REFERENCES public.users(id),
    changed_by_name TEXT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Información adicional
    ip_address INET,
    user_agent TEXT,
    session_id TEXT
);

-- Comentarios de la tabla de auditoría
COMMENT ON TABLE public.audit_log IS 'Historial completo de cambios - OWASP A09: Auditoría completa';
COMMENT ON COLUMN public.audit_log.table_name IS 'Nombre de la tabla modificada';
COMMENT ON COLUMN public.audit_log.record_id IS 'ID del registro modificado';
COMMENT ON COLUMN public.audit_log.operation IS 'Tipo de operación: INSERT, UPDATE, DELETE';
COMMENT ON COLUMN public.audit_log.old_values IS 'Valores anteriores (JSON)';
COMMENT ON COLUMN public.audit_log.new_values IS 'Valores nuevos (JSON)';
COMMENT ON COLUMN public.audit_log.changed_by IS 'Usuario que realizó el cambio';
COMMENT ON COLUMN public.audit_log.changed_by_name IS 'Nombre del usuario que realizó el cambio';
COMMENT ON COLUMN public.audit_log.changed_at IS 'Fecha y hora del cambio';

-- ============================================================================
-- PARTE 3: ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_audit_log_table_record ON public.audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_changed_by ON public.audit_log(changed_by);
CREATE INDEX IF NOT EXISTS idx_audit_log_changed_at ON public.audit_log(changed_at);
CREATE INDEX IF NOT EXISTS idx_audit_log_operation ON public.audit_log(operation);

-- ============================================================================
-- PARTE 4: FUNCIONES DE AUDITORÍA SEGURAS
-- ============================================================================

-- NOTA: NO creamos función update_basic_audit_fields() porque YA EXISTE
--       la función update_updated_at_column() en fase1/04_functions.sql
--       y fase2/04_triggers.sql que hace lo mismo.
--       Los triggers BEFORE UPDATE ya existen y funcionan correctamente.

-- Función para registrar cambios (SEGURA, sin bypass RLS)
CREATE OR REPLACE FUNCTION public.log_table_changes()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
    old_data JSONB;
    new_data JSONB;
    current_user_id UUID;
BEGIN
    -- Obtener usuario actual de forma segura
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
      current_user_id := '00000000-0000-0000-0000-000000000000'::uuid;
  END IF;

  SELECT name INTO user_name FROM public.users WHERE id = current_user_id;
  IF user_name IS NULL THEN
      user_name := 'Sistema';
  END IF;
    
    -- Determinar datos según operación
    IF TG_OP = 'DELETE' THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
    END IF;
    
    -- Insertar en audit_log (SIN bypass RLS)
    INSERT INTO public.audit_log (
        table_name,
        record_id,
        operation,
        old_values,
        new_values,
        changed_by,
        changed_by_name,
        changed_at
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        old_data,
        new_data,
        current_user_id,
        user_name,
        NOW()
    );
    
    -- Retornar el registro apropiado
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PARTE 5: TRIGGERS PARA CAMPOS BÁSICOS (TABLAS NORMALES)
-- ============================================================================

-- NOTA: NO creamos triggers BEFORE UPDATE porque YA EXISTEN:
--   - update_users_updated_at (fase1/05_triggers.sql)
--   - stores_updated_at (fase2/04_triggers.sql)
--   - warehouses_updated_at (fase2/04_triggers.sql)
--   - products_updated_at (fase2/04_triggers.sql)
--   - product_variants_updated_at (fase2/04_triggers.sql)
--   - inventory_update_timestamp (fase4/04_triggers.sql)
--
-- Estos triggers ya actualizan los campos updated_at correctamente.
-- NO es necesario duplicarlos.

-- ============================================================================
-- PARTE 6: TRIGGERS PARA HISTORIAL (TODAS LAS TABLAS)
-- ============================================================================

-- Trigger para users
DROP TRIGGER IF EXISTS trg_audit_users ON public.users;
CREATE TRIGGER trg_audit_users
    AFTER INSERT OR UPDATE OR DELETE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para stores
DROP TRIGGER IF EXISTS trg_audit_stores ON public.stores;
CREATE TRIGGER trg_audit_stores
    AFTER INSERT OR UPDATE OR DELETE ON public.stores
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para warehouses
DROP TRIGGER IF EXISTS trg_audit_warehouses ON public.warehouses;
CREATE TRIGGER trg_audit_warehouses
    AFTER INSERT OR UPDATE OR DELETE ON public.warehouses
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para products
DROP TRIGGER IF EXISTS trg_audit_products ON public.products;
CREATE TRIGGER trg_audit_products
    AFTER INSERT OR UPDATE OR DELETE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para product_variants
DROP TRIGGER IF EXISTS trg_audit_product_variants ON public.product_variants;
CREATE TRIGGER trg_audit_product_variants
    AFTER INSERT OR UPDATE OR DELETE ON public.product_variants
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para inventory
DROP TRIGGER IF EXISTS trg_audit_inventory ON public.inventory;
CREATE TRIGGER trg_audit_inventory
    AFTER INSERT OR UPDATE OR DELETE ON public.inventory
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para carts
DROP TRIGGER IF EXISTS trg_audit_carts ON public.carts;
CREATE TRIGGER trg_audit_carts
    AFTER INSERT OR UPDATE OR DELETE ON public.carts
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para cart_items
DROP TRIGGER IF EXISTS trg_audit_cart_items ON public.cart_items;
CREATE TRIGGER trg_audit_cart_items
    AFTER INSERT OR UPDATE OR DELETE ON public.cart_items
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para payment_receipts
DROP TRIGGER IF EXISTS trg_audit_payment_receipts ON public.payment_receipts;
CREATE TRIGGER trg_audit_payment_receipts
    AFTER INSERT OR UPDATE OR DELETE ON public.payment_receipts
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para transfers (Fase 5)
DROP TRIGGER IF EXISTS trg_audit_transfers ON public.transfers;
CREATE TRIGGER trg_audit_transfers
    AFTER INSERT OR UPDATE OR DELETE ON public.transfers
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para suppliers (Fase 6)
DROP TRIGGER IF EXISTS trg_audit_suppliers ON public.suppliers;
CREATE TRIGGER trg_audit_suppliers
    AFTER INSERT OR UPDATE OR DELETE ON public.suppliers
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para purchases (Fase 6)
DROP TRIGGER IF EXISTS trg_audit_purchases ON public.purchases;
CREATE TRIGGER trg_audit_purchases
    AFTER INSERT OR UPDATE OR DELETE ON public.purchases
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para purchase_items (Fase 6)
DROP TRIGGER IF EXISTS trg_audit_purchase_items ON public.purchase_items;
CREATE TRIGGER trg_audit_purchase_items
    AFTER INSERT OR UPDATE OR DELETE ON public.purchase_items
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para administrators (Fase 7)
DROP TRIGGER IF EXISTS trg_audit_administrators ON public.administrators;
CREATE TRIGGER trg_audit_administrators
    AFTER INSERT OR UPDATE OR DELETE ON public.administrators
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para employees_store (Fase 7)
DROP TRIGGER IF EXISTS trg_audit_employees_store ON public.employees_store;
CREATE TRIGGER trg_audit_employees_store
    AFTER INSERT OR UPDATE OR DELETE ON public.employees_store
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para employees_warehouse (Fase 7)
DROP TRIGGER IF EXISTS trg_audit_employees_warehouse ON public.employees_warehouse;
CREATE TRIGGER trg_audit_employees_warehouse
    AFTER INSERT OR UPDATE OR DELETE ON public.employees_warehouse
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para sales (Fase 8)
DROP TRIGGER IF EXISTS trg_audit_sales ON public.sales;
CREATE TRIGGER trg_audit_sales
    AFTER INSERT OR UPDATE OR DELETE ON public.sales
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para sale_items (Fase 8)
DROP TRIGGER IF EXISTS trg_audit_sale_items ON public.sale_items;
CREATE TRIGGER trg_audit_sale_items
    AFTER INSERT OR UPDATE OR DELETE ON public.sale_items
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- Trigger para customers (Fase 9)
DROP TRIGGER IF EXISTS trg_audit_customers ON public.customers;
CREATE TRIGGER trg_audit_customers
    AFTER INSERT OR UPDATE OR DELETE ON public.customers
    FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();

-- ============================================================================
-- PARTE 7: FUNCIONES DE CONSULTA
-- ============================================================================

-- Función para obtener historial de un registro específico
CREATE OR REPLACE FUNCTION public.get_record_history(
    p_table_name TEXT,
    p_record_id UUID
)
RETURNS TABLE (
    operation TEXT,
    changed_by_name TEXT,
    changed_at TIMESTAMPTZ,
    old_values JSONB,
    new_values JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.operation,
        al.changed_by_name,
        al.changed_at,
        al.old_values,
        al.new_values
    FROM public.audit_log al
    WHERE al.table_name = p_table_name
      AND al.record_id = p_record_id
    ORDER BY al.changed_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener historial de un usuario
CREATE OR REPLACE FUNCTION public.get_user_activity(
    p_user_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    table_name TEXT,
    record_id UUID,
    operation TEXT,
    changed_at TIMESTAMPTZ,
    new_values JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.table_name,
        al.record_id,
        al.operation,
        al.changed_at,
        al.new_values
    FROM public.audit_log al
    WHERE al.changed_by = p_user_id
      AND al.changed_at >= NOW() - INTERVAL '1 day' * p_days
    ORDER BY al.changed_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PARTE 8: RLS PARA AUDIT_LOG (SEGURA)
-- ============================================================================
-- IMPORTANTE: Habilitar RLS para proteger datos de auditoría
-- OWASP A01: Prevenir acceso no autorizado a registros de auditoría

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_select_all_audit_log" ON public.audit_log;
DROP POLICY IF EXISTS "store_managers_select_own_audit_log" ON public.audit_log;
DROP POLICY IF EXISTS "warehouse_managers_select_own_audit_log" ON public.audit_log;
DROP POLICY IF EXISTS "users_select_own_audit_log" ON public.audit_log;
DROP POLICY IF EXISTS "system_insert_audit_log" ON public.audit_log;

-- Admins: Ver TODOS los registros de auditoría
CREATE POLICY "admins_select_all_audit_log" ON public.audit_log
FOR SELECT USING (public.is_admin());

COMMENT ON POLICY "admins_select_all_audit_log" ON public.audit_log IS 'Administradores ven toda la auditoría';

-- Store managers: Ver auditoría de tablas relacionadas con su tienda
-- (stores, inventory de su tienda, transfers de su tienda)
CREATE POLICY "store_managers_select_own_audit_log" ON public.audit_log
FOR SELECT USING (
    public.is_store_manager()
    AND (
        -- Ver cambios que ellos hicieron
        changed_by = auth.uid()
        -- O ver cambios en tablas públicas (products, product_variants)
        OR table_name IN ('products', 'product_variants')
    )
);

COMMENT ON POLICY "store_managers_select_own_audit_log" ON public.audit_log IS 'Store managers ven su propia actividad y cambios en productos';

-- Warehouse managers: Ver auditoría de tablas relacionadas con su almacén
CREATE POLICY "warehouse_managers_select_own_audit_log" ON public.audit_log
FOR SELECT USING (
    public.is_warehouse_manager()
    AND (
        -- Ver cambios que ellos hicieron
        changed_by = auth.uid()
        -- O ver cambios en tablas públicas (products, product_variants)
        OR table_name IN ('products', 'product_variants')
    )
);

COMMENT ON POLICY "warehouse_managers_select_own_audit_log" ON public.audit_log IS 'Warehouse managers ven su propia actividad y cambios en productos';

-- Usuarios: Solo ver su propia actividad
CREATE POLICY "users_select_own_audit_log" ON public.audit_log
FOR SELECT USING (changed_by = auth.uid());

COMMENT ON POLICY "users_select_own_audit_log" ON public.audit_log IS 'Usuarios ven solo su propia actividad';

-- Permitir INSERT desde triggers (sin restricción de usuario)
-- Esto es necesario para que los triggers AFTER puedan insertar en audit_log
CREATE POLICY "system_insert_audit_log" ON public.audit_log
FOR INSERT WITH CHECK (true);

COMMENT ON POLICY "system_insert_audit_log" ON public.audit_log IS 'Permitir inserción desde triggers de auditoría';

-- ============================================================================
-- PARTE 9: VERIFICACIÓN FINAL
-- ============================================================================

-- Verificar que la tabla audit_log fue creada
SELECT
    '✅ Tabla audit_log creada' as status,
    pg_size_pretty(pg_total_relation_size('public.audit_log')) as tamaño
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'audit_log';

-- Verificar que RLS está habilitado en audit_log
SELECT
    '✅ RLS habilitado en audit_log' as status,
    rowsecurity as habilitado
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'audit_log';

-- Contar políticas RLS en audit_log
SELECT
    '✅ Políticas RLS en audit_log' as status,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'audit_log';

-- Contar triggers AFTER creados
SELECT
    '✅ Triggers de auditoría (AFTER)' as status,
    COUNT(*) as total_triggers
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
AND t.tgname LIKE 'trg_audit_%'
AND NOT t.tgisinternal;

-- Mostrar resumen final
SELECT
    '════════════════════════════════════════════════════════════════════════' as separador
UNION ALL
SELECT '✅ SISTEMA DE AUDITORÍA INSTALADO CORRECTAMENTE'
UNION ALL
SELECT '════════════════════════════════════════════════════════════════════════'
UNION ALL
SELECT '📋 Características:'
UNION ALL
SELECT '   • Tabla audit_log con historial completo de cambios'
UNION ALL
SELECT '   • Triggers AFTER en TODAS las tablas:'
UNION ALL
SELECT '     - Fase 1-5: users, stores, warehouses, products, product_variants, inventory, transfers'
UNION ALL
SELECT '     - Fase 6: suppliers, purchases, purchase_items'
UNION ALL
SELECT '     - Fase 7: administrators, employees_store, employees_warehouse'
UNION ALL
SELECT '     - Fase 8: sales, sale_items'
UNION ALL
SELECT '     - Fase 9: customers'
UNION ALL
SELECT '     - Fase 10: carts, cart_items, payment_receipts'
UNION ALL
SELECT '   • RLS habilitado en audit_log (seguridad por rol)'
UNION ALL
SELECT '   • Compatible con triggers BEFORE UPDATE existentes (sin conflictos)'
UNION ALL
SELECT '   • Funciones de consulta: get_record_history(), get_user_activity()'
UNION ALL
SELECT '════════════════════════════════════════════════════════════════════════'
UNION ALL
SELECT '⚠️  NOTAS IMPORTANTES:'
UNION ALL
SELECT '   • NO se agregaron columnas created_by/updated_by (la app debe enviarlas si las necesita)'
UNION ALL
SELECT '   • Los campos updated_at se actualizan con triggers BEFORE existentes'
UNION ALL
SELECT '   • La auditoría completa se registra en audit_log con triggers AFTER'
UNION ALL
SELECT '════════════════════════════════════════════════════════════════════════';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
