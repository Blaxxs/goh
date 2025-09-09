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

  Future<void> _showAuraSelectionDialog() async {
    final selected = await showDialog<Aura>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('오라 선택'),
        children: auras
            .map((aura) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, aura),
                  child: Text(aura.name),
                ))
            .toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedAura = selected;
      });
    }
  }

  Future<void> _showCharyeokSelectionDialog() async {
    final selected = await showDialog<Charyeok>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('차력 선택'),
        children: charyeoks
            .map((charyeok) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, charyeok),
                  child: Text(charyeok.name),
                ))
            .toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedCharyeok = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('데미지 계산기'),
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.damageCalculator),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.35, // 상단 영역 높이
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: _showAuraSelectionDialog,
                      child: const Icon(Icons.wb_sunny_outlined),
                    ),
                    const SizedBox(height: 8),
                    const Text('오라'),
                  ],
                ),
                if (_selectedCharacter != null)
                  Image.asset(
                    _selectedCharacter!.imagePath,
                    width: screenWidth * 0.4,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: screenWidth * 0.4);
                    },
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: _showCharyeokSelectionDialog,
                      child: const Icon(Icons.flash_on_outlined),
                    ),
                    const SizedBox(height: 8),
                    const Text('차력'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                children: [
                  DropdownButton<Character>(
                    value: _selectedCharacter,
                    hint: const Text('캐릭터 선택'),
                    isExpanded: true,
                    items: characters.map((Character character) {
                      return DropdownMenuItem<Character>(
                        value: character,
                        child: Text(character.name),
                      );
                    }).toList(),
                    onChanged: (Character? newValue) {
                      setState(() {
                        _selectedCharacter = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('강화: '),
                      DropdownButton<int>(
                        value: _enhancementLevel,
                        items: List.generate(6, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
                        onChanged: (value) {
                          setState(() {
                            _enhancementLevel = value ?? 0;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('환생: '),
                      DropdownButton<int>(
                        value: _rebirthLevel,
                        items: List.generate(10, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
                        onChanged: (value) {
                          setState(() {
                            _rebirthLevel = value ?? 0;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('탐: '),
                      DropdownButton<int>(
                        value: _tamLevel,
                        items: List.generate(11, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
                        onChanged: (value) {
                          setState(() {
                            _tamLevel = value ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTextField('추가 공격력', _additionalAttackPowerController),
                      _buildTextField('리더 효과', _leaderEffectController, hint: '예) 1.5'),
                      _buildTextField('크리 데미지', _critDamageController),
                      _buildTextField('일반 데미지 증가', _normalDamageIncreaseController, suffix: '%'),
                      _buildTextField('스킬 데미지 증가', _skillDamageIncreaseController, suffix: '%'),
                      _buildTextField('미니게임 데미지 증가', _minigameDamageIncreaseController, suffix: '%'),
                      _buildTextField('하이스쿨 버프', _highSchoolBuffController, suffix: '%'),
                      _buildDropdown('스피릿', spirits, _selectedSpirit, (Spirit? newValue) {
                        setState(() {
                          _selectedSpirit = newValue;
                        });
                      }),
                      CheckboxListTile(
                        title: const Text('역속'),
                        value: _isCounterElement,
                        onChanged: (bool? value) {
                          setState(() {
                            _isCounterElement = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(onPressed: _calculateDamage, child: const Text('계산하기')),
                  const SizedBox(height: 20),
                  Text(
                    '최종 데미지: ${formatter.format(_calculatedDamage)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
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
