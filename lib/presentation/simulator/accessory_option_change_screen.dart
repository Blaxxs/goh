// lib/presentation/simulator/accessory_option_change_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/models/accessory.dart';
import '../accessory/accessory_screen.dart';
import '../../core/constants/accessory_constants.dart'; // AccessoryOptionNames 사용
import 'accessory_option_change_screen_ui.dart';

// Define the actions a user can take
enum OptionChangeAction {
  none,
  expandToThird,
  changeThird,
  expandToFourth,
  changeFourth,
}

class AccessoryOptionChangeScreen extends StatefulWidget {
  const AccessoryOptionChangeScreen({super.key});

  @override
  State<AccessoryOptionChangeScreen> createState() => _AccessoryOptionChangeScreenState();
}

class _AccessoryOptionChangeScreenState extends State<AccessoryOptionChangeScreen> {
  Accessory? _selectedAccessory;
  // The current list of options for the selected accessory, can be modified
  List<AccessoryOption> _currentOptions = [];
  // The currently selected action to perform
  OptionChangeAction _selectedAction = OptionChangeAction.none;
  
  // 누적 소모 재화
  int _totalSoulStonesConsumed = 0;
  int _totalGrindstonesConsumed = 0;
  int _totalRainbowAnvilsConsumed = 0; // 무지개 모루
  int _total9EnhanceAccessoriesConsumed = 0; // 3옵 9강 악세

  // 시뮬레이션용 변경 가능한 옵션 목록 (실제 게임 옵션으로 대체 필요)
  // 3~4 옵션 목록으로 업데이트
  final List<AccessoryOption> _possibleChangeableOptions = [
    const AccessoryOption(optionName: AccessoryOptionNames.attackPowerFlat, optionValue: '2000'),
    const AccessoryOption(optionName: AccessoryOptionNames.hpFlat, optionValue: '10000'),
    const AccessoryOption(optionName: AccessoryOptionNames.critDamageFlat, optionValue: '55'),
    const AccessoryOption(optionName: AccessoryOptionNames.critChanceFlat, optionValue: '47'),
    const AccessoryOption(optionName: AccessoryOptionNames.critResistFlat, optionValue: '47'),
    const AccessoryOption(optionName: AccessoryOptionNames.accuracyFlat, optionValue: '55'),
    const AccessoryOption(optionName: AccessoryOptionNames.evasionFlat, optionValue: '45'),
    const AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgPercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.activeSkillDmgTakenReducePercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgPercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.basicAtkDmgTakenReducePercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.dotDmgPercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.dotDmgTakenReducePercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.allBadEffectResistPercent, optionValue: '55'),
    const AccessoryOption(optionName: AccessoryOptionNames.summonAtkFlat, optionValue: '2500'),
    const AccessoryOption(optionName: AccessoryOptionNames.rabbitMaxHpChancePercent, optionValue: '100'),
    const AccessoryOption(optionName: AccessoryOptionNames.counterAttackChancePercent, optionValue: '27'),
    const AccessoryOption(optionName: AccessoryOptionNames.spaceTravelReturnChancePercent, optionValue: '100'),
    const AccessoryOption(optionName: AccessoryOptionNames.hpRegenPerTurn, optionValue: '6500'),
    const AccessoryOption(optionName: AccessoryOptionNames.allDmgTakenReducePercent, optionValue: '32'),
    const AccessoryOption(optionName: AccessoryOptionNames.miniGameSkillDmgPercent, optionValue: '70'),
    const AccessoryOption(optionName: AccessoryOptionNames.recoveryEffectPercent, optionValue: '24'),
    const AccessoryOption(optionName: AccessoryOptionNames.skillCooldownIncreaseResistPercent, optionValue: '55'),
    const AccessoryOption(optionName: AccessoryOptionNames.atkPercent, optionValue: '19'),
    const AccessoryOption(optionName: AccessoryOptionNames.defenseFlat, optionValue: '10000'),
    const AccessoryOption(optionName: AccessoryOptionNames.hpPercent, optionValue: '19'),
    const AccessoryOption(optionName: AccessoryOptionNames.penetrationResistPercent, optionValue: '19'),
    const AccessoryOption(optionName: AccessoryOptionNames.penetrationChancePercent, optionValue: '19'),
  ];

  @override
  void initState() {
    super.initState();
    _resetScreenState(); // Initial random accessory selection
  }

  void _resetScreenState() {
    if (!mounted) return;
    Accessory? newAccessory;
    if (allAccessories.isNotEmpty) {
      final randomIndex = Random().nextInt(allAccessories.length);
      newAccessory = allAccessories[randomIndex];
    }
    _updateAccessory(newAccessory);
  }

  Future<void> _selectAccessory(BuildContext context) async {
    final pickedAccessory = await Navigator.push<Accessory>(
      context,
      MaterialPageRoute(
        builder: (context) => const AccessoryScreen(isPickerMode: true),
      ),
    );

    if (pickedAccessory != null && mounted) {
      _updateAccessory(pickedAccessory);
    }
  }

  // Helper to set a new accessory and reset related states
  void _updateAccessory(Accessory? newAccessory) {
    setState(() {
      _selectedAccessory = newAccessory;
      if (newAccessory != null) {
        // Make a mutable copy of the accessory's options
        _currentOptions = List.from(newAccessory.options);
      } else {
        _currentOptions = [];
      }
      // Reset action and other stats
      _selectedAction = OptionChangeAction.none;
      // 누적 소모 재화 초기화
      _totalSoulStonesConsumed = 0;
      _totalGrindstonesConsumed = 0;
      _totalRainbowAnvilsConsumed = 0;
      _total9EnhanceAccessoriesConsumed = 0;
    });
  }

  // Handler for when an action button (Expand/Change) is tapped
  void _handleActionSelected(OptionChangeAction action) {
    // 규칙: 기본 옵션이 1개인 악세사리는 옵션 확장 및 변경을 할 수 없음
    if (_selectedAccessory != null && _selectedAccessory!.options.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기본 옵션이 1개인 악세사리는 옵션 확장 및 변경을 할 수 없습니다.'), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      _selectedAction = action;
    });
    // 액션 즉시 수행
    _performOptionChange();
  }

  // Handler for the main "옵션 변경" button
  void _performOptionChange() {
    // 옵션 변경 로직을 setState로 감싸 UI를 즉시 업데이트하고, SnackBar 알림을 제거합니다.
    setState(() {
      switch (_selectedAction) {
        case OptionChangeAction.none:
          // 이 경우는 버튼이 눌리지 않았거나, 선택된 액션이 없는 경우이므로 비용을 소모하지 않음.
          break;
        case OptionChangeAction.expandToThird:
          if (_currentOptions.length < 3) {
            _currentOptions.add(_generateRandomOption(forSlot: 2, existingOptions: _currentOptions));
            _totalRainbowAnvilsConsumed++; // 무지개 모루 소모
          }
          break;
        case OptionChangeAction.changeThird:
          if (_currentOptions.length >= 3) {
            // 3번째 옵션 변경 (인덱스 2)
            // 기존 3번째 옵션을 제외하고 1, 2, 4번째 옵션과 중복되지 않도록 생성
            _currentOptions[2] = _generateRandomOption(forSlot: 2, existingOptions: _currentOptions);
            _totalSoulStonesConsumed += 100; // 영혼석 100개 소모
          }
          break;
        case OptionChangeAction.expandToFourth:
          if (_currentOptions.length < 4 && _currentOptions.length >= 3) {
            _currentOptions.add(_generateRandomOption(forSlot: 3, existingOptions: _currentOptions));
            _total9EnhanceAccessoriesConsumed++; // 3옵 9강 악세 소모
          }
          break;
        case OptionChangeAction.changeFourth:
          if (_currentOptions.length >= 4) {
            // 4번째 옵션 변경 (인덱스 3)
            // 기존 4번째 옵션을 제외하고 1, 2번째 옵션과 중복되지 않도록 생성 (3번째 옵션과는 중복 가능)
            _currentOptions[3] = _generateRandomOption(forSlot: 3, existingOptions: _currentOptions);
            _totalSoulStonesConsumed += 100; // 영혼석 100개 소모
            _totalGrindstonesConsumed += 300; // 숫돌이 300개 소모
          }
          break;
      }
      // 옵션 변경 후 선택된 액션을 초기화하여, 연속적인 버튼 클릭 시에도 비용이 올바르게 표시되도록 함
      _selectedAction = OptionChangeAction.none;
    });
  }

  // 랜덤 옵션을 생성하는 헬퍼 함수 (실제 게임 로직에 따라 구현 필요)
  AccessoryOption _generateRandomOption({required int forSlot, required List<AccessoryOption> existingOptions}) {
    final random = Random();
    Set<String> excludedOptionNames = {};

    if (forSlot == 2) { // 3번째 옵션 생성 규칙 (인덱스 2)
      // 규칙 7: 3 옵션은 1, 2, 4 옵션과 중복될 수 없다
            // 1, 2번째 옵션 제외
      if (existingOptions.isNotEmpty) {
        excludedOptionNames.add(existingOptions[0].optionName);
      }
      if (existingOptions.length > 1) {
        excludedOptionNames.add(existingOptions[1].optionName);
      }
      // 4번째 옵션이 현재 존재하면 제외
      if (existingOptions.length > 3) { // 4번째 옵션이 현재 존재할 경우
        excludedOptionNames.add(existingOptions[3].optionName);
      }
    } else if (forSlot == 3) { // 4번째 옵션 생성 규칙 (인덱스 3)
      // 사용자 요청: 4옵션은 1~3옵션과 중복된 옵션 획득이 가능하게 해줘
      // 따라서, 기존 옵션들과의 중복을 방지하는 규칙을 적용하지 않음.
      // excludedOptionNames는 이 경우 비어있어야 함.
      // (이전 코드에서 1,2옵션 제외 로직이 forSlot == 3에도 적용되던 것을 수정)
      // 이 블록에서는 excludedOptionNames에 아무것도 추가하지 않음
    }

    // 제외 목록에 있는 옵션들을 필터링하여 사용 가능한 옵션 목록 생성
    final List<AccessoryOption> availableOptions = _possibleChangeableOptions
        .where((opt) => !excludedOptionNames.contains(opt.optionName))
        .toList();

    if (availableOptions.isEmpty) {
      // 예외 처리: 가능한 옵션이 없으면 (예: 모든 옵션이 이미 사용 중이거나 규칙에 의해 제외된 경우)
      // 전체 목록에서 무작위로 하나를 반환하여 앱 충돌 방지.
      // 실제 게임에서는 이런 경우가 발생하지 않도록 옵션 풀을 충분히 크게 설계해야 함.
      debugPrint('Warning: No available options after applying duplication rules for slot $forSlot. Returning random from full list.');
      return _possibleChangeableOptions[random.nextInt(_possibleChangeableOptions.length)];
    }

    return availableOptions[random.nextInt(availableOptions.length)];
  }


  @override
  Widget build(BuildContext context) {
    return AccessoryOptionChangeScreenUI(
      selectedAccessory: _selectedAccessory,
      currentOptions: _currentOptions,
      selectedAction: _selectedAction,
      onSelectAccessoryPressed: () => _selectAccessory(context),
      onResetScreenPressed: _resetScreenState,
      onActionSelected: _handleActionSelected,
      totalSoulStonesConsumed: _totalSoulStonesConsumed,
      totalGrindstonesConsumed: _totalGrindstonesConsumed,
      totalRainbowAnvilsConsumed: _totalRainbowAnvilsConsumed,
      total9EnhanceAccessoriesConsumed: _total9EnhanceAccessoriesConsumed,
    );
  }
}