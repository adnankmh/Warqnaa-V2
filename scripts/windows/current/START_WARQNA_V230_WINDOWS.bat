@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R11 Social World
:menu
cls
echo ================================================
echo    WARQNAA R11 SOCIAL WORLD - BUILD 230
echo ================================================
echo 1. Start 8007  [Recommended]
echo 2. Start 8008
echo 3. Start 8009
echo 4. Start 8010
echo 5. Run R11 release checks
echo 0. Exit
set /p R11_CHOICE=Choose: 
if "%R11_CHOICE%"=="1" call scripts\windows\current\START_WARQNA_R11_PORT_8007.bat
if "%R11_CHOICE%"=="2" call scripts\windows\current\START_WARQNA_R11_PORT_8008.bat
if "%R11_CHOICE%"=="3" call scripts\windows\current\START_WARQNA_R11_PORT_8009.bat
if "%R11_CHOICE%"=="4" call scripts\windows\current\START_WARQNA_R11_PORT_8010.bat
if "%R11_CHOICE%"=="5" call scripts\windows\current\CHECK_V230_WINDOWS.bat
if "%R11_CHOICE%"=="0" exit /b 0
goto menu
