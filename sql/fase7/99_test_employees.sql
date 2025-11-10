-- ============================================================================
-- 99_test_employees.sql
-- Datos de prueba para administradores y empleados (OPCIONAL)
-- ============================================================================
-- ADVERTENCIA: Solo ejecutar en entornos de desarrollo/testing
-- NO ejecutar en producción
-- ============================================================================

-- ============================================================================
-- CREAR ADMINISTRADORES DE PRUEBA
-- ============================================================================

-- Administrador 1
INSERT INTO public.administrators (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    notes,
    is_active,
    created_by
) VALUES (
    'Juan Carlos Rodríguez',
    'Juan Carlos',
    '+595 21 111-1111',
    'admin1@empresa.com.py',
    '1234567',
    'Av. Principal 123, Asunción',
    'Administrador principal del sistema',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Administrador 2
INSERT INTO public.administrators (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    notes,
    is_active,
    created_by
) VALUES (
    'María Fernanda López',
    'María',
    '+595 21 222-2222',
    'admin2@empresa.com.py',
    '2345678',
    'Calle Secundaria 456, Asunción',
    'Administradora de sistemas',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- ============================================================================
-- CREAR EMPLEADOS DE TIENDA DE PRUEBA
-- ============================================================================

-- Empleado Tienda 1 - Vendedor
INSERT INTO public.employees_store (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    position,
    department,
    notes,
    is_active,
    created_by
) VALUES (
    'Pedro Martínez',
    'Pedro',
    '+595 21 333-3333',
    'vendedor1@empresa.com.py',
    '3456789',
    'Barrio San Miguel, Asunción',
    'Vendedor',
    'Ventas',
    'Vendedor con 3 años de experiencia',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Empleado Tienda 2 - Cajero
INSERT INTO public.employees_store (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    position,
    department,
    notes,
    is_active,
    created_by
) VALUES (
    'Laura Benítez',
    'Laura',
    '+595 21 444-4444',
    'cajera1@empresa.com.py',
    '4567890',
    'Barrio Las Mercedes, Asunción',
    'Cajera',
    'Caja',
    'Cajera responsable',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Empleado Tienda 3 - Gerente de Tienda
INSERT INTO public.employees_store (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    position,
    department,
    notes,
    is_active,
    created_by
) VALUES (
    'Roberto Gómez',
    'Roberto',
    '+595 21 555-5555',
    'gerente_tienda1@empresa.com.py',
    '5678901',
    'Villa Morra, Asunción',
    'Gerente de Tienda',
    'Administración',
    'Gerente con 5 años de experiencia',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- ============================================================================
-- CREAR EMPLEADOS DE ALMACÉN DE PRUEBA
-- ============================================================================

-- Empleado Almacén 1 - Almacenista
INSERT INTO public.employees_warehouse (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    position,
    department,
    notes,
    is_active,
    created_by
) VALUES (
    'Carlos Ramírez',
    'Carlos',
    '+595 21 666-6666',
    'almacenista1@empresa.com.py',
    '6789012',
    'Luque, Zona Industrial',
    'Almacenista',
    'Recepción',
    'Almacenista con certificación en manejo de inventarios',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Empleado Almacén 2 - Jefe de Almacén
INSERT INTO public.employees_warehouse (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    position,
    department,
    notes,
    is_active,
    created_by
) VALUES (
    'Ana Flores',
    'Ana',
    '+595 21 777-7777',
    'jefe_almacen1@empresa.com.py',
    '7890123',
    'San Lorenzo, Zona Industrial',
    'Jefe de Almacén',
    'Administración',
    'Jefe de almacén con 7 años de experiencia',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- Empleado Almacén 3 - Operador de Montacargas
INSERT INTO public.employees_warehouse (
    name,
    contact_name,
    phone,
    email,
    ci,
    address,
    position,
    department,
    notes,
    is_active,
    created_by
) VALUES (
    'Miguel Torres',
    'Miguel',
    '+595 21 888-8888',
    'operador1@empresa.com.py',
    '8901234',
    'Lambaré, Zona Industrial',
    'Operador de Montacargas',
    'Despacho',
    'Operador certificado',
    true,
    (SELECT id FROM public.users WHERE role = 'admin' LIMIT 1)
);

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Contar registros creados
SELECT
    '✅ Datos de prueba creados' as status;

-- Administradores
SELECT
    'Administradores' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN is_active = true THEN 1 END) as activos
FROM public.administrators;

-- Empleados de Tienda
SELECT
    'Empleados de Tienda' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN is_active = true THEN 1 END) as activos
FROM public.employees_store;

-- Empleados de Almacén
SELECT
    'Empleados de Almacén' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN is_active = true THEN 1 END) as activos
FROM public.employees_warehouse;

-- Mostrar todos los emails disponibles para crear usuarios
SELECT
    'administrators' as origen,
    name,
    email,
    is_active
FROM public.administrators
UNION ALL
SELECT
    'employees_store' as origen,
    name,
    email,
    is_active
FROM public.employees_store
UNION ALL
SELECT
    'employees_warehouse' as origen,
    name,
    email,
    is_active
FROM public.employees_warehouse
ORDER BY origen, name;

-- ============================================================================
-- LIMPIAR DATOS DE PRUEBA (OPCIONAL)
-- ============================================================================
-- Para eliminar los datos de prueba:
-- DELETE FROM public.administrators WHERE email LIKE '%@empresa.com.py';
-- DELETE FROM public.employees_store WHERE email LIKE '%@empresa.com.py';
-- DELETE FROM public.employees_warehouse WHERE email LIKE '%@empresa.com.py';

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
