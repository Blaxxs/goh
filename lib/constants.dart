// lib/constants.dart

// --- 스테이지 기본 데이터 Import ---
import 'stage_data/angel_hell.dart';
import 'stage_data/angel_normal.dart';
import 'stage_data/alex.dart';
import 'stage_data/macheonru.dart';
import 'stage_data/gangrim.dart';
import 'stage_data/mulyong.dart';
import 'stage_data/satan_hell.dart';
import 'stage_data/satan_normal.dart';
import 'stage_data/mujin.dart';
import 'stage_data/yowon.dart';
import 'stage_data/test.dart';


// --- 기본 리스트 및 데이터 ---
const List<String> stageList = [
  '지옥엔젤', '일반엔젤', '알렉스', '마천루', '강림', '물용',
  '지옥사탄', '사탄', '무진', '요원','테스트',
];
const List<String> vipLevels = [
  'VIP14', 'VIP13', 'VIP12', 'VIP11', 'VIP10', 'VIP9', 'VIP8', 'VIP7', 'VIP6',
  'VIP5', 'VIP4', 'VIP3', 'VIP2', 'VIP1', 'VVIP3', 'VVIP2', 'VVIP1',
  'SVIP3', 'SVIP2', 'SVIP1', 'SSVIP3', 'SSVIP2', 'SSVIP1',
];
const List<String> jjolCounts = ['1', '2', '3', '4'];

// 팀 레벨별 최대 스테미너 데이터
const Map<int, int> teamLevelMaxStaminaData = {
   1: 0, 2: 0, 3: 2, 4: 2, 5: 4, 6: 4, 7: 6, 8: 6, 9: 8, 10: 8,
  11: 11, 12: 11, 13: 14, 14: 14, 15: 17, 16: 17, 17: 20, 18: 20, 19: 23, 20: 23,
  21: 26, 22: 26, 23: 29, 24: 29, 25: 32, 26: 32, 27: 35, 28: 35, 29: 38, 30: 38,
  31: 41, 32: 41, 33: 44, 34: 44, 35: 47, 36: 47, 37: 50, 38: 50, 39: 53, 40: 53,
  41: 60, 42: 60, 43: 63, 44: 63, 45: 66, 46: 66, 47: 69, 48: 69, 49: 72, 50: 72,
  51: 75, 52: 75, 53: 79, 54: 79, 55: 83, 56: 83, 57: 87, 58: 87, 59: 91, 60: 91,
  61: 95, 62: 95, 63: 99, 64: 99, 65: 103, 66: 103, 67: 107, 68: 107, 69: 111, 70: 111,
  71: 120, 72: 120, 73: 124, 74: 124, 75: 128, 76: 128, 77: 132, 78: 132, 79: 136, 80: 136,
  81: 140, 82: 140, 83: 144, 84: 144, 85: 148, 86: 148, 87: 152, 88: 152, 89: 156, 90: 156,
  91: 160, 92: 160, 93: 164, 94: 164, 95: 168, 96: 168, 97: 172, 98: 172, 99: 176, 100: 176,
  101: 180, 102: 180, 103: 184, 104: 184, 105: 188, 106: 188, 107: 192, 108: 192, 109: 196, 110: 196,
  111: 200, 112: 200, 113: 204, 114: 204, 115: 208, 116: 208, 117: 208, 118: 208, 119: 211, 120: 211,
  121: 211, 122: 211, 123: 214, 124: 214, 125: 214, 126: 214, 127: 217, 128: 217, 129: 217, 130: 217,
  131: 220, 132: 220, 133: 220, 134: 220, 135: 223, 136: 223, 137: 223, 138: 223, 139: 226, 140: 226,
  141: 226, 142: 226, 143: 229, 144: 229, 145: 229, 146: 229, 147: 232, 148: 232, 149: 232, 150: 232,
  151: 235, 152: 235, 153: 235, 154: 235, 155: 238, 156: 238, 157: 238, 158: 238, 159: 240, 160: 240,
  205: 243, 215: 246, 225: 249, 235: 252, 245: 255, 255: 258, 265: 261, 275: 264, 285: 267, 295: 270,
  300: 270, 350: 270, 400: 270, 450: 270, 500: 270, 550: 270, 600: 270, 650: 270, 700: 270,
};

// VIP 등급별 *추가* 보너스 데이터 (스테미너, 자동교체 슬롯)
const Map<String, Map<String, int>> vipBonusData = {
  'VIP14': {'stamina': 0, 'autoSwap': 0},
  'VIP13': {'stamina': 0, 'autoSwap': 10},
  'VIP12': {'stamina': 0, 'autoSwap': 0},
  'VIP11': {'stamina': 10, 'autoSwap': 0},
  'VIP10': {'stamina': 0, 'autoSwap': 0},
  'VIP9': {'stamina': 10, 'autoSwap': 0},
  'VIP8': {'stamina': 0, 'autoSwap': 0},
  'VIP7': {'stamina': 10, 'autoSwap': 0},
  'VIP6': {'stamina': 0, 'autoSwap': 0},
  'VIP5': {'stamina': 10, 'autoSwap': 0},
  'VIP4': {'stamina': 0, 'autoSwap': 0},
  'VIP3': {'stamina': 10, 'autoSwap': 0},
  'VIP2': {'stamina': 10, 'autoSwap': 0},
  'VIP1': {'stamina': 10, 'autoSwap': 0},
  'VVIP3': {'stamina': 0, 'autoSwap': 0},
  'VVIP2': {'stamina': 0, 'autoSwap': 0},
  'VVIP1': {'stamina': 0, 'autoSwap': 0},
  'SVIP3': {'stamina': 0, 'autoSwap': 0},
  'SVIP2': {'stamina': 0, 'autoSwap': 0},
  'SVIP1': {'stamina': 0, 'autoSwap': 0},
  'SSVIP3': {'stamina': 0, 'autoSwap': 10},
  'SSVIP2': {'stamina': 0, 'autoSwap': 10},
  'SSVIP1': {'stamina': 0, 'autoSwap': 10},
};

// VIP 등급별 *배율* 보너스 데이터 (경험치, 골드)
const Map<String, Map<String, double>> vipMultiplierBonuses = {
  'VIP14': {'expMultiplier': 1.0, 'goldMultiplier': 1.0},
  'VIP13': {'expMultiplier': 1.0, 'goldMultiplier': 1.03},
  'VIP12': {'expMultiplier': 1.0, 'goldMultiplier': 1.05},
  'VIP11': {'expMultiplier': 1.0, 'goldMultiplier': 1.05},
  'VIP10': {'expMultiplier': 1.0, 'goldMultiplier': 1.07},
  'VIP9': {'expMultiplier': 1.0, 'goldMultiplier': 1.07},
  'VIP8': {'expMultiplier': 1.005, 'goldMultiplier': 1.08},
  'VIP7': {'expMultiplier': 1.01, 'goldMultiplier': 1.09},
  'VIP6': {'expMultiplier': 1.015, 'goldMultiplier': 1.1},
  'VIP5': {'expMultiplier': 1.02, 'goldMultiplier': 1.11},
  'VIP4': {'expMultiplier': 1.025, 'goldMultiplier': 1.13},
  'VIP3': {'expMultiplier': 1.03, 'goldMultiplier': 1.15},
  'VIP2': {'expMultiplier': 1.035, 'goldMultiplier': 1.17},
  'VIP1': {'expMultiplier': 1.04, 'goldMultiplier': 1.2},
  'VVIP3': {'expMultiplier': 1.045, 'goldMultiplier': 1.2},
  'VVIP2': {'expMultiplier': 1.055, 'goldMultiplier': 1.2},
  'VVIP1': {'expMultiplier': 1.065, 'goldMultiplier': 1.2},
  'SVIP3': {'expMultiplier': 1.075, 'goldMultiplier': 1.2},
  'SVIP2': {'expMultiplier': 1.1, 'goldMultiplier': 1.2},
  'SVIP1': {'expMultiplier': 1.125, 'goldMultiplier': 1.2},
  'SSVIP3': {'expMultiplier': 1.15, 'goldMultiplier': 1.25},
  'SSVIP2': {'expMultiplier': 1.2, 'goldMultiplier': 1.3},
  'SSVIP1': {'expMultiplier': 1.25, 'goldMultiplier': 1.5},
};


// 달기지 레벨별 자동 교체 슬롯 보너스 데이터
const Map<int, int> dalgijiAutoSwapData = {
   5: 0, 20: 10, 40: 0, 60: 0, 80: 0, 90: 10, 120: 0, 140: 0, 160: 10, 180: 0, 200: 0,
};

// VIP 레벨 순서 (낮은 등급 -> 높은 등급)
const List<String> vipLevelOrder = [
  'VIP14', 'VIP13', 'VIP12', 'VIP11', 'VIP10', 'VIP9', 'VIP8', 'VIP7', 'VIP6',
  'VIP5', 'VIP4', 'VIP3', 'VIP2', 'VIP1', 'VVIP3', 'VVIP2', 'VVIP1',
  'SVIP3', 'SVIP2', 'SVIP1', 'SSVIP3', 'SSVIP2', 'SSVIP1',
];

// --- 리더 관련 데이터 ---
const List<String> leaderList = ['리더 없음', '라이엇', '박형숙'];
const Map<String, double> leaderGoldMultipliers = {
  '리더 없음': 1.0,
  '라이엇': 1.5,
  '박형숙': 1.2,
};

// --- 스테이지 기본 정보 ---
const Map<String, Map<String, dynamic>> stageBaseData = {
  '지옥엔젤': angelHellData,
  '일반엔젤': angelNormalData,
  '알렉스': alexData,
  '마천루': macheonruData,
  '강림': gangrimData,
  '물용': mulyongData,
  '지옥사탄': satanHellData,
  '사탄': satanNormalData,
  '무진': mujinData,
  '요원': yowonData,
  '테스트': testData,
};


// --- 몬스터(쫄) 관련 데이터 ---
const List<String> monsterNameList = ['엔젤', '타우로스', '물용', '까마귀', '요원'];
const List<String> monsterGradeList = ['4성', '5성', '6성'];

// *** 몬스터 등급별 만렙 보상 영혼석 (주석 해제 및 값 확인 필요) ***
const Map<String, int> monsterRewardData = {
  '4성': 2, // 예시 값, 실제 게임 데이터 확인 필요
  '5성': 5, // 예시 값, 실제 게임 데이터 확인 필요
  '6성': 10, // 예시 값, 실제 게임 데이터 확인 필요
};

// 몬스터 이름 및 등급별 만렙 필요 경험치
const Map<String, Map<String, int?>> monsterExpData = {
  '엔젤': { '4성': 220975, '5성': 421845, '6성': 2000000, },
  '타우로스': { '4성': 729313, '5성': 1500000, '6성': 3975940, },
  '물용': { '4성': 168838, '5성': 421845, '6성': 1166900, },
  '까마귀': { '4성': 220975, '5성': 623955, '6성': null, },
  '요원': { '4성': 168838, '5성': 421845, '6성': null, },
};

// --- 계산 예외 스테이지 목록 ---
const List<String> expHotTimeExemptStages = [
  '지옥엔젤', '강림', '지옥사탄', '요원',
];
const List<String> goldHotTimeExemptStages = [
  '지옥엔젤', '지옥사탄', '요원',
];
const List<String> reverseElementAffectedStages = [
  '강림', '요원', '물용','테스트',
];
const List<String> vipExpBonusExemptStages = [
  '강림',
];