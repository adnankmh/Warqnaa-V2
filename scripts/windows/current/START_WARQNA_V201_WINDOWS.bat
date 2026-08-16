@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa V0.4.5+201 Gameplay and Admin Pro
cls
echo ============================================
echo  Warqnaa V201 - choose web port
echo ============================================
echo  [1] 8007  ^(recommended^)
echo  [2] 8008
echo  [3] 8009
echo  [4] 8010
echo.
choice /C 1234 /N /M "Choose 1-4: "
if errorlevel 4 set "P=8010"
if errorlevel 3 if not errorlevel 4 set "P=8009"
if errorlevel 2 if not errorlevel 3 set "P=8008"
if errorlevel 1 if not errorlevel 2 set "P=8007"
call "%~dp0START_WARQNA_V201_PORT_%P%.bat"
