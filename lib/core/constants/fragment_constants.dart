
class Fragment {
  final String name;
  final String imagePath;

  const Fragment({
    required this.name,
    required this.imagePath,
  });
}

const List<Fragment> fragments = [
  Fragment(name: '선택 안함', imagePath: ''),
  Fragment(name: '증폭(스킬)의 파편', imagePath: 'assets/images/fragment/attack.png'),
  Fragment(name: '치명의 파편', imagePath: 'assets/images/fragment/crit.png'),
  Fragment(name: '방어의 파편', imagePath: 'assets/images/fragment/defense.png'),
];
