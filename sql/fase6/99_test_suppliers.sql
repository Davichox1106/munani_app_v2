-- ============================================================================
-- 99_test_suppliers.sql
-- Datos de prueba para proveedores (OPCIONAL)
-- ============================================================================
-- ADVERTENCIA: Solo ejecutar en entornos de desarrollo/testing
-- NO ejecutar en producción
-- ============================================================================

-- ============================================================================
-- CREAR PROVEEDORES DE PRUEBA
-- ============================================================================

-- Proveedor 1: Barritas Nutritivas artesanales
INSERT INTO public.suppliers (
    name,
    contact_name,
    phone,
    email,
    address,
    ruc_nit,
    notes,
    is_active,
    created_by
) VALUES (
    'NutriSnacks del Norte S.A.',
    'Carla Fernández',
    '+595 21 123-4567',
    'ventas@nutrisnacks.com.py',
    'Av. Mariscal López 1234, Asunción',
    '80012345-7',
    'Productores de barritas nutritivas artesanales con ingredientes orgánicos locales.',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Proveedor 2: Barritas proteicas deportivas
INSERT INTO public.suppliers (
    name,
    contact_name,
    phone,
    email,
    address,
    ruc_nit,
    notes,
    is_active,
    created_by
) VALUES (
    'PowerBar Logistics S.R.L.',
    'Andrés García',
    '+595 21 234-5678',
    'andres@powerbar.com.py',
    'Ruta Transchaco Km 15, Luque',
    '80023456-8',
    'Distribuidores de barritas proteicas para gimnasios y tiendas deportivas.',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Proveedor 3: Barritas dietéticas y sin azúcar
INSERT INTO public.suppliers (
    name,
    contact_name,
    phone,
    email,
    address,
    ruc_nit,
    notes,
    is_active,
    created_by
) VALUES (
    'VidaFit Foods',
    'Rocío Silva',
    '+595 21 345-6789',
    'rocio@vidafitfoods.com.py',
    'Calle 15 de Agosto 567, Fernando de la Mora',
    '80034567-9',
    'Especialistas en barritas dietéticas, veganas y sin azúcar añadida.',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Proveedor 4: Inactivo (para pruebas)
INSERT INTO public.suppliers (
    name,
    contact_name,
    phone,
    email,
    address,
    ruc_nit,
    notes,
    is_active,
    created_by
) VALUES (
    'Snacks Inactivos S.A.',
    'Juan Pérez',
    '+595 21 456-7890',
    'juan@snacksinactivos.com.py',
    'Calle Falsa 123, Ciudad',
    '80045678-0',
    'Proveedor deshabilitado para pruebas internas',
    false,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Contar proveedores creados
SELECT
    '✅ Proveedores de prueba creados' as status,
    COUNT(*) as total_proveedores,
    COUNT(CASE WHEN is_active = true THEN 1 END) as activos,
    COUNT(CASE WHEN is_active = false THEN 1 END) as inactivos
FROM public.suppliers;

-- Mostrar proveedores activos
SELECT
    name,
    contact_name,
    phone,
    ruc_nit,
    is_active
FROM public.suppliers
WHERE is_active = true
ORDER BY name;

-- ============================================================================
-- LIMPIAR DATOS DE PRUEBA (OPCIONAL)
-- ============================================================================
-- Para eliminar los proveedores de prueba:
-- DELETE FROM public.suppliers WHERE name LIKE '%Prueba%' OR name LIKE '%Inactivo%';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================



















