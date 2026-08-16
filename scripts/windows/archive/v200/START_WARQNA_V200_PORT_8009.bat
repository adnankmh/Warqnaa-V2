@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa V0.4.4+200 - Port 8009
set "WARQNA_PORT=8009"
set "APP_URL=http://127.0.0.1:8009"
set "FRONTEND_URL=http://127.0.0.1:8009"
if not exist "backend-laravel\vendor\autoload.php" (
  where composer >nul 2>nul || (echo ERROR: Composer not found. Install Composer and run composer install in backend-laravel.& pause & exit /b 1)
  pushd backend-laravel
  call composer install --no-interaction
  popd
)
if not exist "backend-laravel\.env" copy /Y "backend-laravel\.env.example" "backend-laravel\.env" >nul
pushd backend-laravel
if not exist "storage\app\database.sqlite" (if not exist "database\database.sqlite" type nul > "database\database.sqlite")
php artisan key:generate --force >nul 2>nul
php artisan migrate --seed --force
start "Warqnaa Laravel 8009" cmd /k php artisan serve --host=127.0.0.1 --port=8009
popd
timeout /t 2 /nobreak >nul
start "" http://127.0.0.1:8009
echo Laravel: http://127.0.0.1:8009
echo Flutter API: http://127.0.0.1:8009/api/mobile/v1
echo To run Flutter Web use: flutter_app\RUN_FLUTTER_WEB.bat 8009
pause
