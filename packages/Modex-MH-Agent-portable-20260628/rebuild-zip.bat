@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0rebuild-zip.ps1"
pause
