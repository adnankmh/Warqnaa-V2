@echo off
setlocal
cd /d "%~dp0\..\..\.."
echo [R12] Warqnaa 0.7.0+240 verification
python tools\verify_release_versions.py || goto :fail
python tools\test_v208_r8_contract.py || goto :fail
python tools\test_v209_r9_contract.py || goto :fail
python tools\test_v210_r9_1_contract.py || goto :fail
python tools\test_v220_r10_contract.py || goto :fail
python tools\test_v221_r101_contract.py || goto :fail
python tools\test_v230_r11_contract.py || goto :fail
python tools\test_v240_competitive_engines.py || goto :fail
python tools\test_v240_r12_contract.py || goto :fail
python tools\test_v240_php_structure.py || goto :fail
python tools\test_ci_release_compat_contract.py || goto :fail
python tools\validate_release.py || goto :fail

set "WARQNA_PHP="
where php >nul 2>nul && set "WARQNA_PHP=php"
if not defined WARQNA_PHP if exist "C:\xampp\php\php.exe" set "WARQNA_PHP=C:\xampp\php\php.exe"
if defined WARQNA_PHP (
  "%WARQNA_PHP%" backend-laravel\tools\test-v208-r8-rules.php || goto :fail
  "%WARQNA_PHP%" backend-laravel\tools\test-v184-official-rules-audit.php || goto :fail
  set WARQNA_STRESS_ITERATIONS=40
  "%WARQNA_PHP%" backend-laravel\tools\test-v184-engine-stress.php || goto :fail
  set WARQNA_PLAYTHROUGH_RUNS=4
  set WARQNA_PLAYTHROUGH_STEPS=80
  "%WARQNA_PHP%" backend-laravel\tools\test-v208-r8-playthrough-stress.php || goto :fail
  if exist backend-laravel\vendor\autoload.php (
    pushd backend-laravel
    "%WARQNA_PHP%" artisan test --filter V230SocialWorldTest || (popd & goto :fail)
    "%WARQNA_PHP%" artisan test --filter V240CompetitiveArenaTest || (popd & goto :fail)
    "%WARQNA_PHP%" artisan warqna:competitive-tick --dry-run || (popd & goto :fail)
    "%WARQNA_PHP%" artisan test || (popd & goto :fail)
    popd
  ) else (
    echo [INFO] Composer vendor is absent; Laravel PHPUnit remains enforced by GitHub Actions.
  )
) else (
  echo [INFO] PHP is absent; executable engine and Laravel suites remain enforced by GitHub Actions.
)
echo WARQNAA R12 BUILD 240 CHECK: PASS
exit /b 0
:fail
echo WARQNAA R12 BUILD 240 CHECK: FAIL
exit /b 1
