enum CharyeokGrade { normal, advanced, rare, relic, legendary }

enum CharyeokEffectType {
  attackSetPercent, // 공격력이 n%가 된다
  baseAttackIncreasePercent, // 기본 공격력이 n%증가한다
  fixedAdditionalDamage, // 고정 추가 데미지 n을 입힌다
  critDamageIncrease, // 크리티컬 데미지가 n 증가한다.
  none // 없음
}

enum SynergyEffectType {
  skillDamageIncreasePercent,
  normalDamageIncreasePercent,
  none
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
  final String description;
  final Map<CharyeokGrade, List<int>>? decreasePerTurn;
  final Map<CharyeokGrade, List<int>>? minValue;
  final Map<CharyeokGrade, List<int>>? increasePerTurn;
  final Map<CharyeokGrade, List<int>>? maxValue;
  final Map<CharyeokGrade, int>? fragmentSlotCounts; // New property

  const Charyeok({
    required this.name,
    required this.englishName,
    required this.imagePath,
    required this.availableGrades,
    required this.baseEffectType,
    required this.baseEffectValues,
    required this.synergyEffectType,
    required this.synergyEffectValues,
    required this.description,
    this.decreasePerTurn,
    this.minValue,
    this.increasePerTurn,
    this.maxValue,
    this.fragmentSlotCounts, // Initialize new property
  });
}

const List<Charyeok> charyeoks = [
  Charyeok(
    name: '선택 안함',
    englishName: 'none',
    imagePath: '',
    availableGrades: [],
    baseEffectType: CharyeokEffectType.none,
    baseEffectValues: {},
    synergyEffectType: {},
    synergyEffectValues: {},
    description: '없음',
    fragmentSlotCounts: {}, // Default empty map
  ),
  Charyeok(
    name: '제갈택의 탐',
    englishName: 'tam',
    imagePath: 'assets/images/charyeok/tam.png',
    availableGrades: [CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.attackSetPercent,
    baseEffectValues: {
      CharyeokGrade.relic: [150, 152, 156, 162, 170, 180, 190, 202, 220],
      CharyeokGrade.legendary: [250, 252, 256, 262, 170, 280, 290, 302, 320],
    },
    synergyEffectType: {},
    synergyEffectValues: {},
    description: '전투 시작 후 4턴동안 공격력과 체력이 n%가 된다. (단, PVE 콘텐츠에서만 적용.)',
    fragmentSlotCounts: { // Example: Tam has fewer slots
      CharyeokGrade.relic: 4,
      CharyeokGrade.legendary: 5,
    },
  ),
  Charyeok(
    name: '우마왕',
    englishName: 'umawang',
    imagePath: 'assets/images/charyeok/umawang.png',
    availableGrades: [
      CharyeokGrade.normal,
      CharyeokGrade.advanced,
      CharyeokGrade.rare,
      CharyeokGrade.relic,
      CharyeokGrade.legendary
    ],
    baseEffectType: CharyeokEffectType.baseAttackIncreasePercent,
    baseEffectValues: {
      CharyeokGrade.normal: [30, 32, 34, 36, 40, 44, 50, 58, 70],
      CharyeokGrade.advanced: [50, 52, 24, 56, 60, 64, 70, 78, 90],
      CharyeokGrade.rare: [90, 92, 94, 96, 100, 104, 110, 118, 130],
      CharyeokGrade.relic: [160, 162, 164, 166, 170, 174, 180, 188, 200],
      CharyeokGrade.legendary: [260, 262, 264, 266, 270, 274, 280, 288, 300],
    },
    synergyEffectType: {
      CharyeokGrade.relic: SynergyEffectType.skillDamageIncreasePercent,
      CharyeokGrade.legendary: SynergyEffectType.skillDamageIncreasePercent,
    },
    synergyEffectValues: {
      CharyeokGrade.relic: 30,
      CharyeokGrade.legendary: 50,
    },
    description: '전투 시작 시 자신의 기본 공격력이 n%증가한다. 매턴 n%씩 감소하며 최소 n%까지 감소하고 유지한다.',
    decreasePerTurn: {
      CharyeokGrade.normal: [20, 20, 20, 20, 20, 20, 20, 20, 20],
      CharyeokGrade.advanced: [20, 20, 20, 20, 20, 20, 20, 20, 20],
      CharyeokGrade.rare: [30, 30, 30, 30, 30, 30, 30, 30, 30],
      CharyeokGrade.relic: [40, 40, 40, 40, 40, 40, 40, 40, 40],
      CharyeokGrade.legendary: [50, 50, 50, 50, 50, 50, 50, 50, 50],
    },
    minValue: {
      CharyeokGrade.normal: [30, 30, 30, 30, 30, 30, 30, 30, 30],
      CharyeokGrade.advanced: [30, 30, 30, 30, 30, 30, 30, 30, 30],
      CharyeokGrade.rare: [30, 30, 30, 30, 30, 30, 30, 30, 30],
      CharyeokGrade.relic: [40, 40, 40, 40, 40, 40, 40, 40, 40],
      CharyeokGrade.legendary: [50, 50, 50, 50, 50, 50, 50, 50, 50],
    },
  ),
  Charyeok(
    name: '잔다르크',
    englishName: 'jandaleukeu',
    imagePath: 'assets/images/charyeok/jandaleukeu.png',
    availableGrades: [
      CharyeokGrade.normal,
      CharyeokGrade.advanced,
      CharyeokGrade.rare,
      CharyeokGrade.relic,
      CharyeokGrade.legendary
    ],
    baseEffectType: CharyeokEffectType.fixedAdditionalDamage,
    baseEffectValues: {
      CharyeokGrade.normal: [6000, 11000, 16000, 20000, 26000, 32000, 38000, 44000, 50000],
      CharyeokGrade.advanced: [9600, 18000, 26000, 32000, 42000, 51000, 61000, 71000, 80000],
      CharyeokGrade.rare: [18000, 33000, 48000, 60000, 78000, 96000, 114000, 132000, 150000],
      CharyeokGrade.relic: [36000, 66000, 96000, 120000, 156000, 192000, 228000, 264000, 300000],
      CharyeokGrade.legendary: [60000, 110000, 160000, 200000, 260000, 320000, 380000, 440000, 500000],
    },
    synergyEffectType: {},
    synergyEffectValues: {},
    description: '전추 시작 후 1턴간 일반, 스킬, 미니게임 스킬 공격(주사위 미니게임 미포함) 시 고정 추가데미지 n을 입힌다. 해당 효과는 상대의 일반, 스킬, 미니게임 스킬 방어막 및 피해감소, 데미지 제한 효과를 무시한다.',
  ),
  Charyeok(
    name: '아수라',
    englishName: 'asula',
    imagePath: 'assets/images/charyeok/asula.png',
    availableGrades: [CharyeokGrade.rare, CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.none,
    baseEffectValues: {},
    synergyEffectType: {
      CharyeokGrade.relic: SynergyEffectType.normalDamageIncreasePercent,
      CharyeokGrade.legendary: SynergyEffectType.normalDamageIncreasePercent,
    },
    synergyEffectValues: {
      CharyeokGrade.relic: 30,
      CharyeokGrade.legendary: 50,
    },
    description: '자신의 기본 공격이 특정 확률로 전체 대상으로 변경된다.',
  ),
  Charyeok(
    name: '롱기누스',
    englishName: 'longginuseu',
    imagePath: 'assets/images/charyeok/longginuseu.png',
    availableGrades: [CharyeokGrade.rare, CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.baseAttackIncreasePercent,
    baseEffectValues: {
      CharyeokGrade.rare: [10, 11, 12, 13, 14, 15, 16, 18, 20],
      CharyeokGrade.relic: [10, 11, 12, 13, 14, 15, 16, 18, 20],
      CharyeokGrade.legendary: [10, 11, 12, 13, 14, 15, 16, 18, 20],
    },
    synergyEffectType: {
      CharyeokGrade.relic: SynergyEffectType.skillDamageIncreasePercent,
      CharyeokGrade.legendary: SynergyEffectType.skillDamageIncreasePercent,
    },
    synergyEffectValues: {
      CharyeokGrade.relic: 30,
      CharyeokGrade.legendary: 50,
    },
    description: '전투 시작 시 자신의 기본 공격력이 n%증가한다. 매턴 n%씩 증가하며 최대 n%까지 증가하고 유지된다.',
    increasePerTurn: {
      CharyeokGrade.rare: [10, 10, 10, 10, 10, 10, 10, 10, 10],
      CharyeokGrade.relic: [15, 15, 15, 15, 15, 15, 15, 15, 15],
      CharyeokGrade.legendary: [20, 20, 20, 20, 20, 20, 20, 20, 20],
    },
    maxValue: {
      CharyeokGrade.rare: [50, 51, 52, 53, 54, 55, 56, 58, 60],
      CharyeokGrade.relic: [70, 71, 72, 73, 74, 75, 76, 78, 80],
      CharyeokGrade.legendary: [90, 91, 92, 93, 94, 95, 96, 98, 100],
    },
  ),
  Charyeok(
    name: '상형권',
    englishName: 'sanghyeonggwon',
    imagePath: 'assets/images/charyeok/sanghyeonggwon.png',
    availableGrades: [CharyeokGrade.rare, CharyeokGrade.relic, CharyeokGrade.legendary],
    baseEffectType: CharyeokEffectType.critDamageIncrease,
    baseEffectValues: {
      CharyeokGrade.rare: [70, 71, 72, 74, 78, 82, 86, 92, 100],
      CharyeokGrade.relic: [130, 131, 132, 134, 138, 142, 146, 152, 160],
      CharyeokGrade.legendary: [220, 221, 222, 224, 228, 232, 236, 242, 250],
    },
    synergyEffectType: {},
    synergyEffectValues: {},
    description: '전투 시작 시 크리티컬 데미지가 n증가한다. 매턴 n씩 감소하고 최소 n까지 감소 후 유지한다.',
    decreasePerTurn: {
      CharyeokGrade.rare: [30, 30, 30, 30, 30, 30, 30, 30, 30],
      CharyeokGrade.relic: [40, 40, 40, 40, 40, 40, 40, 40, 40],
      CharyeokGrade.legendary: [50, 50, 50, 50, 50, 50, 50, 50, 50],
    },
    minValue: {
      CharyeokGrade.rare: [30, 30, 30, 30, 30, 30, 30, 30, 30],
      CharyeokGrade.relic: [40, 40, 40, 40, 40, 40, 40, 40, 40],
      CharyeokGrade.legendary: [50, 50, 50, 50, 50, 50, 50, 50, 50],
    },
  ),
];