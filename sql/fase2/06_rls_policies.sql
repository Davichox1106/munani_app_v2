-- ============================================================================
-- 06_rls_policies.sql - FASE 2
-- Row Level Security (RLS) - OWASP A01: Broken Access Control
-- ============================================================================
-- IMPORTANTE: Las funciones helper (is_admin, is_admin_or_manager, etc.)
--             están definidas en 05_functions.sql y se ejecutan ANTES
-- ============================================================================

-- ============================================================================
-- HABILITAR RLS EN TODAS LAS TABLAS
-- ============================================================================
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- POLÍTICAS RLS: stores
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_select_all_stores" ON public.stores;
DROP POLICY IF EXISTS "store_managers_select_own" ON public.stores;
DROP POLICY IF EXISTS "warehouse_managers_select_all_stores" ON public.stores;
DROP POLICY IF EXISTS "authenticated_select_stores" ON public.stores;
DROP POLICY IF EXISTS "admins_insert_stores" ON public.stores;
DROP POLICY IF EXISTS "admins_update_stores" ON public.stores;
DROP POLICY IF EXISTS "admins_delete_stores" ON public.stores;

-- Admins: ver todas las tiendas
CREATE POLICY "admins_select_all_stores" ON public.stores
FOR SELECT USING (public.is_admin());

-- Store managers: solo ver su tienda asignada
-- NOTA: Esta política requiere que assigned_location_id esté sincronizado en el JWT
-- Por ahora permitimos ver todas las tiendas a store managers (simplificado)
CREATE POLICY "store_managers_select_own" ON public.stores
FOR SELECT USING (public.is_store_manager());

-- Warehouse managers: ver todas las tiendas (para transferencias)
CREATE POLICY "warehouse_managers_select_all_stores" ON public.stores
FOR SELECT USING (public.is_warehouse_manager());

-- Clientes autenticados: pueden ver tiendas para checkout/catálogos
CREATE POLICY "authenticated_select_stores" ON public.stores
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Solo admins pueden insertar/actualizar/eliminar tiendas
CREATE POLICY "admins_insert_stores" ON public.stores
FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "admins_update_stores" ON public.stores
FOR UPDATE USING (public.is_admin());

CREATE POLICY "admins_delete_stores" ON public.stores
FOR DELETE USING (public.is_admin());

-- ============================================================================
-- POLÍTICAS RLS: warehouses
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "admins_select_all_warehouses" ON public.warehouses;
DROP POLICY IF EXISTS "warehouse_managers_select_own" ON public.warehouses;
DROP POLICY IF EXISTS "store_managers_select_all_warehouses" ON public.warehouses;
DROP POLICY IF EXISTS "authenticated_select_warehouses" ON public.warehouses;
DROP POLICY IF EXISTS "admins_insert_warehouses" ON public.warehouses;
DROP POLICY IF EXISTS "admins_update_warehouses" ON public.warehouses;
DROP POLICY IF EXISTS "admins_delete_warehouses" ON public.warehouses;

-- Admins: ver todos los almacenes
CREATE POLICY "admins_select_all_warehouses" ON public.warehouses
FOR SELECT USING (public.is_admin());

-- Warehouse managers: solo ver su almacén asignado
-- NOTA: Esta política requiere que assigned_location_id esté sincronizado en el JWT
-- Por ahora permitimos ver todos los almacenes a warehouse managers (simplificado)
CREATE POLICY "warehouse_managers_select_own" ON public.warehouses
FOR SELECT USING (public.is_warehouse_manager());

-- Store managers: ver todos los almacenes (para solicitar transferencias)
CREATE POLICY "store_managers_select_all_warehouses" ON public.warehouses
FOR SELECT USING (public.is_store_manager());

-- Clientes autenticados: pueden ver almacenes asociados a inventario
CREATE POLICY "authenticated_select_warehouses" ON public.warehouses
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Solo admins pueden insertar/actualizar/eliminar almacenes
CREATE POLICY "admins_insert_warehouses" ON public.warehouses
FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "admins_update_warehouses" ON public.warehouses
FOR UPDATE USING (public.is_admin());

CREATE POLICY "admins_delete_warehouses" ON public.warehouses
FOR DELETE USING (public.is_admin());

-- ============================================================================
-- POLÍTICAS RLS: products
-- ============================================================================

-- Eliminar políticas existentes si las hay (incluyendo variantes de nombres)
DROP POLICY IF EXISTS "authenticated_select_products" ON public.products;
DROP POLICY IF EXISTS "admins_managers_insert_products" ON public.products;
DROP POLICY IF EXISTS "admins_insert_products" ON public.products;
DROP POLICY IF EXISTS "temp_authenticated_insert_products" ON public.products;
DROP POLICY IF EXISTS "admins_creator_update_products" ON public.products;
DROP POLICY IF EXISTS "admins_update_products" ON public.products;
DROP POLICY IF EXISTS "admins_delete_products" ON public.products;

-- Todos los usuarios autenticados pueden VER productos
CREATE POLICY "authenticated_select_products" ON public.products
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Solo admins y managers pueden CREAR productos
CREATE POLICY "admins_managers_insert_products" ON public.products
FOR INSERT WITH CHECK (public.is_admin_or_manager());

-- Solo admins y el creador pueden ACTUALIZAR productos
CREATE POLICY "admins_creator_update_products" ON public.products
FOR UPDATE USING (
    public.is_admin()
    OR created_by = auth.uid()
);

-- Solo admins pueden ELIMINAR productos
CREATE POLICY "admins_delete_products" ON public.products
FOR DELETE USING (public.is_admin());

-- ============================================================================
-- POLÍTICAS RLS: product_variants
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "authenticated_select_variants" ON public.product_variants;
DROP POLICY IF EXISTS "admins_select_all_variants" ON public.product_variants;
DROP POLICY IF EXISTS "admins_managers_insert_variants" ON public.product_variants;
DROP POLICY IF EXISTS "admins_creator_update_variants" ON public.product_variants;
DROP POLICY IF EXISTS "admins_delete_variants" ON public.product_variants;

-- Todos los usuarios autenticados pueden VER variantes activas
CREATE POLICY "authenticated_select_variants" ON public.product_variants
FOR SELECT USING (
    auth.uid() IS NOT NULL
    AND is_active = true
);

-- Admins ven todas las variantes (incluso inactivas)
CREATE POLICY "admins_select_all_variants" ON public.product_variants
FOR SELECT USING (public.is_admin());

-- Solo admins y managers pueden CREAR variantes
CREATE POLICY "admins_managers_insert_variants" ON public.product_variants
FOR INSERT WITH CHECK (public.is_admin_or_manager());

-- Solo admins y el creador del producto padre pueden ACTUALIZAR variantes
CREATE POLICY "admins_creator_update_variants" ON public.product_variants
FOR UPDATE USING (
    public.is_admin()
    OR EXISTS (
        SELECT 1 FROM public.products
        WHERE id = product_variants.product_id
        AND created_by = auth.uid()
    )
);

-- Solo admins pueden ELIMINAR variantes
CREATE POLICY "admins_delete_variants" ON public.product_variants
FOR DELETE USING (public.is_admin());

-- ============================================================================
-- ACTUALIZAR ROLES EN JWT DE USUARIOS EXISTENTES
-- ============================================================================
-- Asegura que todos los usuarios existentes tengan su rol en app_metadata
-- para que esté disponible en JWT y funcionen las políticas RLS
-- ============================================================================

UPDATE auth.users
SET raw_app_meta_data = 
    COALESCE(raw_app_meta_data, '{}'::jsonb) || 
    jsonb_build_object(
        'user_role', 
        COALESCE(
            (SELECT role FROM public.users WHERE id = auth.users.id),
            'store_manager'
        )
    )
WHERE raw_app_meta_data IS NULL 
   OR raw_app_meta_data->>'user_role' IS NULL;

-- Verificar y mostrar resultados
DO $$
DECLARE
    admin_count INTEGER;
    manager_count INTEGER;
    total_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_count FROM auth.users;
    SELECT COUNT(*) INTO admin_count 
    FROM auth.users 
    WHERE raw_app_meta_data->>'user_role' = 'admin';
    SELECT COUNT(*) INTO manager_count 
    FROM auth.users 
    WHERE raw_app_meta_data->>'user_role' IN ('store_manager', 'warehouse_manager');
    
    RAISE NOTICE '✅ Usuarios actualizados con rol en JWT';
    RAISE NOTICE '   Total usuarios: %', total_count;
    RAISE NOTICE '   Administradores: %', admin_count;
    RAISE NOTICE '   Managers: %', manager_count;
END $$;

-- ============================================================================
-- FIN DE SCRIPT
-- ============================================================================
