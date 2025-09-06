// lib/gold_calculator_logic.dart
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../core/services/settings_service.dart';
import '../../core/constants/stage_constants.dart';
import '../../core/constants/drop_item_constants.dart';
import 'calculator_logic.dart';

class GoldEfficiencyResult {
  final String stageName;
  final String location;
  final double baseStageGold;
  final double finalGoldPerSingleRunNoBonus;
  final double finalGoldPerSingleRunWithBonus;
  final double runsOverSelectedDuration;
  final double expectedGoldFromStage;
  final double expectedGoldFromDemons;
  final double totalExpectedGold;
  final Map<String, double> expectedDemonCounts;
  final double? clearTimeSeconds; // <--- 필드 추가 (nullable)

  GoldEfficiencyResult({
    required this.stageName,
    required this.location,
    required this.baseStageGold,
    required this.finalGoldPerSingleRunNoBonus,
    required this.finalGoldPerSingleRunWithBonus,
    required this.runsOverSelectedDuration,
    required this.expectedGoldFromStage,
    required this.expectedGoldFromDemons,
    required this.totalExpectedGold,
    required this.expectedDemonCounts,
    required this.clearTimeSeconds, // <--- 생성자 파라미터 추가
  });

  // get clearTimeSeconds => null; // <--- 이 라인 삭제
}

class GoldCalculatorLogic {
  final CalculatorLogic _baseCalculatorLogic = CalculatorLogic();

  List<GoldEfficiencyResult> calculateForAllStages({
    required int selectedDurationMinutes,
    required StageSettings stageSettings,
    required CalculatorSettings bonusSettings,
    required bool sellGoldDemons,
    int? boostDurationMinutesFromUI,
  }) {
    List<GoldEfficiencyResult> results = [];
    if (selectedDurationMinutes <= 0) return results;

    final double totalSelectedSeconds = (selectedDurationMinutes * 60).toDouble();

    for (String stageName in stageNameList) {
      final stageData = stageBaseData[stageName];
      if (stageData == null) {
        if (kDebugMode) {
          print('Stage data not found for $stageName in GoldCalculatorLogic');
        }
        continue;
      }

      final String? clearTimeStr = stageSettings.stageClearTimes[stageName];
      final double? clearTimeSeconds = double.tryParse(clearTimeStr ?? ''); // 이 값을 사용
      final String location = stageData['location'] as String? ?? '위치 정보 없음';
      final double baseStageGold = (stageData['baseClearRewardGold'] as num?)?.toDouble() ?? 0.0;

      final double finalGoldPerRunNoTimeNoBoostLeaderVip = _baseCalculatorLogic.calculateFinalGoldPerLoop(
        stageName, false, false, stageSettings.vipLevel, bonusSettings.selectedLeader,
      );
      final double finalGoldPerRunWithAllCurrentBonuses = _baseCalculatorLogic.calculateFinalGoldPerLoop(
        stageName, bonusSettings.goldHotTime, bonusSettings.goldBoost, stageSettings.vipLevel, bonusSettings.selectedLeader,
      );

      // clearTimeSeconds가 null이거나 0 이하일 때 (스테이지 설정 미완료 시)
      if (clearTimeSeconds == null || clearTimeSeconds <= 0) {
        results.add(GoldEfficiencyResult(
          stageName: stageName,
          location: location,
          baseStageGold: baseStageGold,
          finalGoldPerSingleRunNoBonus: finalGoldPerRunNoTimeNoBoostLeaderVip,
          finalGoldPerSingleRunWithBonus: finalGoldPerRunWithAllCurrentBonuses,
          runsOverSelectedDuration: 0,
          expectedGoldFromStage: 0,
          expectedGoldFromDemons: 0,
          totalExpectedGold: 0,
          expectedDemonCounts: {},
          clearTimeSeconds: clearTimeSeconds, // null 또는 0 이하 값 전달
        ));
        continue;
      }

      // --- 이하 로직에서 clearTimeSeconds는 유효한 양수라고 가정 ---
      final double runsOverSelectedDuration = (totalSelectedSeconds / clearTimeSeconds).floorToDouble();
      double expectedGoldFromStage = 0;

      if (runsOverSelectedDuration > 0) {
        final double baseGoldPerRunForBonusCalc = finalGoldPerRunNoTimeNoBoostLeaderVip;
        double hotTimeBonusAmountPerRun = 0;
        if (bonusSettings.goldHotTime) {
          final double goldWithHotTimeOnly = _baseCalculatorLogic.calculateFinalGoldPerLoop(
              stageName, true, false, stageSettings.vipLevel, bonusSettings.selectedLeader);
          hotTimeBonusAmountPerRun = goldWithHotTimeOnly - baseGoldPerRunForBonusCalc;
        }
        double boostBonusAmountPerRun = 0;
        if (bonusSettings.goldBoost) {
          final double goldWithBoostOnly = _baseCalculatorLogic.calculateFinalGoldPerLoop(
              stageName, false, true, stageSettings.vipLevel, bonusSettings.selectedLeader);
          boostBonusAmountPerRun = goldWithBoostOnly - baseGoldPerRunForBonusCalc;
        }
        double totalBonusGoldFromHotTime = 0;
        double totalBonusGoldFromBoost = 0;
        if (bonusSettings.goldHotTime) {
            const int hotTimeDurationLimitMinutes = 120;
            final double hotTimeDurationLimitSeconds = (hotTimeDurationLimitMinutes * 60).toDouble();
            double runsPossibleInHotTimeWindow = (hotTimeDurationLimitSeconds / clearTimeSeconds).floorToDouble();
            double runsActuallyInHotTime = min(runsOverSelectedDuration, runsPossibleInHotTimeWindow);
            totalBonusGoldFromHotTime = runsActuallyInHotTime * hotTimeBonusAmountPerRun;
        }
        if (bonusSettings.goldBoost && boostDurationMinutesFromUI != null && boostDurationMinutesFromUI > 0) {
            final double boostDurationLimitSeconds = (boostDurationMinutesFromUI * 60).toDouble();
            double runsPossibleInBoostWindow = (boostDurationLimitSeconds / clearTimeSeconds).floorToDouble();
            double runsActuallyInBoost = min(runsOverSelectedDuration, runsPossibleInBoostWindow);
            totalBonusGoldFromBoost = runsActuallyInBoost * boostBonusAmountPerRun;
        } else if (bonusSettings.goldBoost) {
            totalBonusGoldFromBoost = runsOverSelectedDuration * boostBonusAmountPerRun;
        }
        expectedGoldFromStage = (baseGoldPerRunForBonusCalc * runsOverSelectedDuration) +
                                totalBonusGoldFromHotTime +
                                totalBonusGoldFromBoost;
      } else {
         results.add(GoldEfficiencyResult(
          stageName: stageName,
          location: location,
          baseStageGold: baseStageGold,
          finalGoldPerSingleRunNoBonus: finalGoldPerRunNoTimeNoBoostLeaderVip,
          finalGoldPerSingleRunWithBonus: finalGoldPerRunWithAllCurrentBonuses,
          runsOverSelectedDuration: 0,
          expectedGoldFromStage: 0,
          expectedGoldFromDemons: 0,
          totalExpectedGold: 0,
          expectedDemonCounts: {},
          clearTimeSeconds: clearTimeSeconds, // 유효하지만 runsOverSelectedDuration이 0인 경우
        ));
        continue;
      }

      double expectedGoldFromDemons = 0;
      Map<String, double> expectedDemonCounts = {};
      final List<DropInfo>? drops = (stageData['drops'] as List<dynamic>?)
          ?.whereType<DropInfo>().toList();

      if (drops != null && drops.isNotEmpty) {
        for (DropInfo dropInfo in drops) {
          if (dropInfo.category == DropCategory.goldDemon && goldDemonSellPrices.containsKey(dropInfo.itemId)) {
            double averageQuantityDropped = (dropInfo.minQuantity + dropInfo.maxQuantity) / 2.0;
            double expectedCountOfThisDemon = runsOverSelectedDuration * dropInfo.probability * averageQuantityDropped;
            expectedDemonCounts[dropInfo.itemId] = (expectedDemonCounts[dropInfo.itemId] ?? 0) + expectedCountOfThisDemon;
            expectedGoldFromDemons += expectedCountOfThisDemon * (goldDemonSellPrices[dropInfo.itemId] ?? 0);
          }
        }
      }

      final double totalExpectedGold = expectedGoldFromStage + (sellGoldDemons ? expectedGoldFromDemons : 0);

      results.add(GoldEfficiencyResult(
        stageName: stageName,
        location: location,
        baseStageGold: baseStageGold,
        finalGoldPerSingleRunNoBonus: finalGoldPerRunNoTimeNoBoostLeaderVip,
        finalGoldPerSingleRunWithBonus: finalGoldPerRunWithAllCurrentBonuses,
        runsOverSelectedDuration: runsOverSelectedDuration,
        expectedGoldFromStage: expectedGoldFromStage,
        expectedGoldFromDemons: expectedGoldFromDemons,
        totalExpectedGold: totalExpectedGold,
        expectedDemonCounts: expectedDemonCounts,
        clearTimeSeconds: clearTimeSeconds, // <--- 계산된 clearTimeSeconds 전달
      ));
    }
    return results;
  }
}