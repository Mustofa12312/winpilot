@echo off
:: WinPilot Agent Shutdown Script
:: This script stops the background WinPilot agent process

echo Stopping WinPilot Agent...
taskkill /F /IM winpilot-agent.exe /T >nul 2>&1
echo WinPilot Agent has been stopped.
timeout /t 3 >nul
