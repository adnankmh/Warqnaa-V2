@echo off
setlocal
cd /d "%~dp0\..\..\.."
echo [R10.1] Warqnaa 0.5.1+221 verification
python tools\test_v221_r101_contract.py || goto :fail
python tools\test_v220_r10_contract.py || goto :fail
python tools\test_v210_r9_1_contract.py || goto :fail
python tools\test_v208_r8_contract.py || goto :fail
python tools\validate_release.py || goto :fail
echo WARQNAA R10.1 CHECK: PASS
exit /b 0
:fail
echo WARQNAA R10.1 CHECK: FAIL
exit /b 1
