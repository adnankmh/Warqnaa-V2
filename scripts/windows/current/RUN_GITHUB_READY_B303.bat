@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
call scripts\windows\current\CLEAN_STALE_FLUTTER_B303.bat || exit /b 1
call scripts\windows\current\CHECK_V303_WINDOWS.bat || exit /b 1
where git >nul 2>nul || (echo ERROR: Git not found.& pause& exit /b 1)
git rev-parse --is-inside-work-tree >nul 2>nul || (echo ERROR: This folder is not your Git repository. Keep the existing .git folder and copy B303 source over it.& pause& exit /b 1)
git add -A
git status --short
echo.
echo B303 checks passed and stale tracked Dart files were synchronized to the release manifest.
echo Press Y to commit and push the current branch, or N to stop.
choice /C YN /N /M "Push B303 now? [Y/N]: "
if errorlevel 2 exit /b 0
git commit -m "Warqnaa v1.2.0+303 runtime social stability and global premium UI" || echo No new commit was created; continuing.
for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if "%BRANCH%"=="" set "BRANCH=main"
git push origin "%BRANCH%" || (echo PUSH FAILED. Check GitHub login/remote.& pause& exit /b 1)
echo PUSH COMPLETE. GitHub Actions will now run Laravel, Flutter, Engine Gold, Web, Android and iOS gates.
pause
