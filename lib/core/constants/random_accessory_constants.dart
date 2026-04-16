import 'dart:math';

import '../../data/models/accessory.dart';
import 'accessory_constants.dart';

typedef RandomAccessoryConfig = AccessoryRandomOptionConfig;
typedef RandomAccessoryOptionRange = AccessoryRandomOptionRange;

class RandomOptionRoll {
  final String optionName;
  final int value;
  final int minForGrade;
  final int maxForGrade;

  const RandomOptionRoll({
    required this.optionName,
    required this.value,
    required this.minForGrade,
    required this.maxForGrade,
  });
}

class RandomAccessoryRollResult {
  final String grade;
  final int optionCount;
  final List<RandomOptionRoll> options;

  const RandomAccessoryRollResult({
    required this.grade,
    required this.optionCount,
    required this.options,
  });
}

class RandomAccessoryRepository {
  static const String gradeBlue = '파랑';
  static const String gradeGreen = '초록';
  static const String gradeYellow = '노랑';

  // 공통 랜덤악세 규칙 (요청대로 시뮬레이터 공통 관리)
  static const Map<int, double> optionCountProbabilitiesOneToTwo = {
    1: 80,
    2: 20,
  };

  static const Map<int, double> optionCountProbabilitiesOneToThree = {
    1: 75,
    2: 20,
    3: 5,
  };

  static const Map<String, double> silverMoruGradeProbabilities = {
    gradeBlue: 10,
    gradeGreen: 35,
    gradeYellow: 55,
  };

  static const Map<String, double> goldMoruGradeProbabilities = {
    gradeBlue: 25,
    gradeGreen: 50,
    gradeYellow: 25,
  };

  static const Map<String, int> craftCost = {
    '영혼석': 200,
    '골드': 500000,
    '은모루': 1,
  };

  static const Map<String, int> modifyCost = {
    '영혼석': 100,
    '숫돌이': 300,
    '골드': 300000,
  };

  static List<Accessory> get randomAccessories {
    final accessories = AccessoryDataManager()
        .allAccessories
        .where((accessory) => accessory.randomOptionConfig != null)
        .toList();
    accessories.sort((a, b) => a.name.compareTo(b.name));
    return accessories;
  }

  static Accessory? firstRandomAccessory() {
    final accessories = randomAccessories;
    if (accessories.isEmpty) return null;
    return accessories.first;
  }

  static bool isRandomAccessory(String accessoryId) {
    return configOf(accessoryId) != null;
  }

  static RandomAccessoryConfig? configOf(String accessoryId) {
    for (final accessory in AccessoryDataManager().allAccessories) {
      if (accessory.id == accessoryId) {
        return accessory.randomOptionConfig;
      }
    }
    return null;
  }

  static List<Accessory> mergeWithFixed(List<Accessory> accessories) {
    final byId = <String, Accessory>{
      for (final accessory in accessories) accessory.id: accessory,
    };
    return byId.values.toList();
  }

  static RandomAccessoryRollResult roll({
    required Accessory accessory,
    required RandomAccessoryConfig config,
    required bool useGoldMoru,
    Random? random,
  }) {
    final rng = random ?? Random();

    final ranges = optionRangesOf(accessory);
    final optionCount = _resolveOptionCount(
      minOptionCount: config.minOptionCount,
      maxOptionCount: config.maxOptionCount,
      availableOptionKinds: ranges.length,
      rng: rng,
    );

    final gradeProb = useGoldMoru
        ? goldMoruGradeProbabilities
        : silverMoruGradeProbabilities;
    final grade = _pickWeightedString(gradeProb, rng);

    final shuffledRanges = List<RandomAccessoryOptionRange>.from(ranges)
      ..shuffle(rng);
    final selectedRanges =
        shuffledRanges.take(optionCount).toList(growable: false);

    final options = selectedRanges.map((range) {
      final gradeRange = _gradeRange(range.min, range.max, grade);
      final rolledValue = _randInt(rng, gradeRange.$1, gradeRange.$2);
      return RandomOptionRoll(
        optionName: range.optionName,
        value: rolledValue,
        minForGrade: gradeRange.$1,
        maxForGrade: gradeRange.$2,
      );
    }).toList(growable: false);

    return RandomAccessoryRollResult(
      grade: grade,
      optionCount: optionCount,
      options: options,
    );
  }

  static int _resolveOptionCount({
    required int minOptionCount,
    required int maxOptionCount,
    required int availableOptionKinds,
    required Random rng,
  }) {
    final safeMin = max(1, minOptionCount);
    final safeMax = max(safeMin, maxOptionCount);

    if (safeMin == safeMax) {
      return min(safeMin, max(1, availableOptionKinds));
    }

    final probs = safeMax >= 3
        ? optionCountProbabilitiesOneToThree
        : optionCountProbabilitiesOneToTwo;
    final picked = _pickWeightedInt(probs, rng);
    final clampedToConfig = picked.clamp(safeMin, safeMax);
    return min(clampedToConfig, max(1, availableOptionKinds));
  }

  static List<RandomAccessoryOptionRange> optionRangesOf(Accessory accessory) {
    return accessory.options
        .where((o) => o.minNormalValue != null && o.maxNormalValue != null)
        .map(
          (o) => RandomAccessoryOptionRange(
            optionName: o.optionName,
            min: o.minNormalValue!,
            max: o.maxNormalValue!,
          ),
        )
        .toList(growable: false);
  }

  static int _pickWeightedInt(Map<int, double> weights, Random rng) {
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var pick = rng.nextDouble() * total;
    for (final entry in weights.entries) {
      pick -= entry.value;
      if (pick <= 0) return entry.key;
    }
    return weights.keys.last;
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

  static int _randInt(Random rng, int min, int max) {
    if (max <= min) return min;
    return min + rng.nextInt(max - min + 1);
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

    if (grade == gradeBlue) {
      return (blueMin, blueMax);
    }
    if (grade == gradeGreen) {
      return (greenMin, greenMax);
    }
    return (yellowMin, yellowMax);
  }
}
