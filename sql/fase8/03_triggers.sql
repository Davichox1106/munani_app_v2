-- FASE 8 - TRIGGERS DE VENTAS

-- Generar sale_number
DROP TRIGGER IF EXISTS trg_sales_generate_number ON public.sales;
CREATE TRIGGER trg_sales_generate_number
BEFORE INSERT ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.generate_sale_number();

-- Recalcular totales al insertar/actualizar/eliminar items
DROP TRIGGER IF EXISTS trg_sale_items_recalc_ins ON public.sale_items;
CREATE TRIGGER trg_sale_items_recalc_ins
AFTER INSERT ON public.sale_items
FOR EACH ROW
EXECUTE FUNCTION public.recalculate_sale_totals();

DROP TRIGGER IF EXISTS trg_sale_items_recalc_upd ON public.sale_items;
CREATE TRIGGER trg_sale_items_recalc_upd
AFTER UPDATE ON public.sale_items
FOR EACH ROW
EXECUTE FUNCTION public.recalculate_sale_totals();

DROP TRIGGER IF EXISTS trg_sale_items_recalc_del ON public.sale_items;
CREATE TRIGGER trg_sale_items_recalc_del
AFTER DELETE ON public.sale_items
FOR EACH ROW
EXECUTE FUNCTION public.recalculate_sale_totals();

-- Aplicar venta a inventario cuando se marca completed
DROP TRIGGER IF EXISTS trg_sales_apply_inventory ON public.sales;
CREATE TRIGGER trg_sales_apply_inventory
AFTER UPDATE ON public.sales
FOR EACH ROW
WHEN (OLD.status <> 'completed' AND NEW.status = 'completed')
EXECUTE FUNCTION public.apply_sale_to_inventory();

-- Auditoría (historial de ventas)
-- NOTA: Los triggers de auditoría se crean en FASE 11
-- Ver: sql/fase11/01_sistema_de_auditoria.sql