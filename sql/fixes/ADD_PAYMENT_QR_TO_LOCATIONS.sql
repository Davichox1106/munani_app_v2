-- ============================================================================
-- FIX: ADD_PAYMENT_QR_TO_LOCATIONS.sql
-- Agrega columnas para almacenar información del código QR de pago
-- en tiendas y almacenes.
-- ============================================================================

DO $$
BEGIN
    -- Tiendas
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'stores'
          AND column_name = 'payment_qr_url'
    ) THEN
        ALTER TABLE public.stores
            ADD COLUMN payment_qr_url TEXT,
            ADD COLUMN payment_qr_description TEXT;

        COMMENT ON COLUMN public.stores.payment_qr_url IS 'URL del código QR para pagos';
        COMMENT ON COLUMN public.stores.payment_qr_description IS 'Descripción/instrucciones para el pago';
    END IF;

    -- Almacenes
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'warehouses'
          AND column_name = 'payment_qr_url'
    ) THEN
        ALTER TABLE public.warehouses
            ADD COLUMN payment_qr_url TEXT,
            ADD COLUMN payment_qr_description TEXT;

        COMMENT ON COLUMN public.warehouses.payment_qr_url IS 'URL del código QR para pagos';
        COMMENT ON COLUMN public.warehouses.payment_qr_description IS 'Descripción/instrucciones para el pago';
    END IF;
END $$;








