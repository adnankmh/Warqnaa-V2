@echo off
rem Historical V200 compatibility shim. Current implementation lives in V201.
call "%~dp0START_WARQNA_V201_PORT_8009.bat" %*
exit /b %ERRORLEVEL%
