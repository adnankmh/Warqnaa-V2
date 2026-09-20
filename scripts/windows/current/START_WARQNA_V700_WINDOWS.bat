@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R7 Build 700
if exist "install-settings.local.json" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "scripts\windows\current\Start-Warqnaa.ps1"
  exit /b
)
set "WARQNA_PORT=8007"
if not "%~1"=="" set "WARQNA_PORT=%~1"
if not "%WARQNA_PORT%"=="8007" if not "%WARQNA_PORT%"=="8008" if not "%WARQNA_PORT%"=="8009" if not "%WARQNA_PORT%"=="8010" set "WARQNA_PORT=8007"
set "WARQNA_PHP="
where php >nul 2>nul && set "WARQNA_PHP=php"
if not defined WARQNA_PHP if exist "C:\xampp\php\php.exe" set "WARQNA_PHP=C:\xampp\php\php.exe"
if not defined WARQNA_PHP (echo ERROR: PHP 8.2+ was not found.& pause& exit /b 1)
if not exist "backend-laravel\.env" copy /Y "backend-laravel\.env.example" "backend-laravel\.env" >nul
if not exist "backend-laravel\vendor\autoload.php" (echo ERROR: Run composer install inside backend-laravel first.& pause& exit /b 1)
pushd backend-laravel
if not exist "database\database.sqlite" type nul > "database\database.sqlite"
findstr /B /C:"APP_KEY=base64:" .env >nul 2>nul || "%WARQNA_PHP%" artisan key:generate --force || (popd & pause & exit /b 1)
"%WARQNA_PHP%" artisan optimize:clear >nul 2>nul
"%WARQNA_PHP%" artisan migrate --seed --force || (popd & pause & exit /b 1)
popd
start "Warqnaa Laravel R7" cmd /k "cd /d \"%CD%\backend-laravel\" && \"%WARQNA_PHP%\" artisan serve --host=127.0.0.1 --port=%WARQNA_PORT%"
timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:%WARQNA_PORT%"
where flutter >nul 2>nul
if not errorlevel 1 start "Warqnaa Flutter R7" cmd /k "cd /d \"%CD%\flutter_app\" && flutter pub get && flutter run -d chrome --dart-define=WARQNA_API_URL=http://127.0.0.1:%WARQNA_PORT%/api/mobile/v1 --dart-define=WARQNA_APP_VERSION=1.8.0 --dart-define=WARQNA_APP_BUILD=700"
echo Warqnaa R7 running at http://127.0.0.1:%WARQNA_PORT%
exit /b 0
