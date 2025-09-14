import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/box_constants.dart';
import 'package:goh_calculator/core/widgets/app_drawer.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';
import 'package:goh_calculator/core/constants/charyeok_constants.dart';
import 'package:goh_calculator/core/constants/spirit_constants.dart';
import 'package:intl/intl.dart';

enum RebirthRealm { none, heavenly, demon }
enum RebirthStat { none, skillDamage, attackPower, critDamage, normalDamage }

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
  }
}

class _DamageCalculatorScreenState extends State<DamageCalculatorScreen> {
  // Character, Charyeok, and Spirit
  Character? _selectedCharacter;
  Charyeok? _selectedCharyeok;
  CharyeokGrade? _selectedCharyeokGrade;
  int _selectedCharyeokStar = 1;
  Spirit? _selectedSpirit;

  // Rebirth
  RebirthRealm _selectedRebirthRealm = RebirthRealm.none;
  int _rebirthLevel = 0;
  RebirthStat _selectedRebirthStat = RebirthStat.none;

  // Calculation Results
  double _calculatedDamage = 0;
  double _currentAttackPower = 0;

  // --- Text Editing Controllers ---
  final _additionalAttackPowerController = TextEditingController();
  final _leaderEffectController = TextEditingController();
  final _highSchoolBuffController = TextEditingController();
  final _moonBaseBuffController = TextEditingController();
  final _powerUpController = TextEditingController();
  final _critDamageController = TextEditingController();
  final _divineItemCritDamageController = TextEditingController();
  final _crestCritDamageController = TextEditingController();
  final _accessoryNormalDamageController = TextEditingController();
  final _equipmentNormalDamageController = TextEditingController();
  final _divineItemNormalDamageController = TextEditingController();
  final _fragmentNormalDamageController = TextEditingController();
  final _accessorySkillDamageController = TextEditingController();
  final _equipmentSkillDamageController = TextEditingController();
  final _divineItemSkillDamageController = TextEditingController();
  final _fragmentSkillDamageController = TextEditingController();
  final _accessoryMinigameDamageController = TextEditingController();
  final _equipmentMinigameDamageController = TextEditingController();
  final _divineItemMinigameDamageController = TextEditingController();
  final _fragmentMinigameDamageController = TextEditingController();
  final _rebirthStatValueController = TextEditingController();

  // --- Rebirth Bonuses ---
  final List<int> demonRebirthAttackBonus = [0, 50, 50, 100, 100, 200, 200, 300, 300, 450];
  final List<int> heavenlyRebirthAttackBonus = [0, 50, 100, 200, 300, 450, 600, 800, 1000, 1400];

  @override
  void initState() {
    super.initState();
    _selectedCharacter = characters[0];
    _selectedSpirit = spirits[0];
    if (charyeoks.isNotEmpty) {
      _selectedCharyeok = charyeoks[0];
      if (_selectedCharyeok!.availableGrades.isNotEmpty) {
        _selectedCharyeokGrade = _selectedCharyeok!.availableGrades[0];
      }
    }
  }

  @override
  void dispose() {
    _additionalAttackPowerController.dispose();
    _leaderEffectController.dispose();
    _highSchoolBuffController.dispose();
    _moonBaseBuffController.dispose();
    _powerUpController.dispose();
    _critDamageController.dispose();
    _divineItemCritDamageController.dispose();
    _crestCritDamageController.dispose();
    _accessoryNormalDamageController.dispose();
    _equipmentNormalDamageController.dispose();
    _divineItemNormalDamageController.dispose();
    _fragmentNormalDamageController.dispose();
    _accessorySkillDamageController.dispose();
    _equipmentSkillDamageController.dispose();
    _divineItemSkillDamageController.dispose();
    _fragmentSkillDamageController.dispose();
    _accessoryMinigameDamageController.dispose();
    _equipmentMinigameDamageController.dispose();
    _divineItemMinigameDamageController.dispose();
    _fragmentMinigameDamageController.dispose();
    _rebirthStatValueController.dispose();
    super.dispose();
  }

  double _getParser(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0;
  }

  void _calculateDamage() {
    if (_selectedCharacter == null) return;

    // --- Charyeok Effects ---
    double charyeokBaseAttackIncrease = 1.0;
    double charyeokAttackIncrease = 1.0;
    double charyeokCritDamage = 0;
    double charyeokNormalDamage = 0;
    double charyeokSkillDamage = 0;
    double charyeokFixedDamage = 0;

    if (_selectedCharyeok != null && _selectedCharyeokGrade != null) {
      final charyeok = _selectedCharyeok!;
      final grade = _selectedCharyeokGrade!;
      final star = _selectedCharyeokStar;

      if (charyeok.baseEffectValues.containsKey(grade)) {
        final value = charyeok.baseEffectValues[grade]![star - 1].toDouble();
        switch (charyeok.baseEffectType) {
          case CharyeokEffectType.baseAttackIncreasePercent:
            charyeokBaseAttackIncrease = 1 + (value / 100);
            break;
          case CharyeokEffectType.critDamageIncrease:
            charyeokCritDamage = value;
            break;
          case CharyeokEffectType.fixedAdditionalDamage:
            charyeokFixedDamage = value;
            break;
          case CharyeokEffectType.attackSetPercent:
            charyeokAttackIncrease = value / 100;
            break;
          case CharyeokEffectType.none:
            break;
        }
      }

      if (charyeok.synergyEffectType.containsKey(grade)) {
        final synergyType = charyeok.synergyEffectType[grade]!;
        final synergyValue = charyeok.synergyEffectValues[grade]!.toDouble();
        switch (synergyType) {
          case SynergyEffectType.skillDamageIncreasePercent:
            charyeokSkillDamage = synergyValue;
            break;
          case SynergyEffectType.normalDamageIncreasePercent:
            charyeokNormalDamage = synergyValue;
            break;
          case SynergyEffectType.none:
            break;
        }
      }
    }
    
    // --- Rebirth Stat Bonus ---
    double rebirthStatValue = _getParser(_rebirthStatValueController);
    double rebirthAttackOption = 0;
    double rebirthCritDmgOption = 0;
    double rebirthNormalDmgOption = 0;
    double rebirthSkillDmgOption = 0;

    if(_selectedRebirthRealm != RebirthRealm.none) {
        switch(_selectedRebirthStat) {
            case RebirthStat.attackPower:
                rebirthAttackOption = rebirthStatValue;
                break;
            case RebirthStat.critDamage:
                rebirthCritDmgOption = rebirthStatValue;
                break;
            case RebirthStat.normalDamage:
                rebirthNormalDmgOption = rebirthStatValue;
                break;
            case RebirthStat.skillDamage:
                rebirthSkillDmgOption = rebirthStatValue;
                break;
            case RebirthStat.none:
                break;
        }
    }

    // --- Part 1: Base Attack Calculation ---
    double baseAttack = _selectedCharacter!.baseAttackPower.toDouble();
    double additionalAttack = _getParser(_additionalAttackPowerController);
    double rebirthAttackBonus = 0;
    if (_selectedRebirthRealm == RebirthRealm.demon) {
      rebirthAttackBonus = demonRebirthAttackBonus[_rebirthLevel].toDouble();
    } else if (_selectedRebirthRealm == RebirthRealm.heavenly) {
      rebirthAttackBonus = heavenlyRebirthAttackBonus[_rebirthLevel].toDouble();
    }

    double totalBaseAttack = (baseAttack * charyeokBaseAttackIncrease) + additionalAttack + rebirthAttackBonus + rebirthAttackOption;

    // --- Part 2: Multipliers ---
    double leaderBuff = _getParser(_leaderEffectController) / 100;
    double highSchoolBuff = _getParser(_highSchoolBuffController) / 100;
    double moonBaseBuff = _getParser(_moonBaseBuffController) / 100;
    double powerUpBuff = _getParser(_powerUpController) / 100;

    leaderBuff = leaderBuff == 0 ? 1.0 : leaderBuff;
    highSchoolBuff = highSchoolBuff == 0 ? 1.0 : highSchoolBuff;
    moonBaseBuff = moonBaseBuff == 0 ? 1.0 : moonBaseBuff;
    powerUpBuff = powerUpBuff == 0 ? 1.0 : powerUpBuff;

    double totalMultiplier = leaderBuff * highSchoolBuff * moonBaseBuff * charyeokAttackIncrease * powerUpBuff;

    // --- Part 3: Damage Type Multipliers ---
    double spiritCritDamage = (_selectedSpirit?.effects['crit_damage'] as num? ?? 0).toDouble();
    double spiritSkillDamage = (_selectedSpirit?.effects['skill_damage_increase'] as num? ?? 0).toDouble();
    double passiveCritDamage = (_selectedCharacter!.passive['critDamage'] as num? ?? 0).toDouble();

    double critDmgSum = _getParser(_critDamageController) +
        _getParser(_divineItemCritDamageController) +
        rebirthCritDmgOption +
        spiritCritDamage +
        _getParser(_crestCritDamageController) +
        passiveCritDamage +
        charyeokCritDamage;
    double critDmgMultiplier = 1 + (critDmgSum / 100);

    double normalDmgSum = _getParser(_accessoryNormalDamageController) +
        _getParser(_equipmentNormalDamageController) +
        _getParser(_divineItemNormalDamageController) +
        charyeokNormalDamage +
        rebirthNormalDmgOption +
        _getParser(_fragmentNormalDamageController);
    double normalDmgMultiplier = 1 + (normalDmgSum / 100);

    double skillDmgSum = _getParser(_accessorySkillDamageController) +
        _getParser(_equipmentSkillDamageController) +
        _getParser(_divineItemSkillDamageController) +
        spiritSkillDamage +
        charyeokSkillDamage +
        rebirthSkillDmgOption +
        _getParser(_fragmentSkillDamageController);
    double skillDmgMultiplier = 1 + (skillDmgSum / 100);

    double minigameDmgSum = _getParser(_accessoryMinigameDamageController) +
        _getParser(_equipmentMinigameDamageController) +
        _getParser(_divineItemMinigameDamageController) +
        _getParser(_fragmentMinigameDamageController);
    double minigameDmgMultiplier = 1 + (minigameDmgSum / 100);

    double skillCoeffSum = _selectedCharacter!.skillMultiplier.toDouble();
    double skillCoeffMultiplier = skillCoeffSum / 100;

    // --- Final Calculation ---
    double finalDamage = totalBaseAttack * totalMultiplier;
    String damageType = _selectedCharacter!.damageType;

    if (damageType.contains('크리 데미지')) finalDamage *= critDmgMultiplier;
    if (damageType.contains('일반 데미지')) finalDamage *= normalDmgMultiplier;
    if (damageType.contains('스킬 데미지')) finalDamage *= skillDmgMultiplier;
    if (damageType.contains('미니게임 데미지')) finalDamage *= minigameDmgMultiplier;
    
    finalDamage *= skillCoeffMultiplier;

    // --- Part 4: Fixed Additional Damage ---
    // For now, rebirth fixed damage is an input field. This can be updated.
    double rebirthFixedDamage = 0; 
    finalDamage += rebirthFixedDamage + charyeokFixedDamage;

    setState(() {
      _calculatedDamage = finalDamage;
      _currentAttackPower = totalBaseAttack * totalMultiplier;
    });
  }

  Future<void> _showCharyeokSelectionDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
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

  Future<void> _showLeaderSelectionDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('리더 효과'),
            content: _buildTextField('리더 효과 (%)', _leaderEffectController, hint: '150'),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final screenHeight = MediaQuery.of(context).size.height;

    Widget charyeokWidget;
    if (_selectedCharyeok != null && _selectedCharyeok!.name != '선택 안함') {
      charyeokWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showCharyeokSelectionDialog,
            customBorder: const CircleBorder(),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _getBorderColorForGrade(_selectedCharyeokGrade), width: 2),
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
          const SizedBox(height: 4),
          Text(
            _selectedCharyeok!.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
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

    Widget leaderWidget = InkWell(
      onTap: _showLeaderSelectionDialog,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: const Text('리더 선택'),
      ),
    );

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
            height: screenHeight * 0.25,
            child: Stack(
              children: [
                if (_selectedCharacter != null)
                  Positioned.fill(
                    child: Image.asset(
                      _selectedCharacter!.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: Text('이미지 없음')),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: leaderWidget,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: charyeokWidget,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                children: [
                  _buildRebirthSelector(),
                  const SizedBox(height: 10),
                  _buildInputFields(),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _calculateDamage, child: const Text('계산하기')),
                  const SizedBox(height: 20),
                  Text(
                    '산출된 공격력: ${formatter.format(_currentAttackPower)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
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

  Widget _buildInputFields() {
    return Column(
      children: [
        ExpansionTile(
          title: const Text('공격력 관련'),
          initiallyExpanded: true,
          children: [
            _buildTextField('추가 공격력', _additionalAttackPowerController),
            _buildTextField('하이스쿨 버프 (%)', _highSchoolBuffController),
            _buildTextField('달기지 공격력 (%)', _moonBaseBuffController),
            _buildTextField('파워업 (%)', _powerUpController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        ExpansionTile(
          title: const Text('크리티컬 데미지 (%)'),
          children: [
            _buildTextField('표기 크뎀', _critDamageController),
            _buildTextField('신기 크뎀', _divineItemCritDamageController),
            _buildTextField('문장 크뎀', _crestCritDamageController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        ExpansionTile(
          title: const Text('일반 공격 데미지 증가 (%)'),
          children: [
            _buildTextField('악세 일공증', _accessoryNormalDamageController),
            _buildTextField('장비 일공증', _equipmentNormalDamageController),
            _buildTextField('신기 일공증', _divineItemNormalDamageController),
            _buildTextField('파편 일공증', _fragmentNormalDamageController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        ExpansionTile(
          title: const Text('스킬 데미지 증가 (%)'),
          children: [
            _buildTextField('악세 스증', _accessorySkillDamageController),
            _buildTextField('장비 스증', _equipmentSkillDamageController),
            _buildTextField('신기 스증', _divineItemSkillDamageController),
            _buildTextField('파편 스증', _fragmentSkillDamageController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        ExpansionTile(
          title: const Text('미니게임 데미지 증가 (%)'),
          children: [
            _buildTextField('악세 미겜증', _accessoryMinigameDamageController),
            _buildTextField('장비 미겜증', _equipmentMinigameDamageController),
            _buildTextField('신기 미겜증', _divineItemMinigameDamageController),
            _buildTextField('파편 미겜증', _fragmentMinigameDamageController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
      ],
    );
  }

  Widget _buildRebirthSelector() {
    List<RebirthStat> availableStats = [];
    if (_selectedRebirthRealm == RebirthRealm.heavenly) {
      availableStats = [RebirthStat.skillDamage, RebirthStat.attackPower, RebirthStat.critDamage];
    } else if (_selectedRebirthRealm == RebirthRealm.demon) {
      availableStats = [RebirthStat.normalDamage];
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('환생: '),
            DropdownButton<RebirthRealm>(
              value: _selectedRebirthRealm,
              items: RebirthRealm.values.map((realm) {
                return DropdownMenuItem<RebirthRealm>(
                  value: realm,
                  child: Text(realm.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRebirthRealm = value ?? RebirthRealm.none;
                  _selectedRebirthStat = RebirthStat.none; // Reset stat selection
                });
              },
            ),
            const SizedBox(width: 10),
            if (_selectedRebirthRealm != RebirthRealm.none)
              DropdownButton<int>(
                value: _rebirthLevel,
                hint: const Text('단계'),
                items: List.generate(10, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
                onChanged: (value) {
                  setState(() {
                    _rebirthLevel = value ?? 0;
                  });
                },
              ),
          ],
        ),
        if (_selectedRebirthRealm != RebirthRealm.none)
          const SizedBox(height: 10),
        if (_selectedRebirthRealm != RebirthRealm.none)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<RebirthStat>(
                value: _selectedRebirthStat,
                hint: const Text('증가 스탯'),
                items: [RebirthStat.none, ...availableStats].map((stat) {
                  return DropdownMenuItem<RebirthStat>(
                    value: stat,
                    child: Text(stat.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRebirthStat = value ?? RebirthStat.none;
                  });
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField('스탯 값', _rebirthStatValueController),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? suffix, String? hint}) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      );
  }
}

extension DropdownDisplay on Object {
  String get displayName {
    if (this is Spirit) return (this as Spirit).name;
    if (this is Charyeok) return (this as Charyeok).name;
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
    if (this is RebirthRealm) {
      switch (this as RebirthRealm) {
        case RebirthRealm.none:
          return '선택 안함';
        case RebirthRealm.heavenly:
          return '천계';
        case RebirthRealm.demon:
          return '마계';
      }
    }
    if (this is RebirthStat) {
        switch (this as RebirthStat) {
            case RebirthStat.none:
                return '스탯 선택';
            case RebirthStat.attackPower:
                return '공격력 증가';
            case RebirthStat.critDamage:
                return '크리티컬 데미지 증가';
            case RebirthStat.normalDamage:
                return '일반 데미지 증가';
            case RebirthStat.skillDamage:
                return '스킬 데미지 증가';
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