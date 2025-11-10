-- ============================================================================
-- 01_extensions.sql - FASE 2
-- Extensiones necesarias para el proyecto
-- ============================================================================
-- NOTA: Las extensiones son a nivel de BASE DE DATOS, no por schema.
-- Si ya ejecutaste FASE 1, las extensiones ya están habilitadas.
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
-- EXTENSIONES ADICIONALES PARA FASE 2
-- ============================================================================

-- Ninguna extensión adicional requerida para Fase 2
-- Fase 2 utiliza:
-- - gen_random_uuid() → requiere uuid-ossp (ya habilitada en Fase 1)
-- - JSONB → tipo nativo de PostgreSQL
-- - GIN indexes → funcionalidad nativa
-- - to_tsvector → funcionalidad nativa de full-text search

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
