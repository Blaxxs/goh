class Spirit {
  final String name;
  final String imagePath;
  final Map<String, dynamic> effects;

  const Spirit({required this.name, required this.imagePath, required this.effects});
}

const List<Spirit> spirits = [
  Spirit(name: '불 스피릿', imagePath: 'assets/images/spirits/fire_spirit.png', effects: {'crit_damage': 50}),
  Spirit(name: '물 스피릿', imagePath: 'assets/images/spirits/water_spirit.png', effects: {'skill_damage_increase': 20}),
];
