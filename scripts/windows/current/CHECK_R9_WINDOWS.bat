@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R9 Full Check
python tools\verify_release_versions.py || goto :fail
python tools\test_v208_r8_contract.py || goto :fail
python tools\test_v209_r9_contract.py || goto :fail
python tools\r9_asset_audit.py
python tools\r9_translation_audit.py || goto :fail
python tools\validate_release.py || goto :fail
php backend-laravel\tools\test-v208-r8-rules.php || goto :fail
set WARQNA_STRESS_ITERATIONS=40
php backend-laravel\tools\test-v184-engine-stress.php || goto :fail
set WARQNA_PLAYTHROUGH_RUNS=4
set WARQNA_PLAYTHROUGH_STEPS=80
php backend-laravel\tools\test-v208-r8-playthrough-stress.php || goto :fail
if exist backend-laravel\vendor\autoload.php (
  pushd backend-laravel
  php artisan optimize:clear >nul 2>nul
  php artisan test || (popd & goto :fail)
  popd
) else echo [INFO] Laravel PHPUnit will run in GitHub CI.
echo.
echo [PASS] WARQNAA R9 CHECK COMPLETED SUCCESSFULLY.
pause
exit /b 0
:fail
echo.
echo [FAIL] R9 check stopped. Read the first failed line above.
pause
exit /b 1
