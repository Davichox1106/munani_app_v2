-- ============================================================================
-- 04_functions.sql
-- Funciones de base de datos
-- ============================================================================
-- Funciones reutilizables para lógica de negocio
-- ============================================================================

-- ============================================================================
-- FUNCIÓN: update_updated_at_column
-- Descripción: Actualiza automáticamente el campo updated_at
-- Uso: Se ejecuta mediante trigger BEFORE UPDATE
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Actualiza automáticamente el campo updated_at al modificar un registro';

-- ============================================================================
-- FUNCIÓN: handle_new_user
-- Descripción: Crea automáticamente un registro en public.users cuando
--              se registra un nuevo usuario en auth.users
-- OWASP A07:2021 - Identification and Authentication Failures
-- Asegura que cada usuario autenticado tenga un perfil en la BD
-- ACTUALIZACIÓN: Agrega rol Y assigned_location_id al JWT (app_metadata)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  user_role TEXT;
  user_assigned_location_id TEXT;
  user_assigned_location_type TEXT;
BEGIN
  -- Obtener datos del metadata
  user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'store_manager');
  user_assigned_location_id := NEW.raw_user_meta_data->>'assigned_location_id';
  user_assigned_location_type := NEW.raw_user_meta_data->>'assigned_location_type';

  -- Insertar en public.users
  INSERT INTO public.users (
    id,
    email,
    name,
    role,
    assigned_location_id,
    assigned_location_type
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Usuario'),
    user_role,
    CASE WHEN user_assigned_location_id IS NOT NULL THEN user_assigned_location_id::uuid ELSE NULL END,
    user_assigned_location_type
  );

  -- Agregar rol Y assigned_location_id al app_metadata para JWT
  -- Esto permite que las políticas RLS de transfers funcionen correctamente
  NEW.raw_app_meta_data :=
    COALESCE(NEW.raw_app_meta_data, '{}'::jsonb) ||
    jsonb_build_object(
      'user_role', user_role,
      'assigned_location_id', user_assigned_location_id,
      'assigned_location_type', user_assigned_location_type
    );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.handle_new_user() IS 'Crea perfil en public.users y agrega rol + assigned_location_id al JWT';

-- ============================================================================
-- FUNCIÓN: get_user_role
-- Descripción: Obtiene el rol de un usuario por su ID
-- Uso: Útil para verificaciones de permisos
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS VARCHAR(50) AS $$
DECLARE
    user_role VARCHAR(50);
BEGIN
    SELECT role INTO user_role
    FROM public.users
    WHERE id = user_id;

    RETURN user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.get_user_role(UUID) IS 'Obtiene el rol de un usuario por su ID';

-- ============================================================================
-- FUNCIÓN: is_admin
-- Descripción: Verifica si el usuario actual es administrador
-- Uso: Útil para políticas RLS y validaciones
-- SEGURIDAD: Lee de app_metadata (solo el servidor puede modificarlo)
-- PRODUCCIÓN: SECURITY DEFINER asegura permisos correctos
-- ACTUALIZACIÓN: Usa JWT app_metadata en lugar de SELECT para evitar recursión
-- ============================================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        current_setting('request.jwt.claims', true)::json->'app_metadata'->>'user_role'
    ) = 'admin';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION public.is_admin() IS 'Verifica si el usuario autenticado es administrador (lee de app_metadata - SEGURO)';

-- ============================================================================
-- FUNCIÓN: update_user_assigned_location_name
-- Descripción: Actualiza automáticamente assigned_location_name cuando cambia
--              assigned_location_id o assigned_location_type
-- Uso: Se ejecuta mediante trigger BEFORE UPDATE
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_user_assigned_location_name()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se actualiza assigned_location_id o assigned_location_type
    IF (TG_OP = 'UPDATE' AND (
        OLD.assigned_location_id IS DISTINCT FROM NEW.assigned_location_id OR
        OLD.assigned_location_type IS DISTINCT FROM NEW.assigned_location_type
    )) THEN
        -- Actualizar con el nombre de la nueva ubicación
        IF NEW.assigned_location_type = 'store' THEN
            SELECT name INTO NEW.assigned_location_name
            FROM public.stores
            WHERE id = NEW.assigned_location_id;
        ELSIF NEW.assigned_location_type = 'warehouse' THEN
            SELECT name INTO NEW.assigned_location_name
            FROM public.warehouses
            WHERE id = NEW.assigned_location_id;
        ELSE
            NEW.assigned_location_name = NULL;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.update_user_assigned_location_name() IS 'Actualiza automáticamente assigned_location_name cuando cambia la ubicación asignada';