#!/bin/sh
#
# 이 스크립트는 Flutter 웹 앱을 빌드하고 GitHub Pages에 배포합니다.
#

# --- 설정 ---
# <<< 여기에 실제 GitHub 사용자 이름과 저장소 이름을 입력하세요. >>>
GITHUB_USERNAME="Blaxxs"
REPOSITORY_NAME="goh_calculator"
# ------------

# 스크립트 실행 중 오류가 발생하면 즉시 중단합니다.
set -e

# 1. GitHub Pages 주소 형식에 맞게 웹 앱을 빌드합니다.
echo "Building Flutter web app for release..."
flutter build web --release --base-href "/${REPOSITORY_NAME}/"

# 2. 빌드 결과물이 있는 디렉토리로 이동합니다.
cd build/web

# 3. 배포를 위한 임시 Git 저장소를 초기화합니다.
# CNAME 파일이 있다면 여기에 복사하여 사용자 정의 도메인을 유지할 수 있습니다.
git init
git checkout -B gh-pages

# 4. 모든 파일을 추가하고 커밋합니다.
git add .
git commit -m "Deploy to GitHub Pages"

# 5. GitHub 저장소의 gh-pages 브랜치로 강제 푸시합니다.
echo "Pushing to gh-pages branch..."
git push -f "https://github.com/${GITHUB_USERNAME}/${REPOSITORY_NAME}.git" gh-pages

# 6. 작업이 끝난 후 상위 디렉토리로 돌아옵니다.
cd -
echo "Deployment to GitHub Pages complete!"