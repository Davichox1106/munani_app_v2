-- ============================================================================
-- 02_tables.sql - FASE 5
-- Tabla: transfers (Transferencias)
-- ============================================================================
-- DESCRIPCIÓN:
-- Tabla para gestionar transferencias de inventario entre ubicaciones
-- Incluye flujo de aprobación y auditoría completa
-- ============================================================================

-- ============================================================================
-- TABLA: transfers
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Información del producto
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    variant_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    
    -- Ubicaciones
    from_location_id UUID NOT NULL,
    from_location_name TEXT NOT NULL,
    from_location_type TEXT NOT NULL CHECK (from_location_type IN ('store', 'warehouse')),
    to_location_id UUID NOT NULL,
    to_location_name TEXT NOT NULL,
    to_location_type TEXT NOT NULL CHECK (to_location_type IN ('store', 'warehouse')),
    
    -- Usuario que solicita
    requested_by UUID NOT NULL REFERENCES public.users(id),
    requested_by_name TEXT NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Aprobación
    approved_by UUID REFERENCES public.users(id),
    approved_by_name TEXT,
    approved_at TIMESTAMPTZ,
    
    -- Rechazo
    rejected_by UUID REFERENCES public.users(id),
    rejected_by_name TEXT,
    rejected_at TIMESTAMPTZ,
    
    -- Cancelación
    cancelled_by UUID REFERENCES public.users(id),
    cancelled_by_name TEXT,
    cancelled_at TIMESTAMPTZ,
    
    -- Finalización
    completed_by UUID REFERENCES public.users(id),
    completed_by_name TEXT,
    completed_at TIMESTAMPTZ,
    
    -- Razón de rechazo
    rejection_reason TEXT,
    
    -- Estado de la transferencia
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'completed')),
    
    -- Notas adicionales
    notes TEXT,
    
    -- Auditoría
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID NOT NULL REFERENCES public.users(id),

    -- Constraints
    CONSTRAINT transfers_different_locations CHECK (from_location_id != to_location_id),
    CONSTRAINT transfers_quantity_positive CHECK (quantity > 0)
);

-- ============================================================================
-- COMENTARIOS
-- ============================================================================
COMMENT ON TABLE public.transfers IS 'Transferencias de inventario entre ubicaciones - OWASP A09: Auditoría completa';
COMMENT ON COLUMN public.transfers.product_variant_id IS 'Variante del producto a transferir';
COMMENT ON COLUMN public.transfers.quantity IS 'Cantidad a transferir (debe ser positiva)';
COMMENT ON COLUMN public.transfers.from_location_id IS 'ID de la ubicación origen';
COMMENT ON COLUMN public.transfers.to_location_id IS 'ID de la ubicación destino';
COMMENT ON COLUMN public.transfers.status IS 'Estado: pending, approved, rejected, cancelled, completed';
COMMENT ON COLUMN public.transfers.requested_by IS 'Usuario que solicita la transferencia';
COMMENT ON COLUMN public.transfers.approved_by IS 'Usuario que aprueba la transferencia';
COMMENT ON COLUMN public.transfers.rejected_by IS 'Usuario que rechaza la transferencia';
COMMENT ON COLUMN public.transfers.cancelled_by IS 'Usuario que cancela la transferencia';
COMMENT ON COLUMN public.transfers.completed_by IS 'Usuario que completa la transferencia';
COMMENT ON COLUMN public.transfers.updated_by IS 'Último usuario que modificó (auditoría)';

-- ============================================================================
-- TRIGGER PARA AUDITORÍA AUTOMÁTICA
-- ============================================================================
-- Función para actualizar automáticamente los campos de auditoría
CREATE OR REPLACE FUNCTION public.update_transfer_audit_fields()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar last_updated siempre
    NEW.last_updated = NOW();
    
    -- Si el status cambió, actualizar el campo correspondiente
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        CASE NEW.status
            WHEN 'rejected' THEN
                NEW.rejected_by = NEW.updated_by;
                NEW.rejected_by_name = (
                    SELECT name FROM public.users WHERE id = NEW.updated_by
                );
                NEW.rejected_at = NOW();
            WHEN 'cancelled' THEN
                NEW.cancelled_by = NEW.updated_by;
                NEW.cancelled_by_name = (
                    SELECT name FROM public.users WHERE id = NEW.updated_by
                );
                NEW.cancelled_at = NOW();
            WHEN 'completed' THEN
                NEW.completed_by = NEW.updated_by;
                NEW.completed_by_name = (
                    SELECT name FROM public.users WHERE id = NEW.updated_by
                );
                NEW.completed_at = NOW();
        END CASE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger para aplicar la función automáticamente
DROP TRIGGER IF EXISTS trg_update_transfer_audit ON public.transfers;
CREATE TRIGGER trg_update_transfer_audit
    BEFORE UPDATE ON public.transfers
    FOR EACH ROW EXECUTE FUNCTION public.update_transfer_audit_fields();

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================

