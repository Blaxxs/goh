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
  Aura(name: '증오', imagePath: 'assets/images/auras/hatred.png', effects: {'attack_power': 2000}),
  Aura(name: '마왕', imagePath: 'assets/images/auras/lucifer.png', effects: {'skill_damage_increase': 35}),
  Aura(name: '10주년 블루', imagePath: 'assets/images/auras/blue.png', effects: {'attack_power_increase': 10}),
  Aura(name: '10주년 퍼플', imagePath: 'assets/images/auras/purple.png', effects: {'attack_power_increase': 10}),
];

