-- ============================================================================
-- 02_tables.sql
-- Creación de tablas principales
-- ============================================================================
-- OWASP A01:2021 - Broken Access Control
-- Se implementará Row Level Security (RLS) en archivo separado
-- ============================================================================

-- ============================================================================
-- TABLA: users
-- Descripción: Almacena información de usuarios del sistema
-- ============================================================================
CREATE TABLE public.users (
    -- Identificadores
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,

    -- Información Personal
    name VARCHAR(255) NOT NULL,

    -- Control de Acceso
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'store_manager', 'warehouse_manager', 'customer')),
    assigned_location_id UUID,
    assigned_location_type VARCHAR(20) CHECK (assigned_location_type IN ('store', 'warehouse')),
    assigned_location_name TEXT, -- Nombre de la ubicación asignada (tienda o almacén)

    -- Estado
    is_active BOOLEAN DEFAULT true,

    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- COMENTARIOS EN TABLA Y COLUMNAS
-- ============================================================================
COMMENT ON TABLE public.users IS 'Usuarios del sistema con roles y ubicaciones asignadas';
COMMENT ON COLUMN public.users.id IS 'UUID único del usuario (sincronizado con auth.users)';
COMMENT ON COLUMN public.users.email IS 'Email único del usuario';
COMMENT ON COLUMN public.users.name IS 'Nombre completo del usuario';
COMMENT ON COLUMN public.users.role IS 'Rol del usuario: admin, store_manager, warehouse_manager, customer';
COMMENT ON COLUMN public.users.assigned_location_id IS 'ID de la tienda o almacén asignado';
COMMENT ON COLUMN public.users.assigned_location_type IS 'Tipo de ubicación: store o warehouse';
COMMENT ON COLUMN public.users.assigned_location_name IS 'Nombre de la ubicación asignada (tienda o almacén)';
COMMENT ON COLUMN public.users.is_active IS 'Indica si el usuario está activo';
COMMENT ON COLUMN public.users.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN public.users.updated_at IS 'Fecha de última actualización';
