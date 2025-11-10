-- ============================================================================
-- 00_run_all.sql - FASE 6
-- Script maestro para ejecutar todos los scripts de Fase 6
-- ============================================================================
-- IMPORTANTE: Ejecutar DESPUÉS de haber completado Fase 1, 2, 4 y 5
-- ============================================================================

\echo '============================================================================'
\echo 'FASE 6: Iniciando setup de base de datos'
\echo 'Módulos: Proveedores + Compras'
\echo '============================================================================'

-- ============================================================================
-- PASO 1: Crear tabla suppliers
-- ============================================================================
\echo ''
\echo '📋 Paso 1/3: Creando tabla suppliers...'
\i 01_suppliers.sql

-- ============================================================================
-- PASO 2: Crear tablas purchases y purchase_items
-- ============================================================================
\echo ''
\echo '📋 Paso 2/3: Creando tablas de compras...'
\i 02_purchases.sql

-- ============================================================================
-- PASO 3: Datos de prueba (OPCIONAL)
-- ============================================================================
\echo ''
\echo '📋 Paso 3/3: Creando datos de prueba (opcional)...'
\echo '⚠️  Solo ejecutar en desarrollo/testing'
\i 99_test_suppliers.sql

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo '✅ FASE 6: Setup completado exitosamente'
\echo '============================================================================'
\echo ''
\echo '📊 Tablas creadas:'
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('suppliers', 'purchases', 'purchase_items')
ORDER BY tablename;

\echo ''
\echo '🔐 Políticas RLS activas:'
SELECT
    tablename,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('suppliers', 'purchases', 'purchase_items')
GROUP BY tablename
ORDER BY tablename;

\echo ''
\echo '⚡ Triggers creados:'
SELECT
    tgrelid::regclass AS tabla,
    COUNT(*) as triggers
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
AND c.relname IN ('suppliers', 'purchases', 'purchase_items')
AND NOT t.tgisinternal
GROUP BY tgrelid
ORDER BY tabla;

\echo ''
\echo '============================================================================'
\echo '📝 Próximos pasos:'
\echo '  1. Crear proveedores desde la app (módulo Suppliers)'
\echo '  2. Crear compras asignando proveedor y ubicación destino'
\echo '  3. Marcar compras como "received" para aplicar al inventario'
\echo '  4. Integrar con módulo de Ventas (Fase 7)'
\echo '============================================================================'

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
