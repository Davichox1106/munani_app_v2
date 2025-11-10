# 📦 FASE 4: Gestión de Inventario - Scripts SQL

## 📋 Descripción

Scripts SQL para crear la tabla `inventory` y configurar Row Level Security (RLS) para el control de inventario por ubicación (tiendas y almacenes).

---

## 🗂️ Archivos SQL

### **00_run_all.sql** - Script Maestro
Ejecuta todos los scripts de Fase 4 en orden correcto.

**Uso:**
```bash
# En Supabase Dashboard → SQL Editor
\i sql/fase4/00_run_all.sql
```

O copiar y pegar cada archivo individual en este orden:

---

### **01_inventory_table.sql** - Tabla Inventory
Crea la tabla `public.inventory` con:
- Relación a `product_variants`
- Relación a `stores` o `warehouses` (polimórfica)
- Control de cantidades (quantity, min_stock, max_stock)
- Auditoría (updated_by, last_updated)
- Constraint UNIQUE por ubicación

**Campos:**
```sql
id                  UUID PRIMARY KEY
product_variant_id  UUID NOT NULL
location_id         UUID NOT NULL
location_type       TEXT ('store' | 'warehouse')
quantity            INTEGER (>= 0)
min_stock           INTEGER (default: 5)
max_stock           INTEGER (default: 1000)
last_updated        TIMESTAMPTZ
updated_by          UUID (FK → users)
```

---

### **02_inventory_indexes.sql** - Índices
Crea 7 índices para optimizar queries:
- `idx_inventory_product_variant` - Búsquedas por producto
- `idx_inventory_location` - Filtrar por ubicación
- `idx_inventory_location_type` - Filtrar por tipo
- `idx_inventory_location_full` - Compuesto (ubicación completa)
- `idx_inventory_low_stock` - Alertas de stock bajo
- `idx_inventory_updated_by` - Auditoría
- `idx_inventory_last_updated` - Ordenar por recientes

---

### **03_inventory_triggers.sql** - Triggers
Crea 2 triggers:
1. **inventory_update_timestamp**
   - Actualiza `last_updated` automáticamente
   - Se ejecuta BEFORE UPDATE

2. **inventory_validate_stock**
   - Valida que `quantity >= 0`
   - Valida que `min_stock < max_stock`
   - Se ejecuta BEFORE INSERT/UPDATE

---

### **04_inventory_rls.sql** - Row Level Security
Crea 6 políticas RLS:

#### **SELECT:**
- `admins_select_all_inventory` → Admins ven todo
- `store_managers_select_own_inventory` → Store managers ven inventario de tiendas
- `warehouse_managers_select_own_inventory` → Warehouse managers ven inventario de almacenes

#### **INSERT:**
- `admins_managers_insert_inventory` → Admins y managers pueden crear

#### **UPDATE:**
- `admins_managers_update_inventory` → Admins todo, managers su tipo

#### **DELETE:**
- `admins_delete_inventory` → Solo admins

---

## 🔐 Seguridad (OWASP)

### **A01:2021 - Broken Access Control**
✅ RLS habilitado en tabla `inventory`
✅ Políticas por rol (admin, store_manager, warehouse_manager)
✅ Managers solo ven/modifican su tipo de ubicación

### **A03:2021 - Injection**
✅ Prepared statements nativos de PostgreSQL
✅ CHECK constraints para validar datos

### **A04:2021 - Insecure Design**
✅ Validación de cantidades (no negativas)
✅ Validación de min_stock < max_stock

### **A09:2021 - Security Logging**
✅ Campo `updated_by` para auditoría
✅ Campo `last_updated` para tracking

---

## 📊 Relaciones

```
inventory
├── product_variant_id → product_variants.id (CASCADE)
├── location_id → stores.id | warehouses.id (NO FK directo, polimórfico)
└── updated_by → users.id (RESTRICT)
```

**NOTA:** `location_id` es polimórfico, por lo que NO tiene FK directo. Se valida en la aplicación.

---

## 🧪 Verificación

Después de ejecutar los scripts, verifica:

```sql
-- 1. Tabla creada
SELECT * FROM pg_tables WHERE tablename = 'inventory';

-- 2. RLS habilitado
SELECT rowsecurity FROM pg_tables WHERE tablename = 'inventory';

-- 3. Políticas RLS (debe mostrar 6)
SELECT COUNT(*) FROM pg_policies WHERE tablename = 'inventory';

-- 4. Índices (debe mostrar 7)
SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'inventory';

-- 5. Triggers (debe mostrar 2)
SELECT COUNT(*) FROM pg_trigger 
WHERE tgrelid = 'public.inventory'::regclass 
AND tgname NOT LIKE 'RI_%';
```

---

## 🚀 Próximos Pasos

1. ✅ **SQL completado**
2. ⏳ **Crear modelos Isar (Flutter)**
3. ⏳ **Implementar InventoryBloc**
4. ⏳ **Crear pantallas de inventario**
5. ⏳ **Probar sincronización offline**

---

## 📝 Notas Importantes

1. **Polimorfismo de location_id:**
   - No usa FK directo porque puede apuntar a `stores` O `warehouses`
   - Validación en capa de aplicación

2. **Alertas de Stock Bajo:**
   - Índice optimizado: `WHERE quantity <= min_stock`
   - Query eficiente para dashboard

3. **Auditoría:**
   - Registra QUIÉN modificó el inventario
   - Registra CUÁNDO se modificó

4. **Constraint UNIQUE:**
   - Evita duplicados por variante y ubicación
   - `(product_variant_id, location_id, location_type)`

---

**Fecha de creación:** 20 de Octubre 2024
**Estado:** ✅ COMPLETADO

































