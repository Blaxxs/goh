// lib/constants/stage_constants.dart

// --- 스테이지 기본 데이터 Import ---
// 각 스테이지별 상세 데이터 파일 import
import '../stage_data/angel_hell.dart';
import '../stage_data/angel_normal.dart';
import '../stage_data/alex.dart';
import '../stage_data/macheonru.dart';
import '../stage_data/gangrim.dart';
import '../stage_data/mulyong.dart';
import '../stage_data/satan_hell.dart';
import '../stage_data/satan_normal.dart';
import '../stage_data/mujin.dart';
import '../stage_data/yowon.dart';
import '../event_manager.dart'; // EventManager import

// --- 스테이지 관련 상수 ---

// 앱에서 다루는 모든 스테이지의 "이름" 목록을 반환하는 getter
// UI 표시 순서 및 식별자 역할
List<String> get stageNameList {
  List<String> names = [
    // 일반 스테이지 이름 (표시하고 싶은 순서대로)
    '사탄',
    '지옥사탄',
    '일반엔젤',
    '지옥엔젤',
    '알렉스',
    '마천루',
    '물용',
    '무진',
    '요원',
    '강림'
  ];

  // EventManager를 통해 현재 활성화된 이벤트 스테이지의 '이름'을 가져와 목록에 추가
  // EventManager.isEventPeriodActive() 와 eventStagesData 가 정의되어 있다고 가정합니다.
  if (EventManager.isEventPeriodActive()) {
    EventManager.eventStagesData.forEach((eventStageId, eventStageInfo) {
      // eventStageInfo Map 안에 'name' 키가 있고, 그 값이 String이라고 가정합니다.
      if (eventStageInfo['name'] != null && eventStageInfo['name'] is String) {
        if (!names.contains(eventStageInfo['name'] as String)) { // 중복 추가 방지
          names.add(eventStageInfo['name'] as String);
        }
      }
    });
  }
  return names;
}

// 모든 스테이지(일반 + 활성화된 이벤트)의 상세 데이터를 통합하여 반환하는 getter
// 스테이지 "이름"을 키로 하고, 해당 스테이지의 상세 정보(Map)를 값으로 가집니다.
Map<String, Map<String, dynamic>> get stageBaseData {
  Map<String, Map<String, dynamic>> allStageData = {
    // 일반 스테이지 데이터
    '사탄': satanNormalData,
    '지옥사탄': satanHellData,
    '일반엔젤': angelNormalData,
    '지옥엔젤': angelHellData,
    '알렉스': alexData,
    '마천루': macheonruData,
    '물용': mulyongData,
    '무진': mujinData,
    '요원': yowonData,
    '강림': gangrimData,
  };

  // EventManager를 통해 현재 활성화된 이벤트 스테이지 데이터를 가져와 추가/덮어쓰기
  if (EventManager.isEventPeriodActive()) {
    EventManager.eventStagesData.forEach((eventStageId, eventStageInfo) {
      if (eventStageInfo['name'] != null && eventStageInfo['name'] is String) {
        // eventStageInfo 자체가 상세 데이터 Map이므로 그대로 할당
        // applyVipExpBonus, applyHotTimeExpBonus, isEventStage 등의 플래그가 포함되어 있다고 가정
        allStageData[eventStageInfo['name'] as String] = eventStageInfo;
      }
    });
  }
  return allStageData;
}

// --- 계산 예외 스테이지 목록 (일반 스테이지 대상) ---
// 아래 목록의 스테이지 이름들은 stageNameList 및 stageBaseData의 키(스테이지 이름)와 일치해야 합니다.

// 경험치 핫타임 적용 예외 스테이지 (일반 스테이지용)
const List<String> expHotTimeExemptStages = [
  '지옥엔젤',
  '강림',
  '지옥사탄',
  '요원',
];

// 골드 핫타임 적용 예외 스테이지 (일반 스테이지용)
const List<String> goldHotTimeExemptStages = [
  '지옥엔젤',
  '지옥사탄',
  '요원',
];

// 역속성 보너스 적용 대상 스테이지 (일반 스테이지용)
const List<String> reverseElementAffectedStages = [
  '강림',
  '요원',
  '물용',
];

// VIP 경험치 보너스 적용 예외 스테이지 (일반 스테이지용)
const List<String> vipExpBonusExemptStages = [
  '강림',
];