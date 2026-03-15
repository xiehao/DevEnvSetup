@echo off
cd /d "%~dp0"
:: 自动提权
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
:: 运行卸载脚本
powershell -NoProfile -ExecutionPolicy Bypass -File "Uninstall.ps1"