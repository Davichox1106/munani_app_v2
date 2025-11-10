@echo off
REM ============================================================================
REM Script: Desplegar Edge Functions a Supabase (Windows)
REM ============================================================================

echo Desplegando Edge Functions a Supabase...
echo.

REM Verificar si Supabase CLI esta instalado
where supabase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Supabase CLI no esta instalado
    echo.
    echo Instalalo con:
    echo   npm install -g supabase
    echo.
    exit /b 1
)

echo [OK] Supabase CLI encontrado
echo.

REM Verificar si esta logueado
echo Verificando autenticacion...
supabase projects list >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No estas logueado en Supabase
    echo.
    echo Ejecuta:
    echo   supabase login
    echo.
    exit /b 1
)

echo [OK] Autenticado correctamente
echo.

REM Desplegar funcion create-user
echo Desplegando funcion 'create-user'...
supabase functions deploy create-user --project-ref bwhcjffaxfcdqimlmvvi

if %ERRORLEVEL% EQU 0 (
    echo [OK] Funcion 'create-user' desplegada correctamente
) else (
    echo ERROR: Error al desplegar 'create-user'
    exit /b 1
)

echo.
echo Despliegue completado!
echo.
echo Proximos pasos:
echo   1. Verifica la funcion en: https://supabase.com/dashboard/project/bwhcjffaxfcdqimlmvvi/functions
echo   2. Prueba la funcion desde tu app Flutter
echo   3. Revisa los logs si hay errores
echo.

























