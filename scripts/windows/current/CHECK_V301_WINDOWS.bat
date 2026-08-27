@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa Build 301 Verification
echo ================================================
echo      WARQNAA V1.1.1 BUILD 301 - FULL CHECK
echo ================================================
where python >nul 2>nul || (echo ERROR: Python not found.& exit /b 1)
python tools\verify_release_versions.py || goto :fail
python tools\test_v208_r8_contract.py || goto :fail
python tools\test_v209_r9_contract.py || goto :fail
python tools\test_v210_r9_1_contract.py || goto :fail
python tools\test_v220_r10_contract.py || goto :fail
python tools\test_v221_r101_contract.py || goto :fail
python tools\test_v230_r11_contract.py || goto :fail
python tools\test_v240_r12_contract.py || goto :fail
python tools\test_v240_competitive_engines.py || goto :fail
python tools\test_v240_php_structure.py || goto :fail
python tools\test_v250_r13_contract.py || goto :fail
python tools\test_v260_r14_contract.py || goto :fail
python tools\test_v263_r14_3_contract.py || goto :fail
python tools\test_v300_world_experience_contract.py || goto :fail
python tools\test_v301_ci_i18n_contract.py || goto :fail
python tools\global_release_preflight.py || goto :fail
python tools\test_v030_contract.py || goto :fail
python tools\validate_v030_static.py || goto :fail
python tools\validate_release.py || goto :fail
set "WARQNA_PHP="
where php >nul 2>nul && set "WARQNA_PHP=php"
if not defined WARQNA_PHP if exist "C:\xampp\php\php.exe" set "WARQNA_PHP=C:\xampp\php\php.exe"
if defined WARQNA_PHP (
  "%WARQNA_PHP%" backend-laravel\tools\test-v208-r8-rules.php || goto :fail
  "%WARQNA_PHP%" backend-laravel\tools\test-v184-official-rules-audit.php || goto :fail
  "%WARQNA_PHP%" backend-laravel\tools\test-v184-engine-stress.php || goto :fail
  if exist backend-laravel\vendor\autoload.php (
    pushd backend-laravel
    "%WARQNA_PHP%" artisan migrate --force || (popd & goto :fail)
    "%WARQNA_PHP%" artisan test || (popd & goto :fail)
    popd
  )
) else (
  echo WARNING: PHP not found; PHP runtime gates will run in GitHub Actions.
)
where flutter >nul 2>nul
if not errorlevel 1 (
  pushd flutter_app
  call flutter pub get || (popd & goto :fail)
  call flutter analyze || (popd & goto :fail)
  call flutter test || (popd & goto :fail)
  popd
) else (
  echo WARNING: Flutter not found; Flutter runtime gates will run in GitHub Actions.
)
echo.
echo WARQNAA V1.1.1 BUILD 301 CHECK: PASS
exit /b 0
:fail
echo.
echo WARQNAA V1.1.1 BUILD 301 CHECK: FAIL
exit /b 1
