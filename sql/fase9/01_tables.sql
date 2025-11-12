-- FASE 9 - TABLAS DE CLIENTES

CREATE TABLE IF NOT EXISTS public.customers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ci text NOT NULL UNIQUE,
    name text NOT NULL,
    phone text,
    email text,
    address text,
    assigned_location_id uuid,
    assigned_location_type text CHECK (assigned_location_type IN ('store','warehouse')),
    assigned_location_name text,
    created_by uuid NOT NULL REFERENCES auth.users(id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.customers IS 'Clientes (con CI único).';

-- Índices
CREATE INDEX IF NOT EXISTS idx_customers_ci ON public.customers(ci);
CREATE INDEX IF NOT EXISTS idx_customers_name ON public.customers USING gin (to_tsvector('spanish', name));

-- Auditoría (historial de clientes)
-- NOTA: Los triggers de auditoría se crean en FASE 11
-- Ver: sql/fase11/01_sistema_de_auditoria.sql