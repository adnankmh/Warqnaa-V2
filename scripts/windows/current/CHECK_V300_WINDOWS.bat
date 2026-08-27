@echo off
setlocal
cd /d "%~dp0\..\..\.."
echo [WORLD] Warqnaa 1.1.0+300 verification
python tools\verify_release_versions.py || goto :fail
python tools\test_v208_r8_contract.py || goto :fail
python tools\test_v209_r9_contract.py || goto :fail
python tools\test_v210_r9_1_contract.py || goto :fail
python tools\test_v220_r10_contract.py || goto :fail
python tools\test_v221_r101_contract.py || goto :fail
python tools\test_v230_r11_contract.py || goto :fail
python tools\test_v240_r12_contract.py || goto :fail
python tools\test_v250_r13_contract.py || goto :fail
python tools\test_v260_r14_contract.py || goto :fail
python tools\test_v263_r14_3_contract.py || goto :fail
python tools\test_v300_world_experience_contract.py || goto :fail
python tools\global_release_preflight.py || goto :fail
python tools\validate_release.py || goto :fail
set "WARQNA_PHP="
where php >nul 2>nul && set "WARQNA_PHP=php"
if not defined WARQNA_PHP if exist "C:\xampp\php\php.exe" set "WARQNA_PHP=C:\xampp\php\php.exe"
if defined WARQNA_PHP (
  set WARQNA_GOLD_MATCHES_PER_ENGINE=25
  set WARQNA_GOLD_MAX_TRANSITIONS=160
  "%WARQNA_PHP%" backend-laravel\tools\test-v250-r13-engine-gold.php || goto :fail
  if exist backend-laravel\vendor\autoload.php (
    pushd backend-laravel
    "%WARQNA_PHP%" artisan migrate --force || (popd & goto :fail)
    "%WARQNA_PHP%" artisan test || (popd & goto :fail)
    "%WARQNA_PHP%" artisan warqna:global-release-check --json || (popd & goto :fail)
    popd
  )
)
echo WARQNAA WORLD EXPERIENCE BUILD 300 CHECK: PASS
exit /b 0
:fail
echo WARQNAA WORLD EXPERIENCE BUILD 300 CHECK: FAIL
exit /b 1
