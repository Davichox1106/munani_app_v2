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
DROP TRIGGER IF EXISTS trg_audit_customers ON public.customers;
CREATE TRIGGER trg_audit_customers
AFTER INSERT OR UPDATE OR DELETE ON public.customers
FOR EACH ROW EXECUTE FUNCTION public.log_table_changes();