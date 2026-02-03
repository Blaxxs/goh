@echo OFF
echo Building Flutter web app...
flutter build web --release --base-href "/goh/"

echo Deploying to GitHub Pages...

REM Change directory to the build output
pushd build\web

REM Initialize a git repo here if one doesn't exist
if not exist .git (
	git init
)

REM Stage all files
git add -A

REM Commit only if there are staged changes
git commit -m "Deploy to GitHub Pages" >nul 2>&1 || (
	echo No changes to commit
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
