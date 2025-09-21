import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/box_constants.dart';
import 'package:goh_calculator/core/services/settings_service.dart';
import 'package:goh_calculator/core/widgets/app_drawer.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';
import 'package:goh_calculator/core/constants/charyeok_constants.dart';
import 'package:goh_calculator/core/constants/spirit_constants.dart';
import 'package:intl/intl.dart';
import 'package:goh_calculator/core/constants/fragment_constants.dart';
import 'package:goh_calculator/presentation/damage_calculator/character_selection_dialog.dart';

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

extension SpiritEffectDisplay on SpiritEffect {
  String descriptionForStar(int star) {
    final value = values[star - 1];
    String description;
    switch (type) {
      case SpiritEffectType.skillCoefficient:
        description = '스킬 계수 +${value}%';
        break;
      case SpiritEffectType.critDamage:
        description = '크리티컬 데미지 ${value}% 증가';
        break;
      case SpiritEffectType.baseAttack:
        description = '기본 공격력 ${value.toInt()} 증가';
        break;
      case SpiritEffectType.normalDamage:
        description = '일반 공격 데미지 ${value}% 증가';
        break;
      case SpiritEffectType.skillDamage:
        description = '스킬 데미지 ${value}% 증가';
        break;
    }
    if (characterDependency != null) {
      return '($characterDependency 전용) $description';
    }
    return description;
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
  List<Fragment> _selectedFragments = [];

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
  final _baseAttackPowerController = TextEditingController();
  final _additionalAttackPowerController = TextEditingController();
  final _highSchoolBuffController = TextEditingController();
  final _powerUpController = TextEditingController();
  final _critDamageController = TextEditingController();
  final _divineItemCritDamageController = TextEditingController();
  final _accessoryNormalDamageController = TextEditingController();
  final _equipmentNormalDamageController = TextEditingController();
  final _divineItemNormalDamageController = TextEditingController();
  final _accessorySkillDamageController = TextEditingController();
  final _equipmentSkillDamageController = TextEditingController();
  final _divineItemSkillDamageController = TextEditingController();
  final _accessoryMinigameDamageController = TextEditingController();
  final _equipmentMinigameDamageController = TextEditingController();
  final _rebirthStatValueController = TextEditingController();
  final _crestValueController = TextEditingController();
  final _elementalDamageController = TextEditingController();

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
    _selectedCharacter = null;
    _selectedSpirit = spirits[0];
    _selectedCrest = crests[0];
    _selectedLeader = leaders[0];
    if (charyeoks.isNotEmpty) {
      _selectedCharyeok = charyeoks[0];
      if (_selectedCharyeok!.availableGrades.isNotEmpty) {
        _selectedCharyeokGrade = _selectedCharyeok!.availableGrades[0];
      }
    }
    _addListenersToControllers();
  }

  @override
  void dispose() {
    _removeListenersFromControllers();
    _baseAttackPowerController.dispose();
    _additionalAttackPowerController.dispose();
    _highSchoolBuffController.dispose();
    _powerUpController.dispose();
    _critDamageController.dispose();
    _divineItemCritDamageController.dispose();
    _accessoryNormalDamageController.dispose();
    _equipmentNormalDamageController.dispose();
    _divineItemNormalDamageController.dispose();
    _accessorySkillDamageController.dispose();
    _equipmentSkillDamageController.dispose();
    _divineItemSkillDamageController.dispose();
    _accessoryMinigameDamageController.dispose();
    _equipmentMinigameDamageController.dispose();
    _rebirthStatValueController.dispose();
    _crestValueController.dispose();
    _elementalDamageController.dispose();
    super.dispose();
  }

  void _addListenersToControllers() {
    _baseAttackPowerController.addListener(_calculateDamage);
    _additionalAttackPowerController.addListener(_calculateDamage);
    _highSchoolBuffController.addListener(_calculateDamage);
    _powerUpController.addListener(_calculateDamage);
    _critDamageController.addListener(_calculateDamage);
    _divineItemCritDamageController.addListener(_calculateDamage);
    _accessoryNormalDamageController.addListener(_calculateDamage);
    _equipmentNormalDamageController.addListener(_calculateDamage);
    _divineItemNormalDamageController.addListener(_calculateDamage);
    _accessorySkillDamageController.addListener(_calculateDamage);
    _equipmentSkillDamageController.addListener(_calculateDamage);
    _divineItemSkillDamageController.addListener(_calculateDamage);
    _accessoryMinigameDamageController.addListener(_calculateDamage);
    _equipmentMinigameDamageController.addListener(_calculateDamage);
    _rebirthStatValueController.addListener(_calculateDamage);
    _crestValueController.addListener(_calculateDamage);
    _elementalDamageController.addListener(_calculateDamage);
  }

  void _removeListenersFromControllers() {
    _baseAttackPowerController.removeListener(_calculateDamage);
    _additionalAttackPowerController.removeListener(_calculateDamage);
    _highSchoolBuffController.removeListener(_calculateDamage);
    _powerUpController.removeListener(_calculateDamage);
    _critDamageController.removeListener(_calculateDamage);
    _divineItemCritDamageController.removeListener(_calculateDamage);
    _accessoryNormalDamageController.removeListener(_calculateDamage);
    _equipmentNormalDamageController.removeListener(_calculateDamage);
    _divineItemNormalDamageController.removeListener(_calculateDamage);
    _accessorySkillDamageController.removeListener(_calculateDamage);
    _equipmentSkillDamageController.removeListener(_calculateDamage);
    _divineItemSkillDamageController.removeListener(_calculateDamage);
    _accessoryMinigameDamageController.removeListener(_calculateDamage);
    _equipmentMinigameDamageController.removeListener(_calculateDamage);
    _rebirthStatValueController.removeListener(_calculateDamage);
    _crestValueController.removeListener(_calculateDamage);
    _elementalDamageController.removeListener(_calculateDamage);
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

        switch (charyeok.baseEffectType) {
          case CharyeokEffectType.critDamageIncrease:
            charyeokCritDamage = value;
            break;
          case CharyeokEffectType.fixedAdditionalDamage:
            charyeokFixedDamage = value;
            break;
          case CharyeokEffectType.none:
            break;
          case CharyeokEffectType.attackSetPercent:
          case CharyeokEffectType.baseAttackIncreasePercent:
            break;
        }

        if (charyeok.baseEffectType == CharyeokEffectType.baseAttackIncreasePercent) {
          charyeokBaseAttackIncrease = 1 + (value / 100);
        }

        if (charyeok.englishName == 'tam') { 
          charyeokAttackIncrease = value / 100;
        } else if (charyeok.englishName == 'umawang' || charyeok.englishName == 'longginuseu') { 
          charyeokAttackIncrease = 1 + (value / 100);
        } else if (charyeok.baseEffectType == CharyeokEffectType.attackSetPercent) {
          charyeokAttackIncrease = value / 100;
        } else if (charyeok.baseEffectType == CharyeokEffectType.baseAttackIncreasePercent) {
          charyeokAttackIncrease = 1 + (value / 100);
        }
      }

      if (charyeok.synergyEffectType.containsKey(grade)) {
        final synergyType = charyeok.synergyEffectType[grade]!;
        final synergyValue = charyeok.synergyEffectValues[grade]!.toDouble();
        switch (synergyType) {
          case SynergyEffectType.skillDamageIncreasePercent:
            synergyName = '스킬 데미지';
            break;
          case SynergyEffectType.normalDamageIncreasePercent:
            synergyName = '일반 공격 데미지';
            break;
          case SynergyEffectType.none:
            break;
        }
      }
    }

    // --- Fragment Effects ---
    double fragmentSkillDamage = 0;
    double fragmentMinigameDamage = 0;
    double fragmentNormalDamage = 0;
    double fragmentCritDamage = 0;
    double fragmentAttack = 0;

    for (var fragment in _selectedFragments) {
      if (fragment.value != null) {
        switch (fragment.name) {
          case '증폭(스킬)의 파편':
            fragmentSkillDamage += fragment.value!;
            break;
          case '증폭(미니게임)의 파편':
            fragmentMinigameDamage += fragment.value!;
            break;
          case '증폭(일반)의 파편':
            fragmentNormalDamage += fragment.value!;
            break;
          case '치명타의 파편':
            fragmentCritDamage += fragment.value!;
            break;
          case '공격의 파편':
            fragmentAttack += fragment.value!;
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

    double baseAttackForCharyeok = baseCharacterAttack + rebirthAttackOption + spiritBaseAttack;
    double totalBaseAttack = (baseAttackForCharyeok * charyeokBaseAttackIncrease) + _getParser(_additionalAttackPowerController) + rebirthAttackBonus + fragmentAttack;

    // --- Part 2: Multipliers ---
    final int dalgijiLevel = int.tryParse(SettingsService.instance.stageSettings.dalgijiLevel.toString()) ?? 0;
    final double moonBaseAttackPercent = moonBaseAttackBuffs[dalgijiLevel] ?? 0.0;
    double moonBaseBuff = 1 + (moonBaseAttackPercent / 100);

    double leaderBuff = _selectedLeader?.multiplier ?? 1.0;
    double highSchoolBuffMultiplier = 1 + (_getParser(_highSchoolBuffController) / 100);
    double powerUpValue = _getParser(_powerUpController);
    double powerUpBuffMultiplier = (powerUpValue == 0) ? 1.0 : (powerUpValue / 100);
    double totalMultiplier = leaderBuff * highSchoolBuffMultiplier * moonBaseBuff * charyeokAttackIncrease * powerUpBuffMultiplier * crestAttackBuff;

    // --- Part 3: Damage Type Multipliers ---
    double passiveCritDamage = (_selectedCharacter!.passive['critDamage'] as num? ?? 0).toDouble();
    double critDmgSum = _getParser(_divineItemCritDamageController) +
        rebirthCritDmgOption +
        spiritCritDamage +
        crestCritDamage +
        passiveCritDamage +
        charyeokCritDamage +
        fragmentCritDamage;

    if (_isCriticalEnabled) {
      critDmgSum += _getParser(_critDamageController);
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
        fragmentNormalDamage;
    double normalDmgMultiplier = 1 + (normalDmgSum / 100);

    double skillDmgSum = _getParser(_accessorySkillDamageController) +
        _getParser(_equipmentSkillDamageController) +
        _getParser(_divineItemSkillDamageController) +
        spiritSkillDamage +
        charyeokSkillDamage +
        rebirthSkillDmgOption +
        crestSkillDamage +
        fragmentSkillDamage;
    double skillDmgMultiplier = 1 + (skillDmgSum / 100);

    double minigameDmgSum = _getParser(_accessoryMinigameDamageController) +
        _getParser(_equipmentMinigameDamageController) +
        fragmentMinigameDamage;
    double minigameDmgMultiplier = 1 + (minigameDmgSum / 100);

    double skillCoeffSum = _selectedCharacter!.skillMultiplier.toDouble() + spiritSkillCoeff;
    double skillCoeffMultiplier = skillCoeffSum / 100;
    
    double elementalDamageMultiplier = 1 + (_getParser(_elementalDamageController) / 100);

    // --- Final Calculation ---
    double finalDamage = totalBaseAttack * totalMultiplier;
    String damageType = _selectedCharacter!.damageType;

    if (damageType.contains('크리 데미지')) finalDamage *= critDmgMultiplier;
    if (damageType.contains('일반 데미지')) finalDamage *= normalDmgMultiplier;
    if (damageType.contains('스킬 데미지')) finalDamage *= skillDmgMultiplier;
    if (damageType.contains('미니게임 데미지')) finalDamage *= minigameDmgMultiplier;
    
    finalDamage *= skillCoeffMultiplier;
    finalDamage *= elementalDamageMultiplier;

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
        child: CharyeokSelectionDialog(
          initialCharyeok: _selectedCharyeok,
          initialGrade: _selectedCharyeokGrade,
          initialStar: _selectedCharyeokStar,
          initialFragments: _selectedFragments,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCharyeok = result['charyeok'];
        _selectedCharyeokGrade = result['grade'];
        _selectedCharyeokStar = result['star'];
        _selectedFragments = (result['fragments'] as List<dynamic>).cast<Fragment>();
        _calculateDamage();
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
        child: SpiritSelectionDialog(
          onDamageRecalculated: _calculateDamage,
          initialSpirit: _selectedSpirit,
          initialStar: _selectedSpiritStar,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSpirit = result['spirit'];
        _selectedSpiritStar = result['star'];
        _calculateDamage();
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
        powerUpController: _powerUpController,
      ),
    );
  }

  Future<void> _showElementalDamageDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ElementalDamageDialog(
        elementalDamageController: _elementalDamageController,
      ),
    );
  }

  Future<void> _showCharacterSelectionDialog() async {
    final result = await showDialog<Character>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: AspectRatio(
            aspectRatio: 1 / 0.8,
            child: CharacterSelectionDialog(),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCharacter = result;
        _baseAttackPowerController.text = _selectedCharacter!.baseAttackPower.toString();
        _calculateDamage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final screenHeight = MediaQuery.of(context).size.height;
    final imageContainerHeight = screenHeight * 0.3;
    final charyeokIconSize = imageContainerHeight / 4;
    final otherIconSize = imageContainerHeight * 0.18;
    final buffIconSize = otherIconSize * (2/3);

    Widget charyeokWidget;
    if (_selectedCharyeok != null && _selectedCharyeok!.name != '선택 안함') {
      charyeokWidget = Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _getBorderColorForGrade(_selectedCharyeokGrade), width: 1.5),
        ),
        child: InkWell(
          onTap: _showCharyeokSelectionDialog,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    _selectedCharyeok!.imagePath,
                    fit: BoxFit.cover,
                    width: charyeokIconSize * 0.8,
                    height: charyeokIconSize * 0.8,
                    errorBuilder: (c, o, s) => const Icon(Icons.error, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      charyeokWidget = ElevatedButton.icon(
        onPressed: _showCharyeokSelectionDialog,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('차력', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(charyeokIconSize, charyeokIconSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
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
        const SizedBox(height: 2),
        const Text(
          '버프',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
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

    Widget elementalDamageWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _showElementalDamageDialog,
          customBorder: const CircleBorder(),
          child: Container(
            width: buffIconSize,
            height: buffIconSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const ClipOval(
              child: Icon(Icons.whatshot, color: Colors.red, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '속성',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
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
      leaderWidget = Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5),
        ),
        child: InkWell(
          onTap: _showLeaderSelectionDialog,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    _selectedLeader!.imagePath,
                    fit: BoxFit.cover,
                    width: otherIconSize * 0.8,
                    height: otherIconSize * 0.8,
                    errorBuilder: (c, o, s) => const Icon(Icons.error, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      leaderWidget = ElevatedButton.icon(
        onPressed: _showLeaderSelectionDialog,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('리더', style: TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(otherIconSize, otherIconSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
      );
    }

    Widget crestWidget;
    if (_selectedCrest != null && _selectedCrest!.type != CrestType.none) {
      crestWidget = Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5),
        ),
        child: InkWell(
          onTap: _showCrestSelectionDialog,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _selectedCrest!.imagePath != null
                    ? ClipOval(
                        child: Image.asset(
                          _selectedCrest!.imagePath!,
                          fit: BoxFit.cover,
                          width: otherIconSize * 0.8,
                          height: otherIconSize * 0.8,
                          errorBuilder: (c, o, s) => const Icon(Icons.error, size: 30),
                        ),
                      )
                    : Icon(_selectedCrest!.icon, color: Colors.blueGrey, size: otherIconSize * 0.8),
              ],
            ),
          ),
        ),
      );
    } else {
      crestWidget = ElevatedButton.icon(
        onPressed: _showCrestSelectionDialog,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('문장', style: TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(otherIconSize, otherIconSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
      );
    }

    Widget spiritWidget;
    if (_selectedSpirit != null && _selectedSpirit!.name != '선택 안함') {
      spiritWidget = Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5),
        ),
        child: InkWell(
          onTap: _showSpiritSelectionDialog,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    _selectedSpirit!.imagePath,
                    fit: BoxFit.cover,
                    width: otherIconSize * 0.8,
                    height: otherIconSize * 0.8,
                    errorBuilder: (c, o, s) => const Icon(Icons.error, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      spiritWidget = ElevatedButton.icon(
        onPressed: _showSpiritSelectionDialog,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('스피릿', style: TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(otherIconSize, otherIconSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
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
          
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              height: screenHeight * 0.3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _selectedCharacter != null
                        ? InkWell(
                            onTap: _showCharacterSelectionDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  _selectedCharacter!.imagePath,
                                  fit: BoxFit.contain,
                                  height: imageContainerHeight * 0.8,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: Text('이미지 없음')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: ElevatedButton.icon(
                              onPressed: _showCharacterSelectionDialog,
                              icon: const Icon(Icons.person_add),
                              label: const Text('캐릭터 선택'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
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
                        const SizedBox(height: 8),
                        elementalDamageWidget,
                      ],
                    ),
                  ),
                ],
              ),
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: _buildTextField('추가 공격력', _additionalAttackPowerController),
              ),
            ),
            const SizedBox(height: 10),
            
            if (!isSatanOrWamira)
              ExpansionTile(
                title: const Text('일반 공격 데미지 증가 (%)'),
                children: [
                  _buildTextField('악세 일공증', _accessoryNormalDamageController),
                  _buildTextField('장비 일공증', _equipmentNormalDamageController),
                ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
              ),
            if (!isHaegaeltaek)
              ExpansionTile(
                title: const Text('스킬 데미지 증가 (%)'),
                children: [
                  _buildTextField('악세 스증', _accessorySkillDamageController),
                  _buildTextField('장비 스증', _equipmentSkillDamageController),
                ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
              ),
            if (!isHaegaeltaek)
              ExpansionTile(
                title: const Text('미니게임 데미지 증가 (%)'),
                children: [
                  _buildTextField('악세 미겜증', _accessoryMinigameDamageController),
                  _buildTextField('장비 미겜증', _equipmentMinigameDamageController),
                ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRebirthSelector() {
    List<RebirthStat> availableStats = [];
    if (_selectedRebirthRealm == RebirthRealm.heavenly) {
      availableStats = [RebirthStat.skillDamage, RebirthStat.attackPower, RebirthStat.critDamage];
    } else if (_selectedRebirthRealm == RebirthRealm.demon) {
      availableStats = [RebirthStat.normalDamage];
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCriticalEnabled = !_isCriticalEnabled;
                      });
                    },
                    icon: Icon(_isCriticalEnabled ? Icons.check_circle : Icons.circle_outlined),
                    label: const Text('크리티컬'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCriticalEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: _isCriticalEnabled ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<RebirthRealm>(
                          value: _selectedRebirthRealm,
                          decoration: const InputDecoration(
                            labelText: '환생',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20), // Changed to 20
                          ),
                          items: RebirthRealm.values.map((realm) {
                            return DropdownMenuItem<RebirthRealm>(
                              value: realm,
                              child: Text(realm.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRebirthRealm = value ?? RebirthRealm.none;
                              _selectedRebirthStat = RebirthStat.none;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_selectedRebirthRealm != RebirthRealm.none)
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _rebirthLevel,
                            decoration: const InputDecoration(
                              labelText: '단계',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20), // Changed to 20
                            ),
                            items: List.generate(10, (index) => DropdownMenuItem(value: index, child: Text('$index'))),
                            onChanged: (value) {
                              setState(() {
                                _rebirthLevel = value ?? 0;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedRebirthRealm != RebirthRealm.none)
              const SizedBox(height: 10),
            if (_selectedRebirthRealm != RebirthRealm.none)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<RebirthStat>(
                      value: _selectedRebirthStat,
                      decoration: const InputDecoration(
                        labelText: '증가 스탯',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20), // Changed to 20
                      ),
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
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField('스탯 값', _rebirthStatValueController),
                  ),
                ],
              ),
            if (_isCriticalEnabled)
              Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTextField('표기 크뎀', _critDamageController),
                ],
              ),
          ],
        ),
      ),
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
  final TextEditingController powerUpController;

  const BuffSelectionDialog({
    super.key,
    required this.highSchoolBuffController,
    required this.divineItemNormalDamageController,
    required this.divineItemSkillDamageController,
    required this.divineItemCritDamageController,
    required this.powerUpController,
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
            _buildTextField('파워업 (%)', powerUpController),
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

class ElementalDamageDialog extends StatelessWidget {
  final TextEditingController elementalDamageController;

  const ElementalDamageDialog({
    super.key,
    required this.elementalDamageController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('속성 피해 정보 입력', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextFormField(
              controller: elementalDamageController,
              decoration: const InputDecoration(
                labelText: '속성 피해',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
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

  void _updateStars(int star) {
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
        final double totalWidth = constraints.maxWidth;
        const int numberOfStars = 9;
        const double itemSpacing = 2.0;

        final double calculatedStarSize = (totalWidth - (numberOfStars - 1) * itemSpacing) / numberOfStars;
        final double starSize = calculatedStarSize - 1.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(numberOfStars, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _updateStars(index + 1),
                  child: SizedBox(
                    width: starSize,
                    height: starSize,
                    child: Icon(
                      index < _currentStar ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: starSize,
                    ),
                  ),
                ),
                if (index < numberOfStars - 1) SizedBox(width: itemSpacing),
              ],
            );
          }),
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
  final Charyeok? initialCharyeok;
  final CharyeokGrade? initialGrade;
  final int initialStar;
  final List<Fragment> initialFragments;

  const CharyeokSelectionDialog({
    super.key,
    this.initialCharyeok,
    this.initialGrade,
    this.initialStar = 1,
    required this.initialFragments,
  });

  @override
  CharyeokSelectionDialogState createState() => CharyeokSelectionDialogState();
}

class CharyeokSelectionDialogState extends State<CharyeokSelectionDialog> {
  Charyeok? _detailedCharyeok;
  CharyeokGrade? _selectedGrade;
  int _selectedStar = 1;
  late List<Fragment> _selectedFragments;
  final Map<Fragment, TextEditingController> _fragmentValueControllers = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCharyeok != null && widget.initialCharyeok!.name != '선택 안함') {
      _detailedCharyeok = widget.initialCharyeok;
      _selectedGrade = widget.initialGrade;
      _selectedStar = widget.initialStar;
      _selectedFragments = List.from(widget.initialFragments);
      _initializeFragmentControllers();
    } else {
      _selectedFragments = [];
    }
  }

  void _initializeFragmentControllers() {
    _fragmentValueControllers.forEach((_, controller) => controller.dispose());
    _fragmentValueControllers.clear();
    for (var fragment in _selectedFragments) {
      if (fragment.minValue != null || fragment.maxValue != null) {
        final controller = TextEditingController(text: fragment.value?.toString() ?? '');
        controller.addListener(() {
          fragment.value = double.tryParse(controller.text);
          _setHasChanges(true);
        });
        _fragmentValueControllers[fragment] = controller;
      }
    }
  }

  void _setHasChanges(bool value) {
    if (_hasChanges != value) {
      setState(() {
        _hasChanges = value;
      });
    }
  }

  @override
  void dispose() {
    _fragmentValueControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
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
      final slotCount = _getFragmentSlotCount(_selectedGrade);
      _selectedFragments = List.generate(slotCount, (index) => Fragment.none());
      _initializeFragmentControllers();
      _setHasChanges(true);
    });
  }

  int _getFragmentSlotCount(CharyeokGrade? grade) {
    if (grade == null) return 0;
    if (grade == CharyeokGrade.legendary) return 6;
    if (_detailedCharyeok != null && _detailedCharyeok!.fragmentSlotCounts != null && _detailedCharyeok!.fragmentSlotCounts!.containsKey(grade)) {
      return _detailedCharyeok!.fragmentSlotCounts![grade]!;
    }
    switch (grade) {
      case CharyeokGrade.normal:
        return 1;
      case CharyeokGrade.advanced:
        return 2;
      case CharyeokGrade.rare:
        return 3;
      case CharyeokGrade.relic:
        return 4;
      case CharyeokGrade.legendary:
        return 6;
      }
  }

  Widget _buildGridView() {
    final displayCharyeoks = charyeoks.where((c) => c.name != '선택 안함').toList();
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text("차력 선택", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: displayCharyeoks.length,
              itemBuilder: (context, index) {
                final charyeok = displayCharyeoks[index];
                return GestureDetector(
                  onTap: () => _selectCharyeok(charyeok),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          charyeok.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              charyeok.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (c, o, s) => const Icon(Icons.error, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("선택 안함"),
              onPressed: () {
                Navigator.pop(context, {
                  'charyeok': charyeoks[0],
                  'grade': null,
                  'star': 1,
                  'fragments': [],
                });
              },
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    final charyeok = _detailedCharyeok!;
    String description = charyeok.description;
    String synergyDescription = '';

    if (_selectedGrade != null) {
      List<String> values = [];
      if (charyeok.baseEffectValues.containsKey(_selectedGrade)) {
        values.add(charyeok.baseEffectValues[_selectedGrade]![_selectedStar - 1].toString());
      }

      if (charyeok.englishName == 'longginuseu') {
        if (charyeok.increasePerTurn != null && charyeok.increasePerTurn!.containsKey(_selectedGrade)) {
          values.add(charyeok.increasePerTurn![_selectedGrade]![_selectedStar - 1].toString());
        }
        if (charyeok.maxValue != null && charyeok.maxValue!.containsKey(_selectedGrade)) {
          values.add(charyeok.maxValue![_selectedGrade]![_selectedStar - 1].toString());
        }
      } else {
        if (charyeok.decreasePerTurn != null && charyeok.decreasePerTurn!.containsKey(_selectedGrade)) {
          values.add(charyeok.decreasePerTurn![_selectedGrade]![_selectedStar - 1].toString());
        }
        if (charyeok.minValue != null && charyeok.minValue!.containsKey(_selectedGrade)) {
          values.add(charyeok.minValue![_selectedGrade]![_selectedStar - 1].toString());
        }
      }

      int i = 0;
      while(description.contains('n')) {
        if (i < values.length) {
          description = description.replaceFirst('n', values[i]);
          i++;
        } else {
          break;
        }
      }

      if (charyeok.synergyEffectType.containsKey(_selectedGrade) && charyeok.synergyEffectType[_selectedGrade] != SynergyEffectType.none) {
        final synergyType = charyeok.synergyEffectType[_selectedGrade]!;
        final synergyValue = charyeok.synergyEffectValues[_selectedGrade]!;
        String synergyName = '';
        switch (synergyType) {
          case SynergyEffectType.skillDamageIncreasePercent:
            synergyName = '스킬 데미지';
            break;
          case SynergyEffectType.normalDamageIncreasePercent:
            synergyName = '일반 공격 데미지';
            break;
          case SynergyEffectType.none:
            break;
        }
        synergyDescription = '상성효과: $synergyName $synergyValue% 증가';
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
            charyeok.imagePath.isNotEmpty
                ? Image.asset(charyeok.imagePath, height: 100, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 100))
                : const SizedBox(height: 100, child: Center(child: Text('이미지 없음'))),
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
                          final slotCount = _getFragmentSlotCount(_selectedGrade);
                          _selectedFragments = List.generate(slotCount, (index) => Fragment.none());
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
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildFragmentSelector(),
            const SizedBox(height: 16),
            Text('효과: $description'),
            if (synergyDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(synergyDescription, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'charyeok': _detailedCharyeok,
                      'grade': _selectedGrade,
                      'star': _selectedStar,
                      'fragments': _selectedFragments,
                    });
                  },
                  child: Text(_hasChanges ? '저장' : '닫기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'charyeok': charyeoks[0],
                      'grade': null,
                      'star': 1,
                      'fragments': [],
                    });
                  },
                  child: const Text('초기화'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFragmentSelector() {
    final int maxSlots = 6;
    final int activeSlots = _getFragmentSlotCount(_selectedGrade);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double spacing = 8.0;
        final double iconSize = (totalWidth - (maxSlots - 1) * spacing) / maxSlots;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('파편 슬롯', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(maxSlots, (index) {
                final bool isActive = index < activeSlots;
                Fragment? fragment = isActive && _selectedFragments.length > index ? _selectedFragments[index] : null;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: isActive
                          ? () async {
                              final selected = await showDialog<Fragment>(
                                context: context,
                                builder: (context) => const FragmentSelectionDialog(),
                              );
                              if (selected != null) {
                                setState(() {
                                  final newFragment = Fragment(
                                    name: selected.name,
                                    imagePath: selected.imagePath,
                                    minValue: selected.minValue,
                                    maxValue: selected.maxValue,
                                    unit: selected.unit,
                                    value: selected.value,
                                  );
                                  _selectedFragments[index] = newFragment;
                                  _initializeFragmentControllers();
                                  _setHasChanges(true);
                                });
                              }
                            }
                          : null,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: isActive ? Colors.grey : Colors.grey.shade800),
                          borderRadius: BorderRadius.circular(8),
                          color: isActive ? null : Colors.grey.shade900,
                        ),
                        child: fragment != null && fragment.name != '선택 안함'
                            ? Image.asset(fragment.imagePath, errorBuilder: (c, o, s) => const Icon(Icons.error))
                            : (isActive ? const Icon(Icons.add) : Icon(Icons.lock, color: Colors.grey.shade600)),
                      ),
                    ),
                    if (isActive && fragment != null && (fragment.minValue != null || fragment.maxValue != null)) ...[
                      const SizedBox(height: 4),
                      SizedBox(
                        width: iconSize,
                        child: TextFormField(
                          controller: _fragmentValueControllers[fragment],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            labelText: '값',
                            suffixText: fragment.unit,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: isActive,
                          onChanged: (text) {
                            fragment.value = double.tryParse(text);
                            _setHasChanges(true);
                          },
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        );
      },
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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCrest.type != CrestType.none) {
      _detailedCrest = widget.initialCrest;
    }
    _valueController = TextEditingController(text: widget.initialValue);
    _valueController.addListener(() {
      if (!_hasChanges) {
        setState(() {
          _hasChanges = true;
        });
      }
    });
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
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text("문장 선택", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: displayCrests.length,
              itemBuilder: (context, index) {
                final crest = displayCrests[index];
                return GestureDetector(
                  onTap: () => _selectCrest(crest),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          crest.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: crest.imagePath != null
                                ? Image.asset(crest.imagePath!, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error, color: Colors.grey))
                                : Icon(crest.icon, size: 40, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("선택 안함"),
              onPressed: () {
                Navigator.pop(context, {
                  'crest': crests[0],
                  'value': '',
                });
              },
            ),
          ),
        ],
      ),
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
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'crest': _detailedCrest,
                    'value': _valueController.text,
                  });
                },
                child: Text(_hasChanges ? '저장' : '닫기'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'crest': crests[0],
                    'value': '',
                  });
                },
                child: const Text('초기화'),
              ),
            ],
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

class SpiritSelectionDialog extends StatefulWidget {
  final VoidCallback? onDamageRecalculated;
  final Spirit? initialSpirit;
  final int? initialStar;

  const SpiritSelectionDialog({
    super.key,
    this.onDamageRecalculated,
    this.initialSpirit,
    this.initialStar,
  });

  @override
  State<SpiritSelectionDialog> createState() => _SpiritSelectionDialogState();
}

class _SpiritSelectionDialogState extends State<SpiritSelectionDialog> {
  Spirit? _selectedSpirit;
  int _selectedStar = 1;

  @override
  void initState() {
    super.initState();
    _selectedSpirit = widget.initialSpirit;
    _selectedStar = widget.initialStar ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the "선택 안함" spirit from the list
    final displaySpirits = spirits.where((s) => s.name != '선택 안함').toList();

    return Dialog(
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text("정령 선택", style: Theme.of(context).textTheme.headlineSmall),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: displaySpirits.length,
                itemBuilder: (context, index) {
                  final spirit = displaySpirits[index];
                  final isSelected = _selectedSpirit == spirit;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpirit = spirit;
                        _selectedStar = 1; // Reset star on new selection
                      });
                    },
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            spirit.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                spirit.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (c, o, s) => const Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedSpirit != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Text(_selectedSpirit!.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    StarSelector(
                      initialStar: _selectedStar,
                      onChanged: (star) {
                        setState(() {
                          _selectedStar = star;
                        });
                      },
                    ),
                     const SizedBox(height: 8),
                    // Display spirit effects
                    if (_selectedSpirit!.effects.isNotEmpty)
                      ..._selectedSpirit!.effects.where((e) => e.characterDependency == null).map((effect) {
                        return Text(effect.descriptionForStar(_selectedStar));
                      }).toList(),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("선택 안함"),
                    onPressed: () {
                      Navigator.pop(context, {
                        'spirit': spirits.firstWhere((s) => s.name == '선택 안함'),
                        'star': 1,
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: _selectedSpirit != null
                        ? () {
                            Navigator.of(context).pop({
                              'spirit': _selectedSpirit,
                              'star': _selectedStar,
                            });
                          }
                        : null,
                    child: const Text('선택'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FragmentSelectionDialog extends StatelessWidget {
  const FragmentSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final displayFragments = fragments.where((f) => f.name != '선택 안함').toList();
    return Dialog(
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text("파편 선택", style: Theme.of(context).textTheme.headlineSmall),
          ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: displayFragments.length,
                itemBuilder: (context, index) {
                  final fragment = displayFragments[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(fragment);
                    },
                    child: Card(
                      elevation: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            fragment.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                fragment.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (c, o, s) => const Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text("선택 안함"),
                onPressed: () {
                  Navigator.of(context).pop(fragments.firstWhere((f) => f.name == '선택 안함'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderSelectionDialog extends StatefulWidget {
  const LeaderSelectionDialog({super.key});
  @override
  LeaderSelectionDialogState createState() => LeaderSelectionDialogState();
}

class LeaderSelectionDialogState extends State<LeaderSelectionDialog> {

  Widget _buildListView() {
    final displayLeaders = leaders.where((l) => l.name != '선택 안함').toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text("리더 선택", style: Theme.of(context).textTheme.headlineSmall),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayLeaders.length,
            itemBuilder: (context, index) {
              final leader = displayLeaders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(leader),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              leader.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (c, o, s) => const Icon(Icons.error, size: 60)
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(leader.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  if (leader.skillName != null)
                                    Text(leader.skillName!, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (leader.skillDescription != null) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(leader.skillDescription!, style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: const Text("선택 안함"),
            onPressed: () => Navigator.of(context).pop(leaders[0]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView();
  }
}