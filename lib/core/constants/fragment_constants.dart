class Fragment {
  final String name;
  final String imagePath;
  final double? minValue;
  final double? maxValue;
  final String? unit; // e.g., "%" or ""
  double? value; // User-entered value for the fragment

  Fragment({
    required this.name,
    required this.imagePath,
    this.minValue,
    this.maxValue,
    this.unit,
    this.value,
  });

  // Factory constructor for "선택 안함" fragment
  factory Fragment.none() {
    return Fragment(name: '선택 안함', imagePath: '', value: 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fragment &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imagePath == other.imagePath &&
          minValue == other.minValue &&
          maxValue == other.maxValue &&
          unit == other.unit; // value는 변경될 수 있으므로 비교 대상에서 제외

  @override
  int get hashCode =>
      name.hashCode ^
      imagePath.hashCode ^
      minValue.hashCode ^
      maxValue.hashCode ^
      unit.hashCode;
}

List<Fragment> fragments = [
  Fragment(name: '증폭(스킬)의 파편', imagePath: 'assets/images/fragment/skill_fragment.png', minValue: 2, maxValue: 30, unit: '%'),
  Fragment(name: '증폭(미니게임)의 파편', imagePath: 'assets/images/fragment/minigame_fragment.png', minValue: 2, maxValue: 30, unit: '%'),
  Fragment(name: '증폭(일반)의 파편', imagePath: 'assets/images/fragment/normal_fragment.png', minValue: 2, maxValue: 30, unit: '%'),
  Fragment(name: '치명타의 파편', imagePath: 'assets/images/fragment/crit_fragment.png', minValue: 1, maxValue: 20),
  Fragment(name: '공격의 파편', imagePath: 'assets/images/fragment/attack_fragment.png', minValue: 80, maxValue: 2000),
];