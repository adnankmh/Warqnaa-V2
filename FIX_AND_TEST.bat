@echo off
setlocal
cd /d "%~dp0"
echo ============================================================
echo   WARQNAA V2 - BUILD 305 CI FIX
echo ============================================================
echo.
where py >nul 2>nul
if %errorlevel%==0 (
    py -3 apply_ci_fix.py
) else (
    python apply_ci_fix.py
)
if errorlevel 1 (
    echo.
    echo PATCH/TEST FAILED. Nothing will be pushed.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo Local tests passed.
echo ============================================================
echo.
choice /C YN /N /M "Commit and push this fix to GitHub now? [Y/N]: "
if errorlevel 2 goto done

git status --short
git add tools/test_v210_r9_1_contract.py
git commit -m "fix(ci): align R9.1 reward ceiling contract with build 305"
if errorlevel 1 (
    echo.
    echo Commit failed or there was nothing new to commit.
    pause
    exit /b 1
)

git push
if errorlevel 1 (
    echo.
    echo Push failed. The local commit is preserved.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Fix committed and pushed to GitHub.
:done
echo.
pause
