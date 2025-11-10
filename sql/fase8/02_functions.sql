-- FASE 8 - FUNCIONES DE VENTAS

-- Generar correlativo de número de venta: SAL-YYYY-XXXX
CREATE OR REPLACE FUNCTION public.generate_sale_number()
RETURNS trigger AS $$
DECLARE
  year_part text := to_char(now(), 'YYYY');
  seq int;
BEGIN
  IF NEW.sale_number IS NOT NULL THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(MAX(split_part(sale_number, '-', 3)::int), 0) + 1 INTO seq
  FROM public.sales
  WHERE split_part(sale_number, '-', 2) = year_part;

  NEW.sale_number := format('SAL-%s-%04s', year_part, seq::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recalcular totales de venta a partir de items (trigger)
CREATE OR REPLACE FUNCTION public.recalculate_sale_totals()
RETURNS trigger AS $$
DECLARE
  v_sale_id uuid;
  v_subtotal numeric(12,2);
  v_tax numeric(12,2);
  v_total numeric(12,2);
BEGIN
  v_sale_id := COALESCE(NEW.sale_id, OLD.sale_id);

  SELECT COALESCE(SUM(subtotal), 0.00) INTO v_subtotal
  FROM public.sale_items WHERE sale_id = v_sale_id;

  -- IVA 15% como ejemplo (ajustable según negocio)
  v_tax := round(v_subtotal * 0.15, 2);
  v_total := v_subtotal + v_tax;

  UPDATE public.sales
  SET subtotal = v_subtotal,
      tax = v_tax,
      total = v_total,
      updated_at = now()
  WHERE id = v_sale_id;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar venta a inventario (salida de stock) - trigger
CREATE OR REPLACE FUNCTION public.apply_sale_to_inventory()
RETURNS trigger AS $$
DECLARE
  r_item RECORD;
  inv_id uuid;
  new_quantity integer;
  new_unit_cost numeric(10,2);
  new_total_cost numeric(12,2);
  old_q integer;
  old_uc numeric(10,2);
BEGIN
  -- Solo aplicar cuando el estado cambia a completed
  IF NOT (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'completed') THEN
    RETURN NEW;
  END IF;

  FOR r_item IN SELECT * FROM public.sale_items WHERE sale_id = NEW.id LOOP
    SELECT id INTO inv_id
    FROM public.inventory
    WHERE product_variant_id = r_item.product_variant_id
      AND location_id = NEW.location_id
      AND location_type = NEW.location_type;

    IF inv_id IS NOT NULL THEN
      SELECT quantity, unit_cost INTO old_q, old_uc
      FROM public.inventory
      WHERE id = inv_id;

      SELECT 
          (old_q * old_uc + r_item.quantity * r_item.unit_cost) / NULLIF((old_q + r_item.quantity), 0),
          old_q + r_item.quantity
      INTO new_unit_cost, new_quantity;

      new_total_cost := new_quantity * COALESCE(new_unit_cost, old_uc);

      UPDATE public.inventory
      SET quantity = new_quantity,
          unit_cost = COALESCE(new_unit_cost, unit_cost),
          total_cost = COALESCE(new_total_cost, total_cost),
          last_cost = r_item.unit_cost,
          last_updated = now(),
          cost_updated_at = now(),
          updated_by = auth.uid()
      WHERE id = inv_id;
    ELSE
      new_quantity := r_item.quantity;
      new_unit_cost := r_item.unit_cost;
      new_total_cost := new_quantity * new_unit_cost;

      INSERT INTO public.inventory (
        product_variant_id,
        location_id,
        location_type,
        quantity,
        unit_cost,
        total_cost,
        last_cost,
        last_updated,
        cost_updated_at,
        updated_by
      ) VALUES (
        r_item.product_variant_id,
        NEW.location_id,
        NEW.location_type,
        new_quantity,
        new_unit_cost,
        new_total_cost,
        r_item.unit_cost,
        now(),
        now(),
        auth.uid()
      );
    END IF;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
