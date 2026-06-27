@echo off
:: WinPilot Agent - Windows Service Uninstaller
:: Run this script as Administrator

echo Uninstalling WinPilot Agent Windows Service...

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges confirmed.
) else (
    echo WARNING: You must run this script as Administrator.
    echo Right-click the file and select "Run as administrator".
    pause
    exit /b 1
)

set SERVICE_NAME=WinPilotAgent

echo Stopping service %SERVICE_NAME%...
sc stop %SERVICE_NAME% >nul 2>&1
timeout /t 2 >nul

echo Deleting service %SERVICE_NAME%...
sc delete %SERVICE_NAME%

if %errorLevel% == 0 (
    echo.
    echo Service successfully removed! WinPilot Agent will no longer start automatically.
) else (
    echo Failed to remove the service. It might not be installed.
)

pause
