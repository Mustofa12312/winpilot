@echo off
:: WinPilot Agent - Windows Service Installer
:: Run this script as Administrator

echo Installing WinPilot Agent as a Windows Service...

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

:: Define service name and binary path
set SERVICE_NAME=WinPilotAgent
set BINARY_PATH=%~dp0winpilot-agent.exe

:: Check if binary exists
if not exist "%BINARY_PATH%" (
    echo ERROR: Could not find winpilot-agent.exe in %~dp0
    pause
    exit /b 1
)

:: Stop existing service if any
sc stop %SERVICE_NAME% >nul 2>&1

:: Create the service
echo Creating service %SERVICE_NAME%...
sc create %SERVICE_NAME% binPath= "%BINARY_PATH% -service" start= auto obj= LocalSystem

if %errorLevel% == 0 (
    echo Service successfully installed.
    echo Configuring recovery options...
    sc failure %SERVICE_NAME% reset= 86400 actions= restart/60000/restart/60000/restart/60000
    
    echo Starting the service...
    sc start %SERVICE_NAME%
    
    echo.
    echo WinPilot Agent is now running as a background Windows Service!
    echo It will automatically start whenever your PC turns on.
) else (
    echo Failed to install the service.
)

pause
