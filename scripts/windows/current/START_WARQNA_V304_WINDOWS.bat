@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0\..\..\.."
title Warqnaa V1.3.0 Build 304 - VERTICAL LEGEND
set "WARQNA_PORT=8007"
if not "%~1"=="" set "WARQNA_PORT=%~1"
if not "%WARQNA_PORT%"=="8007" if not "%WARQNA_PORT%"=="8008" if not "%WARQNA_PORT%"=="8009" if not "%WARQNA_PORT%"=="8010" set "WARQNA_PORT=8007"
set "WARQNA_PHP="
where php >nul 2>nul && set "WARQNA_PHP=php"
if not defined WARQNA_PHP if exist "C:\xampp\php\php.exe" set "WARQNA_PHP=C:\xampp\php\php.exe"
if not defined WARQNA_PHP (echo ERROR: PHP not found. Install XAMPP or PHP 8.2+ once.& pause& exit /b 1)
set "WARQNA_COMPOSER="
where composer >nul 2>nul && set "WARQNA_COMPOSER=composer"
if not defined WARQNA_COMPOSER if exist "C:\ProgramData\ComposerSetup\bin\composer.bat" set "WARQNA_COMPOSER=C:\ProgramData\ComposerSetup\bin\composer.bat"
if not exist "backend-laravel\vendor\autoload.php" (
  if not defined WARQNA_COMPOSER (echo ERROR: Composer is required for first run.& pause& exit /b 1)
  pushd backend-laravel
  call "%WARQNA_COMPOSER%" install --prefer-dist --no-interaction --no-progress || (popd & pause & exit /b 1)
  popd
)
if not exist "backend-laravel\.env" copy /Y "backend-laravel\.env.example" "backend-laravel\.env" >nul
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
rem Load private administrator variables only from the ignored local file when present.
if exist ".warqnaa-admin.local.env" (
  for /f "usebackq tokens=1,* delims==" %%A in (".warqnaa-admin.local.env") do if not "%%A"=="" if not "%%A:~0,1"=="#" set "%%A=%%B"
  "%WARQNA_PHP%" artisan warqnaa:local-admin-setup --force || (popd & pause & exit /b 1)
) else (
  echo INFO: Private admin setup not installed. Use the separate DO_NOT_UPLOAD package for the agreed Adnan/Abd credentials.
)
"%WARQNA_PHP%" artisan storage:link >nul 2>nul
popd
start "Warqnaa Laravel B304" cmd /k "cd /d \"%CD%\backend-laravel\" && \"%WARQNA_PHP%\" artisan serve --host=127.0.0.1 --port=%WARQNA_PORT%"
timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:%WARQNA_PORT%"
where flutter >nul 2>nul
if not errorlevel 1 (
  start "Warqnaa Flutter B304" cmd /k "cd /d \"%CD%\flutter_app\" && flutter pub get && flutter run -d chrome --dart-define=WARQNA_API_URL=http://127.0.0.1:%WARQNA_PORT%/api/mobile/v1 --dart-define=WARQNA_APP_VERSION=1.3.0 --dart-define=WARQNA_APP_BUILD=304"
) else echo INFO: Flutter not installed locally; Laravel web is running and Flutter builds remain available in GitHub Actions.
echo Warqnaa B304 running at http://127.0.0.1:%WARQNA_PORT%
exit /b 0
