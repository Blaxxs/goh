// lib/constants/vip_constants.dart

// --- VIP 관련 상수 ---

// VIP 등급 목록
const List<String> vipLevels = [
  'VIP14', 'VIP13', 'VIP12', 'VIP11', 'VIP10', 'VIP9', 'VIP8', 'VIP7', 'VIP6',
  'VIP5', 'VIP4', 'VIP3', 'VIP2', 'VIP1', 'VVIP3', 'VVIP2', 'VVIP1',
  'SVIP3', 'SVIP2', 'SVIP1', 'SSVIP3', 'SSVIP2', 'SSVIP1',
];

// VIP 등급별 *추가* 보너스 데이터 (스테미너, 자동교체 슬롯 - 누적 적용됨)
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

// VIP 등급별 *배율* 보너스 데이터 (경험치, 골드 - 해당 등급의 최종 배율)
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

// VIP 레벨 순서 (낮은 등급 -> 높은 등급), 보너스 누적 계산 시 사용
const List<String> vipLevelOrder = [
  'VIP14', 'VIP13', 'VIP12', 'VIP11', 'VIP10', 'VIP9', 'VIP8', 'VIP7', 'VIP6',
  'VIP5', 'VIP4', 'VIP3', 'VIP2', 'VIP1', 'VVIP3', 'VVIP2', 'VVIP1',
  'SVIP3', 'SVIP2', 'SVIP1', 'SSVIP3', 'SSVIP2', 'SSVIP1',
];