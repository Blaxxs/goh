class Aura {
  final String name;
  final String imagePath;
  final Map<String, dynamic> effects;

  const Aura({required this.name, required this.imagePath, required this.effects});
}

const List<Aura> auras = [
  Aura(name: '공격력 오라', imagePath: 'assets/images/auras/attack_aura.png', effects: {'attack_power': 2000}),
  Aura(name: '스킬 데미지 오라', imagePath: 'assets/images/auras/skill_damage_aura.png', effects: {'skill_damage_increase': 35}),
  Aura(name: '공격력% 오라', imagePath: 'assets/images/auras/attack_percent_aura.png', effects: {'attack_power_increase': 10}),
];
