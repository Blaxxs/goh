@echo OFF
echo Building Flutter web app...
flutter build web --release --base-href "/goh/"

echo Deploying to GitHub Pages...

REM Change directory to the build output
pushd build\web

REM Initialize a new git repo and commit the build files
git init
git config user.email "bot@github.com"
git config user.name "GitHub Pages Bot"
git add -A
git commit -m "Deploy to GitHub Pages"

REM Add the remote origin with SSH (or HTTPS if SSH fails)
git remote add origin https://github.com/Blaxxs/goh.git

echo Pushing to gh-pages branch...
REM Force push the current commit to the gh-pages branch on the remote
REM Using --force-with-lease for safer force push
git push -f origin HEAD:gh-pages

REM Return to the original directory
popd

echo.
echo ========================================
echo Deployment complete!
echo GitHub Pages URL: https://blaxxs.github.io/goh/
echo ========================================
