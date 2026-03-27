@echo OFF
SETLOCAL

REM Set the repository path (current script directory)
SET REPO_PATH=%~dp0

REM Change to the repository directory
cd /D "%REPO_PATH%"

REM Add a small delay to avoid race conditions with other extensions
timeout /t 1 /nobreak > NUL

REM Add all changes
git add .

REM Commit with a simple message
git commit -m "Auto-commit on save"

REM Push to the remote repository
git push

ENDLOCAL