enum CharyeokGrade { normal, advanced, rare, relic, legendary }

enum CharyeokEffectType {
  ATTACK_SET_PERCENT, // 공격력이 n%가 된다
  BASE_ATTACK_INCREASE_PERCENT, // 기본 공격력이 n%증가한다
  FIXED_ADDITIONAL_DAMAGE, // 고정 추가 데미지 n을 입힌다
  CRIT_DAMAGE_INCREASE, // 크리티컬 데미지가 n 증가한다.
  NONE // 없음
}

enum SynergyEffectType {
  SKILL_DAMAGE_INCREASE_PERCENT,
  NORMAL_DAMAGE_INCREASE_PERCENT,
  NONE
}

class Charyeok {
  final String name;
  final String englishName;
  final String imagePath;
  final List<CharyeokGrade> availableGrades;
  final CharyeokEffectType baseEffectType;
  final Map<CharyeokGrade, List<int>> baseEffectValues;
  final Map<CharyeokGrade, SynergyEffectType> synergyEffectType;
  final Map<CharyeokGrade, int> synergyEffectValues;

  const Charyeok({
    required this.name,
    required this.englishName,
    required this.imagePath,
    required this.availableGrades,
    required this.baseEffectType,
    required this.baseEffectValues,
    required this.synergyEffectType,
    required this.synergyEffectValues,
  });
}

const List<Charyeok> charyeoks = [
  Charyeok(
    name: '제갈택의 탐',
    englishName: 'tam',
    imagePath: 'images/charyeok/tam.png',
    availableGrades: [CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.ATTACK_SET_PERCENT,
    baseEffectValues: {
      CharyeokGrade.relic: [150, 152, 156, 162, 170, 180, 190, 202, 220],
      CharyeokGrade.legendary: [250, 252, 256, 262, 170, 280, 290, 302, 320],
    },
    synergyEffectType: {},
    synergyEffectValues: {},
  ),
  Charyeok(
    name: '우마왕',
    englishName: 'umawang',
    imagePath: 'images/charyeok/umawang.png',
    availableGrades: [
      CharyeokGrade.normal,
      CharyeokGrade.advanced,
      CharyeokGrade.rare,
      CharyeokGrade.relic,
      CharyeokGrade.legendary
    ],
    baseEffectType: CharyeokEffectType.BASE_ATTACK_INCREASE_PERCENT,
    baseEffectValues: {
      CharyeokGrade.normal: [30, 32, 34, 36, 40, 44, 50, 58, 70],
      CharyeokGrade.advanced: [50, 52, 24, 56, 60, 64, 70, 78, 90],
      CharyeokGrade.rare: [90, 92, 94, 96, 100, 104, 110, 118, 130],
      CharyeokGrade.relic: [160, 162, 164, 166, 170, 174, 180, 188, 200],
      CharyeokGrade.legendary: [260, 262, 264, 266, 270, 274, 280, 288, 300],
    },
    synergyEffectType: {
      CharyeokGrade.relic: SynergyEffectType.SKILL_DAMAGE_INCREASE_PERCENT,
      CharyeokGrade.legendary: SynergyEffectType.SKILL_DAMAGE_INCREASE_PERCENT,
    },
    synergyEffectValues: {
      CharyeokGrade.relic: 30,
      CharyeokGrade.legendary: 50,
    },
  ),
  Charyeok(
    name: '잔다르크',
    englishName: 'jandaleukeu',
    imagePath: 'images/charyeok/jandaleukeu.png',
    availableGrades: [
      CharyeokGrade.normal,
      CharyeokGrade.advanced,
      CharyeokGrade.rare,
      CharyeokGrade.relic,
      CharyeokGrade.legendary
    ],
    baseEffectType: CharyeokEffectType.FIXED_ADDITIONAL_DAMAGE,
    baseEffectValues: {
      CharyeokGrade.normal: [6000, 11000, 16000, 20000, 26000, 32000, 38000, 44000, 50000],
      CharyeokGrade.advanced: [9600, 18000, 26000, 32000, 42000, 51000, 61000, 71000, 80000],
      CharyeokGrade.rare: [18000, 33000, 48000, 60000, 78000, 96000, 114000, 132000, 150000],
      CharyeokGrade.relic: [36000, 66000, 96000, 120000, 156000, 192000, 228000, 264000, 300000],
      CharyeokGrade.legendary: [60000, 110000, 160000, 200000, 260000, 320000, 380000, 440000, 500000],
    },
    synergyEffectType: {},
    synergyEffectValues: {},
  ),
  Charyeok(
    name: '아수라',
    englishName: 'asula',
    imagePath: 'images/charyeok/asula.png',
    availableGrades: [CharyeokGrade.rare, CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.NONE,
    baseEffectValues: {},
    synergyEffectType: {
      CharyeokGrade.relic: SynergyEffectType.NORMAL_DAMAGE_INCREASE_PERCENT,
      CharyeokGrade.legendary: SynergyEffectType.NORMAL_DAMAGE_INCREASE_PERCENT,
    },
    synergyEffectValues: {
      CharyeokGrade.relic: 30,
      CharyeokGrade.legendary: 50,
    },
  ),
  Charyeok(
    name: '롱기누스',
    englishName: 'longginuseu',
    imagePath: 'images/charyeok/longginuseu.png',
    availableGrades: [CharyeokGrade.rare, CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.BASE_ATTACK_INCREASE_PERCENT,
    baseEffectValues: {
      CharyeokGrade.rare: [10, 11, 12, 13, 14, 15, 16, 18, 20],
      CharyeokGrade.relic: [10, 11, 12, 13, 14, 15, 16, 18, 20],
      CharyeokGrade.legendary: [10, 11, 12, 13, 14, 15, 16, 18, 20],
    },
    synergyEffectType: {
      CharyeokGrade.relic: SynergyEffectType.SKILL_DAMAGE_INCREASE_PERCENT,
      CharyeokGrade.legendary: SynergyEffectType.SKILL_DAMAGE_INCREASE_PERCENT,
    },
    synergyEffectValues: {
      CharyeokGrade.relic: 30,
      CharyeokGrade.legendary: 50,
    },
  ),
  Charyeok(
    name: '상형권',
    englishName: 'sanghyeonggwon',
    imagePath: 'images/charyeok/sanghyeonggwon.png',
    availableGrades: [CharyeokGrade.rare, CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.CRIT_DAMAGE_INCREASE,
    baseEffectValues: {
      CharyeokGrade.rare: [70, 71, 72, 74, 78, 82, 86, 92, 100],
      CharyeokGrade.relic: [130, 131, 132, 134, 138, 142, 146, 152, 160],
      CharyeokGrade.legendary: [220, 221, 222, 224, 228, 232, 236, 242, 250],
    },
    synergyEffectType: {},
    synergyEffectValues: {},
  ),
];
