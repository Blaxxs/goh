# PC 초기화 전 백업 체크리스트 (GOH Calculator)

이 문서는 현재 작업 환경을 초기화 후 최대한 동일하게 복원하기 위한 체크리스트입니다.

## 1) 가장 안전한 백업 방식
- flutter_application 폴더 전체를 외장 SSD 또는 클라우드에 통째로 백업
- 폴더 전체 백업이 가능하면 파일 누락 위험이 가장 낮음

## 2) 필수 백업 항목
### 프로젝트 핵심
- lib/
- assets/
- pubspec.yaml
- analysis_options.yaml
- devtools_options.yaml
- README.md

### Firebase 및 배포 관련
- firebase.json
- lib/firebase_options.dart
- android/app/google-services.json

### 서명/민감 설정
- android/key.properties
- Android 서명 키스토어 파일 (key.properties 안에 지정된 .jks 또는 .keystore 실제 파일)

### 플랫폼 설정
- android/
- ios/
- web/
- windows/
- macos/
- linux/

### 배포 스크립트
- deploy.bat
- deploy.sh
- autocommit.bat
- auto-commit.sh

## 3) 선택 백업 항목 (권장)
- .git/ (커밋 히스토리까지 유지하려면 백업)
- SETOPTIOMS_DEBUG_GUIDE.md
- SETOPTIOMS_FIX_SUMMARY.md
- test/

## 4) 백업 제외 가능 항목 (재생성 가능)
- build/
- .dart_tool/
- android/.gradle/
- ios/Pods/ (필요 시 pod install로 재생성)
- 기타 캐시/임시 산출물

## 5) VS Code 환경 백업 (같은 개발감 유지)
### 사용자 설정
- %APPDATA%\Code\User\settings.json
- %APPDATA%\Code\User\keybindings.json
- %APPDATA%\Code\User\snippets\

### 확장 목록 백업
PowerShell:
code --list-extensions > extensions.txt

## 6) 복원 순서
1. Flutter SDK, Android SDK, (macOS면 Xcode) 재설치
2. 프로젝트 폴더 복원
3. VS Code 설정/확장 복원
4. 프로젝트 루트에서 flutter pub get 실행
5. 플랫폼별 의존성 복구
   - Android: Gradle 동기화
   - iOS: pod install (macOS)
6. 실행 확인
   - flutter run

## 7) 빠른 백업 명령 예시 (Windows PowerShell)
아래는 폴더 전체를 D:\backup\flutter_application 으로 복사하는 예시입니다.

robocopy "c:\goh\test\goh_calculator\flutter_application" "D:\backup\flutter_application" /MIR /XD build .dart_tool android\.gradle ios\Pods

주의:
- /MIR 는 대상 폴더를 원본과 동일하게 맞추므로, 대상 기존 파일이 삭제될 수 있음
- 처음 백업은 빈 폴더를 대상으로 실행 권장

## 8) 초기화 직전 최종 점검
- key.properties 및 실제 키스토어 파일 백업 완료
- google-services.json 백업 완료
- flutter_application 전체 백업 완료
- VS Code settings/keybindings/snippets 백업 완료
- extensions.txt 생성 완료

완료 기준:
위 5개가 모두 완료되면, 초기화 후 동일 환경 복원이 가능함.
