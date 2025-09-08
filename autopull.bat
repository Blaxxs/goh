@echo OFF
SETLOCAL

REM Set the repository path
SET REPO_PATH=c:\goh\test\goh_calculator\flutter_application

REM Change to the repository directory
cd /D "%REPO_PATH%"

:loop
echo Checking for remote changes...
git pull
echo Waiting for 10 seconds before next check...
timeout /t 10 /nobreak > NUL
goto loop

ENDLOCAL
