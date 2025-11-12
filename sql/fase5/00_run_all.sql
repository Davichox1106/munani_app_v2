-- ============================================================================
-- 00_run_all.sql - FASE 5
-- Script maestro para ejecutar todos los scripts de Fase 5
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado Fase 1, 2 y 4
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 5: Iniciando setup de base de datos'
\echo 'Tablas: transfers'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Crear tabla transfers
-- ============================================================================
\echo ''
\echo '📋 Paso 1/2: Creando tabla transfers...'
\i 02_tables.sql

-- ============================================================================
-- PASO 2: Configurar Row Level Security (RLS) para transfers
-- ============================================================================
\echo ''
\echo '🔒 Paso 2/2: Configurando políticas RLS para transfers...'
\i 05_rls_policies.sql

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ FASE 5: Setup completado exitosamente'
\echo '============================================================================'
\echo ''
\echo '📊 Tabla creada:'
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'transfers'
ORDER BY tablename;

\echo ''
\echo '🔐 Políticas RLS activas en transfers:'
SELECT
    schemaname,
    tablename,
    policyname,
    cmd AS operation
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'transfers'
ORDER BY policyname;

\echo ''
\echo '============================================================================'
\echo '📝 Próximos pasos:'
\echo '  1. Verificar que la tabla transfers se creó correctamente'
\echo '  2. Probar las políticas RLS con diferentes roles'
\echo '  3. Probar crear una transferencia'
\echo '  4. Continuar con FASE 6, 7, 8, 9, 10'
\echo '  5. Ejecutar FASE 11 (Sistema de Auditoría) al FINAL'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
