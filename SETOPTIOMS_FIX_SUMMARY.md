# 악세사리 세트옵션 표시 문제 해결

## 문제점
1. **세트옵션 내부 악세사리 이미지가 보이지 않음** - Firebase Storage의 이미지 URL을 올바르게 생성하지 않았음
2. **세트옵션의 수치가 보이지 않음** - `stageValues` 맵 키 처리 로직에 문제가 있었음

---

## 적용된 해결 방안

### 1. **lib/data/models/accessory.dart** 수정

#### SetOptionEffect.fromJson 개선
- `stageValues` 맵의 키를 문자열로 올바르게 변환
- 단계별 수치 값이 올바르게 저장되도록 개선
- 파싱 실패 시 디버그 경고 메시지 추가

```dart
final keyStr = key is int ? key.toString() : key.toString();
final valueStr = value?.toString() ?? '';
stageValues[keyStr] = valueStr;
```

#### AccessorySetOption.fromJson 개선
- `requiredAccessoryImages`의 각 항목에 대해 **Firebase Storage URL 자동 생성**
- 이미 URL 형식이면 그대로 사용
- Firebase Storage 경로: `accessories/{id}.png`
- 버킷: `gohcalculator.firebasestorage.app` (하드코딩)

```dart
final processedImages = requiredImgList.map((e) {
  final imageId = e.toString();
  if (imageId.startsWith('http')) {
    return imageId;
  }
  final encodedId = Uri.encodeComponent(imageId);
  return 'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$encodedId.png?alt=media';
}).toList();
```

---

### 2. **lib/presentation/accessory/accessory_screen.dart** 수정

#### 세트옵션 수치 표시 개선
- `stageValues` 키가 없을 때 안전하게 '-' 표시
- 빈 문자열을 명확히 확인하여 처리

```dart
String currentValue = '';

if (effect.stageValues.isNotEmpty) {
  currentValue = effect.stageValues[currentStageIndex.toString()] ?? '-';
  if (currentValue.isEmpty) {
    currentValue = '-';
  }
} else {
  currentValue = '-';
}
```

#### 이미지 로드 실패 시 디버그 정보 추가
- `CachedNetworkImage`의 `errorWidget`에서 URL과 에러 정보 로깅
- 이미지 목록이 비었을 때 안내 메시지 표시

```dart
errorWidget: (context, url, error) {
  debugPrint('[SetOption] Image load failed for URL: $url, Error: $error');
  return const Center(
    child: Icon(Icons.broken_image, size: 20, color: Colors.grey),
  );
}
```

---

### 3. **lib/core/constants/accessory_constants.dart** 수정

#### AccessoryDataManager 디버그 로깅 강화
Firebase에서 데이터 로드 시 상세 정보 출력:
- 각 악세사리별 세트옵션 개수
- 세트옵션별 필요한 이미지 목록
- 각 효과의 단계별 값 키 확인

```dart
if (kDebugMode) {
  debugPrint('[AccessoryDataManager] Loading accessory: $key');
  debugPrint('  - Set Options count: ${setOptionsList?.length ?? 0}');
  // ... 상세 정보 출력
}
```

---

## 예상 결과

### 수정 전
```
❌ 세트옵션 섹션에 broken_image 아이콘 표시
❌ 세트옵션 수치에 '-' 표시
❌ 이미지 로드 실패 원인 파악 불가
```

### 수정 후
```
✅ Firebase Storage에서 세트옵션 악세사리 이미지 정상 로드
✅ 세트옵션의 단계별 수치 정상 표시
✅ 이미지 로드 실패 시 콘솔에 URL 정보 출력
✅ 단계 전환 화살표로 각 단계의 수치 확인 가능
```

---

## Firebase 데이터 검증 체크리스트

다음 조건들을 Firebase 콘솔에서 확인하세요:

### 필수 데이터 구조
```json
{
  "setOptions": [
    {
      "setId": "set_001",
      "setName": "세트이름",
      "requiredAccessories": ["acc_id_1", "acc_id_2"],
      "requiredAccessoryImages": ["acc_id_1", "acc_id_2"],
      "effects": [
        {
          "optionName": "공격력 %증가",
          "stageValues": {
            "0": "5%",
            "1": "10%",
            ...
            "18": "95%"
          }
        }
      ]
    }
  ]
}
```

### 체크 항목
- [ ] `setOptions` 필드가 존재하고 배열 타입인가?
- [ ] `requiredAccessoryImages` 배열에 올바른 악세사리 ID가 저장되어 있는가?
- [ ] `stageValues`의 키가 `"0"`, `"1"`, ... `"18"`의 문자열 형식인가?
- [ ] 각 악세사리 ID에 해당하는 PNG 파일이 Firebase Storage의 `accessories/` 폴더에 있는가?

---

## 디버그 방법

### 콘솔 로그 확인
```
flutter run -d chrome
```

개발자 도구 콘솔(F12)에서 다음 로그 패턴 검색:
- `[AccessoryDataManager]` - 악세사리 로드 정보
- `[AccessorySetOption]` - 세트옵션 파싱 정보  
- `[SetOptionEffect]` - 효과 파싱 정보
- `[SetOption]` - UI 렌더링 시 이미지 로드 정보

이미지가 여전히 로드되지 않으면:
1. 콘솔에서 `Generated URL for` 로그로 생성된 URL 확인
2. 그 URL을 브라우저 새 탭에서 직접 열어 이미지 로드 가능 여부 확인
3. Firebase Storage 경로와 파일명 확인

---

## 수정 파일 목록
- `lib/data/models/accessory.dart` - SetOptionEffect, AccessorySetOption 개선
- `lib/presentation/accessory/accessory_screen.dart` - 세트옵션 수치 안전 처리 및 이미지 로드 실패 로깅
- `lib/core/constants/accessory_constants.dart` - AccessoryDataManager 디버그 로깅 강화
