
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
  Fragment(name: '증폭(스킬)의 파편', imagePath: 'assets/images/fragment/skill_fragment.png'),
  Fragment(name: '증폭(미니게임)의 파편', imagePath: 'assets/images/fragment/minigame_fragment.png'),
  Fragment(name: '증폭(일반)의 파편', imagePath: 'assets/images/fragment/normal_fragment.png'),
  Fragment(name: '치명타의 파편', imagePath: 'assets/images/fragment/crit_fragment.png'),
  Fragment(name: '공격의 파편', imagePath: 'assets/images/fragment/attack_fragment.png'),
];
