// lib/calculator_logic.dart
import 'package:flutter/foundation.dart';
import 'constants/team_level_constants.dart';
import 'constants/lunar_base_constants.dart';
import 'constants/vip_constants.dart';
import 'constants/stage_constants.dart'; // stageBaseData getter 사용
import 'constants/leader_constants.dart';
import 'constants/monster_constants.dart';

import 'stage_calculation_service.dart';


class CalculatorLogic {
  final StageCalculationService _stageCalculationService = StageCalculationService();

  int calculateMaxStamina(String? teamLevel, String? vipLevel) {
    int baseStamina = 10;
    int teamLevelBonus = 0;
    int userLevel = int.tryParse(teamLevel ?? '0') ?? 0;
    if (userLevel > 0) {
      List<int> levelKeys = teamLevelMaxStaminaData.keys.toList();
      levelKeys.sort();
      int? effectiveLevelKey;
      for (int key in levelKeys) {
        if (key <= userLevel) {
          effectiveLevelKey = key;
        } else {
          break;
        }
      }
      if (effectiveLevelKey != null) {
        teamLevelBonus = teamLevelMaxStaminaData[effectiveLevelKey] ?? 0;
      }
    }
    int vipBonusValue = 0;
    int currentVipIndex = vipLevelOrder.indexOf(vipLevel ?? 'VIP14');
    if (currentVipIndex != -1) {
      for (int i = 0; i <= currentVipIndex; i++) {
        vipBonusValue += vipBonusData[vipLevelOrder[i]]?['stamina'] ?? 0;
      }
    }
    return baseStamina + teamLevelBonus + vipBonusValue;
  }

  int calculateAutoSwapSlots(String? vipLevel, String? dalgijiLevel) {
    int baseAutoSwap = 20;
    int vipBonusValue = 0;
    int currentVipIndex = vipLevelOrder.indexOf(vipLevel ?? 'VIP14');
    if (currentVipIndex != -1) {
        for (int i = 0; i <= currentVipIndex; i++) {
          vipBonusValue += vipBonusData[vipLevelOrder[i]]?['autoSwap'] ?? 0;
        }
      }
    int dalgijiBonus = 0;
    int dalgijiLevelInt = int.tryParse(dalgijiLevel ?? '0') ?? 0;
    dalgijiAutoSwapData.forEach((level, slots) {
      if (dalgijiLevelInt >= level) {
        dalgijiBonus += slots;
      }
    });
    return baseAutoSwap + vipBonusValue + dalgijiBonus;
  }

  double calculateFinalGoldPerLoop(String stageName, bool goldHotTime, bool goldBoost, String? vipLevel, String? selectedLeader) {
      final currentStageData = stageBaseData[stageName]; // getter 사용
      double baseGold = (currentStageData?['baseClearRewardGold'] as num?)?.toDouble() ?? 0.0;
      if (baseGold < 0) baseGold = 0;

      // 이벤트 스테이지의 경우 골드 핫타임 적용 여부 플래그 확인
      bool isEvent = currentStageData?['isEventStage'] as bool? ?? false;
      bool eventAppliesHotTimeGold = currentStageData?['applyHotTimeGoldBonus'] as bool? ?? (isEvent ? false : true);


      double hotTimeBonus = 0.0;
      double boostBonus = 0.0;

      bool applyHotTime = true;
      if (isEvent) {
        applyHotTime = eventAppliesHotTimeGold;
      } else {
        applyHotTime = !goldHotTimeExemptStages.contains(stageName);
      }

      if (goldHotTime && applyHotTime) {
          hotTimeBonus = baseGold * 0.2;
      }
      if (goldBoost) { // 골드 부스트는 이벤트 여부와 관계없이 적용될 수 있음 (별도 플래그 없다면)
          boostBonus = baseGold * 0.5;
      }

      double summedGold = baseGold + hotTimeBonus + boostBonus;
      double vipMultiplier = vipMultiplierBonuses[vipLevel]?['goldMultiplier'] ?? 1.0;
      double leaderMultiplier = leaderGoldMultipliers[selectedLeader ?? leaderList[0]] ?? 1.0;
      double finalGold = summedGold * vipMultiplier * leaderMultiplier;

      return finalGold.ceilToDouble();
  }


  double calculateGoldPerMin(String stageName, bool goldHotTime, bool goldBoost, String? clearTimeStr, String? vipLevel, String? selectedLeader) {
    double finalGoldPerLoop = calculateFinalGoldPerLoop(stageName, goldHotTime, goldBoost, vipLevel, selectedLeader);

    double? clearTimeDouble = double.tryParse(clearTimeStr ?? '');
    if (clearTimeDouble == null || clearTimeDouble <= 0) {
      return 0.0;
    }

    double goldPerMin = finalGoldPerLoop / (clearTimeDouble / 60.0);
    return goldPerMin;
  }

  // --- calculateFinalExpPerLoop 함수 수정 ---
  double calculateFinalExpPerLoop(String stageName, bool expHotTime, bool expBoost, bool pass, bool reverseElement, String? vipLevel) {
    final Map<String, dynamic>? currentStageData = stageBaseData[stageName]; // stageBaseData getter 사용
    if (currentStageData == null) {
      if (kDebugMode) print("[CalcLogic] Stage data not found for $stageName in calculateFinalExpPerLoop");
      return 0.0;
    }

    double baseExp = (currentStageData['baseClearRewardExp'] as num?)?.toDouble() ?? 0.0;
    if (baseExp <= 0) return 0.0;

    // 이벤트 스테이지 여부 및 보너스 적용 플래그 확인
    // 'isEventStage' 플래그가 없다면 일반 스테이지로 간주 (또는 필요시 false로 기본값 설정)
    bool isEvent = currentStageData['isEventStage'] as bool? ?? false;
    // 이벤트 스테이지이고 applyVipExpBonus 플래그가 false면 VIP 보너스 미적용. 플래그 없으면 일반 스테이지 규칙 따름.
    bool eventAppliesVipExp = currentStageData['applyVipExpBonus'] as bool? ?? (isEvent ? false : true);
    // 이벤트 스테이지이고 applyHotTimeExpBonus 플래그가 false면 핫타임 미적용. 플래그 없으면 일반 스테이지 규칙 따름.
    bool eventAppliesHotTimeExp = currentStageData['applyHotTimeExpBonus'] as bool? ?? (isEvent ? false : true);

    double boostBonus = 0.0;
    double passBonus = 0.0;
    double vipBonusValue = 0.0;
    double hotTimeBonus = 0.0;

    if (expBoost) { boostBonus = baseExp * 1.0; }
    if (pass) { passBonus = baseExp * 0.1; }

    // VIP 경험치 보너스 적용 로직 수정
    bool applyVipBonusNow = true;
    if (isEvent) {
      applyVipBonusNow = eventAppliesVipExp;
    } else {
      applyVipBonusNow = !vipExpBonusExemptStages.contains(stageName);
    }

    if (vipLevel != null && applyVipBonusNow) {
      double vipMultiplier = vipMultiplierBonuses[vipLevel]?['expMultiplier'] ?? 1.0;
      if (vipMultiplier > 1.0) { vipBonusValue = baseExp * (vipMultiplier - 1.0); }
    }

    // 경험치 핫타임 보너스 적용 로직 수정
    bool applyHotTimeExpNow = true;
    if (isEvent) {
      applyHotTimeExpNow = eventAppliesHotTimeExp;
    } else {
      applyHotTimeExpNow = !expHotTimeExemptStages.contains(stageName);
    }

    if (expHotTime && applyHotTimeExpNow) {
      hotTimeBonus = baseExp * 0.2;
    }

    double summedExp = baseExp + boostBonus + passBonus + vipBonusValue + hotTimeBonus;

    // 역속성 보너스 (이벤트 스테이지의 경우 별도 플래그 'applyReverseElementBonus'를 확인하거나, 일반적으로 미적용으로 가정)
    double reverseElementMultiplier = 1.0;
    bool allowReverseElementForThisStage = true;
    if (isEvent) {
        // 이벤트 스테이지는 역속 보너스를 기본적으로 받지 않는다고 가정. 필요시 'applyReverseElementBonus': true 플래그 추가.
        allowReverseElementForThisStage = currentStageData['applyReverseElementBonus'] as bool? ?? false;
    } else {
        allowReverseElementForThisStage = reverseElementAffectedStages.contains(stageName);
    }

    if (reverseElement && allowReverseElementForThisStage) {
      reverseElementMultiplier = 1.2;
    }

    double finalExp = summedExp * reverseElementMultiplier;
    
    if (kDebugMode) {
        print("[CalcLogic-FinalExp] Stage: $stageName, isEvent: $isEvent");
        print("[CalcLogic-FinalExp] BaseExp: $baseExp, VipBonus: $vipBonusValue (apply: $applyVipBonusNow), HotTime: $hotTimeBonus (apply: $applyHotTimeExpNow)");
        print("[CalcLogic-FinalExp] SummedExp: $summedExp, ReverseMult: $reverseElementMultiplier (allow: $allowReverseElementForThisStage)");
        print("[CalcLogic-FinalExp] Final Exp for $stageName: $finalExp");
    }

    return finalExp.ceilToDouble();
  }
  // --- calculateFinalExpPerLoop 함수 수정 끝 ---

  double calculateExpPerMin(String stageName, bool expHotTime, bool expBoost, bool pass, bool reverseElement, String? clearTimeStr, String? vipLevel) {
    double finalExpPerLoop = calculateFinalExpPerLoop(stageName, expHotTime, expBoost, pass, reverseElement, vipLevel);
    if (finalExpPerLoop <= 0) return 0.0;

    double? clearTimeDouble = double.tryParse(clearTimeStr ?? '');
    if (clearTimeDouble == null || clearTimeDouble <= 0) {
      return 0.0;
    }

    double expPerMin = finalExpPerLoop / (clearTimeDouble / 60.0);
    return expPerMin.ceilToDouble();
  }

  double calculateSoulStonesPerEffectiveLoop({ // 반환 타입 double로 유지 (이전 수정 반영)
      required String stageName,
      required String? selectedMonsterGrade,
      required String? jjolCountPerStageStr,
      required int autoSwapSlots,
      required double finalExpPerLoop,
      required int? requiredMonsterExp,
      required String? clearTimeStr,
      required String? teamLevel,
      required String? vipLevel,
    }) {
    const double sentinelNullReturn = -999999.0;

    final int rewardPerMonster = monsterRewardData[selectedMonsterGrade ?? ''] ?? 0;
    final int? jjolCount = int.tryParse(jjolCountPerStageStr ?? '');
    final double? clearTimePerRun = double.tryParse(clearTimeStr ?? '');
    final currentStageData = stageBaseData[stageName]; // getter 사용
    final double staminaCostPerRun = (currentStageData?['staminaCost'] as num?)?.toDouble() ?? 0.0;
    final int maxStamina = calculateMaxStamina(teamLevel, vipLevel);

    if (rewardPerMonster == 0 ||
        jjolCount == null || jjolCount <= 0 ||
        clearTimePerRun == null || clearTimePerRun <= 0 ||
        staminaCostPerRun <= 0 ||
        requiredMonsterExp == null || requiredMonsterExp <= 0 ||
        finalExpPerLoop <= 0 ||
        maxStamina <= 0) {
      if (kDebugMode) {
        print("[SoulStoneCalc] GUARD CLAUSE 1 HIT for $stageName. Returning sentinel $sentinelNullReturn. Values: reward=$rewardPerMonster, jjol=$jjolCount, clearTime=$clearTimePerRun, staminaCost=$staminaCostPerRun, reqExp=$requiredMonsterExp, finalExp=$finalExpPerLoop, maxStam=$maxStamina");
      }
      return sentinelNullReturn;
    }

    double? runsPerMonster = _stageCalculationService.calculateRunsToMax(finalExpPerLoop, requiredMonsterExp);
    if (runsPerMonster == null) {
      if (kDebugMode) {
        print("[SoulStoneCalc] GUARD CLAUSE 2 HIT for $stageName (runsPerMonster is null). Returning sentinel $sentinelNullReturn.");
      }
      return sentinelNullReturn;
    }

    double totalMonstersInSystem = (autoSwapSlots + jjolCount).toDouble();
    double batchesNeeded = (totalMonstersInSystem / jjolCount).ceilToDouble();
    double staminaPerMonster = runsPerMonster * staminaCostPerRun;

    double term1 = rewardPerMonster * totalMonstersInSystem;

    double staminaPart = staminaPerMonster * batchesNeeded;
    double timePartRaw = clearTimePerRun * runsPerMonster * batchesNeeded;
    double timePartFloored = timePartRaw.floorToDouble();
    double timePartAdjusted = timePartFloored / 300.0;
    double numerator = staminaPart - timePartAdjusted;
    double divisionResult = numerator / maxStamina;
    double flooredDivisionResult = divisionResult.floorToDouble();
    double term2 = 5.0 * flooredDivisionResult;

    double finalValue = term1 - term2;

    if (kDebugMode) {
      print("[SoulStoneCalc] Inputs for $stageName: grade=$selectedMonsterGrade, jjol=$jjolCount, slots=$autoSwapSlots, finalExp=$finalExpPerLoop, reqExp=$requiredMonsterExp, clearTime=$clearTimePerRun, teamLvl=$teamLevel, vip=$vipLevel");
      print("[SoulStoneCalc] Calculated for $stageName: reward=$rewardPerMonster, runs=$runsPerMonster, staminaCost=$staminaCostPerRun, maxStamina=$maxStamina");
      print("[SoulStoneCalc] Intermediate for $stageName: totalMonsters=$totalMonstersInSystem, batches=$batchesNeeded, staminaPerMonster=$staminaPerMonster");
      print("[SoulStoneCalc] Formula for $stageName: term1=$term1, staminaPart=$staminaPart, timePartRaw=$timePartRaw, timePartFloored=$timePartFloored, timePartAdjusted=$timePartAdjusted, numerator=$numerator");
      print("[SoulStoneCalc] Formula Term2 steps for $stageName: divisionResult(num/maxStam)=$divisionResult, flooredDivisionResult=$flooredDivisionResult, term2(5*floor)=$term2");
      print("-----------------------------------------------------");
      print("[SoulStoneCalc] FINAL VALUE for $stageName BEFORE RETURN: $finalValue");
      print("-----------------------------------------------------");
    }

    return finalValue;
  }
}