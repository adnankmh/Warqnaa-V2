@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R9 Easy Launcher
:menu
cls
echo ================================================
echo       WARQNAA R9 - VISUAL REVOLUTION
echo ================================================
echo 1. Start 8007  [Recommended]
echo 2. Start 8008
echo 3. Start 8009
echo 4. Start 8010
echo 5. Run R9 checks
echo 0. Exit
set /p CHOICE=Choose: 
if "%CHOICE%"=="1" call scripts\windows\current\START_WARQNA_R9_PORT_8007.bat
if "%CHOICE%"=="2" call scripts\windows\current\START_WARQNA_R9_PORT_8008.bat
if "%CHOICE%"=="3" call scripts\windows\current\START_WARQNA_R9_PORT_8009.bat
if "%CHOICE%"=="4" call scripts\windows\current\START_WARQNA_R9_PORT_8010.bat
if "%CHOICE%"=="5" call scripts\windows\current\CHECK_R9_WINDOWS.bat
if "%CHOICE%"=="0" exit /b 0
goto menu
