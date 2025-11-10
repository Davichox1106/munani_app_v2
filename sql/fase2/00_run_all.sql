-- ============================================================================
-- 00_run_all.sql - FASE 2
-- Script maestro para ejecutar todos los scripts de Fase 2
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado Fase 1
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 2: Iniciando setup de base de datos'
\echo 'Tablas: stores, warehouses, products, product_variants'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Verificar extensiones
-- ============================================================================
\echo ''
\echo '🔧 Paso 1/6: Verificando extensiones...'
\i 01_extensions.sql

-- ============================================================================
-- PASO 2: Crear tablas
-- ============================================================================
\echo ''
\echo '📋 Paso 2/6: Creando tablas...'
\i 02_tables.sql

-- ============================================================================
-- PASO 3: Crear índices
-- ============================================================================
\echo ''
\echo '🔍 Paso 3/6: Creando índices...'
\i 03_indexes.sql

-- ============================================================================
-- PASO 4: Crear triggers
-- ============================================================================
\echo ''
\echo '⚡ Paso 4/6: Creando triggers...'
\i 04_triggers.sql

-- ============================================================================
-- PASO 5: Crear funciones de seguridad (IMPORTANTE: Antes de RLS)
-- ============================================================================
\echo ''
\echo '🔧 Paso 5/6: Creando funciones de seguridad (is_admin, is_admin_or_manager)...'
\i 05_functions.sql

-- ============================================================================
-- PASO 6: Configurar Row Level Security (RLS)
-- ============================================================================
\echo ''
\echo '🔒 Paso 6/6: Configurando políticas RLS...'
\i 06_rls_policies.sql

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ FASE 2: Setup completado exitosamente'
\echo '============================================================================'
\echo ''
\echo '📊 Tablas creadas:'
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('stores', 'warehouses', 'products', 'product_variants')
ORDER BY tablename;

\echo ''
\echo '🔐 Políticas RLS activas:'
SELECT
    schemaname,
    tablename,
    policyname,
    cmd AS operation
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('stores', 'warehouses', 'products', 'product_variants')
ORDER BY tablename, policyname;

\echo ''
\echo '============================================================================'
\echo '📝 Próximos pasos:'
\echo '  1. Verificar que las tablas se crearon correctamente'
\echo '  2. Probar las políticas RLS con diferentes roles'
\echo '  3. Continuar con Fase 3 (Inventario)'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
