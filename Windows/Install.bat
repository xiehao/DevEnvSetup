@echo off
:: Move to the directory where the script is located
cd /d "%~dp0"

:: Check for Administrator privileges
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ===========================================
echo   Starting Environment Setup Launcher
echo ===========================================

:: Check if Install.ps1 exists
if not exist "Install.ps1" (
    echo [ERROR] Install.ps1 not found in: %cd%
    pause
    exit /b
)

:: Run PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "Install.ps1"

:: If the PowerShell script crashes, keep the window open
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] The setup process encountered an error (Exit Code: %errorlevel%)
    pause
)