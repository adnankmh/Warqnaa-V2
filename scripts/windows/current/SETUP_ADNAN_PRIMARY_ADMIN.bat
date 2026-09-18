@echo off
setlocal
cd /d "%~dp0\..\..\..\backend-laravel"
echo ============================================
echo WARQNAA - SETUP ADNAN PRIMARY ADMIN
echo ============================================
php artisan optimize:clear
if errorlevel 1 goto fail
powershell -NoProfile -ExecutionPolicy Bypass -Command "$mail=Read-Host 'Admin email'; $secure=Read-Host 'Admin password (hidden)' -AsSecureString; $ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure); try { $plain=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr); $env:WARQNAA_ADNAN_ADMIN_EMAIL=$mail; $env:WARQNAA_ADNAN_ADMIN_PASSWORD=$plain; php artisan warqnaa:setup-adnan-admin --force; exit $LASTEXITCODE } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr); Remove-Item Env:WARQNAA_ADNAN_ADMIN_PASSWORD -ErrorAction SilentlyContinue }"
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
