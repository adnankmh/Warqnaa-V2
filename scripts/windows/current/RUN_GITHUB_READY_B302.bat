@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
call scripts\windows\current\CHECK_V302_WINDOWS.bat || exit /b 1
where git >nul 2>nul || (echo ERROR: Git not found.& pause& exit /b 1)
git rev-parse --is-inside-work-tree >nul 2>nul || (echo ERROR: This folder is not your Git repository. Copy this full source over your existing Warqnaa repo while keeping .git.& pause& exit /b 1)
if exist flutter_app\lib\r14_1_legendary.dart echo R14.1 compatibility file present.
git add -A
git status --short
echo.
echo Files are staged. The script will NOT expose secrets because .env is ignored.
echo Press Y to commit and push the current branch, or any other key to stop here.
choice /C YN /N /M "Push now? [Y/N]: "
if errorlevel 2 exit /b 0
git commit -m "Warqnaa v1.1.2+302 Flutter and Hand final stability" || echo No new commit was created; continuing.
for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if "%BRANCH%"=="" set "BRANCH=main"
git push origin "%BRANCH%" || (echo PUSH FAILED. Check GitHub login/remote.& pause& exit /b 1)
echo PUSH COMPLETE. Open GitHub Actions now.
pause
