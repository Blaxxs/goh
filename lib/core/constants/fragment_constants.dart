class Fragment {
  final String name;
  final String imagePath;
  final double? minValue;
  final double? maxValue;
  final String? unit; // e.g., "%" or ""

  const Fragment({
    required this.name,
    required this.imagePath,
    this.minValue,
    this.maxValue,
    this.unit,
  });
}

const List<Fragment> fragments = [
  Fragment(name: '선택 안함', imagePath: ''),
  Fragment(name: '증폭(스킬)의 파편', imagePath: 'assets/images/fragment/skill_amp.png', minValue: 2, maxValue: 30, unit: '%'),
  Fragment(name: '증폭(미니게임)의 파편', imagePath: 'assets/images/fragment/minigame_amp.png', minValue: 2, maxValue: 30, unit: '%'),
  Fragment(name: '증폭(일반)의 파편', imagePath: 'assets/images/fragment/normal_amp.png', minValue: 2, maxValue: 30, unit: '%'),
  Fragment(name: '치명타의 파편', imagePath: 'assets/images/fragment/crit.png', minValue: 1, maxValue: 20),
  Fragment(name: '공격의 파편', imagePath: 'assets/images/fragment/attack_fragment.png', minValue: 80, maxValue: 2000),
];