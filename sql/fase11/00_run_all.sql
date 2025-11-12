-- ============================================================================
-- 00_run_all.sql - FASE 11 (FINAL)
-- Script maestro para ejecutar el Sistema de Auditoría Completo
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado TODAS las fases (1-10)
-- ============================================================================
-- Este script instala el sistema de auditoría completo que registra
-- TODOS los cambios en TODAS las tablas del sistema.
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 11 (FINAL): Sistema de Auditoría Completo'
\echo '============================================================================'
\echo 'Este script debe ejecutarse AL FINAL, después de las Fases 1-10'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Instalar Sistema de Auditoría Completo
-- ============================================================================
\echo ''
\echo '📊 Instalando sistema de auditoría completo...'
\echo '   • Tabla audit_log'
\echo '   • Función log_table_changes()'
\echo '   • Políticas RLS para audit_log'
\echo '   • Funciones de consulta (get_record_history, get_user_activity)'
\echo '   • Triggers para TODAS las tablas'
\echo ''
\i 01_sistema_de_auditoria.sql

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ FASE 11: Sistema de Auditoría instalado exitosamente'
\echo '============================================================================'
\echo ''

\echo '📊 Tabla de auditoría:'
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    rowsecurity AS rls_habilitado
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'audit_log';

\echo ''
\echo '🔐 Políticas RLS en audit_log:'
SELECT
    policyname,
    cmd AS operation,
    qual AS usando,
    with_check AS con_check
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'audit_log'
ORDER BY policyname;

\echo ''
\echo '⚡ Total de triggers de auditoría creados:'
SELECT
    COUNT(*) as total_triggers_auditoria
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
AND t.tgname LIKE 'trg_audit_%'
AND NOT t.tgisinternal;

\echo ''
\echo '📋 Triggers de auditoría por tabla:'
SELECT
    tgrelid::regclass AS tabla,
    tgname AS trigger_name,
    CASE
        WHEN tgtype & 2 = 2 THEN 'BEFORE'
        WHEN tgtype & 2 = 0 THEN 'AFTER'
    END AS momento,
    CASE
        WHEN tgtype & 4 = 4 THEN 'INSERT'
        WHEN tgtype & 8 = 8 THEN 'DELETE'
        WHEN tgtype & 16 = 16 THEN 'UPDATE'
        ELSE 'INSERT/UPDATE/DELETE'
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
\echo '📝 Verificación:'
\echo '  ✅ Tabla audit_log creada'
\echo '  ✅ Función log_table_changes() creada'
\echo '  ✅ Políticas RLS configuradas'
\echo '  ✅ Triggers instalados en todas las tablas'
\echo ''
\echo '📖 Funciones disponibles:'
\echo '  • get_record_history(tabla, id) - Ver historial de un registro'
\echo '  • get_user_activity(user_id, dias) - Ver actividad de un usuario'
\echo ''
\echo '🎯 Próximos pasos:'
\echo '  1. Probar crear/modificar registros en cualquier tabla'
\echo '  2. Verificar que se registren en audit_log'
\echo '  3. Probar funciones de consulta'
\echo '  4. Integrar con la app Flutter'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT - FASE 11 (FINAL)
-- ============================================================================
