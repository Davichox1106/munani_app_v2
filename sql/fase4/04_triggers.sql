-- ============================================================================
-- 04_triggers.sql - FASE 4
-- Triggers para inventory
-- ============================================================================

-- ============================================================================
-- TRIGGER: Actualizar last_updated automáticamente
-- ============================================================================
CREATE OR REPLACE FUNCTION update_inventory_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inventory_update_timestamp
    BEFORE UPDATE ON public.inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_timestamp();

COMMENT ON TRIGGER inventory_update_timestamp ON public.inventory IS 'Actualiza last_updated automáticamente';

-- ============================================================================
-- FUNCIÓN: Validar stock mínimo/máximo
-- ============================================================================
CREATE OR REPLACE FUNCTION validate_inventory_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que quantity no sea negativo (ya hay CHECK, pero por seguridad)
    IF NEW.quantity < 0 THEN
        RAISE EXCEPTION 'La cantidad no puede ser negativa';
    END IF;
    
    -- Validar que min_stock sea menor que max_stock
    IF NEW.min_stock >= NEW.max_stock THEN
        RAISE EXCEPTION 'El stock mínimo debe ser menor que el stock máximo';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inventory_validate_stock
    BEFORE INSERT OR UPDATE ON public.inventory
    FOR EACH ROW
    EXECUTE FUNCTION validate_inventory_stock();

COMMENT ON TRIGGER inventory_validate_stock ON public.inventory IS 'Valida que min_stock < max_stock';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================

