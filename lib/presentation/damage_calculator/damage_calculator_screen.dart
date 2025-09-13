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

Color _getBorderColorForGrade(CharyeokGrade? grade) {
  if (grade == null) {
    return Colors.grey.shade300;
  }
  switch (grade) {
    case CharyeokGrade.normal:
      return const Color(0xFFDBEDFA);
    case CharyeokGrade.advanced:
      return const Color(0xFF0FD380);
    case CharyeokGrade.rare:
      return const Color(0xFF6BBDF7);
    case CharyeokGrade.relic:
      return const Color(0xFFE0564B);
    case CharyeokGrade.legendary:
      return const Color(0xFFF7C05F);
    default:
      return Colors.grey.shade300;
  }
}

class _DamageCalculatorScreenState extends State<DamageCalculatorScreen> {
  Character? _selectedCharacter;
  Aura? _selectedAura;
  Charyeok? _selectedCharyeok;
  CharyeokGrade? _selectedCharyeokGrade;
  int _selectedCharyeokStar = 1;
  Spirit? _selectedSpirit;
  
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
      if (_selectedCharyeok!.availableGrades.isNotEmpty) {
        _selectedCharyeokGrade = _selectedCharyeok!.availableGrades[0];
      }
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
    if (_selectedCharacter == null) return;

    // Base Stats
    double baseAttack = _selectedCharacter!.baseAttackPower.toDouble();
    double additionalAttack = double.tryParse(_additionalAttackPowerController.text) ?? 0;

    // Multipliers & Buffs from TextFields
    double leaderEffect = double.tryParse(_leaderEffectController.text) ?? 1.0;
    double critDamage = (double.tryParse(_critDamageController.text) ?? 0);
    double normalDamageIncrease = (double.tryParse(_normalDamageIncreaseController.text) ?? 0) / 100;
    double skillDamageIncrease = (double.tryParse(_skillDamageIncreaseController.text) ?? 0) / 100;
    // Other buffs can be added here

    // Aura Effects
    if (_selectedAura != null) {
      final aura = _selectedAura!;
      if (aura.effects.containsKey('attack_power')) {
        additionalAttack += aura.effects['attack_power'] as int;
      }
      if (aura.effects.containsKey('skill_damage_increase')) {
        skillDamageIncrease += (aura.effects['skill_damage_increase'] as int) / 100.0;
      }
      if (aura.effects.containsKey('attack_power_increase')) {
        baseAttack *= (1 + (aura.effects['attack_power_increase'] as int) / 100.0);
      }
    }

    // Charyeok Effects
    if (_selectedCharyeok != null && _selectedCharyeokGrade != null) {
      final charyeok = _selectedCharyeok!;
      final grade = _selectedCharyeokGrade!;
      final star = _selectedCharyeokStar;

      // Base Effect
      if (charyeok.baseEffectValues.containsKey(grade)) {
        final value = charyeok.baseEffectValues[grade]![star - 1].toDouble();
        switch (charyeok.baseEffectType) {
          case CharyeokEffectType.baseAttackIncreasePercent:
            baseAttack *= (1 + value / 100);
            break;
          case CharyeokEffectType.critDamageIncrease:
            critDamage += value;
            break;
          // ATTACK_SET_PERCENT and FIXED_ADDITIONAL_DAMAGE are applied later
          default:
            break;
        }
      }

      // Synergy Effect
      if (charyeok.synergyEffectType.containsKey(grade)) {
        final synergyType = charyeok.synergyEffectType[grade]!;
        final synergyValue = charyeok.synergyEffectValues[grade]!.toDouble();
        switch (synergyType) {
          case SynergyEffectType.skillDamageIncreasePercent:
            skillDamageIncrease += (synergyValue / 100);
            break;
          case SynergyEffectType.normalDamageIncreasePercent:
            normalDamageIncrease += (synergyValue / 100);
            break;
          default:
            break;
        }
      }
    }

    // Final Calculation (simplified formula)
    double totalAttack = baseAttack + additionalAttack;
    double finalDamage = totalAttack * leaderEffect * (1 + skillDamageIncrease) * (1 + normalDamageIncrease) * (1 + (critDamage/100));

    // Apply Charyeok effects that modify the final damage
    if (_selectedCharyeok != null && _selectedCharyeokGrade != null) {
      final charyeok = _selectedCharyeok!;
      final grade = _selectedCharyeokGrade!;
      final star = _selectedCharyeokStar;

      if (charyeok.baseEffectValues.containsKey(grade)) {
        final value = charyeok.baseEffectValues[grade]![star - 1].toDouble();
        switch (charyeok.baseEffectType) {
          case CharyeokEffectType.attackSetPercent:
            finalDamage *= (value / 100);
            break;
          case CharyeokEffectType.fixedAdditionalDamage:
            finalDamage += value;
            break;
          default:
            break;
        }
      }
    }

    setState(() {
      _calculatedDamage = finalDamage;
    });
  }

  Future<void> _showAuraSelectionDialog() async {
    final selected = await showDialog<Aura>(
      context: context,
      builder: (context) => _AuraSelectionDialog(),
    );
    if (selected != null) {
      setState(() {
        _selectedAura = selected;
      });
    }
  }

  Future<void> _showCharyeokSelectionDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      // Make the dialog larger to accommodate the new UI
      builder: (context) => Dialog(
        child: _CharyeokSelectionDialog(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCharyeok = result['charyeok'];
        _selectedCharyeokGrade = result['grade'];
        _selectedCharyeokStar = result['star'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Widget auraWidget;
    if (_selectedAura != null && _selectedAura!.name != '선택 안함') {
      // Selected state: Larger circular image with name below
      auraWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showAuraSelectionDialog,
            customBorder: const CircleBorder(),
            child: Container(
              width: 128, // Increased size
              height: 128, // Increased size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _selectedAura!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedAura!.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Default state: Text button
      auraWidget = InkWell(
        onTap: _showAuraSelectionDialog,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: const Text('오라 선택'),
        ),
      );
    }

    Widget charyeokWidget;
    if (_selectedCharyeok != null && _selectedCharyeok!.name != '선택 안함') {
      // Selected state: Larger circular image with name below
      charyeokWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showCharyeokSelectionDialog,
            customBorder: const CircleBorder(),
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _getBorderColorForGrade(_selectedCharyeokGrade), width: 3),
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _selectedCharyeok!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCharyeok!.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Default state: Text button
      charyeokWidget = InkWell(
        onTap: _showCharyeokSelectionDialog,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: const Text('차력 선택'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('데미지 계산기'),
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.damageCalculator),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<Character>(
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
          ),
          SizedBox(
            height: screenHeight * 0.35, // Increased height for the stack
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Character Image
                if (_selectedCharacter != null)
                  Positioned.fill(
                    child: Image.asset(
                      _selectedCharacter!.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Display a placeholder or error message
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: Text('이미지 없음')),
                        );
                      },
                    ),
                  ),
                // Foreground Icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      auraWidget,
                      charyeokWidget,
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
    if (this is CharyeokGrade) {
      switch (this as CharyeokGrade) {
        case CharyeokGrade.normal:
          return '일반';
        case CharyeokGrade.advanced:
          return '고급';
        case CharyeokGrade.rare:
          return '희귀';
        case CharyeokGrade.relic:
          return '유물';
        case CharyeokGrade.legendary:
          return '전설';
      }
    }
    return toString();
  }
}

class _CharyeokSelectionDialog extends StatefulWidget {
  @override
  __CharyeokSelectionDialogState createState() => __CharyeokSelectionDialogState();
}

class __CharyeokSelectionDialogState extends State<_CharyeokSelectionDialog> {
  Charyeok? _detailedCharyeok;
  CharyeokGrade? _selectedGrade;
  int _selectedStar = 1;

  @override
  void initState() {
    super.initState();
  }

  void _selectCharyeok(Charyeok charyeok) {
    setState(() {
      _detailedCharyeok = charyeok;
      if (charyeok.availableGrades.isNotEmpty) {
        _selectedGrade = charyeok.availableGrades[0];
      } else {
        _selectedGrade = null;
      }
      _selectedStar = 1;
    });
  }

  Widget _buildGridView() {
    final displayCharyeoks = charyeoks.where((c) => c.name != '선택 안함').toList();
    return Column(
      children: [
        Text("차력 선택", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: displayCharyeoks.length,
            itemBuilder: (context, index) {
              final charyeok = displayCharyeoks[index];
              return GestureDetector(
                onTap: () => _selectCharyeok(charyeok),
                child: GridTile(
                  footer: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      charyeok.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  child: Image.asset(charyeok.imagePath, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text("선택 취소"),
            onPressed: () {
              Navigator.pop(context, {
                'charyeok': charyeoks[0],
                'grade': null,
                'star': 1,
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    final charyeok = _detailedCharyeok!;
    String effectValueText = 'N/A';
    if (_selectedGrade != null && charyeok.baseEffectValues.containsKey(_selectedGrade)) {
      final values = charyeok.baseEffectValues[_selectedGrade]!;
      if (values.isNotEmpty) {
         effectValueText = values[_selectedStar - 1].toString();
      }
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _detailedCharyeok = null)),
              Expanded(child: Text(charyeok.name, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          Image.asset(charyeok.imagePath, height: 100, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 100)),
          const SizedBox(height: 16),
          if (charyeok.availableGrades.isNotEmpty)
            DropdownButton<CharyeokGrade>(
              value: _selectedGrade,
              items: charyeok.availableGrades
                  .map((grade) => DropdownMenuItem(value: grade, child: Text(grade.displayName)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGrade = value),
            ),
          const SizedBox(height: 16),
          Text('성급: $_selectedStar성'),
          Slider(
            value: _selectedStar.toDouble(),
            min: 1,
            max: 9,
            divisions: 8,
            label: '$_selectedStar성',
            onChanged: (value) => setState(() => _selectedStar = value.round()),
          ),
          const SizedBox(height: 16),
          Text('효과: ${charyeok.baseEffectDescription.replaceFirst('n', effectValueText)}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'charyeok': _detailedCharyeok,
                'grade': _selectedGrade,
                'star': _selectedStar,
              });
            },
            child: const Text('선택'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _detailedCharyeok == null ? _buildGridView() : _buildDetailView();
  }
}

class _AuraSelectionDialog extends StatefulWidget {
  @override
  __AuraSelectionDialogState createState() => __AuraSelectionDialogState();
}

class __AuraSelectionDialogState extends State<_AuraSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    final displayAuras = auras.where((a) => a.name != '선택 안함').toList();
    return Dialog(
      child: Column(
        children: [
          Text("오라 선택", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: displayAuras.length,
              itemBuilder: (context, index) {
                final aura = displayAuras[index];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, aura),
                  child: GridTile(
                    footer: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        aura.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    child: Image.asset(aura.imagePath, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text("선택 취소"),
              onPressed: () {
                // Pop with the "None" aura
                Navigator.pop(context, auras[0]);
              },
            ),
          ),
        ],
      ),
    );
  }
}


