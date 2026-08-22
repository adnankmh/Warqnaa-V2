@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R14.1 Legendary Experience
:menu
cls
echo ==================================================
echo   WARQNAA R14.1 LEGENDARY EXPERIENCE - BUILD 261
echo ==================================================
echo 1. Start 8007  [Recommended]
echo 2. Start 8008
echo 3. Start 8009
echo 4. Start 8010
echo 5. Run complete Build 261 checks
echo 0. Exit
set /p R141_CHOICE=Choose:
if "%R141_CHOICE%"=="1" call scripts\windows\current\START_WARQNA_R12_PORT_8007.bat
if "%R141_CHOICE%"=="2" call scripts\windows\current\START_WARQNA_R12_PORT_8008.bat
if "%R141_CHOICE%"=="3" call scripts\windows\current\START_WARQNA_R12_PORT_8009.bat
if "%R141_CHOICE%"=="4" call scripts\windows\current\START_WARQNA_R12_PORT_8010.bat
if "%R141_CHOICE%"=="5" call scripts\windows\current\CHECK_V261_WINDOWS.bat
if "%R141_CHOICE%"=="0" exit /b 0
goto menu
