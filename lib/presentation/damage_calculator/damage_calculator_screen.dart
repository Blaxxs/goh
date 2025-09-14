import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/box_constants.dart';
import 'package:goh_calculator/core/services/settings_service.dart';
import 'package:goh_calculator/core/widgets/app_drawer.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';
import 'package:goh_calculator/core/constants/charyeok_constants.dart';
import 'package:goh_calculator/core/constants/spirit_constants.dart';
import 'package:intl/intl.dart';

enum RebirthRealm { none, heavenly, demon }
enum RebirthStat { none, skillDamage, attackPower, critDamage, normalDamage }
enum CrestType { none, attack, critDamage, skillDamage }

class Crest {
  final String name;
  final CrestType type;
  final String? imagePath;
  final IconData? icon;

  const Crest({required this.name, required this.type, this.imagePath, this.icon});
}

const List<Crest> crests = [
  Crest(name: '선택 안함', type: CrestType.none, icon: Icons.cancel_outlined),
  Crest(name: '공격강화 문장', type: CrestType.attack, imagePath: 'assets/images/crest/attack.png'),
  Crest(name: '치명피해 문장', type: CrestType.critDamage, imagePath: 'assets/images/crest/fatal.png'),
  Crest(name: '스킬 문장', type: CrestType.skillDamage, imagePath: 'assets/images/crest/skill.png'),
];

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
  // Selections
  Character? _selectedCharacter;
  Charyeok? _selectedCharyeok;
  CharyeokGrade? _selectedCharyeokGrade;
  int _selectedCharyeokStar = 1;
  Spirit? _selectedSpirit;
  Crest? _selectedCrest;

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
  final _powerUpController = TextEditingController();
  final _critDamageController = TextEditingController();
  final _divineItemCritDamageController = TextEditingController();
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
  final _crestValueController = TextEditingController();

  // --- Data Maps ---
  final List<int> demonRebirthAttackBonus = [0, 50, 50, 100, 100, 200, 200, 300, 300, 450];
  final List<int> heavenlyRebirthAttackBonus = [0, 50, 100, 200, 300, 450, 600, 800, 1000, 1400];
  final Map<int, double> moonBaseAttackBuffs = {
    0: 0, 1: 0.1, 2: 0.1, 3: 0.2, 4: 0.2, 5: 0.3, 6: 0.3, 7: 0.4, 8: 0.4, 9: 0.5, 10: 1.5,
    11: 1.6, 12: 1.6, 13: 1.7, 14: 1.7, 15: 1.8, 16: 1.8, 17: 1.9, 18: 1.9, 19: 2, 20: 3,
    21: 3.1, 22: 3.1, 23: 3.2, 24: 3.2, 25: 3.3, 26: 3.3, 27: 3.4, 28: 3.4, 29: 3.5, 30: 4.5,
    31: 4.6, 32: 4.6, 33: 4.7, 34: 4.7, 35: 4.8, 36: 4.8, 37: 4.9, 38: 4.9, 39: 5, 40: 6,
    41: 6.1, 42: 6.1, 43: 6.2, 44: 6.2, 45: 6.3, 46: 6.3, 47: 6.4, 48: 6.4, 49: 6.5, 50: 7.5,
    51: 7.6, 52: 7.6, 53: 7.7, 54: 7.7, 55: 7.8, 56: 7.8, 57: 7.9, 58: 7.9, 59: 8, 60: 9,
    61: 9.1, 62: 9.1, 63: 9.2, 64: 9.2, 65: 9.3, 66: 9.3, 67: 9.4, 68: 9.4, 69: 9.5, 70: 11.5,
    71: 11.6, 72: 11.6, 73: 11.7, 74: 11.7, 75: 11.8, 76: 11.8, 77: 11.9, 78: 11.9, 79: 12, 80: 14,
    81: 14.1, 82: 14.1, 83: 14.2, 84: 14.2, 85: 14.3, 86: 14.3, 87: 14.4, 88: 14.4, 89: 14.5, 90: 16.5,
    91: 16.6, 92: 16.6, 93: 16.7, 94: 16.7, 95: 17.8, 96: 17.8, 97: 17.9, 98: 17.9, 99: 18, 100: 20,
    101: 20.1, 102: 20.1, 103: 20.2, 104: 20.2, 105: 20.3, 106: 20.3, 107: 20.4, 108: 20.4, 109: 20.5, 110: 21.5,
    111: 21.6, 112: 21.6, 113: 21.7, 114: 21.7, 115: 21.8, 116: 21.8, 117: 21.9, 118: 21.9, 119: 22, 120: 23,
    121: 23.1, 122: 23.1, 123: 23.2, 124: 23.2, 125: 23.3, 126: 23.3, 127: 23.4, 128: 23.4, 129: 23.5, 130: 24.5,
    131: 24.6, 132: 24.6, 133: 24.7, 134: 24.7, 135: 24.8, 136: 24.8, 137: 24.9, 138: 24.9, 139: 25, 140: 26,
    141: 26.1, 142: 26.1, 143: 26.2, 144: 26.2, 145: 26.3, 146: 26.3, 147: 26.4, 148: 26.4, 149: 26.5, 150: 27.5,
    151: 27.6, 152: 27.6, 153: 27.7, 154: 27.7, 155: 27.8, 156: 27.8, 157: 27.9, 158: 27.9, 159: 28, 160: 29,
    161: 29.1, 162: 29.1, 163: 29.2, 164: 29.2, 165: 29.3, 166: 29.3, 167: 29.4, 168: 29.4, 169: 29.5, 170: 31.5,
    171: 31.6, 172: 31.6, 173: 31.7, 174: 31.7, 175: 31.8, 176: 31.8, 177: 31.9, 178: 31.9, 179: 32, 180: 34,
    181: 34.1, 182: 34.1, 183: 34.2, 184: 34.2, 185: 34.3, 186: 34.3, 187: 34.4, 188: 34.4, 189: 34.5, 190: 36.5,
    191: 36.6, 192: 36.6, 193: 36.7, 194: 36.7, 195: 37.8, 196: 37.8, 197: 37.9, 198: 37.9, 199: 38, 200: 40,
  };

  @override
  void initState() {
    super.initState();
    _selectedCharacter = characters[0];
    _selectedSpirit = spirits[0];
    _selectedCrest = crests[0];
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
    _powerUpController.dispose();
    _critDamageController.dispose();
    _divineItemCritDamageController.dispose();
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
    _crestValueController.dispose();
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

    // --- Crest Bonus ---
    double crestValue = _getParser(_crestValueController);
    double crestAttackBuff = 1.0;
    double crestCritDamage = 0;
    double crestSkillDamage = 0;
    if (_selectedCrest != null) {
        switch(_selectedCrest!.type) {
            case CrestType.attack:
                crestAttackBuff = 1 + (crestValue / 100);
                break;
            case CrestType.critDamage:
                crestCritDamage = crestValue;
                break;
            case CrestType.skillDamage:
                crestSkillDamage = crestValue;
                break;
            case CrestType.none:
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
    final Object dalgijiLevel = SettingsService.instance.stageSettings.dalgijiLevel ?? 0;
    final double moonBaseAttackPercent = moonBaseAttackBuffs[dalgijiLevel] ?? 0.0;
    double moonBaseBuff = 1 + (moonBaseAttackPercent / 100);

    double leaderBuff = _getParser(_leaderEffectController) / 100;
    double highSchoolBuff = _getParser(_highSchoolBuffController) / 100;
    double powerUpBuff = _getParser(_powerUpController) / 100;

    leaderBuff = leaderBuff == 0 ? 1.0 : leaderBuff;
    highSchoolBuff = highSchoolBuff == 0 ? 1.0 : highSchoolBuff;
    powerUpBuff = powerUpBuff == 0 ? 1.0 : powerUpBuff;

    double totalMultiplier = leaderBuff * highSchoolBuff * moonBaseBuff * charyeokAttackIncrease * powerUpBuff * crestAttackBuff;

    // --- Part 3: Damage Type Multipliers ---
    double spiritCritDamage = (_selectedSpirit?.effects['crit_damage'] as num? ?? 0).toDouble();
    double spiritSkillDamage = (_selectedSpirit?.effects['skill_damage_increase'] as num? ?? 0).toDouble();
    double passiveCritDamage = (_selectedCharacter!.passive['critDamage'] as num? ?? 0).toDouble();

    double critDmgSum = _getParser(_critDamageController) +
        _getParser(_divineItemCritDamageController) +
        rebirthCritDmgOption +
        spiritCritDamage +
        crestCritDamage +
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
        crestSkillDamage +
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

  Future<void> _showCrestSelectionDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return _CrestSelectionDialog(
          initialCrest: _selectedCrest ?? crests[0],
          initialValue: _crestValueController.text,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCrest = result['crest'];
        _crestValueController.text = result['value'];
      });
    }
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

    Widget crestWidget;
    if (_selectedCrest != null && _selectedCrest!.type != CrestType.none) {
        crestWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                InkWell(
                    onTap: _showCrestSelectionDialog,
                    customBorder: const CircleBorder(),
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: _selectedCrest!.imagePath != null
                            ? ClipOval(child: Image.asset(_selectedCrest!.imagePath!, fit: BoxFit.cover))
                            : Icon(_selectedCrest!.icon, color: Colors.blueGrey, size: 30),
                    ),
                ),
                const SizedBox(height: 4),
                Text(
                    _selectedCrest!.name,
                    style: const TextStyle(color: Colors.white, fontSize: 10, shadows: <Shadow>[Shadow(offset: Offset(1.0, 1.0), blurRadius: 2.0, color: Colors.black,)]),
                ),
            ],
        );
    } else {
        crestWidget = InkWell(
          onTap: _showCrestSelectionDialog,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Text('문장 선택'),
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: leaderWidget,
                ),
                Positioned(
                  top: 68, 
                  left: 8,
                  child: crestWidget,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: charyeokWidget,
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
            _buildTextField('파워업 (%)', _powerUpController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        ExpansionTile(
          title: const Text('크리티컬 데미지 (%)'),
          children: [
            _buildTextField('표기 크뎀', _critDamageController),
            _buildTextField('신기 크뎀', _divineItemCritDamageController),
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
    if (this is Crest) {
        return (this as Crest).name;
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

class _CrestSelectionDialog extends StatefulWidget {
  final Crest initialCrest;
  final String initialValue;

  const _CrestSelectionDialog({required this.initialCrest, required this.initialValue});

  @override
  __CrestSelectionDialogState createState() => __CrestSelectionDialogState();
}

class __CrestSelectionDialogState extends State<_CrestSelectionDialog> {
  late Crest _selectedCrest;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _selectedCrest = widget.initialCrest;
    _valueController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('문장 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: crests.where((c) => c.type != CrestType.none).map((crest) {
              bool isSelected = _selectedCrest.type == crest.type;
              return InkWell(
                onTap: () => setState(() => _selectedCrest = crest),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                    border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
                  ),
                  child: Column(
                    children: [
                      if (crest.imagePath != null)
                        Image.asset(crest.imagePath!, width: 30, height: 30)
                      else if (crest.icon != null)
                        Icon(crest.icon!, size: 30),
                      const SizedBox(height: 4),
                      Text(crest.name, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_selectedCrest.type != CrestType.none)
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: '${_selectedCrest.name} 값',
                hintText: 'n% 또는 n 입력',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('확인'),
          onPressed: () {
            Navigator.of(context).pop({
              'crest': _selectedCrest,
              'value': _valueController.text,
            });
          },
        ),
      ],
    );
  }
}
