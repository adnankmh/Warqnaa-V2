@echo off
setlocal
cd /d "%~dp0\..\..\.."
where python >nul 2>nul || (echo ERROR: Python not found.& exit /b 1)
python tools\clean_stale_flutter_v304.py
