import 'dart:math';

import '../../core/constants/accessory_constants.dart';
import '../../core/constants/random_accessory_constants.dart';
import '../../data/models/accessory.dart';

class AccessoryOptionRollLogic {
  static const List<AccessoryOption> defaultChangeableOptions = [
    AccessoryOption(
      optionName: AccessoryOptionNames.attackPowerFlat,
      optionValue: '2000',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.hpFlat,
      optionValue: '10000',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.critDamageFlat,
      optionValue: '55',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.critChanceFlat,
      optionValue: '47',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.critResistFlat,
      optionValue: '47',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.accuracyFlat,
      optionValue: '55',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.evasionFlat,
      optionValue: '45',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.activeSkillDmgPercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.activeSkillDmgTakenReducePercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.basicAtkDmgPercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.basicAtkDmgTakenReducePercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.dotDmgPercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.dotDmgTakenReducePercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.allBadEffectResistPercent,
      optionValue: '55',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.summonAtkFlat,
      optionValue: '2500',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.rabbitMaxHpChancePercent,
      optionValue: '100',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.counterAttackChancePercent,
      optionValue: '27',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.spaceTravelReturnChancePercent,
      optionValue: '100',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.hpRegenPerTurn,
      optionValue: '6500',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.allDmgTakenReducePercent,
      optionValue: '32',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.miniGameSkillDmgPercent,
      optionValue: '70',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.recoveryEffectPercent,
      optionValue: '24',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.skillCooldownIncreaseResistPercent,
      optionValue: '55',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.atkPercent,
      optionValue: '19',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.defenseFlat,
      optionValue: '10000',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.hpPercent,
      optionValue: '19',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.penetrationResistPercent,
      optionValue: '19',
    ),
    AccessoryOption(
      optionName: AccessoryOptionNames.penetrationChancePercent,
      optionValue: '19',
    ),
  ];

  static const Map<String, List<int>> randomOptionValueRangeTable = {
    AccessoryOptionNames.attackPowerFlat: [300, 1500],
    AccessoryOptionNames.hpFlat: [2000, 5000],
    AccessoryOptionNames.critDamageFlat: [10, 35],
    AccessoryOptionNames.critChanceFlat: [10, 30],
    AccessoryOptionNames.critResistFlat: [10, 30],
    AccessoryOptionNames.accuracyFlat: [10, 35],
    AccessoryOptionNames.evasionFlat: [5, 25],
    AccessoryOptionNames.activeSkillDmgPercent: [10, 35],
    AccessoryOptionNames.activeSkillDmgTakenReducePercent: [10, 35],
    AccessoryOptionNames.basicAtkDmgPercent: [10, 35],
    AccessoryOptionNames.basicAtkDmgTakenReducePercent: [10, 35],
    AccessoryOptionNames.dotDmgPercent: [10, 35],
    AccessoryOptionNames.dotDmgTakenReducePercent: [10, 35],
    AccessoryOptionNames.allBadEffectResistPercent: [10, 35],
    AccessoryOptionNames.summonAtkFlat: [500, 2000],
    AccessoryOptionNames.rabbitMaxHpChancePercent: [30, 50],
    AccessoryOptionNames.counterAttackChancePercent: [3, 10],
    AccessoryOptionNames.spaceTravelReturnChancePercent: [30, 50],
    AccessoryOptionNames.hpRegenPerTurn: [1000, 3000],
    AccessoryOptionNames.allDmgTakenReducePercent: [3, 15],
    AccessoryOptionNames.miniGameSkillDmgPercent: [10, 35],
    AccessoryOptionNames.recoveryEffectPercent: [5, 15],
    AccessoryOptionNames.skillCooldownIncreaseResistPercent: [5, 20],
    AccessoryOptionNames.atkPercent: [3, 10],
    AccessoryOptionNames.defenseFlat: [2000, 5000],
    AccessoryOptionNames.hpPercent: [3, 10],
    AccessoryOptionNames.penetrationResistPercent: [2, 10],
    AccessoryOptionNames.penetrationChancePercent: [2, 10],
  };

  static const Map<String, List<int>> thirdFourthOptionEnhancementBonuses = {
    AccessoryOptionNames.attackPowerFlat: [20, 40, 60, 80, 120, 170, 250, 350, 500],
    AccessoryOptionNames.atkPercent: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    AccessoryOptionNames.hpFlat: [200, 350, 500, 750, 1000, 1500, 2000, 3000, 5000],
    AccessoryOptionNames.hpPercent: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    AccessoryOptionNames.defenseFlat: [200, 350, 500, 750, 1000, 1500, 2000, 3000, 5000],
    AccessoryOptionNames.critDamageFlat: [2, 3, 5, 7, 9, 11, 13, 16, 20],
    AccessoryOptionNames.critChanceFlat: [1, 2, 3, 4, 5, 7, 9, 12, 17],
    AccessoryOptionNames.critResistFlat: [1, 2, 3, 4, 5, 7, 9, 12, 17],
    AccessoryOptionNames.accuracyFlat: [2, 3, 5, 7, 9, 11, 13, 16, 20],
    AccessoryOptionNames.evasionFlat: [2, 3, 5, 7, 9, 11, 13, 16, 20],
    AccessoryOptionNames.activeSkillDmgPercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.activeSkillDmgTakenReducePercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.basicAtkDmgPercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.basicAtkDmgTakenReducePercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.dotDmgPercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.dotDmgTakenReducePercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.allBadEffectResistPercent: [2, 3, 5, 7, 9, 11, 13, 16, 20],
    AccessoryOptionNames.allDmgTakenReducePercent: [1, 2, 3, 4, 5, 7, 9, 12, 17],
    AccessoryOptionNames.miniGameSkillDmgPercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.penetrationChancePercent: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    AccessoryOptionNames.penetrationResistPercent: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    AccessoryOptionNames.counterAttackChancePercent: [1, 2, 3, 4, 5, 7, 9, 12, 17],
    AccessoryOptionNames.skillCooldownIncreaseResistPercent: [1, 2, 3, 5, 7, 10, 15, 23, 35],
    AccessoryOptionNames.recoveryEffectPercent: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    AccessoryOptionNames.summonAtkFlat: [20, 40, 60, 80, 120, 170, 250, 350, 500],
    AccessoryOptionNames.hpRegenPerTurn: [100, 200, 300, 500, 700, 1000, 1500, 2300, 3500],
    AccessoryOptionNames.rabbitMaxHpChancePercent: [2, 4, 6, 8, 12, 17, 25, 35, 50],
    AccessoryOptionNames.spaceTravelReturnChancePercent: [2, 4, 6, 8, 12, 17, 25, 35, 50],
  };

  static String normalizeOptionName(String name) {
    final trimmed = name.trim();
    if (trimmed == '모든피해 %감소') {
      return '모든 피해 %감소';
    }
    return trimmed;
  }

  static AccessoryOption? findTemplateByName(String optionName) {
    final normalized = normalizeOptionName(optionName);
    for (final option in defaultChangeableOptions) {
      if (normalizeOptionName(option.optionName) == normalized) {
        return option;
      }
    }
    return null;
  }

  static int optionWeight(String optionName) {
    if (optionName == AccessoryOptionNames.rabbitMaxHpChancePercent ||
        optionName == AccessoryOptionNames.spaceTravelReturnChancePercent ||
        optionName == AccessoryOptionNames.hpRegenPerTurn) {
      return 5;
    }

    if (optionName.contains('%') ||
        optionName == AccessoryOptionNames.critChanceFlat ||
        optionName == AccessoryOptionNames.critDamageFlat ||
        optionName == AccessoryOptionNames.critResistFlat ||
        optionName == AccessoryOptionNames.accuracyFlat ||
        optionName == AccessoryOptionNames.evasionFlat) {
      return 40;
    }

    return 100;
  }

  static (int, int) resolveOptionRange({
    required Accessory accessory,
    required AccessoryOption option,
  }) {
    final isRandomAccessory = accessory.randomOptionConfig != null;
    if (isRandomAccessory) {
      final template = findTemplateByName(option.optionName);
      final tableRange = randomOptionValueRangeTable[
          template?.optionName ?? option.optionName];
      if (tableRange != null && tableRange.length == 2) {
        return (tableRange[0], tableRange[1]);
      }
    }

    final parsedValue = int.tryParse(option.optionValue) ?? 1;
    final rawMin = option.minNormalValue ?? max(1, (parsedValue * 0.6).round());
    final rawMax = option.maxNormalValue ?? parsedValue;
    final minValue = min(rawMin, rawMax);
    final maxValue = max(rawMin, rawMax);
    return (minValue, maxValue);
  }

  static int enhancementBonusForOption({
    required Accessory accessory,
    required AccessoryOption option,
    required int slotIndex,
    required int enhancementLevel,
  }) {
    if (enhancementLevel <= 0) {
      return 0;
    }

    final normalizedOptionName = normalizeOptionName(option.optionName);
    for (final bonus in accessory.enhancementStageBonuses) {
      if (normalizeOptionName(bonus.optionName) == normalizedOptionName) {
        return int.tryParse(bonus.valueAtLevel(enhancementLevel)) ?? 0;
      }
    }

    if (slotIndex != 2 && slotIndex != 3) {
      return 0;
    }

    for (final entry in thirdFourthOptionEnhancementBonuses.entries) {
      if (normalizeOptionName(entry.key) != normalizedOptionName) {
        continue;
      }
      final stageIndex = enhancementLevel - 1;
      if (stageIndex < 0) {
        return 0;
      }
      if (stageIndex < entry.value.length) {
        return entry.value[stageIndex];
      }
      return entry.value.last;
    }

    return 0;
  }

  static AccessoryOption rollOptionValue({
    required Accessory accessory,
    required AccessoryOption source,
    required Random random,
  }) {
    final (minValue, maxValue) = resolveOptionRange(
      accessory: accessory,
      option: source,
    );
    final value = accessory.randomOptionConfig == null
        ? maxValue
        : _randInt(random, minValue, maxValue);

    return AccessoryOption(
      optionName: source.optionName,
      optionValue: value.toString(),
      minNormalValue: minValue,
      maxNormalValue: maxValue,
    );
  }

  static AccessoryOption rollOptionValueWithSilverMoru({
    required Accessory accessory,
    required AccessoryOption source,
    required Random random,
  }) {
    final (minValue, maxValue) = resolveOptionRange(
      accessory: accessory,
      option: source,
    );
    final optionGrade = _pickWeightedString(
      RandomAccessoryRepository.silverMoruGradeProbabilities,
      random,
    );
    final range = _gradeRange(minValue, maxValue, optionGrade);
    final value = _randInt(random, range.$1, range.$2);
    return AccessoryOption(
      optionName: source.optionName,
      optionValue: value.toString(),
      minNormalValue: minValue,
      maxNormalValue: maxValue,
    );
  }

  static AccessoryOption pickWeightedTemplate({
    required List<AccessoryOption> pool,
    required Random random,
  }) {
    var totalWeight = 0;
    for (final option in pool) {
      totalWeight += optionWeight(option.optionName);
    }

    var randomValue = random.nextInt(max(1, totalWeight));
    for (final option in pool) {
      randomValue -= optionWeight(option.optionName);
      if (randomValue < 0) {
        return option;
      }
    }

    return pool.last;
  }

  static int _randInt(Random rng, int minValue, int maxValue) {
    if (maxValue <= minValue) return minValue;
    return minValue + rng.nextInt(maxValue - minValue + 1);
  }

  static String _pickWeightedString(Map<String, double> weights, Random rng) {
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var pick = rng.nextDouble() * total;
    for (final entry in weights.entries) {
      pick -= entry.value;
      if (pick <= 0) return entry.key;
    }
    return weights.keys.last;
  }

  static (int, int) _gradeRange(int minValue, int maxValue, String grade) {
    final span = maxValue - minValue;
    final accessoryConst = max(1, (span / 3).ceil());

    final yellowMin = minValue;
    final yellowMax = max(minValue, maxValue - accessoryConst * 2);

    final greenMin = min(maxValue, yellowMax + 1);
    final greenMax = max(greenMin, maxValue - accessoryConst);

    final blueMin = min(maxValue, greenMax + 1);
    final blueMax = maxValue;

    if (grade == RandomAccessoryRepository.gradeBlue) {
      return (blueMin, blueMax);
    }
    if (grade == RandomAccessoryRepository.gradeGreen) {
      return (greenMin, greenMax);
    }
    return (yellowMin, yellowMax);
  }
}