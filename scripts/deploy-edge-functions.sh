#!/bin/bash

# ============================================================================
# Script: Desplegar Edge Functions a Supabase
# ============================================================================

set -e  # Salir si hay error

echo "🚀 Desplegando Edge Functions a Supabase..."
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si Supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI no está instalado${NC}"
    echo ""
    echo "Instálalo con:"
    echo "  npm install -g supabase"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Supabase CLI encontrado${NC}"
echo ""

# Verificar si está logueado
echo "🔐 Verificando autenticación..."
if ! supabase projects list &> /dev/null; then
    echo -e "${RED}❌ No estás logueado en Supabase${NC}"
    echo ""
    echo "Ejecuta:"
    echo "  supabase login"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Autenticado correctamente${NC}"
echo ""

# Desplegar función create-user
echo "📦 Desplegando función 'create-user'..."
supabase functions deploy create-user --project-ref bwhcjffaxfcdqimlmvvi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Función 'create-user' desplegada correctamente${NC}"
else
    echo -e "${RED}❌ Error al desplegar 'create-user'${NC}"
    exit 1
fi

echo ""
echo "🎉 ¡Despliegue completado!"
echo ""
echo "📝 Próximos pasos:"
echo "  1. Verifica la función en: https://supabase.com/dashboard/project/bwhcjffaxfcdqimlmvvi/functions"
echo "  2. Prueba la función desde tu app Flutter"
echo "  3. Revisa los logs si hay errores"
echo ""

























