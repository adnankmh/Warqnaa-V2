@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R14 Global Release
:menu
cls
echo ================================================
echo       WARQNAA R14 GLOBAL RELEASE - BUILD 260
echo ================================================
echo 1. Start 8007  [Recommended]
echo 2. Start 8008
echo 3. Start 8009
echo 4. Start 8010
echo 5. Run Global Release checks
echo 0. Exit
set /p R14_CHOICE=Choose: 
if "%R14_CHOICE%"=="1" call scripts\windows\current\START_WARQNA_R12_PORT_8007.bat
if "%R14_CHOICE%"=="2" call scripts\windows\current\START_WARQNA_R12_PORT_8008.bat
if "%R14_CHOICE%"=="3" call scripts\windows\current\START_WARQNA_R12_PORT_8009.bat
if "%R14_CHOICE%"=="4" call scripts\windows\current\START_WARQNA_R12_PORT_8010.bat
if "%R14_CHOICE%"=="5" call scripts\windows\current\CHECK_V260_WINDOWS.bat
if "%R14_CHOICE%"=="0" exit /b 0
goto menu
