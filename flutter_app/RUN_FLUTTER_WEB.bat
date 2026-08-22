@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Warqnaa Flutter V0.4.4+200
set "WARQNA_PORT=%~1"
if "%WARQNA_PORT%"=="" set "WARQNA_PORT=8007"
if not "%WARQNA_PORT%"=="8007" if not "%WARQNA_PORT%"=="8008" if not "%WARQNA_PORT%"=="8009" if not "%WARQNA_PORT%"=="8010" (
  echo ERROR: Allowed ports are 8007, 8008, 8009, 8010.
  pause & exit /b 1
)
where flutter >nul 2>nul
if %errorlevel% neq 0 (echo ERROR: Flutter SDK was not found in PATH.& echo GitHub Actions can build Android/Web without Android Studio.& pause & exit /b 1)
if not exist "web\index.html" flutter create . --platforms=web,android,ios --project-name warqna_mobile --org com.warqna
call flutter pub get
if %errorlevel% neq 0 (echo ERROR: flutter pub get failed.& pause & exit /b 1)
set "API_URL=http://127.0.0.1:%WARQNA_PORT%/api/mobile/v1"
echo Starting Warqnaa Flutter Web with API: %API_URL%
call flutter run -d chrome --dart-define=WARQNA_API_URL=%API_URL% --dart-define=WARQNA_PRODUCTION_MODE=false --dart-define=WARQNA_APP_VERSION=0.4.4 --dart-define=WARQNA_APP_BUILD=200
pause
