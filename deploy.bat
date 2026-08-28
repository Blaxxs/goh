@echo OFF
setlocal EnableExtensions EnableDelayedExpansion

set "BUMP_TYPE=%~1"
if "%BUMP_TYPE%"=="" set "BUMP_TYPE=small"
if /I not "%BUMP_TYPE%"=="small" if /I not "%BUMP_TYPE%"=="medium" if /I not "%BUMP_TYPE%"=="large" (
  echo Usage: deploy.bat [small^|medium^|large]
  echo Default: small
  set "BUMP_TYPE=small"
)

echo Updating app version for web build...
powershell -NoProfile -Command "$env:BUMP_TYPE = '%BUMP_TYPE%'; $path = 'pubspec.yaml'; $content = Get-Content -Raw $path; $match = [regex]::Match($content, '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)(?:\+[0-9A-Za-z.-]+)?\s*$'); if (-not $match.Success) { throw 'Could not parse version from pubspec.yaml' }; $major = [int]$match.Groups[1].Value; $minor = [int]$match.Groups[2].Value; $patch = [int]$match.Groups[3].Value; switch ($env:BUMP_TYPE.ToLowerInvariant()) { 'small' { $patch += 1 } 'medium' { $minor += 1; $patch = 0 } 'large' { $major += 1; $minor = 0; $patch = 0 } default { throw ('Unsupported bump type: ' + $env:BUMP_TYPE) } }; $timestamp = (Get-Date).ToString('yyyyMMddHHmm'); $newVersion = '{0}.{1}.{2}+{3}' -f $major, $minor, $patch, $timestamp; $updated = [regex]::Replace($content, '(?m)^version:\s*\d+\.\d+\.\d+(?:\+[0-9A-Za-z.-]+)?\s*$', ('version: ' + $newVersion), 1); if ($content -eq $updated) { throw 'Version line was not updated.' }; [System.IO.File]::WriteAllText($path, $updated, (New-Object System.Text.UTF8Encoding($false))); Write-Host ('Updated version to ' + $newVersion);"

echo Building Flutter web app...
call flutter build web --release --base-href "/goh/"

echo Deploying to GitHub Pages...

REM Change directory to the build output
pushd build\web

REM Initialize a git repo here if one doesn't exist
if not exist .git (
	git init
)

REM Stage all files
git add -A

REM Commit only when there are staged changes; fail fast on commit errors
git diff --cached --quiet
if %ERRORLEVEL% EQU 0 (
	echo No changes to commit
) else (
	git commit -m "Deploy to GitHub Pages"
	if errorlevel 1 (
		echo ERROR: Commit failed. Deployment aborted.
		popd
		exit /b 1
	)
)

REM Ensure remote 'origin' points to the correct repository
set REPO_URL=https://github.com/Blaxxs/goh.git
git remote get-url origin >nul 2>&1 && (
	git remote set-url origin %REPO_URL%
) || (
	git remote add origin %REPO_URL%
)

echo Pushing to gh-pages branch...
REM Force push the current commit to the gh-pages branch on the remote
git push -f origin HEAD:gh-pages

REM Return to the original directory
popd

echo.
echo ========================================
echo Deployment complete!
echo GitHub Pages URL: https://blaxxs.github.io/goh/
echo ========================================
