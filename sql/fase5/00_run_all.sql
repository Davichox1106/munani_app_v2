-- ============================================================================
-- 00_run_all.sql - FASE 5
-- Script maestro para ejecutar todos los scripts de Fase 5
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado Fase 1, 2 y 4
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 5: Iniciando setup de base de datos'
\echo 'Tablas: transfers + Sistema de Auditoría'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Crear tabla transfers
-- ============================================================================
\echo ''
\echo '📋 Paso 1/3: Creando tabla transfers...'
\i 02_tables.sql

-- ============================================================================
-- PASO 2: Configurar Row Level Security (RLS) para transfers
-- ============================================================================
\echo ''
\echo '🔒 Paso 2/3: Configurando políticas RLS para transfers...'
\i 05_rls_policies.sql

-- ============================================================================
-- PASO 3: Instalar Sistema de Auditoría
-- ============================================================================
\echo ''
\echo '📊 Paso 3/3: Instalando sistema de auditoría completo...'
\i 06_sistema_de_auditoria.sql

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
AND tablename IN ('transfers', 'audit_log')
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
\echo '🔐 Políticas RLS activas en audit_log:'
SELECT
    schemaname,
    tablename,
    policyname,
    cmd AS operation
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'audit_log'
ORDER BY policyname;

\echo ''
\echo '⚡ Triggers de auditoría creados:'
SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS tabla,
    CASE
        WHEN tgtype & 2 = 2 THEN 'BEFORE'
        WHEN tgtype & 2 = 0 THEN 'AFTER'
    END AS momento,
    CASE
        WHEN tgtype & 4 = 4 THEN 'INSERT'
        WHEN tgtype & 8 = 8 THEN 'DELETE'
        WHEN tgtype & 16 = 16 THEN 'UPDATE'
    END AS operacion
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
AND t.tgname LIKE 'trg_audit_%'
AND NOT t.tgisinternal
ORDER BY tabla, tgname;

\echo ''
\echo '============================================================================'
\echo '📝 Próximos pasos:'
\echo '  1. Verificar que las tablas se crearon correctamente'
\echo '  2. Probar las políticas RLS con diferentes roles'
\echo '  3. Probar crear una transferencia y verificar auditoría'
\echo '  4. Integrar con la app Flutter'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
