-- ============================================================================
-- 00_run_all.sql - FASE 4
-- Script maestro para ejecutar todos los scripts de Fase 4
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado Fase 1, 2 y 3
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 4: Iniciando setup de base de datos'
\echo 'Tabla: inventory (Inventario)'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Verificar extensiones
-- ============================================================================
\echo ''
\echo '🔧 Paso 1/5: Verificando extensiones...'
\i 01_extensions.sql

-- ============================================================================
-- PASO 2: Crear tabla inventory
-- ============================================================================
\echo ''
\echo '📋 Paso 2/5: Creando tabla inventory...'
\i 02_tables.sql

-- ============================================================================
-- PASO 3: Crear índices
-- ============================================================================
\echo ''
\echo '🔍 Paso 3/5: Creando índices...'
\i 03_indexes.sql

-- ============================================================================
-- PASO 4: Crear triggers
-- ============================================================================
\echo ''
\echo '⚡ Paso 4/5: Creando triggers...'
\i 04_triggers.sql

-- ============================================================================
-- PASO 5: Configurar Row Level Security (RLS)
-- ============================================================================
\echo ''
\echo '🔒 Paso 5/5: Configurando políticas RLS...'
\i 05_rls_policies.sql

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ FASE 4: Setup completado exitosamente'
\echo '============================================================================'
\echo ''
\echo '📊 Tabla creada:'
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'inventory'
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
AND tablename = 'inventory'
ORDER BY policyname;

\echo ''
\echo '🔍 Índices creados:'
SELECT
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename = 'inventory'
ORDER BY indexname;

\echo ''
\echo '⚡ Triggers creados:'
SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS tabla
FROM pg_trigger
WHERE tgrelid = 'public.inventory'::regclass
AND tgname NOT LIKE 'RI_%'
ORDER BY tgname;

\echo ''
\echo '============================================================================'
\echo '📝 Próximos pasos:'
\echo '  1. Verificar que la tabla se creó correctamente'
\echo '  2. Probar las políticas RLS con diferentes roles'
\echo '  3. Crear modelos Isar para inventario (Flutter)'
\echo '  4. Implementar InventoryBloc'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
