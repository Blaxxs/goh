#!/bin/sh
#
# 이 스크립트는 파일 저장 시 Git 변경사항을 자동으로 커밋하고 푸시합니다.
#

# --- 디버깅을 위한 로그 파일 설정 ---
LOG_FILE="$(dirname "$0")/auto-commit.log"
echo "---" >> "$LOG_FILE"
echo "Auto-commit script started at $(date)" >> "$LOG_FILE"

# 이 스크립트 파일이 위치한 디렉토리로 이동합니다.
# 이렇게 하면 VS Code를 어느 폴더에서 열든 항상 올바른 Git 저장소에서 명령이 실행됩니다.
cd "$(dirname "$0")"
echo "Changed directory to: $(pwd)" >> "$LOG_FILE"

# 변경 사항이 있는지 확인
if git diff-index --quiet HEAD --; then
    echo "No changes to commit." | tee -a "$LOG_FILE"
    exit 0
fi

echo "Changes detected. Committing..." | tee -a "$LOG_FILE"
git add .

# 커밋 메시지에 날짜와 시간 포함
COMMIT_MSG="Auto-commit on save: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

echo "Pushing to remote..." | tee -a "$LOG_FILE"
# git push 실행. 실패 시 사용자에게 명확한 안내를 제공합니다.
if git push >> "$LOG_FILE" 2>&1; then
    echo "Push successful." | tee -a "$LOG_FILE"
else
    # 실패 메시지는 이미 stderr로 리디렉션되어 로그 파일에 기록됨
    echo "Push failed. See auto-commit.log for details." | tee -a "$LOG_FILE"
    echo "--------------------------------------------------" >&2
    echo "경고: 'git push'에 실패했습니다. 로컬 변경사항은 커밋되었지만, 원격 저장소에는 반영되지 않았습니다." >&2
    echo "원격 저장소에 새로운 변경사항이 있을 수 있습니다. 터미널에서 'git pull'을 실행하여 동기화 후 다시 시도해주세요." >&2
    echo "--------------------------------------------------" >&2
    exit 1 # 실패했음을 VS Code에 알림
fi

echo "Auto-commit script finished at $(date)" >> "$LOG_FILE"