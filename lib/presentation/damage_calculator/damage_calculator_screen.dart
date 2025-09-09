import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/box_constants.dart';
import 'package:goh_calculator/core/widgets/app_drawer.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';
import 'package:goh_calculator/core/constants/aura_constants.dart';
import 'package:goh_calculator/core/constants/charyeok_constants.dart';
import 'package:goh_calculator/core/constants/spirit_constants.dart';
import 'package:intl/intl.dart';

class DamageCalculatorScreen extends StatefulWidget {
  const DamageCalculatorScreen({super.key});

  @override
  State<DamageCalculatorScreen> createState() => _DamageCalculatorScreenState();
}

class _DamageCalculatorScreenState extends State<DamageCalculatorScreen> {
  Character? _selectedCharacter;
  Aura? _selectedAura;
  Charyeok? _selectedCharyeok;
  Spirit? _selectedSpirit;
  int _enhancementLevel = 0;
  int _tamLevel = 0;
  int _rebirthLevel = 0;
  bool _isCounterElement = false;
  double _calculatedDamage = 0;

  final _additionalAttackPowerController = TextEditingController();
  final _leaderEffectController = TextEditingController();
  final _critDamageController = TextEditingController();
  final _normalDamageIncreaseController = TextEditingController();
  final _skillDamageIncreaseController = TextEditingController();
  final _minigameDamageIncreaseController = TextEditingController();
  final _highSchoolBuffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCharacter = characters[0];
    _selectedAura = auras[0];
    if (charyeoks.isNotEmpty) {
      _selectedCharyeok = charyeoks[0];
    }
    _selectedSpirit = spirits[0];
  }

  @override
  void dispose() {
    _additionalAttackPowerController.dispose();
    _leaderEffectController.dispose();
    _critDamageController.dispose();
    _normalDamageIncreaseController.dispose();
    _skillDamageIncreaseController.dispose();
    _minigameDamageIncreaseController.dispose();
    _highSchoolBuffController.dispose();
    super.dispose();
  }

  void _calculateDamage() {
    // This is a placeholder formula. Replace with the actual formula.
    final baseAttack = _selectedCharacter?.baseAttackPower ?? 0;
    final additionalAttack = double.tryParse(_additionalAttackPowerController.text) ?? 0;
    final leaderEffect = double.tryParse(_leaderEffectController.text) ?? 1.0;
    final skillDamageIncrease = (double.tryParse(_skillDamageIncreaseController.text) ?? 0) / 100;

    setState(() {
      _calculatedDamage = (baseAttack + additionalAttack) * leaderEffect * (1 + skillDamageIncrease);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('데미지 계산기'),
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.damageCalculator),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/damage_calculator_screen_background_image.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // SingleChildScrollView(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     children: [
          //       DropdownButton<Character>(
          //         value: _selectedCharacter,
          //         hint: const Text('캐릭터 선택'),
          //         isExpanded: true,
          //         items: characters.map((Character character) {
          //           return DropdownMenuItem<Character>(
          //             value: character,
          //             child: Text(character.name),
          //           );
          //         }).toList(),
          //         onChanged: (Character? newValue) {
          //           setState(() {
          //             _selectedCharacter = newValue;
          //           });
          //         },
          //       ),
          //       const SizedBox(height: 20),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: [
          //           const Text('강화: '),
          //           DropdownButton<int>(
          //             value: _enhancementLevel,
          //             items: List.generate(6, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
          //             onChanged: (value) {
          //               setState(() {
          //                 _enhancementLevel = value ?? 0;
          //               });
          //             },
          //           ),
          //           const SizedBox(width: 10),
          //           const Text('환생: '),
          //           DropdownButton<int>(
          //             value: _rebirthLevel,
          //             items: List.generate(10, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
          //             onChanged: (value) {
          //               setState(() {
          //                 _rebirthLevel = value ?? 0;
          //               });
          //             },
          //           ),
          //           const SizedBox(width: 10),
          //           const Text('탐: '),
          //           DropdownButton<int>(
          //             value: _tamLevel,
          //             items: List.generate(11, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
          //             onChanged: (value) {
          //               setState(() {
          //                 _tamLevel = value ?? 0;
          //               });
          //             },
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 20),
          //       Wrap(
          //         spacing: 16.0,
          //         runSpacing: 16.0,
          //         alignment: WrapAlignment.center,
          //         children: [
          //           _buildTextField('추가 공격력', _additionalAttackPowerController),
          //           _buildTextField('리더 효과', _leaderEffectController, hint: '예) 1.5'),
          //           _buildTextField('크리 데미지', _critDamageController),
          //           _buildTextField('일반 데미지 증가', _normalDamageIncreaseController, suffix: '%'),
          //           _buildTextField('스킬 데미지 증가', _skillDamageIncreaseController, suffix: '%'),
          //           _buildTextField('미니게임 데미지 증가', _minigameDamageIncreaseController, suffix: '%'),
          //           _buildTextField('하이스쿨 버프', _highSchoolBuffController, suffix: '%'),
          //           _buildDropdown('오라', auras, _selectedAura, (Aura? newValue) {
          //             setState(() {
          //               _selectedAura = newValue;
          //             });
          //           }),
          //           _buildDropdown('차력', charyeoks, _selectedCharyeok, (Charyeok? newValue) {
          //             setState(() {
          //               _selectedCharyeok = newValue;
          //             });
          //           }),
          //           _buildDropdown('스피릿', spirits, _selectedSpirit, (Spirit? newValue) {
          //             setState(() {
          //               _selectedSpirit = newValue;
          //             });
          //           }),
          //           CheckboxListTile(
          //             title: const Text('역속'),
          //             value: _isCounterElement,
          //             onChanged: (bool? value) {
          //               setState(() {
          //                 _isCounterElement = value ?? false;
          //               });
          //             },
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 30),
          //       ElevatedButton(onPressed: _calculateDamage, child: const Text('계산하기')),
          //       const SizedBox(height: 20),
          //       Text(
          //         '최종 데미지: ${formatter.format(_calculatedDamage)}',
          //         style: Theme.of(context).textTheme.headlineMedium,
          //       ),
          //     ],
          //   ),
          // ),
          if (_selectedCharacter != null)
            Positioned(
              top: 100.0,
              left: 100.0,
              child: Image.asset(
                _selectedCharacter!.imagePath,
                width: screenWidth / 2,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: screenWidth / 2);
                },
              ),
            ),
          if (_selectedCharacter != null)
            Positioned(
              top: 400.0,
              left: 100.0,
              child: Text(
                '기본 공격력: ${formatter.format(_selectedCharacter!.baseAttackPower)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? suffix, String? hint}) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildDropdown<T>(String label, List<T> items, T? selectedItem, ValueChanged<T?> onChanged) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: selectedItem,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item!.displayName, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// A helper to get the name of the items in the dropdown
extension DropdownDisplay on Object {
  String get displayName {
    if (this is Aura) return (this as Aura).name;
    if (this is Charyeok) return (this as Charyeok).name;
    if (this is Spirit) return (this as Spirit).name;
    return toString();
  }
}
