@echo off
setlocal
cd /d "%~dp0\..\..\..\backend-laravel"
echo ============================================
echo WARQNAA - SETUP ADNAN PRIMARY ADMIN
echo ============================================
php artisan optimize:clear
if errorlevel 1 goto fail
php artisan warqnaa:setup-adnan-admin --force
if errorlevel 1 goto fail
echo.
echo SUCCESS - Adnan primary admin is ready.
pause
exit /b 0
:fail
echo.
echo ERROR - setup failed. Read the message above.
pause
exit /b 1
