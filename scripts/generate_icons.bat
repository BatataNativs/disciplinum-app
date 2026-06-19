@echo off
REM Script para gerar ícones do app
REM Uso: scripts\generate_icons.bat

setlocal

echo ========================================
echo Gerando ícones do app
echo ========================================

REM Verifica se flutter_launcher_icons está instalado
echo Verificando dependencias...
flutter pub deps | findstr flutter_launcher_icons >nul
if %ERRORLEVEL% NEQ 0 (
    echo flutter_launcher_icons não encontrado. Instalando...
    flutter pub add flutter_launcher_icons
)

echo.
echo Gerando ícones...
flutter pub run flutter_launcher_icons

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Ícones gerados com sucesso!
    echo ========================================
    echo.
    echo Ícones gerados em:
    echo - android/app/src/main/res/
    echo - ios/Runner/Assets.xcassets/
) else (
    echo.
    echo ========================================
    echo Falha ao gerar ícones!
    echo ========================================
    exit /b 1
)

endlocal
