-- ============================================================================
-- 03_indexes.sql
-- Creación de índices para optimización de consultas
-- ============================================================================
-- Los índices mejoran el rendimiento de las consultas frecuentes
-- ============================================================================

-- ============================================================================
-- ÍNDICES PARA TABLA: users
-- ============================================================================

-- Índice en email (búsquedas por email son muy frecuentes en login)
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Índice en role (filtrado por rol es común en queries)
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- Índice en assigned_location_id (filtrado por ubicación asignada)
CREATE INDEX IF NOT EXISTS idx_users_assigned_location ON public.users(assigned_location_id);

-- Índice compuesto para búsquedas por ubicación y tipo
CREATE INDEX IF NOT EXISTS idx_users_location_type
ON public.users(assigned_location_id, assigned_location_type);

-- Índice para usuarios activos (filtrado frecuente)
CREATE INDEX IF NOT EXISTS idx_users_active ON public.users(is_active) WHERE is_active = true;

-- ============================================================================
-- ANÁLISIS DE ÍNDICES
-- ============================================================================
-- Para verificar el uso de índices, ejecutar:
-- EXPLAIN ANALYZE SELECT * FROM public.users WHERE email = 'test@example.com';
