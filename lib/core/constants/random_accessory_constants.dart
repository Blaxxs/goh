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
    required RandomAccessoryConfig config,
    required bool useGoldMoru,
    Random? random,
  }) {
    final rng = random ?? Random();

    final optionCount = _pickWeightedInt(config.optionCountProbabilities, rng);

    final gradeProb = useGoldMoru
        ? config.goldMoruGradeProbabilities
        : config.silverMoruGradeProbabilities;
    final grade = _pickWeightedString(gradeProb, rng);

    final ranges = List<RandomAccessoryOptionRange>.from(config.optionRanges)
      ..shuffle(rng);
    final selectedRanges = ranges.take(optionCount).toList(growable: false);

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
