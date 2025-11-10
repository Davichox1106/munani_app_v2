# Pasos posteriores a migraciones SQL: despliegue de `create-user`

Ejecuta estas instrucciones después de aplicar todos los scripts SQL para habilitar la función Edge `create-user` en Supabase.

> **Requisitos**
> - Node.js 16 o superior.
> - Acceso a la CLI de Supabase (usaremos `npx supabase`).
> - Rol **Owner** del proyecto donde se va a desplegar la función.

## 1. Navegar al proyecto

```bash
cd D:/Informes_y_Documentos/Maestria_FullStack_Development/Desarrollo\ de\ avanzado\ de\ aplicaciones\ moviles/Proyectos/munani_app_v2
```

## 2. (Opcional) Cerrar sesión previa

```bash
npx supabase logout
```

Si aparece “You were not logged in, nothing to do”, continúa.

## 3. Iniciar sesión en la CLI

```bash
npx supabase login
```

Completa el proceso desde el navegador o con el código de verificación hasta que veas “You are now logged in”.

## 4. Verificar proyectos disponibles

```bash
npx supabase projects list
```

Confirma que `wntpvekmtajzwjncmwgr` (nombre `Munani`) esté en la lista.

## 5. Enlazar carpeta local con el proyecto

```bash
npx supabase link --project-ref wntpvekmtajzwjncmwgr
```

Si pide la contraseña de la base de datos, está en Supabase Dashboard → **Settings → Database → Connection info**.

## 6. Desplegar la función `create-user`

Desde la **raíz** del repositorio:

```bash
npx supabase functions deploy create-user
```

Ignora la advertencia sobre Docker si no usas funciones en modo local.

## 7. Verificar

- En Supabase Dashboard → **Edge Functions**, asegúrate de que `create-user` aparezca activa.
- Desde la app, vuelve a crear un usuario en la pantalla de gestión para confirmar que ya no aparece el error 404.

---

### 8. Nuevas tablas y fixes (Fase 10)

Tras ejecutar los pasos anteriores, aplica las migraciones del carrito y pagos:

```sql
\i sql/fase10/01_tables.sql
\i sql/fixes/ADD_PAYMENT_QR_TO_LOCATIONS.sql
\i sql/fixes/UPDATE_INVENTORY_IMAGE_URLS.sql
```

Esto creará las tablas `carts`, `cart_items`, `payment_receipts` y añadirá los campos de QR en tiendas/almacenes, además de rellenar imágenes faltantes en inventario.

### Troubleshooting

- **403 “privileges”**: tu cuenta en el proyecto no tiene rol Owner. Revisa en Settings → Team.
- **404 “Function not found”**: la función no fue desplegada o estás apuntando al proyecto equivocado.
- **Error de ruta**: si el deploy se hace dentro de la carpeta `supabase/`, moverás la ruta y fallará. Ejecuta el comando desde la raíz del repo.

