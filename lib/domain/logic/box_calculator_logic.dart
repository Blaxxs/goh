// lib/domain/logic/box_calculator_logic.dart
import '../../core/constants/box_constants.dart';

// 계산 결과를 담을 클래스
class ExpectedValueResult {
  final String itemName;
  final double expectedValue;

  ExpectedValueResult({required this.itemName, required this.expectedValue});
}

// `calculate` 메서드의 반환 타입을 위한 클래스
class CalculationOutput {
  final List<ExpectedValueResult> results;
  final int totalGoldCost;

  CalculationOutput({required this.results, required this.totalGoldCost});
}

// 보상 아이템의 데이터 구조
class Reward {
  final String name; // 아이템 이름
  final int quantity; // 1회 획득 시 수량
  final double probability; // 획득 확률 (0.0 ~ 1.0)

  const Reward({
    required this.name,
    required this.quantity,
    required this.probability,
  });
}

// 각 상자의 데이터(비용, 아이템별 기대값)를 담을 클래스 (내부 구현용)
class _BoxData {
  final int cost;
  final List<Reward> rewards; // 보상 목록

  const _BoxData({required this.cost, required this.rewards});
}

class BoxCalculatorLogic {
  // 각 상자 종류별 데이터 정의
  static final Map<String, _BoxData> _boxDataMap = {
    normalBox: const _BoxData(
      cost: 100000,
      rewards: [
        Reward(name: '무지개 비스킷', quantity: 1, probability: 0.75),
        Reward(name: '은코인', quantity: 1, probability: 0.125),
        Reward(name: '금코인', quantity: 1, probability: 0.025),
        Reward(name: '희귀 BOX', quantity: 1, probability: 0.1),
      ],
    ),
    rareBox: const _BoxData(
      cost: 500000,
      rewards: [
        Reward(name: '4성 부적', quantity: 1, probability: 0.1),
        Reward(name: '5성 부적', quantity: 1, probability: 0.05),
        Reward(name: '비스킹', quantity: 1, probability: 0.15),
        Reward(name: '숯돌이', quantity: 50, probability: 0.1),
        Reward(name: '신기 티켓', quantity: 1, probability: 0.1),
        Reward(name: '금코인', quantity: 5, probability: 0.085),
        Reward(name: '속성석', quantity: 15, probability: 0.3),
        Reward(name: '씨앗', quantity: 1, probability: 0.065),
        Reward(name: '싸움의 흔적 조각(100개 = 악세사리 1개)', quantity: 100, probability: 0.0125),
        Reward(name: '손수건 조각(100개 = 악세사리 1개)', quantity: 100, probability: 0.0125),
        Reward(name: '전설 BOX', quantity: 1, probability: 0.025),
      ],
    ),
    legendaryBox: const _BoxData(
      cost: 5000000,
      rewards: [
        Reward(name: '콜라보 스피릿', quantity: 25, probability: 0.225),
        Reward(name: '금코인', quantity: 10, probability: 0.055),
        Reward(name: '금코인', quantity: 15, probability: 0.05),
        Reward(name: '금코인', quantity: 20, probability: 0.04),
        Reward(name: '금코인', quantity: 50, probability: 0.01),
        Reward(name: '5성 부적', quantity: 1, probability: 0.05),
        Reward(name: '6성 부적', quantity: 1, probability: 0.05),
        Reward(name: '5성 금각인형', quantity: 1, probability: 0.05),
        Reward(name: '6성 금각인형', quantity: 1, probability: 0.05),
        Reward(name: '영혼석', quantity: 100, probability: 0.05),
        Reward(name: '영혼석', quantity: 500, probability: 0.01),
        Reward(name: '숯돌이', quantity: 300, probability: 0.1),
        Reward(name: '무지개모루 조각(100개 = 1무지개모루)', quantity: 5, probability: 0.03),
        Reward(name: '선령환', quantity: 1, probability: 0.115),
        Reward(name: '콜라보 석판', quantity: 1, probability: 0.095),
        Reward(name: '스피릿 조커 선택권 조각', quantity: 1, probability: 0.01),
        Reward(name: '조커 조각(120개 = 1조커)', quantity: 12, probability: 0.01),
      ],
    ),
  };

  // 보상 목록 정렬 순서 정의
  static const List<String> _rewardSortOrderTop = [
    '금코인',
    '은코인',
    '영혼석',
    '조커 조각(120개 = 1조커)',
    '무지개모루 조각(100개 = 1무지개모루)',
    '콜라보 석판',
    '스피릿 조커 선택권 조각', // "조커 선택권 조각"
    '콜라보 스피릿', // "스피릿 조커 선택권"
    '싸움의 흔적 조각(100개 = 악세사리 1개)',
    '손수건 조각(100개 = 악세사리 1개)',
    '숯돌이',
    '선령환',
    '씨앗',
    '속성석',
    '무지개 비스킷',
    '비스킹',
  ];

  static const List<String> _rewardSortOrderBottom = [
    '4성 부적',
    '5성 부적',
    '6성 부적',
    '5성 금각인형',
    '6성 금각인형',
  ];

  // 계산 로직
  CalculationOutput calculate({
    int normalBoxCount = 0,
    int rareBoxCount = 0,
    int legendaryBoxCount = 0,
  }) {
    int totalCost = 0;
    final Map<String, double> totalExpectedQuantities = {};
    const Set<String> boxItemNames = {'희귀 BOX', '전설 BOX'};

    // 개봉할 상자 목록 (정수 단위)
    int normalToOpen = normalBoxCount;
    int rareToOpen = rareBoxCount;
    int legendaryToOpen = legendaryBoxCount;

    // 보상으로 얻는 상자의 기대값 (소수점 포함)
    double pendingRare = 0.0;
    double pendingLegendary = 0.0;

    // 상위 상자가 1개 이상 생성되는 한 계속 반복하여 계산
    while (true) {
      // 현재 개봉할 상자가 없으면 반복 중단
      if (normalToOpen == 0 && rareToOpen == 0 && legendaryToOpen == 0) break;

      // 일반 상자 개봉
      if (normalToOpen > 0) {
        final boxData = _boxDataMap[normalBox]!;
        totalCost += normalToOpen * boxData.cost;
        for (final reward in boxData.rewards) {
          if (reward.name == '희귀 BOX') {
            pendingRare += normalToOpen * reward.probability * reward.quantity;
          } else {
            final expected = normalToOpen * reward.probability * reward.quantity;
            totalExpectedQuantities.update(reward.name, (v) => v + expected, ifAbsent: () => expected);
          }
        }
      }

      // 희귀 상자 개봉
      if (rareToOpen > 0) {
        final boxData = _boxDataMap[rareBox]!;
        totalCost += rareToOpen * boxData.cost;
        for (final reward in boxData.rewards) {
          if (reward.name == '전설 BOX') {
            pendingLegendary += rareToOpen * reward.probability * reward.quantity;
          } else if (!boxItemNames.contains(reward.name)) {
            final expected = rareToOpen * reward.probability * reward.quantity;
            totalExpectedQuantities.update(reward.name, (v) => v + expected, ifAbsent: () => expected);
          }
        }
      }

      // 전설 상자 개봉
      if (legendaryToOpen > 0) {
        final boxData = _boxDataMap[legendaryBox]!;
        totalCost += legendaryToOpen * boxData.cost;
        for (final reward in boxData.rewards) {
          if (!boxItemNames.contains(reward.name)) {
            final expected = legendaryToOpen * reward.probability * reward.quantity;
            totalExpectedQuantities.update(reward.name, (v) => v + expected, ifAbsent: () => expected);
          }
        }
      }

      // 다음 반복에서 개봉할 상자 개수 계산 (정수 부분만)
      normalToOpen = 0; // 일반 상자는 생성되지 않음
      rareToOpen = pendingRare.floor();
      pendingRare -= rareToOpen; // 소수점 부분은 남겨둠

      legendaryToOpen = pendingLegendary.floor();
      pendingLegendary -= legendaryToOpen; // 소수점 부분은 남겨둠
    }

    // 반복문 종료 후 남은 소수점 기대값 처리
    // 남은 희귀 상자 기대값 처리
    if (pendingRare > 0) {
      final boxData = _boxDataMap[rareBox]!;
      totalCost += (pendingRare * boxData.cost).round();
      for (final reward in boxData.rewards) {
        if (reward.name == '전설 BOX') {
          pendingLegendary += pendingRare * reward.probability * reward.quantity;
        } else if (!boxItemNames.contains(reward.name)) {
          final expected = pendingRare * reward.probability * reward.quantity;
          totalExpectedQuantities.update(reward.name, (v) => v + expected, ifAbsent: () => expected);
        }
      }
    }

    // 남은 전설 상자 기대값 처리 (희귀 상자에서 추가된 부분 포함)
    if (pendingLegendary > 0) {
      final boxData = _boxDataMap[legendaryBox]!;
      totalCost += (pendingLegendary * boxData.cost).round();
      for (final reward in boxData.rewards) {
        if (!boxItemNames.contains(reward.name)) {
          final expected = pendingLegendary * reward.probability * reward.quantity;
          totalExpectedQuantities.update(reward.name, (v) => v + expected, ifAbsent: () => expected);
        }
      }
    }

    final results = totalExpectedQuantities.entries.map((e) => ExpectedValueResult(itemName: e.key, expectedValue: e.value)).toList();

    // 사용자 정의 순서에 따라 결과 목록 정렬
    results.sort((a, b) {
      int getCategory(String name) {
        if (_rewardSortOrderTop.contains(name)) return 0; // 상단 그룹
        if (_rewardSortOrderBottom.contains(name)) return 2; // 하단 그룹
        return 1; // 중간 그룹 (기타)
      }

      final categoryA = getCategory(a.itemName);
      final categoryB = getCategory(b.itemName);

      if (categoryA != categoryB) {
        return categoryA.compareTo(categoryB);
      }

      // 같은 그룹 내에서는 정의된 순서 또는 알파벳 순으로 정렬
      if (categoryA == 0) {
        return _rewardSortOrderTop.indexOf(a.itemName).compareTo(_rewardSortOrderTop.indexOf(b.itemName));
      } else if (categoryA == 2) {
        return _rewardSortOrderBottom.indexOf(a.itemName).compareTo(_rewardSortOrderBottom.indexOf(b.itemName));
      }
      return a.itemName.compareTo(b.itemName); // 중간 그룹은 알파벳순
    });

    return CalculationOutput(results: results, totalGoldCost: totalCost);
  }
}