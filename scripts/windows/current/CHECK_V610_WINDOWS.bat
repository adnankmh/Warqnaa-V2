@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R6.1 Build 610 Verification
echo ==================================================
echo   WARQNAA R6.1 BUILD 610 - RELEASE CHECK
echo ==================================================
where python >nul 2>nul || (echo ERROR: Python not found.& exit /b 1)
python tools\verify_release_versions.py || goto :fail
python tools\test_r61_world_class_contract.py || goto :fail
python tools\test_v305_single_table_contract.py || goto :fail
python tools\check_git_privacy_v304.py || goto :fail
python tools\validate_v030_static.py || goto :fail
python tools\validate_release.py || goto :fail
echo WARQNAA R6.1 BUILD 610 CHECK: PASS
exit /b 0
:fail
echo WARQNAA R6.1 BUILD 610 CHECK: FAIL
exit /b 1
