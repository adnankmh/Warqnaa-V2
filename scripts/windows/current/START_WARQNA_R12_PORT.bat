@echo off
setlocal EnableExtensions
set "R12_PORT=%~1"
if "%R12_PORT%"=="" set "R12_PORT=8007"
if not "%R12_PORT%"=="8007" if not "%R12_PORT%"=="8008" if not "%R12_PORT%"=="8009" if not "%R12_PORT%"=="8010" (
  echo ERROR: R12 supports local ports 8007, 8008, 8009 or 8010.
  exit /b 2
)
cd /d "%~dp0\..\..\.."
title Warqnaa R12 Competitive Arena - Port %R12_PORT%
set "WARQNA_PORT=%R12_PORT%"
set "APP_URL=http://127.0.0.1:%R12_PORT%"
set "FRONTEND_URL=http://127.0.0.1:%R12_PORT%"
where php >nul 2>nul || (echo ERROR: PHP not found. Start XAMPP or add PHP to PATH.& pause & exit /b 1)
if not exist "backend-laravel\vendor\autoload.php" (
  where composer >nul 2>nul || (echo ERROR: Composer not found. Install Composer, then run this file again.& pause & exit /b 1)
  pushd backend-laravel
  call composer install --prefer-dist --no-interaction --no-progress || (popd & pause & exit /b 1)
  popd
)
if not exist "backend-laravel\.env" copy /Y "backend-laravel\.env.example" "backend-laravel\.env" >nul
pushd backend-laravel
if not exist "storage\framework\views" mkdir "storage\framework\views"
if not exist "storage\framework\cache\data" mkdir "storage\framework\cache\data"
if not exist "storage\framework\sessions" mkdir "storage\framework\sessions"
if not exist "bootstrap\cache" mkdir "bootstrap\cache"
if not exist "database\database.sqlite" type nul > "database\database.sqlite"
findstr /B /C:"APP_KEY=base64:" .env >nul 2>nul || php artisan key:generate --force || (popd & pause & exit /b 1)
php artisan optimize:clear >nul 2>nul
php artisan migrate --force || (popd & pause & exit /b 1)
start "Warqnaa R12 Laravel %R12_PORT%" cmd /k php artisan serve --host=127.0.0.1 --port=%R12_PORT%
popd
timeout /t 2 /nobreak >nul
start "" http://127.0.0.1:%R12_PORT%/competitive
echo.
echo Warqnaa R12 Competitive Arena 0.7.0+240 is running:
echo   Website:          http://127.0.0.1:%R12_PORT%
echo   Competitive:      http://127.0.0.1:%R12_PORT%/competitive
echo   Social World:     http://127.0.0.1:%R12_PORT%/social-world
echo   Mobile API:       http://127.0.0.1:%R12_PORT%/api/mobile/v1
echo   Competitive tick: php artisan warqna:competitive-tick --dry-run
echo.
pause
