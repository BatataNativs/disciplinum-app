@echo off
REM Script para limpar o projeto
REM Uso: scripts\clean_project.bat

setlocal

echo ========================================
echo Limpando projeto
echo ========================================

echo.
echo Limpando Flutter...
flutter clean

if %ERRORLEVEL% NEQ 0 (
    echo Falha ao limpar Flutter
    exit /b 1
)

echo.
echo Limpando code generation...
flutter pub run build_runner clean

echo.
echo Limpando cache do pub...
flutter pub cache repair

echo.
echo ========================================
echo Projeto limpo com sucesso!
echo ========================================
echo.
echo Proximos passos:
echo 1. flutter pub get
echo 2. scripts\run_codegen.bat build

endlocal
