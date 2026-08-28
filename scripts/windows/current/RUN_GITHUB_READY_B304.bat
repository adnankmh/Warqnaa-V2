@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa B304 GitHub Ready
where git >nul 2>nul || (echo ERROR: Git not found.& pause& exit /b 1)
git rev-parse --is-inside-work-tree >nul 2>nul || (echo ERROR: This folder is not the existing Git repository. Keep the old .git folder, copy B304 src contents over it, then retry.& pause& exit /b 1)
call scripts\windows\current\CLEAN_STALE_FLUTTER_B304.bat || goto :fail
call scripts\windows\current\CHECK_V304_WINDOWS.bat || goto :fail
python tools\check_git_privacy_v304.py || goto :fail
echo.
git status --short
echo.
set /p CONFIRM=Commit and push Warqnaa V1.3.0+304 now? [Y/N]: 
if /I not "%CONFIRM%"=="Y" exit /b 0
git add -A || goto :fail
python tools\check_git_privacy_v304.py || goto :fail
git commit -m "Warqnaa v1.3.0+304 VERTICAL LEGEND" || echo INFO: No new commit may be required.
for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if not defined BRANCH set "BRANCH=main"
git push origin "%BRANCH%" || goto :fail
echo GitHub push complete.
exit /b 0
:fail
echo B304 GitHub preparation failed. Nothing unsafe should be pushed.
pause
exit /b 1
