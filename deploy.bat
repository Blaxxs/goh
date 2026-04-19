@echo OFF
echo Updating app version for web build...
powershell -NoProfile -Command "$path = 'pubspec.yaml'; $content = Get-Content -Raw $path; $timestamp = (Get-Date).ToString('yyyyMMddHHmm'); $pattern = '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)(\+\d+)?\s*$'; $updated = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, ('version: $1+' + $timestamp), [System.Text.RegularExpressions.RegexOptions]::Multiline); if ($content -eq $updated) { Write-Host 'Warning: version line not updated. Check pubspec.yaml format.' } [System.IO.File]::WriteAllText($path, $updated, (New-Object System.Text.UTF8Encoding($false)))"
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
	if %ERRORLEVEL% NEQ 0 (
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
