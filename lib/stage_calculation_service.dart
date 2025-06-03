// lib/stage_calculation_service.dart
// import 'dart:math'; // ceilToDouble은 double 타입에 내장되어 있으므로 제거 가능
// 변경: monsterExpData 사용 위해 monster_constants.dart import 필요
import 'constants/monster_constants.dart';

class StageCalculationService {

  int? getMonsterRequiredExp(String? monsterName, String? monsterGrade) {
    if (monsterName == null || monsterGrade == null) {
      return null;
    }
    // 변경: monsterExpData 사용 위해 monster_constants.dart import 필요
    return monsterExpData[monsterName]?[monsterGrade];
  }

  double? calculateRunsToMax(double finalExpPerLoop, int? requiredExp) {
    if (requiredExp == null || requiredExp <= 0 || finalExpPerLoop <= 0) {
      return null;
    }
    double runs = requiredExp / finalExpPerLoop;
    return runs.ceilToDouble();
  }

  double? calculateTotalLoops(int autoSwapSlots, String? jjolCountPerStageStr, double? runsPerMonster) {
    int? jjolCount = int.tryParse(jjolCountPerStageStr ?? '');
    if (jjolCount == null || jjolCount <= 0 || runsPerMonster == null || runsPerMonster <= 0) {
      return null;
    }
    double totalMonsters = (autoSwapSlots + jjolCount).toDouble();
    double numberOfBatches = (totalMonsters / jjolCount).ceilToDouble();
    double totalLoops = numberOfBatches * runsPerMonster;
    return totalLoops.ceilToDouble();
  }
}