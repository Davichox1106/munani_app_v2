-- ============================================================================
-- 01_extensions.sql - FASE 4
-- Extensiones necesarias para el proyecto
-- ============================================================================
-- NOTA: Las extensiones son a nivel de BASE DE DATOS, no por schema.
-- Si ya ejecutaste FASE 1 y FASE 2, las extensiones ya están habilitadas.
-- ============================================================================

-- Verificar que uuid-ossp está habilitada (necesaria para gen_random_uuid())
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp'
    ) THEN
        CREATE EXTENSION "uuid-ossp";
        RAISE NOTICE 'Extensión uuid-ossp creada';
    ELSE
        RAISE NOTICE 'Extensión uuid-ossp ya existe (creada en Fase 1)';
    END IF;
END
$$;

-- ============================================================================
-- EXTENSIONES ADICIONALES PARA FASE 4
-- ============================================================================

-- Ninguna extensión adicional requerida para Fase 4
-- Fase 4 utiliza:
-- - gen_random_uuid() → requiere uuid-ossp (ya habilitada en Fase 1)
-- - INTEGER, TEXT, TIMESTAMPTZ → tipos nativos de PostgreSQL

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================