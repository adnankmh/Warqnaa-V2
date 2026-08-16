@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
python tools\verify_release_versions.py || exit /b 1
python tools\test_v200_full_fusion_contract.py || exit /b 1
python tools\validate_release.py || exit /b 1
php backend-laravel\tools\test-v184-engine-stress.php || exit /b 1
php backend-laravel\tools\test-v184-official-rules-audit.php || exit /b 1
echo [PASS] Warqnaa V0.4.4+200 source checks completed.
pause
