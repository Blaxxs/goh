@echo OFF
SETLOCAL

REM Set the repository path
SET REPO_PATH=c:\goh\test\goh_calculator\flutter_application

REM Change to the repository directory
cd /D "%REPO_PATH%"

REM Add all changes
git add .

REM Commit with a timestamp
FOR /F "tokens=2 delims==" %%I IN ('wmic os get localdatetime /value') DO SET "timestamp=%%I"
SET "commit_message=Auto-commit at %timestamp:~0,4%-%timestamp:~4,2%-%timestamp:~6,2% %timestamp:~8,2%:%timestamp:~10,2%:%timestamp:~12,2%"
git commit -m "%commit_message%"

REM Push to the remote repository
git push

ENDLOCAL
