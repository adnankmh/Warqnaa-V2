@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
if not exist releases\manifests\current\FLUTTER_LIB_MANIFEST_V303.txt (
  echo ERROR: B303 Flutter manifest is missing.
  exit /b 1
)
where git >nul 2>nul || exit /b 0
git rev-parse --is-inside-work-tree >nul 2>nul || exit /b 0
echo Cleaning stale tracked Dart files left by older Warqnaa copies...
for /f "delims=" %%F in ('git ls-files flutter_app/lib') do (
  echo %%F| findstr /R /C:"\.dart$" >nul
  if not errorlevel 1 (
    findstr /X /L /C:"%%F" releases\manifests\current\FLUTTER_LIB_MANIFEST_V303.txt >nul 2>nul
    if errorlevel 1 (
      if exist "%%F" (
        echo Removing stale source: %%F
        del /Q "%%F"
      )
    )
  )
)
exit /b 0
