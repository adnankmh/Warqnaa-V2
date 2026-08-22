@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa R13 Engine Gold
:menu
cls
echo ================================================
echo       WARQNAA R13 ENGINE GOLD - BUILD 250
echo ================================================
echo 1. Start 8007  [Recommended]
echo 2. Start 8008
echo 3. Start 8009
echo 4. Start 8010
echo 5. Run R13 release checks
echo 0. Exit
set /p R13_CHOICE=Choose: 
if "%R13_CHOICE%"=="1" call scripts\windows\current\START_WARQNA_R12_PORT_8007.bat
if "%R13_CHOICE%"=="2" call scripts\windows\current\START_WARQNA_R12_PORT_8008.bat
if "%R13_CHOICE%"=="3" call scripts\windows\current\START_WARQNA_R12_PORT_8009.bat
if "%R13_CHOICE%"=="4" call scripts\windows\current\START_WARQNA_R12_PORT_8010.bat
if "%R13_CHOICE%"=="5" call scripts\windows\current\CHECK_V250_WINDOWS.bat
if "%R13_CHOICE%"=="0" exit /b 0
goto menu
