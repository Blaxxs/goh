class Character {
  final String name;
  final String englishName;
  final String imagePath;
  final int baseAttackPower;
  final int skillMultiplier;
  final String damageType;
  final Map<String, dynamic> passive;

  const Character({
    required this.name,
    required this.englishName,
    required this.imagePath,
    required this.baseAttackPower,
    required this.skillMultiplier,
    required this.damageType,
    required this.passive,
  });
}

const List<Character> characters = [
  Character(
    name: '헤일로의 발현 사탄:666',
    englishName: 'satan',
    imagePath: 'assets/images/characters/satan.png',
    baseAttackPower: 16666,
    skillMultiplier: 150,
    damageType: '미니게임 데미지 * 스킬 데미지',
    passive: {},
  ),
  Character(
    name: 'Wi-Fi 오른팔의 유미라',
    englishName: 'mira',
    imagePath: 'assets/images/characters/mira.png',
    baseAttackPower: 14000,
    skillMultiplier: 150,
    damageType: '미니게임 데미지 * 스킬 데미지',
    passive: {
      'critDamage': 100,
      'finalDamage': 30000,
      'finalDamagePerStack': 15000,
    },
  ),
  Character(
    name: '해적 제갈택',
    englishName: 'haegaltaeg',
    imagePath: 'assets/images/characters/haegaltaeg.png',
    baseAttackPower: 15000,
    skillMultiplier: 160,
    damageType: '일반 데미지',
    passive: {
      'critDamage': 120,
    },
  ),
];

class Leader {
  final String name;
  final String imagePath;
  final double multiplier;

  const Leader({
    required this.name,
    required this.imagePath,
    required this.multiplier,
  });
}

const List<Leader> leaders = [
  Leader(
    name: '선택 안함',
    imagePath: '',
    multiplier: 1.0,
  ),
  Leader(
    name: '헤일로의 발현 사탄:666',
    imagePath: 'assets/images/leader/satan.png',
    multiplier: 1.9,
  ),
  Leader(
    name: '해적 제갈택',
    imagePath: 'assets/images/leader/haegaltaeg.png',
    multiplier: 2.0,
  ),
  Leader(
    name: 'Wi-Fi 오른팔의 유미라',
    imagePath: 'assets/images/leader/mira.png',
    multiplier: 2.0,
  ),
];
