@echo off
REM Script para build Android APK
REM Uso: scripts\build_android.bat [release|debug]

setlocal

set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=release

echo ========================================
echo Build Android APK - %BUILD_TYPE%
echo ========================================

if "%BUILD_TYPE%"=="release" (
    echo Building RELEASE APK...
    flutter build apk --release
) else (
    echo Building DEBUG APK...
    flutter build apk --debug
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build concluido com sucesso!
    echo ========================================
    echo.
    if "%BUILD_TYPE%"=="release" (
        echo APK localizado em: build\app\outputs\flutter-apk\app-release.apk
    ) else (
        echo APK localizado em: build\app\outputs\flutter-apk\app-debug.apk
    )
) else (
    echo.
    echo ========================================
    echo Build falhou!
    echo ========================================
    exit /b 1
)

endlocal
