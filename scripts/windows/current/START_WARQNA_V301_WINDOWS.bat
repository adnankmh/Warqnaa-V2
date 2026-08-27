@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0\..\..\.."
title Warqnaa V1.1.1 Build 301
set "WARQNA_PORT=8007"
if not "%~1"=="" set "WARQNA_PORT=%~1"
if not "%WARQNA_PORT%"=="8007" if not "%WARQNA_PORT%"=="8008" if not "%WARQNA_PORT%"=="8009" if not "%WARQNA_PORT%"=="8010" set "WARQNA_PORT=8007"

set "WARQNA_PHP="
where php >nul 2>nul && set "WARQNA_PHP=php"
if not defined WARQNA_PHP if exist "C:\xampp\php\php.exe" set "WARQNA_PHP=C:\xampp\php\php.exe"
if not defined WARQNA_PHP (
  echo ERROR: PHP not found. Install XAMPP or PHP 8.2+ once, then double-click this file again.
  pause
  exit /b 1
)

set "WARQNA_COMPOSER="
where composer >nul 2>nul && set "WARQNA_COMPOSER=composer"
if not defined WARQNA_COMPOSER if exist "C:\ProgramData\ComposerSetup\bin\composer.bat" set "WARQNA_COMPOSER=C:\ProgramData\ComposerSetup\bin\composer.bat"

if not exist "backend-laravel\vendor\autoload.php" (
  if not defined WARQNA_COMPOSER (
    echo ERROR: Composer is required only for the first run and was not found.
    echo Install Composer once, then run START_WARQNA_WINDOWS.bat again.
    pause
    exit /b 1
  )
  echo [1/7] Installing Laravel dependencies...
  pushd backend-laravel
  call "%WARQNA_COMPOSER%" install --prefer-dist --no-interaction --no-progress || (popd & pause & exit /b 1)
  popd
)

if not exist "backend-laravel\.env" (
  copy /Y "backend-laravel\.env.example" "backend-laravel\.env" >nul
  for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$chars='abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -join (1..24 ^| ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })"`) do set "WARQNA_LOCAL_ADMIN_PASSWORD=%%P"
  if not defined WARQNA_LOCAL_ADMIN_PASSWORD set "WARQNA_LOCAL_ADMIN_PASSWORD=LocalWarqnaa301ChangeMe"
  powershell -NoProfile -Command "$p='backend-laravel/.env'; $s=Get-Content $p -Raw; $s=$s -replace 'ADMIN_PASSWORD=CHANGE_ME_STRONG_ADMIN_PASSWORD','ADMIN_PASSWORD=!WARQNA_LOCAL_ADMIN_PASSWORD!'; Set-Content -Path $p -Value $s -Encoding UTF8"
  if not exist "backend-laravel\storage\app" mkdir "backend-laravel\storage\app"
  >"backend-laravel\storage\app\LOCAL_ADMIN_ACCESS.txt" echo Warqnaa local admin access
  >>"backend-laravel\storage\app\LOCAL_ADMIN_ACCESS.txt" echo Username: Adnan
  >>"backend-laravel\storage\app\LOCAL_ADMIN_ACCESS.txt" echo Email: admin@example.com
  >>"backend-laravel\storage\app\LOCAL_ADMIN_ACCESS.txt" echo Password: !WARQNA_LOCAL_ADMIN_PASSWORD!
)

pushd backend-laravel
if not exist "storage\framework\views" mkdir "storage\framework\views"
if not exist "storage\framework\cache\data" mkdir "storage\framework\cache\data"
if not exist "storage\framework\sessions" mkdir "storage\framework\sessions"
if not exist "storage\app" mkdir "storage\app"
if not exist "bootstrap\cache" mkdir "bootstrap\cache"
if not exist "database\database.sqlite" type nul > "database\database.sqlite"
findstr /B /C:"APP_KEY=base64:" .env >nul 2>nul || "%WARQNA_PHP%" artisan key:generate --force || (popd & pause & exit /b 1)
"%WARQNA_PHP%" artisan optimize:clear >nul 2>nul
"%WARQNA_PHP%" artisan migrate --seed --force || (popd & pause & exit /b 1)
"%WARQNA_PHP%" artisan storage:link >nul 2>nul
popd

start "Warqnaa Laravel B301" cmd /k "cd /d \"%CD%\backend-laravel\" && \"%WARQNA_PHP%\" artisan serve --host=127.0.0.1 --port=%WARQNA_PORT%"
timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:%WARQNA_PORT%"

echo.
echo ================================================
echo Warqnaa is running on http://127.0.0.1:%WARQNA_PORT%
echo ================================================
if exist "backend-laravel\storage\app\LOCAL_ADMIN_ACCESS.txt" (
  echo Local admin details are saved ONLY on this PC in:
  echo backend-laravel\storage\app\LOCAL_ADMIN_ACCESS.txt
)

where flutter >nul 2>nul
if not errorlevel 1 (
  echo Flutter detected. Starting Flutter Web automatically...
  start "Warqnaa Flutter B301" cmd /k "cd /d \"%CD%\flutter_app\" && flutter pub get && flutter run -d chrome --dart-define=WARQNA_API_URL=http://127.0.0.1:%WARQNA_PORT%/api/mobile/v1 --dart-define=WARQNA_APP_VERSION=1.1.1 --dart-define=WARQNA_APP_BUILD=301"
) else (
  echo Flutter is not installed on this PC; Laravel web is already running normally.
  echo APK/AAB/Web builds will still run in GitHub Actions.
)
exit /b 0
