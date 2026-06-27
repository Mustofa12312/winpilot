@echo off
:: WinPilot Agent Startup Script
:: This script starts the WinPilot agent in the background

echo Starting WinPilot Agent...
start /b "" "%~dp0winpilot-agent.exe" -port 8080 > "%~dp0winpilot.log" 2>&1
echo WinPilot Agent is now running in the background.
echo You can close this window.
timeout /t 3 >nul
