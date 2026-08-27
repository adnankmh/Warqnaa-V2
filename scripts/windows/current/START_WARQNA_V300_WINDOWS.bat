@echo off
setlocal EnableExtensions
cd /d "%~dp0\..\..\.."
title Warqnaa WORLD EXPERIENCE Build 300
:menu
cls
echo ================================================
echo       WARQNAA WORLD EXPERIENCE - BUILD 300
echo ================================================
echo 1. Start 8007  [Recommended]
echo 2. Start 8008
echo 3. Start 8009
echo 4. Start 8010
echo 5. Run Build 300 checks
echo 0. Exit
set /p WORLD_CHOICE=Choose: 
if "%WORLD_CHOICE%"=="1" call scripts\windows\current\START_WARQNA_R12_PORT_8007.bat
if "%WORLD_CHOICE%"=="2" call scripts\windows\current\START_WARQNA_R12_PORT_8008.bat
if "%WORLD_CHOICE%"=="3" call scripts\windows\current\START_WARQNA_R12_PORT_8009.bat
if "%WORLD_CHOICE%"=="4" call scripts\windows\current\START_WARQNA_R12_PORT_8010.bat
if "%WORLD_CHOICE%"=="5" call scripts\windows\current\CHECK_V300_WINDOWS.bat
if "%WORLD_CHOICE%"=="0" exit /b 0
goto menu
