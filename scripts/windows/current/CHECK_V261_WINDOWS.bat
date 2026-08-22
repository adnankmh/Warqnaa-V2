@echo off
setlocal
cd /d "%~dp0\..\..\.."
echo [R14.1] Warqnaa 1.0.1+261 Legendary Experience verification
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
python tools\test_v261_r14_1_contract.py || goto :fail
python tools\global_release_preflight.py || goto :fail
python tools\validate_release.py || goto :fail
echo WARQNAA R14.1 BUILD 261 CHECK: PASS
exit /b 0
:fail
echo WARQNAA R14.1 BUILD 261 CHECK: FAIL
exit /b 1
