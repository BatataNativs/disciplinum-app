@echo off
REM Script para rodar code generation (build_runner)
REM Uso: scripts\run_codegen.bat [build|clean]

setlocal

set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=build

echo ========================================
echo Code Generation - %COMMAND%
echo ========================================

if "%COMMAND%"=="clean" (
    echo Limpando arquivos gerados...
    flutter pub run build_runner clean
) else if "%COMMAND%"=="build" (
    echo Gerando arquivos...
    flutter pub run build_runner build --delete-conflicting-outputs
) else if "%COMMAND%"=="watch" (
    echo Monitorando mudanças...
    flutter pub run build_runner watch --delete-conflicting-outputs
) else (
    echo Comando desconhecido: %COMMAND%
    echo Uso: scripts\run_codegen.bat [build|clean|watch]
    exit /b 1
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Code generation concluido com sucesso!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Code generation falhou!
    echo ========================================
    exit /b 1
)

endlocal
