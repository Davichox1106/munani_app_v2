# 📊 Scripts SQL - Munani (E-commerce de Barritas Nutritivas)

Scripts SQL organizados para la configuración de la base de datos en Supabase.

## 📂 Estructura de Archivos

```
sql/
├── 00_run_all.sql          🚀 Script maestro (ejecuta todo en orden)
├── 01_extensions.sql       ✅ Extensiones (uuid-ossp)
├── 02_tables.sql           ✅ Creación de tablas
├── 03_indexes.sql          ✅ Índices de optimización
├── 04_functions.sql        ✅ Funciones de base de datos
├── 05_triggers.sql         ✅ Triggers automáticos
├── 06_rls_policies.sql     ✅ Row Level Security (OWASP A01)
├── 99_test_data.sql        🧪 Datos de prueba (opcional)
└── README.md               📖 Este archivo
```

## 🚀 Orden de Ejecución

### Opción A: Todo de una vez (RECOMENDADO) ⚡

**Ejecutar un solo archivo con todo:**

1. Abre Supabase → SQL Editor
2. Copia **TODO** el contenido de `00_run_all.sql`
3. Pega en el editor
4. Click en **Run** (o Ctrl+Enter)
5. ✅ Verifica que no haya errores

**Ventajas:**
- ✅ Más rápido (1 clic)
- ✅ Garantiza orden correcto
- ✅ Incluye verificación automática al final

---

### Opción B: Paso a paso (MANUAL) 🔧

Ejecutar los scripts **EN ESTE ORDEN** en el SQL Editor de Supabase:

### 1️⃣ Extensiones (OBLIGATORIO)
```sql
-- Copiar y ejecutar: 01_extensions.sql
```
Habilita extensiones necesarias como `uuid-ossp`.

### 2️⃣ Tablas (OBLIGATORIO)
```sql
-- Copiar y ejecutar: 02_tables.sql
```
Crea la tabla `users` con todas sus columnas y constraints.

### 3️⃣ Índices (OBLIGATORIO)
```sql
-- Copiar y ejecutar: 03_indexes.sql
```
Crea índices para optimizar consultas frecuentes.

### 4️⃣ Funciones (OBLIGATORIO)
```sql
-- Copiar y ejecutar: 04_functions.sql
```
Crea funciones reutilizables:
- `update_updated_at_column()` - Actualiza timestamps
- `handle_new_user()` - Sincroniza auth.users con public.users
- `get_user_role()` - Obtiene rol de usuario
- `is_admin()` - Verifica si es admin

### 5️⃣ Triggers (OBLIGATORIO)
```sql
-- Copiar y ejecutar: 05_triggers.sql
```
Configura triggers automáticos:
- `update_users_updated_at` - Actualiza updated_at en cada UPDATE
- `on_auth_user_created` - Crea perfil al registrarse

### 6️⃣ Row Level Security (OBLIGATORIO)
```sql
-- Copiar y ejecutar: 06_rls_policies.sql
```
Implementa políticas de seguridad OWASP A01:
- Usuarios ven solo su información
- Admins ven todo
- Control de INSERT/UPDATE/DELETE por rol

### 7️⃣ Datos de Prueba (OPCIONAL)
```sql
-- Copiar y ejecutar: 99_test_data.sql
```
Crea usuarios de prueba para desarrollo.

## ✅ Verificación

Después de ejecutar todos los scripts, verifica:

### En SQL Editor:
```sql
-- Ver tablas creadas
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Ver políticas RLS
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Ver funciones
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public';
```

### En Dashboard:
1. **Table Editor** → Debe aparecer tabla `users`
2. **Database** → Policies → Debe mostrar 7 políticas
3. **SQL Editor** → Sin errores al ejecutar scripts

## 🔒 Seguridad (OWASP Top 10)

### A01: Broken Access Control ✅
- Row Level Security (RLS) habilitado
- Políticas por rol (admin, store_manager, warehouse_manager)
- Usuarios solo acceden a sus datos

### A02: Cryptographic Failures ✅
- HTTPS obligatorio en Supabase
- Contraseñas hasheadas por Supabase Auth
- Encriptación en tránsito y en reposo

### A03: Injection ✅
- Prepared statements (automático en Supabase)
- Validación de CHECK constraints
- Sin SQL dinámico inseguro

### A07: Identification and Authentication Failures ✅
- JWT tokens con expiración
- Trigger sincroniza auth.users con public.users
- Validación de roles en base de datos

## 🛠️ Comandos Útiles

### Deshabilitar RLS temporalmente (solo para debug):
```sql
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
```

### Volver a habilitar RLS:
```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
```

### Ver todos los triggers:
```sql
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

### Eliminar todas las políticas (CUIDADO):
```sql
DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "admins_select_all" ON public.users;
-- ... etc
```

## 📝 Notas Importantes

- ⚠️ **NUNCA** ejecutar `99_test_data.sql` en producción
- 🔐 Los scripts incluyen comentarios OWASP para auditoría
- 📊 Los índices mejoran performance pero ocupan espacio
- 🔄 Los triggers se ejecutan automáticamente, no requieren intervención
- 🛡️ RLS es la primera línea de defensa - no deshabilitarlo en producción

## 🐛 Troubleshooting

### Error: "extension uuid-ossp does not exist"
**Solución:** Ejecutar primero `01_extensions.sql`

### Error: "permission denied for schema public"
**Solución:** Verificar que estás usando el usuario correcto de Supabase

### Error: "function handle_new_user() does not exist"
**Solución:** Ejecutar `04_functions.sql` antes que `05_triggers.sql`

### Políticas RLS no funcionan
**Solución:** Verificar que RLS está habilitado con:
```sql
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'users';
```
El campo `rowsecurity` debe ser `true`.

## 📚 Referencias

- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/trigger-definition.html)
- [OWASP Top 10 2021](https://owasp.org/Top10/)

---

**Última actualización:** Octubre 2024
**Versión:** 1.0.0
**Proyecto:** Munani - E-commerce Offline-First de Barritas Nutritivas
