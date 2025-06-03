// lib/event_manager.dart
// KST (한국 표준시) 기준으로 DateTime 객체를 생성하기 위한 helper
// DateTime.parse()는 UTC를 기본으로 해석하므로, KST 오프셋(+9시간)을 고려해야 합니다.
// 하지만 여기서는 종료 시점을 명확히 하기 위해 UTC로 변환된 시간을 사용하는 것이 더 안전할 수 있습니다.
// 2025년 5월 11일 23시 59분 29초 KST는 UTC로는 2025년 5월 11일 14시 59분 29초 UTC 입니다.
// 또는 DateTime 생성 시 isUtc: false (기본값) 로 하고, 비교 시 .toUtc()를 사용할 수 있습니다.
// 여기서는 명시적으로 UTC 시간을 사용하겠습니다.
final DateTime _eventEndTimeUtc = DateTime.utc(2025, 5, 11, 14, 59, 29);

class EventManager {
  // --- !!! 이벤트 관리 핵심 설정 !!! ---
  // 이벤트 활성화 여부: true로 바꾸면 이벤트 던전이 나타나고, false로 바꾸면 사라집니다.
  static const bool isEventActive = true; // <--- 이 값을 true/false로 변경하여 이벤트 제어

  // 이벤트 종료 시간 (UTC 기준)
  static final DateTime eventEndTimeUtc = _eventEndTimeUtc;
  // --- !!! 설정 끝 !!! ---

  // 현재 시간이 이벤트 기간 내인지 확인하는 함수
  static bool isEventPeriodActive() {
    if (!isEventActive) return false;
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.isBefore(eventEndTimeUtc);
  }

  // 이벤트 스테이지 데이터 정의
  // 기존 stage_constants.dart 의 stageBaseData 와 유사한 구조 사용
  static const Map<String, Map<String, dynamic>> eventStagesData = {
    'EVENT_STAGE_01': {
      'name': '어쩔티비',
      'location': '이벤트 하급',
      'baseClearRewardExp': 25000.0,
      'baseClearRewardGold': 0.0,
      'staminaCost': 30.0,
      'applyVipExpBonus': false, // VIP 경험치 보너스 적용 안함
      'applyHotTimeExpBonus': false, // 핫타임 경험치 보너스 적용 안함
      'isEventStage': true, // 이벤트 스테이지 식별자
    },
    'EVENT_STAGE_02': {
      'name': '저쩔티비',
      'location': '이벤트 상급',
      'baseClearRewardExp': 55000.0,
      'baseClearRewardGold': 0.0,
      'staminaCost': 55.0,
      'applyVipExpBonus': false,
      'applyHotTimeExpBonus': false,
      'isEventStage': true,
    },
  };

 // 활성화된 이벤트 스테이지 ID 목록 반환
  static List<String> get eventStageIds {
    if (!isEventPeriodActive()) {
      return [];
    }
    return eventStagesData.keys.toList();
  }

  // 모든 활성화된 이벤트 스테이지 데이터 반환
  static Map<String, Map<String, dynamic>> get activeEventStagesData {
    if (!isEventPeriodActive()) {
      return {};
    }
    return eventStagesData;
  }
}