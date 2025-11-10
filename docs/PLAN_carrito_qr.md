# Plan Implementación: Catálogo Cliente, Carrito y Pagos QR

## 1. Objetivo General
Transformar la experiencia del cliente para que:
- Visualice el inventario como un catálogo de productos (sin controles administrativos).
- Pueda crear un carrito, respetando el stock disponible.
- Realice el pago mediante un QR configurado por el gerente.
- Suba el comprobante para revisión; el gerente valida y descuenta inventario.

## 2. Cambios de Permisos y UI para Cliente
- Rol `customer`:
  - Vista estilo catálogo de productos.
  - Ocultar botones `+/-`, editar, eliminar, stock mínimo/máximo y costos extra.
  - Mostrar solo costo unitario y stock disponible.
- `PermissionHelper`/BLoC: bloquear acciones administrativas para clientes.

## 3. Carrito y Checkout
- **Entidades nuevas**:
  - `carts`: id, customer_id, status, location_id, created_at, updated_at.
  - `cart_items`: id, cart_id, inventory_id, quantity, unit_price_snapshot, image_urls_snapshot.
- **Estados del carrito/pedido**:
  - `pending`: carrito abierto.
  - `awaiting_payment`: cliente inicia checkout.
  - `payment_submitted`: comprobante cargado.
  - `payment_rejected`: gerente rechaza.
  - `completed`: pedido finalizado (stock descontado).
  - `cancelled`.
- Limitar cantidad al stock del inventario seleccionado.
- Checkout muestra:
  - QR de pago del store/warehouse.
  - Formulario para subir comprobante (imagen/pdf → Supabase Storage).
- Tras subida de comprobante, pedido queda en `payment_submitted`.

## 4. Configuración de QR por Gerentes
- Nuevos campos en:
  - `stores`: `payment_qr_url`, `payment_qr_description`.
  - `warehouses`: idem.
- Formularios (`StoreFormPage`, etc.) para subir/editar QR.
- Cliente ve QR en checkout según ubicación del inventario.

## 5. Flujo de Aprobación (Gerente)
- Vista “Pedidos pendientes” para roles manager/admin:
  - Listar pedidos `payment_submitted`.
  - Ver comprobante adjunto (descarga desde storage).
  - Botones `Aceptar`/`Rechazar`:
    - Al aceptar, descontar inventario (`inventory.quantity -= cart_item.quantity`).
    - Al rechazar, cambiar estado a `payment_rejected` y permitir comentarios (opcional).
- Registrar `completed_by` y timestamps en pedido.

## 6. Sincronización Offline-First
- Componentes a crear:
  - Modelos Isar (`CartLocalModel`, `CartItemLocalModel`).
  - Modelos remotos (`CartRemoteModel`, `CartItemRemoteModel`, `OrderRemoteModel` si se separa).
  - Repositorios + DataSources para offline-first (similar a inventario).
  - Nuevos tipos en `SyncEntityType` (`cart`, `cart_item`, `order`, `payment_receipt`).
- **Conectividad**:
  - Agregar al carrito puede funcionar offline.
  - Subir comprobante requiere internet → bloquear si no hay conexión o guardar en cola con reintento (evaluar).

## 7. SQL (nueva fase)
- Crear `fase10/01_tables.sql` con:
  - Tabla `carts`.
  - Tabla `cart_items`.
  - Tabla `orders` (opcional si no se usa `carts` directamente).
  - Tabla `payment_receipts` (cart_id, uploaded_by, storage_path, status, notes, created_at).
- Fixes:
  - `ADD_PAYMENT_QR_TO_LOCATIONS.sql`.
  - `ADD_CART_TABLES.sql` (si se entrega por fix separado).
  - `UPDATE_INVENTORY_IMAGE_URLS.sql` ya creado para fotos.

## 8. UI Cliente
- Página “Productos disponibles”:
  - Grid/lista similar a `ProductListPage` pero usando inventario.
  - Mostrar imagen, nombre, costo unitario, stock disponible.
- Página “Carrito”:
  - Lista de items con cantidad editable (no más que stock).
  - Botón `Proceder al pago`.
- Página “Pago/checkout”:
  - Mostrar QR, instrucciones, formulario de comprobante, botón `Enviar`.
- Página “Mis pedidos”:
  - Listar estado de cada compra.

## 9. UI Gerente/Admin
- “Pedidos pendientes”:
  - Lista con estado, cliente, ubicación, monto total.
  - Acceso al comprobante (preview).
  - Botones `Aceptar` / `Rechazar`.
- “Pedidos completados / historial”.

## 10. Consideraciones de Negocio / Auditoría
- Mantener historial de movimientos de inventario (opcional `inventory_movements`).
- Log de cambios en pedidos (timestamps, usuario).
- RLS/seguridad:
  - Clientes solo ven sus carritos/pedidos.
  - Gerentes ven pedidos de su store/warehouse.
- Notificaciones (opcional) al gerente cuando llega pedido.

## 11. Orden sugerido de implementación
1. Actualizar permisos y vista de inventario (cliente vs admin).
2. Añadir campos QR a stores/warehouses + UI.
3. Implementar lógica de carrito offline-first.
4. Implementar checkout y subida de comprobantes.
5. Implementar revisión de pedidos para gerentes (descuento inventario).
6. Ajustar `SyncRepository` para nuevas entidades.
7. Scripts SQL fase10 + fixes (aplicar en Supabase).
8. Tests manuales: flujo completo, límites de stock, desconexiones.

## 12. Pendientes/Decisiones
- Definir si manejo de comprobante offline (cola) o bloquear sin internet.
- Confirmar estados finales (¿necesario `shipped`/`delivered`?).
- Definir si se requiere factura o solo comprobante.
- Validar reactividad: actualizar vistas en vivo tras aprobar pedido.
  - Probablemente sí: streams de Isar + sync.
- Evaluar cron para limpiar carritos abandonados.

---

Este documento se actualizará a medida que concretemos cada componente. Ajusta/ordena prioridades según necesidades del negocio.








