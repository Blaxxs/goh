# 세트옵션 디버깅 가이드

## 문제 상황
1. 악세사리 도감에서 세트옵션이 있는 악세사리의 **세트옵션 내부 악세사리 이미지가 보이지 않음**
2. **세트옵션의 수치가 보이지 않음**

## 수정 사항

### 1. 악세사리 이미지 URL 생성 개선 (AccessorySetOption.fromJson)
- **파일**: `lib/data/models/accessory.dart`
- **변경사항**: 
  - `requiredAccessoryImages` 필드의 각 항목에 대해 Firebase Storage URL 자동 생성
  - 이미 URL 형식이면 그대로 사용
  - Firebase Storage ID는 `Uri.encodeComponent()`로 인코딩

### 2. 세트옵션 수치 안전 처리 (SetOptionEffect.fromJson & accessory_screen.dart)
- **파일**: `lib/data/models/accessory.dart`, `lib/presentation/accessory/accessory_screen.dart`
- **변경사항**:
  - `stageValues` 맵의 키 변환 로직 개선
  - 단계 인덱스를 문자열로 변환하여 매칭
  - 값이 없을 때 '-' 표시 로직 추가

### 3. 디버그 로그 추가
- **파일**: `lib/core/constants/accessory_constants.dart`, `lib/data/models/accessory.dart`, `lib/presentation/accessory/accessory_screen.dart`
- **변경사항**:
  - Firebase로부터 데이터 로드 시 상세 로그 출력
  - Set Options 개수, 이미지 목록, 효과 목록 로깅
  - 이미지 로드 실패 시 URL 정보 출력

## 디버그 방법

### 1. 콘솔 로그 확인
앱 실행 중:
```
flutter run -d chrome  # 웹에서 실행
```

개발자 도구 콘솔에서 다음 로그를 확인:
- `[AccessoryDataManager]` - 악세사리 로드 정보
- `[AccessorySetOption]` - 세트옵션 파싱 정보
- `[SetOptionEffect]` - 세트옵션 효과 파싱 정보
- `[SetOption]` - UI 렌더링 시 이미지 로드 정보

### 2. Firebase 데이터 구조 확인
필요한 Firebase 데이터 구조:
```json
{
  "accessories": {
    "악세사리ID": {
      "id": "악세사리ID",
      "name": "악세사리이름",
      "part": "부위",
      "restrictions": "제한사항",
      "options": [
        {
          "optionName": "옵션이름",
          "optionValue": "수치"
        }
      ],
      "setOptions": [
        {
          "setId": "세트ID",
          "setName": "세트이름",
          "requiredAccessories": ["악세1", "악세2"],
          "requiredAccessoryImages": ["악세1ID", "악세2ID"],
          "effects": [
            {
              "optionName": "효과옵션명",
              "stageValues": {
                "0": "0단계값",
                "1": "1단계값",
                ...
                "18": "18단계값"
              }
            }
          ]
        }
      ]
    }
  }
}
```

### 3. 확인할 항목
- [ ] Firebase 콘솔에서 `setOptions` 필드가 실제로 존재하는가?
- [ ] `requiredAccessoryImages`에 악세사리 ID가 올바르게 저장되어 있는가?
- [ ] `stageValues`의 키가 "0", "1", ... "18"의 문자열 형식인가?
- [ ] 각 이미지 ID에 해당하는 PNG 파일이 Firebase Storage의 `accessories/` 폴더에 있는가?

## 예상 동작

### 수정 전
- 세트옵션 섹션에서 이미지가 "broken_image" 아이콘으로 표시됨
- 세트옵션 수치가 '-'로 표시됨

### 수정 후
- 세트옵션에 필요한 악세사리 이미지 표시
- 세트옵션 각 효과의 단계별 수치 정상 표시
- 화살표 버튼으로 단계 전환 가능

## 추가 확인 사항
- 이미지가 로드되지 않으면 콘솔에 URL과 에러 메시지 출력
- 수치가 '-'로 표시되면 Firebase의 `stageValues` 데이터 확인 필요
