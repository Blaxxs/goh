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
  int _selectedSpiritStar = 1;
  Crest? _selectedCrest;
  Leader? _selectedLeader;

  // Rebirth
  RebirthRealm _selectedRebirthRealm = RebirthRealm.none;
  int _rebirthLevel = 0;
  RebirthStat _selectedRebirthStat = RebirthStat.none;

  // Critical
  bool _isCriticalEnabled = false;

  // Calculation Results
  double _calculatedDamage = 0;
  double _currentAttackPower = 0;

  // --- Text Editing Controllers ---
  final _additionalAttackPowerController = TextEditingController();
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
    _selectedLeader = leaders[0];
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

    // --- Spirit Effects ---
    double spiritSkillCoeff = 0;
    double spiritCritDamage = 0;
    double spiritBaseAttack = 0;
    double spiritNormalDamage = 0;
    double spiritSkillDamage = 0;

    if (_selectedSpirit != null) {
      for (var effect in _selectedSpirit!.effects) {
        if (effect.characterDependency == null || effect.characterDependency == _selectedCharacter!.englishName) {
          final value = effect.values[_selectedSpiritStar - 1];
          switch (effect.type) {
            case SpiritEffectType.skillCoefficient:
              spiritSkillCoeff = value;
              break;
            case SpiritEffectType.critDamage:
              spiritCritDamage = value;
              break;
            case SpiritEffectType.baseAttack:
              spiritBaseAttack = value;
              break;
            case SpiritEffectType.normalDamage:
              spiritNormalDamage = value;
              break;
            case SpiritEffectType.skillDamage:
              spiritSkillDamage = value;
              break;
          }
        }
      }
    }

    // --- Charyeok Effects ---
    double charyeokBaseAttackIncrease = 1.0;
    double charyeokAttackIncrease = 1.0; // Initialize to 1.0, will be set below
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

        // Handle effects that are NOT attackSetPercent or baseAttackIncreasePercent
        // These are critDamageIncrease and fixedAdditionalDamage
        switch (charyeok.baseEffectType) {
          case CharyeokEffectType.critDamageIncrease:
            charyeokCritDamage = value;
            break;
          case CharyeokEffectType.fixedAdditionalDamage:
            charyeokFixedDamage = value;
            break;
          case CharyeokEffectType.none:
            break;
          // attackSetPercent and baseAttackIncreasePercent are handled below
          case CharyeokEffectType.attackSetPercent:
          case CharyeokEffectType.baseAttackIncreasePercent:
            // Do nothing here, handled by specific Charyeok name below
            break;
        }

        // Handle charyeokBaseAttackIncrease (for "기본 공격력이 n%증가한다" type)
        if (charyeok.baseEffectType == CharyeokEffectType.baseAttackIncreasePercent) {
          charyeokBaseAttackIncrease = 1 + (value / 100);
        }

        // Handle charyeokAttackIncrease based on specific Charyeok name
        if (charyeok.englishName == 'tam') { // 제갈택의 탐: 공격력이 n%가 된다
          charyeokAttackIncrease = value / 100;
        } else if (charyeok.englishName == 'umawang' || charyeok.englishName == 'longginuseu') { // 우마왕, 롱기누스: 기본 공격력이 n%증가한다 (이것이 totalMultiplier에 영향을 주는 경우)
          charyeokAttackIncrease = 1 + (value / 100);
        } else if (charyeok.baseEffectType == CharyeokEffectType.attackSetPercent) {
          // Default for other attackSetPercent types if not tam
          charyeokAttackIncrease = value / 100;
        } else if (charyeok.baseEffectType == CharyeokEffectType.baseAttackIncreasePercent) {
          // Default for other baseAttackIncreasePercent types if not umawang/longginuseu
          // If baseAttackIncreasePercent also affects totalMultiplier as 1 + n/100, then:
          charyeokAttackIncrease = 1 + (value / 100);
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
    double baseCharacterAttack = _selectedCharacter!.baseAttackPower.toDouble();
    double rebirthAttackBonus = 0;
    if (_selectedRebirthRealm == RebirthRealm.demon) {
      rebirthAttackBonus = demonRebirthAttackBonus[_rebirthLevel].toDouble();
    } else if (_selectedRebirthRealm == RebirthRealm.heavenly) {
      rebirthAttackBonus = heavenlyRebirthAttackBonus[_rebirthLevel].toDouble();
    }

    // New term: baseAttackForCharyeok includes character base, rebirth stat option, and spirit base attack
    double baseAttackForCharyeok = baseCharacterAttack + rebirthAttackOption + spiritBaseAttack;

    // totalBaseAttack now uses baseAttackForCharyeok
    double totalBaseAttack = (baseAttackForCharyeok * charyeokBaseAttackIncrease) + _getParser(_additionalAttackPowerController) + rebirthAttackBonus;


    // --- Part 2: Multipliers ---
    final Object dalgijiLevel = SettingsService.instance.stageSettings.dalgijiLevel ?? 0;
    final double moonBaseAttackPercent = moonBaseAttackBuffs[dalgijiLevel] ?? 0.0;
    double moonBaseBuff = 1 + (moonBaseAttackPercent / 100);

    double leaderBuff = _selectedLeader?.multiplier ?? 1.0;

    // Changed highSchoolBuff and powerUpBuff calculation as per user's clarification
    double highSchoolBuffMultiplier = 1 + (_getParser(_highSchoolBuffController) / 100);
    double powerUpValue = _getParser(_powerUpController);
    double powerUpBuffMultiplier = (powerUpValue == 0) ? 1.0 : (powerUpValue / 100);

    // charyeokAttackIncrease remains value / 100 (assuming "n%가 된다" type)
    // crestAttackBuff remains 1 + (crestValue / 100)

    double totalMultiplier = leaderBuff * highSchoolBuffMultiplier * moonBaseBuff * charyeokAttackIncrease * powerUpBuffMultiplier * crestAttackBuff;

    // --- Part 3: Damage Type Multipliers ---
    double passiveCritDamage = (_selectedCharacter!.passive['critDamage'] as num? ?? 0).toDouble();

    double critDmgSum = _getParser(_divineItemCritDamageController) +
        rebirthCritDmgOption +
        spiritCritDamage +
        crestCritDamage +
        passiveCritDamage +
        charyeokCritDamage;

    if (_isCriticalEnabled) {
      critDmgSum += _getParser(_critDamageController); // Add '표기 크뎀' only if critical is enabled
    }

    

    double critDmgMultiplier;
    if (_isCriticalEnabled) {
      critDmgMultiplier = (critDmgSum / 100);
    } else {
      critDmgMultiplier = 1.0;
    }

    double normalDmgSum = _getParser(_accessoryNormalDamageController) +
        _getParser(_equipmentNormalDamageController) +
        _getParser(_divineItemNormalDamageController) +
        charyeokNormalDamage +
        rebirthNormalDmgOption +
        spiritNormalDamage +
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
        _getParser(_fragmentMinigameDamageController);
    double minigameDmgMultiplier = 1 + (minigameDmgSum / 100);

    double skillCoeffSum = _selectedCharacter!.skillMultiplier.toDouble() + spiritSkillCoeff;
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
        child: CharyeokSelectionDialog(),
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
    final result = await showDialog<Leader>(
      context: context,
      builder: (context) {
        return Dialog(
          child: LeaderSelectionDialog(),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedLeader = result;
      });
    }
  }

  Future<void> _showCrestSelectionDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return Dialog(
          child: CrestSelectionDialog(
            initialCrest: _selectedCrest ?? crests[0],
            initialValue: _crestValueController.text,
          ),
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

  Future<void> _showSpiritSelectionDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        child: SpiritSelectionDialog(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSpirit = result['spirit'];
        _selectedSpiritStar = result['star'];
      });
    }
  }

  Future<void> _showBuffSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => BuffSelectionDialog(
        highSchoolBuffController: _highSchoolBuffController,
        divineItemNormalDamageController: _divineItemNormalDamageController,
        divineItemSkillDamageController: _divineItemSkillDamageController,
        divineItemCritDamageController: _divineItemCritDamageController,
        powerUpController: _powerUpController, // ADDED
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final screenHeight = MediaQuery.of(context).size.height;
    final imageContainerHeight = screenHeight * 0.3;
    final charyeokIconSize = imageContainerHeight / 3;
    final otherIconSize = imageContainerHeight * 0.225;
    final buffIconSize = otherIconSize * (2/3);

    Widget charyeokWidget;
    if (_selectedCharyeok != null && _selectedCharyeok!.name != '선택 안함') {
      charyeokWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showCharyeokSelectionDialog,
            customBorder: const CircleBorder(),
            child: Container(
              width: charyeokIconSize,
              height: charyeokIconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _getBorderColorForGrade(_selectedCharyeokGrade), width: 2),
                 boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, (0.5 * 255).round().toDouble()),
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

    Widget buffWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _showBuffSelectionDialog,
          customBorder: const CircleBorder(),
          child: Container(
            width: buffIconSize,
            height: buffIconSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Icon/buff.png',
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '버프',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
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

    Widget leaderWidget;
    if (_selectedLeader != null && _selectedLeader!.name != '선택 안함') {
      leaderWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showLeaderSelectionDialog,
            customBorder: const CircleBorder(),
            child: Container(
              width: otherIconSize,
              height: otherIconSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  _selectedLeader!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _selectedLeader!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      leaderWidget = InkWell(
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
    }

    Widget crestWidget;
    if (_selectedCrest != null && _selectedCrest!.type != CrestType.none) {
        crestWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                InkWell(
                    onTap: _showCrestSelectionDialog,
                    customBorder: const CircleBorder(),
                    child: Container(
                        width: otherIconSize,
                        height: otherIconSize,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                        ),
                        child: _selectedCrest!.imagePath != null
                            ? ClipOval(child: Image.asset(_selectedCrest!.imagePath!, fit: BoxFit.cover))
                            : Icon(_selectedCrest!.icon, color: Colors.blueGrey, size: 30),
                    ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                      _selectedCrest!.name,
                      style: const TextStyle(color: Colors.white, fontSize: 10, shadows: <Shadow>[Shadow(offset: Offset(1.0, 1.0), blurRadius: 2.0, color: Colors.black,)]),
                  ),
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

    Widget spiritWidget;
    if (_selectedSpirit != null && _selectedSpirit!.name != '선택 안함') {
      spiritWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showSpiritSelectionDialog,
            customBorder: const CircleBorder(),
            child: Container(
              width: otherIconSize,
              height: otherIconSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  _selectedSpirit!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _selectedSpirit!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      spiritWidget = InkWell(
        onTap: _showSpiritSelectionDialog,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: const Text('스피릿 선택'),
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
            height: screenHeight * 0.3,
            child: Stack(
              children: [
                if (_selectedCharacter != null)
                  Positioned.fill(
                    child: Image.asset(
                      _selectedCharacter!.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: Text('이미지 없음')),
                        );
                      },
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 8,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [leaderWidget, crestWidget, spiritWidget],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      charyeokWidget,
                      const SizedBox(height: 8),
                      buffWidget,
                    ],
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
    final String? selectedCharacterName = _selectedCharacter?.name;
    final bool isSatanOrWamira = selectedCharacterName == '사탄' || selectedCharacterName == '와미라';
    final bool isHaegaeltaek = selectedCharacterName == '해갈택';

    return Column(
      children: [
        ExpansionTile(
          title: const Text('공격력 관련'),
          initiallyExpanded: true,
          children: [
            _buildTextField('추가 공격력', _additionalAttackPowerController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        if (_isCriticalEnabled) // Only show if critical is enabled
          ExpansionTile(
            title: const Text('크리티컬 데미지 (%)'),
            children: [
              _buildTextField('표기 크뎀', _critDamageController),
            ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
          ),
        if (!isSatanOrWamira) // Hide if Satan or Wamira
          ExpansionTile(
            title: const Text('일반 공격 데미지 증가 (%)'),
            children: [
              _buildTextField('악세 일공증', _accessoryNormalDamageController),
              _buildTextField('장비 일공증', _equipmentNormalDamageController),
              _buildTextField('파편 일공증', _fragmentNormalDamageController),
            ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
          ),
        if (!isHaegaeltaek) // Hide if Haegaeltaek
          ExpansionTile(
            title: const Text('스킬 데미지 증가 (%)'),
            children: [
              _buildTextField('악세 스증', _accessorySkillDamageController),
              _buildTextField('장비 스증', _equipmentSkillDamageController),
              _buildTextField('파편 스증', _fragmentSkillDamageController),
            ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
          ),
        if (!isHaegaeltaek) // Hide if Haegaeltaek
          ExpansionTile(
            title: const Text('미니게임 데미지 증가 (%)'),
            children: [
              _buildTextField('악세 미겜증', _accessoryMinigameDamageController),
              _buildTextField('장비 미겜증', _equipmentMinigameDamageController),
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
        Row( // Existing Rebirth Row
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
          children: [
            ElevatedButton( // Moved Critical button here
              onPressed: () {
                setState(() {
                  _isCriticalEnabled = !_isCriticalEnabled;
                });
              },
              child: Text(_isCriticalEnabled ? '크리티컬 비활성화' : '크리티컬 활성화'),
            ),
            Row( // Wrapped Rebirth elements in a Row to keep them together
              mainAxisSize: MainAxisSize.min,
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

class BuffSelectionDialog extends StatelessWidget {
  final TextEditingController highSchoolBuffController;
  final TextEditingController divineItemNormalDamageController;
  final TextEditingController divineItemSkillDamageController;
  final TextEditingController divineItemCritDamageController;
  final TextEditingController powerUpController; // ADDED

  const BuffSelectionDialog({
    super.key,
    required this.highSchoolBuffController,
    required this.divineItemNormalDamageController,
    required this.divineItemSkillDamageController,
    required this.divineItemCritDamageController,
    required this.powerUpController, // ADDED
  });

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('버프 정보 입력', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _buildTextField('하이스쿨 버프', highSchoolBuffController),
            const SizedBox(height: 12),
            _buildTextField('파워업 (%)', powerUpController), // ADDED
            const SizedBox(height: 12),
            _buildTextField('신기 일공증', divineItemNormalDamageController),
            const SizedBox(height: 12),
            _buildTextField('신기 스증', divineItemSkillDamageController),
            const SizedBox(height: 12),
            _buildTextField('신기 크뎀증', divineItemCritDamageController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            )
          ],
        ),
      ),
    );
  }
}

class StarSelector extends StatefulWidget {
  final int initialStar;
  final ValueChanged<int> onChanged;
  final double size;

  const StarSelector({
    super.key,
    required this.initialStar,
    required this.onChanged,
    this.size = 30,
  });

  @override
  StarSelectorState createState() => StarSelectorState();
}

class StarSelectorState extends State<StarSelector> {
  late int _currentStar;

  @override
  void initState() {
    super.initState();
    _currentStar = widget.initialStar;
  }

  @override
  void didUpdateWidget(covariant StarSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStar != oldWidget.initialStar) {
      _currentStar = widget.initialStar;
    }
  }

  void _updateStars(Offset localPosition, double width) {
    final starWidth = width / 9;
    final star = (localPosition.dx / starWidth).clamp(0, 8).floor() + 1;
    if (star != _currentStar) {
      setState(() {
        _currentStar = star;
      });
      widget.onChanged(star);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _updateStars(details.localPosition, constraints.maxWidth),
          onPanStart: (details) => _updateStars(details.localPosition, constraints.maxWidth),
          onPanUpdate: (details) => _updateStars(details.localPosition, constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (index) {
              return Icon(
                index < _currentStar ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: widget.size,
              );
            }),
          ),
        );
      },
    );
  }
}

extension DropdownDisplay on Object {
  String get displayName {
    if (this is Spirit) return (this as Spirit).name;
    if (this is Charyeok) return (this as Charyeok).name;
    if (this is Leader) return (this as Leader).name;
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

class CharyeokSelectionDialog extends StatefulWidget {
  const CharyeokSelectionDialog({super.key});
  @override
  CharyeokSelectionDialogState createState() => CharyeokSelectionDialogState();
}

class CharyeokSelectionDialogState extends State<CharyeokSelectionDialog> {
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: charyeok.availableGrades.map((grade) {
                  return ChoiceChip(
                    label: Text(grade.displayName),
                    selected: _selectedGrade == grade,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedGrade = grade;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            StarSelector(
              initialStar: _selectedStar,
              onChanged: (star) {
                setState(() {
                  _selectedStar = star;
                });
              },
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _detailedCharyeok == null ? _buildGridView() : _buildDetailView();
  }
}

class CrestSelectionDialog extends StatefulWidget {
  final Crest initialCrest;
  final String initialValue;

  const CrestSelectionDialog({super.key, required this.initialCrest, required this.initialValue});

  @override
  CrestSelectionDialogState createState() => CrestSelectionDialogState();
}

class CrestSelectionDialogState extends State<CrestSelectionDialog> {
  Crest? _detailedCrest;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _selectCrest(Crest crest) {
    setState(() {
      _detailedCrest = crest;
    });
  }

  Widget _buildGridView() {
    final displayCrests = crests.where((c) => c.type != CrestType.none).toList();
    return Column(
      children: [
        Text("문장 선택", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: displayCrests.length,
            itemBuilder: (context, index) {
              final crest = displayCrests[index];
              return GestureDetector(
                onTap: () => _selectCrest(crest),
                child: GridTile(
                  footer: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      crest.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  child: crest.imagePath != null
                      ? Image.asset(crest.imagePath!, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error))
                      : Icon(crest.icon, size: 50),
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
                'crest': crests[0],
                'value': '',
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    final crest = _detailedCrest!;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _detailedCrest = null)),
              Expanded(child: Text(crest.name, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          if (crest.imagePath != null)
            Image.asset(crest.imagePath!, height: 100, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 100))
          else if (crest.icon != null)
            Icon(crest.icon, size: 100),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: '${crest.name} 값',
                hintText: 'n% 또는 n 입력',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'crest': _detailedCrest,
                'value': _valueController.text,
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
    return _detailedCrest == null ? _buildGridView() : _buildDetailView();
  }
}

class LeaderSelectionDialog extends StatefulWidget {
  const LeaderSelectionDialog({super.key});
  @override
  LeaderSelectionDialogState createState() => LeaderSelectionDialogState();
}

class LeaderSelectionDialogState extends State<LeaderSelectionDialog> {
  // Removed _detailedLeader;
  // Removed _selectLeader method

  Widget _buildGridView() {
    final displayLeaders = leaders.where((l) => l.name != '선택 안함').toList();
    return Column(
      children: [
        Text("리더 선택", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: displayLeaders.length,
            itemBuilder: (context, index) {
              final leader = displayLeaders[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(leader),
                child: GridTile(
                  footer: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      leader.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  child: Image.asset(leader.imagePath, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error)),
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
              Navigator.pop(context, leaders[0]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGridView();
  }
}

class SpiritSelectionDialog extends StatefulWidget {
  const SpiritSelectionDialog({super.key});
  @override
  SpiritSelectionDialogState createState() => SpiritSelectionDialogState();
}

class SpiritSelectionDialogState extends State<SpiritSelectionDialog> {
  Spirit? _detailedSpirit;
  int _selectedStar = 1;

  void _selectSpirit(Spirit spirit) {
    setState(() {
      _detailedSpirit = spirit;
    });
  }

  Widget _buildGridView() {
    final displaySpirits = spirits.where((s) => s.name != '선택 안함').toList();
    return Column(
      children: [
        Text("스피릿 선택", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: displaySpirits.length,
            itemBuilder: (context, index) {
              final spirit = displaySpirits[index];
              return GestureDetector(
                onTap: () => _selectSpirit(spirit),
                child: GridTile(
                  footer: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      spirit.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  child: Image.asset(spirit.imagePath, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error)),
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
                'spirit': spirits[0],
                'star': 1,
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    final spirit = _detailedSpirit!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _detailedSpirit = null)),
                Expanded(child: Text(spirit.name, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            Image.asset(spirit.imagePath, height: 100, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 100)),
            const SizedBox(height: 16),
            StarSelector(
              initialStar: _selectedStar,
              onChanged: (star) {
                setState(() {
                  _selectedStar = star;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'spirit': _detailedSpirit,
                  'star': _selectedStar,
                });
              },
              child: const Text('선택'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _detailedSpirit == null ? _buildGridView() : _buildDetailView();
  }
}