class Charyeok {
  final String name;
  final String imagePath;
  final List<Map<String, dynamic>> grades;

  const Charyeok({required this.name, required this.imagePath, required this.grades});
}

const List<Charyeok> charyeoks = [
  Charyeok(
    name: '탐',
    imagePath: 'assets/images/charyeoks/tam.png',
    grades: [
      {'grade': 1, 'effects': {'base_attack_increase': 160, 'skill_damage_increase': 30}},
      {'grade': 2, 'effects': {'base_attack_increase': 200, 'skill_damage_increase': 40}},
    ],
  ),
  Charyeok(
    name: '나봉침',
    imagePath: 'assets/images/charyeoks/nabongchim.png',
    grades: [
      {'grade': 1, 'effects': {'crit_damage': 130}},
      {'grade': 2, 'effects': {'crit_damage': 150}},
    ],
  ),
];
