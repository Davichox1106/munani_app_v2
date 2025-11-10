-- ============================================================================
-- 00_run_all.sql - FASE 7
-- Script maestro para ejecutar todos los scripts de Fase 7
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado Fases anteriores
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 7: Iniciando setup de base de datos'
\echo 'Módulos: Administradores + Empleados de Tiendas + Empleados de Almacenes'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Crear tabla administrators
-- ============================================================================
\echo ''
\echo '📋 Paso 1/4: Creando tabla administrators...'
\i 01_administrators.sql

-- ============================================================================
-- PASO 2: Crear tabla employees_store
-- ============================================================================
\echo ''
\echo '📋 Paso 2/4: Creando tabla employees_store...'
\i 02_employees_store.sql

-- ============================================================================
-- PASO 3: Crear tabla employees_warehouse
-- ============================================================================
\echo ''
\echo '📋 Paso 3/4: Creando tabla employees_warehouse...'
\i 03_employees_warehouse.sql

-- ============================================================================
-- PASO 4: Datos de prueba (OPCIONAL)
-- ============================================================================
\echo ''
\echo '📋 Paso 4/4: Creando datos de prueba (opcional)...'
\echo '⚠️  Solo ejecutar en desarrollo/testing'
\i 99_test_employees.sql

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ FASE 7: Setup completado exitosamente'
\echo '============================================================================'
\echo ''
\echo '📊 Tablas creadas:'
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('administrators', 'employees_store', 'employees_warehouse')
ORDER BY tablename;

\echo ''
\echo '🔐 Políticas RLS activas:'
SELECT
    tablename,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('administrators', 'employees_store', 'employees_warehouse')
GROUP BY tablename
ORDER BY tablename;

\echo ''
\echo '📧 Emails disponibles para crear usuarios:'
SELECT COUNT(*) as total_emails
FROM (
    SELECT email FROM public.administrators WHERE is_active = true
    UNION ALL
    SELECT email FROM public.employees_store WHERE is_active = true
    UNION ALL
    SELECT email FROM public.employees_warehouse WHERE is_active = true
) AS all_emails;

\echo ''
\echo '============================================================================'
\echo '📝 Próximos pasos:'
\echo '  1. Registrar administradores en la tabla administrators'
\echo '  2. Registrar empleados en employees_store / employees_warehouse'
\echo '  3. En el UI de gestión de usuarios:'
\echo '     - Seleccionar tabla origen (administrators/employees_store/employees_warehouse)'
\echo '     - Buscar por email'
\echo '     - Autorellenar datos del formulario'
\echo '     - Crear usuario en tabla users con rol correspondiente'
\echo '  4. Asignar ubicación (store/warehouse) al usuario creado'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
