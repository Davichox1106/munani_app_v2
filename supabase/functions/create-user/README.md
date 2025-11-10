# Edge Function: create-user

Edge Function segura para crear usuarios usando Service Role Key.

## 🔐 Seguridad (OWASP)

- **A01: Broken Access Control** ✅
  - Verifica que el usuario esté autenticado
  - Verifica que el usuario sea admin antes de crear usuarios
  - Usa Service Role Key solo en el servidor

- **A02: Cryptographic Failures** ✅
  - Passwords se hashean en Supabase Auth (bcrypt)
  - Service Role Key solo en el servidor (no en cliente)
  - HTTPS obligatorio

- **A07: Authentication Failures** ✅
  - Email auto-confirmado para simplificar
  - JWT token validado en cada request

## 📝 Request

```json
POST /functions/v1/create-user
Authorization: Bearer <user-jwt-token>

{
  "email": "juan@example.com",
  "password": "Password123!",
  "name": "Juan Pérez",
  "role": "store_manager",
  "assignedLocationId": "uuid-tienda",
  "assignedLocationType": "store"
}
```

## ✅ Response Exitoso

```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "juan@example.com",
    "name": "Juan Pérez",
    "role": "store_manager",
    "assigned_location_id": "uuid-tienda",
    "assigned_location_type": "store",
    "is_active": true,
    "created_at": "2024-10-22T...",
    "updated_at": "2024-10-22T..."
  }
}
```

## ❌ Errores Posibles

- `401`: No autenticado
- `403`: No es admin
- `400`: Datos inválidos
- `500`: Error del servidor

## 🚀 Despliegue

1. Instalar Supabase CLI:
```bash
npm install -g supabase
```

2. Hacer login:
```bash
supabase login
```

3. Link al proyecto:
```bash
supabase link --project-ref bwhcjffaxfcdqimlmvvi
```

4. Desplegar la función:
```bash
supabase functions deploy create-user
```

5. Verificar:
```bash
supabase functions list
```

## 🧪 Testing Local

```bash
# Iniciar Edge Functions localmente
supabase start

# Desplegar localmente
supabase functions serve create-user

# Probar con curl
curl -X POST http://localhost:54321/functions/v1/create-user \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "name": "Test User",
    "role": "customer"
  }'
```

## 🔧 Variables de Entorno

Las variables se configuran automáticamente en Supabase:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

No necesitas configurarlas manualmente.

## 📚 Referencias

- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Deno Deploy](https://deno.com/deploy)

























