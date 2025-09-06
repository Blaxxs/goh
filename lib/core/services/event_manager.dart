// lib/event_manager.dart
// KST (한국 표준시) 기준으로 DateTime 객체를 생성하기 위한 helper
// DateTime.parse()는 UTC를 기본으로 해석하므로, KST 오프셋(+9시간)을 고려해야 합니다.
// 2025년 7월 23일 09시 59분 59초 KST는 UTC로는 2025년 7월 23일 00시 59분 59초 UTC 입니다.
// 또는 DateTime 생성 시 isUtc: false (기본값) 로 하고, 비교 시 .toUtc()를 사용할 수 있습니다.
// 여기서는 명시적으로 UTC 시간을 사용하겠습니다.
final DateTime _eventEndTimeUtc = DateTime.utc(2025, 7, 23, 0, 59, 59);

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
    // --- 신규 이벤트 스테이지 ---
    'EVENT_STAGE_03': {
      'name': '콜라보 스테이지1',
      'location': '콜라보 스테이지_개최! 최대 토너먼트',
      'baseClearRewardExp': 15000.0,
      'baseClearRewardGold': 0.0,
      'staminaCost': 30.0,
      'applyVipExpBonus': false,
      'applyHotTimeExpBonus': false,
      'isEventStage': true,
    },
    'EVENT_STAGE_04': {
      'name': '콜라보 스테이지2',
      'location': '콜라보 스테이지_초절! 감옥 배틀',
      'baseClearRewardExp': 25000.0,
      'baseClearRewardGold': 0.0,
      'staminaCost': 25.0,
      'applyVipExpBonus': false,
      'applyHotTimeExpBonus': false,
      'isEventStage': true,
    },
    'EVENT_STAGE_05': {
      'name': '콜라보 스테이지3',
      'location': '콜라보 스테이지_고대에서 온 전사',
      'baseClearRewardExp': 50000.0,
      'baseClearRewardGold': 0.0,
      'staminaCost': 25.0,
      'applyVipExpBonus': false,
      'applyHotTimeExpBonus': false,
      'isEventStage': true,
    },
    'EVENT_STAGE_06': {
      'name': '콜라보 스테이지4',
      'location': '콜라보 스테이지_사상 최강의 부자싸움',
      'baseClearRewardExp': 100000.0,
      'baseClearRewardGold': 0.0,
      'staminaCost': 50.0,
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