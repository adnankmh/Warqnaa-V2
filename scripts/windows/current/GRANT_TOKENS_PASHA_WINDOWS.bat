@echo off
setlocal
cd /d %~dp0\..\..\..
if "%~1"=="" (
  echo Usage:
  echo   GRANT_TOKENS_PASHA_WINDOWS.bat username_or_email 5000 3 promo_campaign
  echo Example:
  echo   GRANT_TOKENS_PASHA_WINDOWS.bat admin@example.com 10000 7 leap_promo
  exit /b 1
)
set TARGET=%~1
set TOKENS=%~2
set PASHA=%~3
set REASON=%~4
if "%TOKENS%"=="" set TOKENS=0
if "%PASHA%"=="" set PASHA=0
if "%REASON%"=="" set REASON=manual_windows_grant
php backend-laravel\tools\grant_tokens_pasha.php --user="%TARGET%" --tokens=%TOKENS% --pasha-days=%PASHA% --reason="%REASON%"
endlocal
