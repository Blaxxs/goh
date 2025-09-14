enum SpiritEffectType {
  skillCoefficient,
  critDamage,
  baseAttack,
  normalDamage,
  skillDamage,
}

class SpiritEffect {
  final SpiritEffectType type;
  final List<double> values; // 9 values for 9 stars
  final String? characterDependency; // To which character this effect applies

  const SpiritEffect({
    required this.type,
    required this.values,
    this.characterDependency,
  });
}

class Spirit {
  final String name;
  final String englishName;
  final String imagePath;
  final List<SpiritEffect> effects;

  const Spirit({
    required this.name,
    required this.englishName,
    required this.imagePath,
    required this.effects,
  });
}

const List<Spirit> spirits = [
  Spirit(
    name: '선택 안함',
    englishName: 'none',
    imagePath: '',
    effects: [],
  ),
  Spirit(
    name: '헤일로 사탄의 희생',
    englishName: 'satan_spirit',
    imagePath: 'assets/images/spirit/satan_spirit.png',
    effects: [
      SpiritEffect(
        type: SpiritEffectType.skillCoefficient,
        values: [0, 0, 0, 0, 10, 20, 20, 20, 30],
        characterDependency: 'satan',
      ),
    ],
  ),
  Spirit(
    name: '유미라의 투혼',
    englishName: 'mira_spirit',
    imagePath: 'assets/images/spirit/mira_spirit.png',
    effects: [
      SpiritEffect(
        type: SpiritEffectType.skillCoefficient,
        values: [0, 0, 0, 0, 10, 10, 20, 20, 30],
        characterDependency: 'mira',
      ),
    ],
  ),
  Spirit(
    name: '해적 제갈택의 탐',
    englishName: 'haegaltaeg_spirit',
    imagePath: 'assets/images/spirit/haegaltaeg_spirit.png',
    effects: [
      SpiritEffect(
        type: SpiritEffectType.skillCoefficient,
        values: [5, 10, 15, 20, 25, 30, 35, 40, 50],
        characterDependency: 'haegaltaeg',
      ),
      SpiritEffect(
        type: SpiritEffectType.critDamage,
        values: [2, 5, 10, 15, 20, 25, 30, 35, 40],
      ),
    ],
  ),
  Spirit(
    name: '공격력의 스피릿',
    englishName: 'attack_spirit',
    imagePath: 'assets/images/spirit/attack_spirit.png',
    effects: [
      SpiritEffect(
        type: SpiritEffectType.baseAttack,
        values: [500, 700, 900, 1000, 1200, 2500, 3000, 4000, 5000],
      ),
    ],
  ),
  Spirit(
    name: '증폭-일반 공격의 스피릿',
    englishName: 'normal_spirit',
    imagePath: 'assets/images/spirit/normal_spirit.png',
    effects: [
      SpiritEffect(
        type: SpiritEffectType.normalDamage,
        values: [2, 5, 8, 12, 16, 20, 25, 30, 35],
      ),
    ],
  ),
  Spirit(
    name: '증폭-스킬 공격의 스피릿',
    englishName: 'skill_spirit',
    imagePath: 'assets/images/spirit/skill_spirit.png',
    effects: [
      SpiritEffect(
        type: SpiritEffectType.skillDamage,
        values: [2, 5, 8, 12, 16, 20, 25, 30, 35],
      ),
    ],
  ),
];