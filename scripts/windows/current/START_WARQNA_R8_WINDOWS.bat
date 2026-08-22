@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R8 Launcher
echo ==========================================
echo       WARQNAA R8 - EASY LAUNCHER
echo ==========================================
echo 1. Port 8007  [Recommended]
echo 2. Port 8008
echo 3. Port 8009
echo 4. Port 8010
echo 5. Run R8 checks
echo 0. Exit
set /p CHOICE=Choose: 
if "%CHOICE%"=="1" call "scripts\windows\current\START_WARQNA_R8_PORT_8007.bat"
if "%CHOICE%"=="2" call "scripts\windows\current\START_WARQNA_R8_PORT_8008.bat"
if "%CHOICE%"=="3" call "scripts\windows\current\START_WARQNA_R8_PORT_8009.bat"
if "%CHOICE%"=="4" call "scripts\windows\current\START_WARQNA_R8_PORT_8010.bat"
if "%CHOICE%"=="5" call "scripts\windows\current\CHECK_R8_WINDOWS.bat"
endlocal
