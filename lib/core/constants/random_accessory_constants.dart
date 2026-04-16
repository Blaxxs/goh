import 'dart:math';

import '../../data/models/accessory.dart';

class RandomAccessoryOptionRange {
  final String optionName;
  final int min;
  final int max;

  const RandomAccessoryOptionRange({
    required this.optionName,
    required this.min,
    required this.max,
  });
}

class RandomAccessoryConfig {
  final String accessoryId;
  final int minOptionCount;
  final int maxOptionCount;
  final Map<int, double> optionCountProbabilities;
  final Map<String, double> silverMoruGradeProbabilities;
  final Map<String, double> goldMoruGradeProbabilities;
  final Map<String, int> craftCost;
  final Map<String, int> modifyCost;
  final List<RandomAccessoryOptionRange> optionRanges;

  const RandomAccessoryConfig({
    required this.accessoryId,
    required this.minOptionCount,
    required this.maxOptionCount,
    required this.optionCountProbabilities,
    required this.silverMoruGradeProbabilities,
    required this.goldMoruGradeProbabilities,
    required this.craftCost,
    required this.modifyCost,
    required this.optionRanges,
  });
}

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

  static const String _jinMoriId = 'jinmori_sleep_mask';
  static const String _chuunibyouId = 'chuunibyou_seal_patch';
  static const String _raidHatId = 'raid_commemorative_hat';

  static String _url(String id) {
    final encodedId = Uri.encodeComponent(id);
    return 'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F$encodedId.png?alt=media';
  }

  static const Map<int, double> _oneToTwoOptionProb = {
    1: 80,
    2: 20,
  };

  static const Map<int, double> _oneToThreeOptionProb = {
    1: 75,
    2: 20,
    3: 5,
  };

  static const Map<String, double> _silverMoruGradeProb = {
    gradeBlue: 10,
    gradeGreen: 35,
    gradeYellow: 55,
  };

  static const Map<String, double> _goldMoruGradeProb = {
    gradeBlue: 25,
    gradeGreen: 50,
    gradeYellow: 25,
  };

  static final List<Accessory> randomAccessories = [
    Accessory(
      id: _jinMoriId,
      name: '진모리수면안대',
      imageUrl: _url(_jinMoriId),
      part: '머리',
      restrictions: '랜덤 옵션 악세사리',
      options: const [
        AccessoryOption(optionName: '공격력 증가', optionValue: '30~150'),
        AccessoryOption(optionName: '체력 증가', optionValue: '200~500'),
        AccessoryOption(optionName: '명중 증가', optionValue: '3~15'),
        AccessoryOption(optionName: '회피 증가', optionValue: '2~10'),
        AccessoryOption(optionName: '크리티컬 증가', optionValue: '3~15'),
        AccessoryOption(optionName: '크리티컬 피해 증가', optionValue: '3~10'),
      ],
    ),
    Accessory(
      id: _chuunibyouId,
      name: '중2병 봉인안대',
      imageUrl: _url(_chuunibyouId),
      part: '머리',
      restrictions: '랜덤 옵션 악세사리',
      options: const [
        AccessoryOption(optionName: '공격력 증가', optionValue: '30~150'),
        AccessoryOption(optionName: '체력 증가', optionValue: '200~500'),
        AccessoryOption(optionName: '명중 증가', optionValue: '3~15'),
        AccessoryOption(optionName: '크리티컬 증가', optionValue: '3~15'),
        AccessoryOption(optionName: '크리티컬 저항 증가', optionValue: '3~15'),
        AccessoryOption(optionName: '지속피해 %증가', optionValue: '10~25'),
      ],
    ),
    Accessory(
      id: _raidHatId,
      name: '레이드기념 모자',
      imageUrl: _url(_raidHatId),
      part: '머리',
      restrictions: '랜덤 옵션 악세사리',
      options: const [
        AccessoryOption(optionName: '공격력 증가', optionValue: '20~40'),
        AccessoryOption(optionName: '체력 증가', optionValue: '150~250'),
        AccessoryOption(optionName: '명중 증가', optionValue: '2~4'),
        AccessoryOption(optionName: '크리티컬 증가', optionValue: '2~4'),
      ],
      setOptions: const [
        AccessorySetOption(
          setId: 'raid_memory_set',
          setName: '레이드 기념 세트',
          requiredAccessories: ['레이드기념 모자', '레이드기념 목걸이'],
          requiredAccessoryImages: [
            'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2Fraid_commemorative_hat.png?alt=media',
            'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2Fraid_commemorative_necklace.png?alt=media',
          ],
          effects: [
            SetOptionEffect(
              optionName: '공격력 %증가',
              stageValues: {
                '0': '0%',
                '6': '4%',
                '12': '8%',
                '18': '12%',
              },
            ),
          ],
        ),
      ],
    ),
  ];

  static final Map<String, RandomAccessoryConfig> _configById = {
    _jinMoriId: const RandomAccessoryConfig(
      accessoryId: _jinMoriId,
      minOptionCount: 1,
      maxOptionCount: 2,
      optionCountProbabilities: _oneToTwoOptionProb,
      silverMoruGradeProbabilities: _silverMoruGradeProb,
      goldMoruGradeProbabilities: _goldMoruGradeProb,
      craftCost: {
        '영혼석': 200,
        '골드': 500000,
        '은모루': 1,
      },
      modifyCost: {
        '영혼석': 100,
        '숫돌이': 300,
        '골드': 300000,
      },
      optionRanges: [
        RandomAccessoryOptionRange(optionName: '공격력 증가', min: 30, max: 150),
        RandomAccessoryOptionRange(optionName: '체력 증가', min: 200, max: 500),
        RandomAccessoryOptionRange(optionName: '명중 증가', min: 3, max: 15),
        RandomAccessoryOptionRange(optionName: '회피 증가', min: 2, max: 10),
        RandomAccessoryOptionRange(optionName: '크리티컬 증가', min: 3, max: 15),
        RandomAccessoryOptionRange(optionName: '크리티컬 피해 증가', min: 3, max: 10),
      ],
    ),
    _chuunibyouId: const RandomAccessoryConfig(
      accessoryId: _chuunibyouId,
      minOptionCount: 1,
      maxOptionCount: 2,
      optionCountProbabilities: _oneToTwoOptionProb,
      silverMoruGradeProbabilities: _silverMoruGradeProb,
      goldMoruGradeProbabilities: _goldMoruGradeProb,
      craftCost: {
        '영혼석': 200,
        '골드': 500000,
        '은모루': 1,
      },
      modifyCost: {
        '영혼석': 100,
        '숫돌이': 300,
        '골드': 300000,
      },
      optionRanges: [
        RandomAccessoryOptionRange(optionName: '공격력 증가', min: 30, max: 150),
        RandomAccessoryOptionRange(optionName: '체력 증가', min: 200, max: 500),
        RandomAccessoryOptionRange(optionName: '명중 증가', min: 3, max: 15),
        RandomAccessoryOptionRange(optionName: '크리티컬 증가', min: 3, max: 15),
        RandomAccessoryOptionRange(optionName: '크리티컬 저항 증가', min: 3, max: 15),
        RandomAccessoryOptionRange(optionName: '지속피해 %증가', min: 10, max: 25),
      ],
    ),
    _raidHatId: const RandomAccessoryConfig(
      accessoryId: _raidHatId,
      minOptionCount: 1,
      maxOptionCount: 3,
      optionCountProbabilities: _oneToThreeOptionProb,
      silverMoruGradeProbabilities: _silverMoruGradeProb,
      goldMoruGradeProbabilities: _goldMoruGradeProb,
      craftCost: {
        '영혼석': 250,
        '골드': 650000,
        '금모루': 1,
      },
      modifyCost: {
        '영혼석': 120,
        '숫돌이': 360,
        '골드': 350000,
      },
      optionRanges: [
        RandomAccessoryOptionRange(optionName: '공격력 증가', min: 20, max: 40),
        RandomAccessoryOptionRange(optionName: '체력 증가', min: 150, max: 250),
        RandomAccessoryOptionRange(optionName: '명중 증가', min: 2, max: 4),
        RandomAccessoryOptionRange(optionName: '크리티컬 증가', min: 2, max: 4),
      ],
    ),
  };

  static bool isRandomAccessory(String accessoryId) {
    return _configById.containsKey(accessoryId);
  }

  static RandomAccessoryConfig? configOf(String accessoryId) {
    return _configById[accessoryId];
  }

  static List<Accessory> mergeWithFixed(List<Accessory> fixedAccessories) {
    final byId = <String, Accessory>{
      for (final accessory in fixedAccessories) accessory.id: accessory,
    };
    for (final random in randomAccessories) {
      byId[random.id] = random;
    }
    return byId.values.toList();
  }

  static RandomAccessoryRollResult roll({
    required RandomAccessoryConfig config,
    required bool useGoldMoru,
    Random? random,
  }) {
    final rng = random ?? Random();

    final optionCount = _pickWeightedInt(config.optionCountProbabilities, rng);

    final gradeProb =
        useGoldMoru ? config.goldMoruGradeProbabilities : config.silverMoruGradeProbabilities;
    final grade = _pickWeightedString(gradeProb, rng);

    final ranges = List<RandomAccessoryOptionRange>.from(config.optionRanges)..shuffle(rng);
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

  // 규칙:
  // 상수 = ceil((max - min) / 3), 1 미만이면 1
  // 파랑 최대 = max
  // 초록 최대 = max - 상수
  // 노랑 최대 = max - 2*상수
  // 파랑 최소 = 초록 최대 + 1
  // 초록 최소 = 노랑 최대 + 1
  // 노랑 최소 = min
  static (int, int) _gradeRange(int min, int max, String grade) {
    final span = max - min;
    final accessoryConst = max(1, (span / 3).ceil());

    final yellowMin = min;
    final yellowMax = max(min, max - accessoryConst * 2);

    final greenMin = min(max, yellowMax + 1);
    final greenMax = max(greenMin, max - accessoryConst);

    final blueMin = min(max, greenMax + 1);
    final blueMax = max;

    if (grade == gradeBlue) {
      return (blueMin, blueMax);
    }
    if (grade == gradeGreen) {
      return (greenMin, greenMax);
    }
    return (yellowMin, yellowMax);
  }
}
