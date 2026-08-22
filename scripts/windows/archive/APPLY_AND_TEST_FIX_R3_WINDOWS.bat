@echo off
setlocal
cd /d "%~dp0"

if not exist "backend-laravel\artisan" (
  echo [ERROR] Put/extract this hotfix in the Warqnaa project root.
  echo Expected: backend-laravel\artisan
  pause
  exit /b 1
)

cd backend-laravel
if not exist "storage\framework\views" mkdir "storage\framework\views"
if not exist "storage\framework\cache\data" mkdir "storage\framework\cache\data"
if not exist "storage\framework\sessions" mkdir "storage\framework\sessions"
if not exist "bootstrap\cache" mkdir "bootstrap\cache"

echo [1/4] Clearing Laravel caches...
php artisan optimize:clear
if errorlevel 1 goto :fail

echo [2/4] Clearing compiled views...
php artisan view:clear
if errorlevel 1 goto :fail

echo [3/4] Running Laravel tests...
php artisan test
if errorlevel 1 goto :fail

echo [4/4] Production preflight...
php artisan warqna:production-check
if errorlevel 1 goto :fail

echo.
echo ========================================
echo HOTFIX R3: PASS
 echo ========================================
pause
exit /b 0

:fail
echo.
echo ========================================
echo HOTFIX R3: FAILED - copy the full output
 echo ========================================
pause
exit /b 1
