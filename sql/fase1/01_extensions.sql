-- ============================================================================
-- 01_extensions.sql
-- Extensiones necesarias para el proyecto
-- ============================================================================
-- Ejecutar PRIMERO antes que cualquier otro script
-- ============================================================================

-- Extensión para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Nota: La extensión pgcrypto viene habilitada por defecto en Supabase
-- pero si necesitas funciones de encriptación adicionales, descomenta:
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";
