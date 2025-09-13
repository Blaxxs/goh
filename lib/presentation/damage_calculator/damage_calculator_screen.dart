import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/box_constants.dart';
import 'package:goh_calculator/core/widgets/app_drawer.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';
import 'package:goh_calculator/core/constants/charyeok_constants.dart';
import 'package:goh_calculator/core/constants/spirit_constants.dart';
import 'package:intl/intl.dart';

enum RebirthRealm { none, heavenly, demon }

class DamageCalculatorScreen extends StatefulWidget {
  const DamageCalculatorScreen({super.key});

  @override
  State<DamageCalculatorScreen> createState() => _DamageCalculatorScreenState();
}

class _DamageCalculatorScreenState extends State<DamageCalculatorScreen> {
  // Character and Spirit
  Character? _selectedCharacter;
  Spirit? _selectedSpirit;

  // Rebirth
  RebirthRealm _selectedRebirthRealm = RebirthRealm.none;
  int _rebirthLevel = 0;

  // Calculation Results
  double _calculatedDamage = 0;
  double _currentAttackPower = 0;

  // --- Text Editing Controllers ---
  final _additionalAttackPowerController = TextEditingController();
  final _rebirthOptionAttackController = TextEditingController();
  final _leaderEffectController = TextEditingController();
  final _highSchoolBuffController = TextEditingController();
  final _moonBaseBuffController = TextEditingController();
  final _powerUpController = TextEditingController();
  final _critDamageController = TextEditingController();
  final _divineItemCritDamageController = TextEditingController();
  final _rebirthCritDamageController = TextEditingController();
  final _crestCritDamageController = TextEditingController();
  final _passiveCritDamageController = TextEditingController();
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
  final _skillCoefficientController = TextEditingController();
  final _rebirthAdditionalDamageController = TextEditingController();

  // --- Rebirth Bonuses ---
  final List<int> demonRebirthAttackBonus = [0, 50, 50, 100, 100, 200, 200, 300, 300, 450];
  final List<int> heavenlyRebirthAttackBonus = [0, 50, 100, 200, 300, 450, 600, 800, 1000, 1400];

  @override
  void initState() {
    super.initState();
    _selectedCharacter = characters[0];
    _selectedSpirit = spirits[0];
  }

  @override
  void dispose() {
    _additionalAttackPowerController.dispose();
    _rebirthOptionAttackController.dispose();
    _leaderEffectController.dispose();
    _highSchoolBuffController.dispose();
    _moonBaseBuffController.dispose();
    _powerUpController.dispose();
    _critDamageController.dispose();
    _divineItemCritDamageController.dispose();
    _rebirthCritDamageController.dispose();
    _crestCritDamageController.dispose();
    _passiveCritDamageController.dispose();
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
    _skillCoefficientController.dispose();
    _rebirthAdditionalDamageController.dispose();
    super.dispose();
  }

  double _getParser(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0;
  }

  void _calculateDamage() {
    if (_selectedCharacter == null) return;

    // For now, charyeok effects are added as input fields.
    // This section can be expanded later if charyeok constants are updated.
    double charyeokBaseAttackIncrease = 1.0;
    double charyeokAttackIncrease = 1.0;
    double charyeokCritDamage = 0;
    double charyeokNormalDamage = 0;
    double charyeokSkillDamage = 0;
    double charyeokFixedDamage = 0;

    // --- Part 1: Base Attack Calculation ---
    double baseAttack = _selectedCharacter!.baseAttackPower.toDouble();
    double additionalAttack = _getParser(_additionalAttackPowerController);
    double rebirthAttackBonus = 0;
    if (_selectedRebirthRealm == RebirthRealm.demon) {
      rebirthAttackBonus = demonRebirthAttackBonus[_rebirthLevel].toDouble();
    } else if (_selectedRebirthRealm == RebirthRealm.heavenly) {
      rebirthAttackBonus = heavenlyRebirthAttackBonus[_rebirthLevel].toDouble();
    }
    double rebirthOptionAttack = _getParser(_rebirthOptionAttackController);

    double totalBaseAttack = (baseAttack * charyeokBaseAttackIncrease) + additionalAttack + rebirthAttackBonus + rebirthOptionAttack;

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

    double critDmgSum = _getParser(_critDamageController) +
        _getParser(_divineItemCritDamageController) +
        _getParser(_rebirthCritDamageController) +
        spiritCritDamage +
        _getParser(_crestCritDamageController) +
        _getParser(_passiveCritDamageController) +
        charyeokCritDamage;
    double critDmgMultiplier = 1 + (critDmgSum / 100);

    double normalDmgSum = _getParser(_accessoryNormalDamageController) +
        _getParser(_equipmentNormalDamageController) +
        _getParser(_divineItemNormalDamageController) +
        charyeokNormalDamage +
        _getParser(_fragmentNormalDamageController);
    double normalDmgMultiplier = 1 + (normalDmgSum / 100);

    double skillDmgSum = _getParser(_accessorySkillDamageController) +
        _getParser(_equipmentSkillDamageController) +
        _getParser(_divineItemSkillDamageController) +
        spiritSkillDamage +
        charyeokSkillDamage +
        _getParser(_fragmentSkillDamageController);
    double skillDmgMultiplier = 1 + (skillDmgSum / 100);

    double minigameDmgSum = _getParser(_accessoryMinigameDamageController) +
        _getParser(_equipmentMinigameDamageController) +
        _getParser(_divineItemMinigameDamageController) +
        _getParser(_fragmentMinigameDamageController);
    double minigameDmgMultiplier = 1 + (minigameDmgSum / 100);

    double skillCoeffSum = _getParser(_skillCoefficientController);
    double skillCoeffMultiplier = skillCoeffSum / 100;

    // --- Final Calculation ---
    double finalDamage = totalBaseAttack * totalMultiplier;

    if (_selectedCharacter?.englishName == 'satan') {
      finalDamage *= critDmgMultiplier * skillDmgMultiplier * minigameDmgMultiplier * skillCoeffMultiplier;
    } else {
      finalDamage *= critDmgMultiplier * normalDmgMultiplier * skillDmgMultiplier * minigameDmgMultiplier * skillCoeffMultiplier;
    }

    // --- Part 4: Fixed Additional Damage ---
    double rebirthFixedDamage = _getParser(_rebirthAdditionalDamageController);
    finalDamage += rebirthFixedDamage + charyeokFixedDamage;

    setState(() {
      _calculatedDamage = finalDamage;
      _currentAttackPower = totalBaseAttack * totalMultiplier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
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
            _buildTextField('환생 옵션 공격력', _rebirthOptionAttackController),
            _buildTextField('리더 효과 (%)', _leaderEffectController),
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
            _buildTextField('환생 크뎀', _rebirthCritDamageController),
            _buildTextField('문장 크뎀', _crestCritDamageController),
            _buildTextField('패시브 크뎀', _passiveCritDamageController),
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
        ExpansionTile(
          title: const Text('스킬 계수 (%)'),
          children: [
            _buildTextField('스킬 계수', _skillCoefficientController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
        ExpansionTile(
          title: const Text('고정 추가 데미지'),
          children: [
            _buildTextField('환생 추가 데미지', _rebirthAdditionalDamageController),
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList(),
        ),
      ],
    );
  }

  Widget _buildRebirthSelector() {
    return Row(
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
    return toString();
  }
}
