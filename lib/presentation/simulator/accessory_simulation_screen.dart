import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/accessory_constants.dart';
import '../../core/constants/box_constants.dart';
import '../../core/constants/random_accessory_constants.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/models/accessory.dart';
import 'accessory_enhancement_screen_ui.dart';

const _silverRemodelGoldCost = 20000;
const _goldRemodelGoldCost = 3000;

enum AccessorySimulationMode {
  craft,
  enhance,
  optionChange,
  remodel,
}

enum AccessorySimulationOptionChangeAction {
  none,
  expandToThird,
  changeThird,
  expandToFourth,
  changeFourth,
}

class SimulatedAccessoryState {
  final Accessory accessory;
  final List<AccessoryOption> baseOptions;
  final List<AccessoryOption> currentOptions;
  final String? grade;

  const SimulatedAccessoryState({
    required this.accessory,
    required this.baseOptions,
    required this.currentOptions,
    this.grade,
  });

  SimulatedAccessoryState copyWith({
    Accessory? accessory,
    List<AccessoryOption>? baseOptions,
    List<AccessoryOption>? currentOptions,
    Object? grade = _noValue,
  }) {
    return SimulatedAccessoryState(
      accessory: accessory ?? this.accessory,
      baseOptions: baseOptions ?? this.baseOptions,
      currentOptions: currentOptions ?? this.currentOptions,
      grade: identical(grade, _noValue) ? this.grade : grade as String?,
    );
  }
}

class CraftedAccessoryLogEntry {
  final int attempt;
  final Accessory accessory;
  final List<AccessoryOption> options;
  final String? grade;

  const CraftedAccessoryLogEntry({
    required this.attempt,
    required this.accessory,
    required this.options,
    this.grade,
  });
}

const _noValue = Object();

class AccessorySimulationScreen extends StatefulWidget {
  const AccessorySimulationScreen({super.key});

  @override
  State<AccessorySimulationScreen> createState() =>
      _AccessorySimulationScreenState();
}

class _AccessorySimulationScreenState extends State<AccessorySimulationScreen> {
  static final NumberFormat _numberFormat = NumberFormat('#,##0');

  final Random _random = Random();

  final List<String> _enhancementAids = [
    '선택 안함',
    '하급 보조제',
    '중급 보조제',
    '상급 보조제',
    '스페셜 하급 보조제',
    '스페셜 중급 보조제',
    '스페셜 상급 보조제',
    '스페셜 특급 보조제',
  ];

  final List<AccessoryOption> _defaultChangeableOptions = [
    const AccessoryOption(
      optionName: AccessoryOptionNames.attackPowerFlat,
      optionValue: '2000',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.hpFlat,
      optionValue: '10000',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.critDamageFlat,
      optionValue: '55',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.critChanceFlat,
      optionValue: '47',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.critResistFlat,
      optionValue: '47',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.accuracyFlat,
      optionValue: '55',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.evasionFlat,
      optionValue: '45',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.activeSkillDmgPercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.activeSkillDmgTakenReducePercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.basicAtkDmgPercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.basicAtkDmgTakenReducePercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.dotDmgPercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.dotDmgTakenReducePercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.allBadEffectResistPercent,
      optionValue: '55',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.summonAtkFlat,
      optionValue: '2500',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.rabbitMaxHpChancePercent,
      optionValue: '100',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.counterAttackChancePercent,
      optionValue: '27',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.spaceTravelReturnChancePercent,
      optionValue: '100',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.hpRegenPerTurn,
      optionValue: '6500',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.allDmgTakenReducePercent,
      optionValue: '32',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.miniGameSkillDmgPercent,
      optionValue: '70',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.recoveryEffectPercent,
      optionValue: '24',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.skillCooldownIncreaseResistPercent,
      optionValue: '55',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.atkPercent,
      optionValue: '19',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.defenseFlat,
      optionValue: '10000',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.hpPercent,
      optionValue: '19',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.penetrationResistPercent,
      optionValue: '19',
    ),
    const AccessoryOption(
      optionName: AccessoryOptionNames.penetrationChancePercent,
      optionValue: '19',
    ),
  ];

  static const Map<String, List<int>> _randomOptionValueRangeTable = {
    AccessoryOptionNames.attackPowerFlat: [300, 1500],
    AccessoryOptionNames.hpFlat: [2000, 5000],
    AccessoryOptionNames.critDamageFlat: [10, 35],
    AccessoryOptionNames.critChanceFlat: [10, 30],
    AccessoryOptionNames.critResistFlat: [10, 30],
    AccessoryOptionNames.accuracyFlat: [10, 35],
    AccessoryOptionNames.evasionFlat: [5, 25],
    AccessoryOptionNames.activeSkillDmgPercent: [10, 35],
    AccessoryOptionNames.activeSkillDmgTakenReducePercent: [10, 35],
    AccessoryOptionNames.basicAtkDmgPercent: [10, 35],
    AccessoryOptionNames.basicAtkDmgTakenReducePercent: [10, 35],
    AccessoryOptionNames.dotDmgPercent: [10, 35],
    AccessoryOptionNames.dotDmgTakenReducePercent: [10, 35],
    AccessoryOptionNames.allBadEffectResistPercent: [10, 35],
    AccessoryOptionNames.summonAtkFlat: [500, 2000],
    AccessoryOptionNames.rabbitMaxHpChancePercent: [30, 50],
    AccessoryOptionNames.counterAttackChancePercent: [3, 10],
    AccessoryOptionNames.spaceTravelReturnChancePercent: [30, 50],
    AccessoryOptionNames.hpRegenPerTurn: [1000, 3000],
    AccessoryOptionNames.allDmgTakenReducePercent: [3, 15],
    AccessoryOptionNames.miniGameSkillDmgPercent: [10, 35],
    AccessoryOptionNames.recoveryEffectPercent: [5, 15],
    AccessoryOptionNames.skillCooldownIncreaseResistPercent: [5, 20],
    AccessoryOptionNames.atkPercent: [3, 10],
    AccessoryOptionNames.defenseFlat: [2000, 5000],
    AccessoryOptionNames.hpPercent: [3, 10],
    AccessoryOptionNames.penetrationResistPercent: [2, 10],
    AccessoryOptionNames.penetrationChancePercent: [2, 10],
  };

  Accessory? _selectedAccessory;
  AccessorySimulationMode _selectedMode = AccessorySimulationMode.craft;
  SimulatedAccessoryState? _simulatedState;

  int _currentEnhancementLevel = 0;
  int? _targetEnhancementLevel;
  bool _isAutoEnhancing = false;
  bool _isAutoEnhanceMode = false;
  String _selectedEnhancementAid = '선택 안함';
  int _selectedOptionCount = 2;
  int _enhancementAttemptCount = 0;
  int _enhancementSuccessCount = 0;
  int _enhancementFailKeepCount = 0;
  int _enhancementFailDowngradeCount = 0;
  int _totalConsumedStones = 0;
  int _totalConsumedGold = 0;
  final Map<String, int> _consumedAidsCount = {};

  AccessorySimulationOptionChangeAction _selectedAction =
      AccessorySimulationOptionChangeAction.none;
  int _totalSoulStonesConsumed = 0;
  int _totalGrindstonesConsumed = 0;
  int _totalRainbowAnvilsConsumed = 0;
  int _total9EnhanceAccessoriesConsumed = 0;

  bool _useGoldMoruForRemodel = false;
  int _silverMoruConsumed = 0;
  int _goldMoruConsumed = 0;
  int _totalRemodelGoldConsumed = 0;
  int _craftAttemptCount = 0;
  final List<CraftedAccessoryLogEntry> _craftLogs = [];

  @override
  void initState() {
    super.initState();
    final allAccessories = AccessoryDataManager().allAccessories;
    if (allAccessories.isNotEmpty) {
      _selectedAccessory = allAccessories.first;
    }
    _syncSelectedOptionCount();
  }

  bool get _isRandomAccessory => _selectedAccessory?.randomOptionConfig != null;

  bool get _hasSimulatedItem => _simulatedState != null;

  List<AccessoryOption> get _currentOptions =>
      _simulatedState?.currentOptions ?? const [];

  List<AccessoryOption> get _baseOptions =>
      _simulatedState?.baseOptions ?? const [];

  Map<String, int> get _currentEnhancementCosts {
    final costs = _selectedOptionCount == 1
        ? AccessoryEnhancementScreenUI
            .enhancementCostsOneOption[_currentEnhancementLevel]
        : AccessoryEnhancementScreenUI
            .enhancementCostsTwoPlusOptions[_currentEnhancementLevel];
    return costs ?? const {'stones': 0, 'gold': 0};
  }

  Map<String, int> get _currentRemodelCost => {
        _useGoldMoruForRemodel ? '금모루' : '은모루': 1,
        '골드': _useGoldMoruForRemodel
            ? _goldRemodelGoldCost
            : _silverRemodelGoldCost,
      };

  void _selectAccessory(BuildContext context) {
    final allAccessories = AccessoryDataManager().allAccessories;
    if (allAccessories.isEmpty) return;

    final parts = allAccessories.map((a) => a.part).toSet().toList()..sort();
    String? selectedPart;
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = allAccessories.where((a) {
              final matchesPart =
                  selectedPart == null || a.part == selectedPart;
              final matchesSearch = searchQuery.isEmpty ||
                  a.name.toLowerCase().contains(searchQuery.toLowerCase());
              return matchesPart && matchesSearch;
            }).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '악세사리 선택',
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        onChanged: (v) => setSheetState(() => searchQuery = v),
                        decoration: const InputDecoration(
                          hintText: '이름 검색',
                          prefixIcon: Icon(Icons.search, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('전체'),
                            selected: selectedPart == null,
                            onSelected: (_) =>
                                setSheetState(() => selectedPart = null),
                          ),
                          const SizedBox(width: 6),
                          ...parts.map(
                            (part) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(part),
                                selected: selectedPart == part,
                                onSelected: (_) => setSheetState(
                                  () => selectedPart =
                                      selectedPart == part ? null : part,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('검색 결과가 없습니다.'))
                          : GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 90,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final acc = filtered[index];
                                final isCurrent =
                                    _selectedAccessory?.id == acc.id;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(sheetContext);
                                    _updateSelectedAccessory(acc);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isCurrent
                                                ? Theme.of(ctx)
                                                    .colorScheme
                                                    .primary
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: CachedNetworkImage(
                                            imageUrl: acc.imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) =>
                                                const SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                const SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        acc.name,
                                        style:
                                            Theme.of(ctx).textTheme.labelSmall,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _updateSelectedAccessory(Accessory accessory) {
    setState(() {
      _selectedAccessory = accessory;
      _simulatedState = null;
      _craftAttemptCount = 0;
      _craftLogs.clear();
      _resetEnhancementState();
      _resetOptionChangeState();
      _resetRemodelState();
      _syncSelectedOptionCount();
      _selectedMode = AccessorySimulationMode.craft;
    });
  }

  void _resetEnhancementState() {
    _currentEnhancementLevel = 0;
    _targetEnhancementLevel = null;
    _isAutoEnhancing = false;
    _isAutoEnhanceMode = false;
    _selectedEnhancementAid = '선택 안함';
    _enhancementAttemptCount = 0;
    _enhancementSuccessCount = 0;
    _enhancementFailKeepCount = 0;
    _enhancementFailDowngradeCount = 0;
    _totalConsumedStones = 0;
    _totalConsumedGold = 0;
    _consumedAidsCount.clear();
  }

  void _resetOptionChangeState() {
    _selectedAction = AccessorySimulationOptionChangeAction.none;
    _totalSoulStonesConsumed = 0;
    _totalGrindstonesConsumed = 0;
    _totalRainbowAnvilsConsumed = 0;
    _total9EnhanceAccessoriesConsumed = 0;
  }

  void _resetRemodelState() {
    _useGoldMoruForRemodel = false;
    _silverMoruConsumed = 0;
    _goldMoruConsumed = 0;
    _totalRemodelGoldConsumed = 0;
  }

  void _syncSelectedOptionCount() {
    final optionCount = _simulatedState?.currentOptions.length ??
        _selectedAccessory?.options.length ??
        2;
    _selectedOptionCount = optionCount <= 1 ? 1 : 2;
  }

  void _craftSelectedAccessory() {
    final accessory = _selectedAccessory;
    if (accessory == null) return;

    if (accessory.randomOptionConfig == null) {
      final craftedOptions = List<AccessoryOption>.from(accessory.options);
      setState(() {
        _simulatedState = SimulatedAccessoryState(
          accessory: accessory,
          baseOptions: craftedOptions,
          currentOptions: List<AccessoryOption>.from(craftedOptions),
        );
        _appendCraftLog(accessory, craftedOptions);
        _resetEnhancementState();
        _resetOptionChangeState();
        _resetRemodelState();
        _syncSelectedOptionCount();
      });
      return;
    }

    final result = RandomAccessoryRepository.roll(
      accessory: accessory,
      config: accessory.randomOptionConfig!,
      useGoldMoru: false,
      random: _random,
    );

    final rolledOptions = result.options
        .map(
          (roll) => _buildOptionFromRoll(accessory, roll),
        )
        .toList(growable: false);

    setState(() {
      _simulatedState = SimulatedAccessoryState(
        accessory: accessory,
        baseOptions: rolledOptions,
        currentOptions: List<AccessoryOption>.from(rolledOptions),
        grade: result.grade,
      );
      _appendCraftLog(accessory, rolledOptions, grade: result.grade);
      _resetEnhancementState();
      _resetOptionChangeState();
      _resetRemodelState();
      _syncSelectedOptionCount();
    });
  }

  void _appendCraftLog(
    Accessory accessory,
    List<AccessoryOption> options, {
    String? grade,
  }) {
    _craftAttemptCount += 1;
    _craftLogs.insert(
      0,
      CraftedAccessoryLogEntry(
        attempt: _craftAttemptCount,
        accessory: accessory,
        options: List<AccessoryOption>.from(options),
        grade: grade,
      ),
    );
  }

  AccessoryOption _buildOptionFromRoll(
    Accessory accessory,
    RandomOptionRoll roll,
  ) {
    final source = _findSourceOptionByName(accessory, roll.optionName);
    return AccessoryOption(
      optionName: roll.optionName,
      optionValue: roll.value.toString(),
      minNormalValue: source?.minNormalValue,
      maxNormalValue: source?.maxNormalValue,
    );
  }

  AccessoryOption? _findSourceOptionByName(
      Accessory accessory, String optionName) {
    for (final option in accessory.options) {
      if (option.optionName == optionName) {
        return option;
      }
    }
    return null;
  }

  Future<void> _handleEnhanceButtonPressed() async {
    if (_simulatedState == null) {
      _showSnack('먼저 악세사리를 제작해 주세요.');
      return;
    }

    if (_isAutoEnhanceMode) {
      setState(() => _isAutoEnhancing = true);
      await _performEnhancementLoop();
      if (mounted) {
        setState(() {
          _isAutoEnhancing = false;
          _isAutoEnhanceMode = false;
        });
      }
    } else {
      _performSingleEnhancement();
    }
  }

  void _performSingleEnhancement() {
    if (_simulatedState == null || _currentEnhancementLevel >= 9) {
      return;
    }

    _syncSelectedOptionCount();
    final costs = _currentEnhancementCosts;
    final baseProbs = AccessoryEnhancementScreenUI
            .baseEnhancementProbabilities[_currentEnhancementLevel] ??
        {'success': 0.0, 'fail_no_change': 0.0, 'downgrade': 0.0};
    final double baseSuccess = baseProbs['success']!;
    final double baseFailNoChange = baseProbs['fail_no_change']!;
    final double baseDowngrade = baseProbs['downgrade']!;

    final double aidBonusValue = AccessoryEnhancementScreenUI
            .enhancementAidBonuses[_selectedEnhancementAid] ??
        0.0;
    final bool isSpecialAidNoDowngrade =
        _selectedEnhancementAid.startsWith('스페셜') &&
            _selectedEnhancementAid != '스페셜 특급 보조제';
    final bool isSuperSpecialAid100Success =
        _selectedEnhancementAid == '스페셜 특급 보조제';

    double finalSuccessChance;
    double finalDowngradeChance;

    if (isSuperSpecialAid100Success) {
      finalSuccessChance = 1.0;
      finalDowngradeChance = 0.0;
    } else {
      double bonusToApply = aidBonusValue;
      if (bonusToApply > baseFailNoChange) {
        bonusToApply = baseFailNoChange;
      }
      finalSuccessChance = baseSuccess + bonusToApply;
      finalDowngradeChance = isSpecialAidNoDowngrade ? 0.0 : baseDowngrade;
    }

    setState(() {
      if (_selectedEnhancementAid != '선택 안함') {
        _consumedAidsCount[_selectedEnhancementAid] =
            (_consumedAidsCount[_selectedEnhancementAid] ?? 0) + 1;
      }
      _totalConsumedStones += costs['stones'] ?? 0;
      _totalConsumedGold += costs['gold'] ?? 0;
      _enhancementAttemptCount++;

      final randomValue = _random.nextDouble();
      if (randomValue < finalSuccessChance) {
        _currentEnhancementLevel++;
        _enhancementSuccessCount++;
      } else if (randomValue < finalSuccessChance + finalDowngradeChance) {
        _enhancementFailDowngradeCount++;
        _currentEnhancementLevel = max(0, _currentEnhancementLevel - 1);
      } else {
        _enhancementFailKeepCount++;
      }
    });
  }

  Future<void> _performEnhancementLoop() async {
    while (_isAutoEnhancing && mounted) {
      _performSingleEnhancement();
      if (_currentEnhancementLevel >= 9 ||
          (_targetEnhancementLevel != null &&
              _currentEnhancementLevel >= _targetEnhancementLevel!)) {
        if (mounted) {
          _showSnack('자동 강화가 완료되었습니다.');
        }
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    if (mounted) {
      setState(() => _isAutoEnhancing = false);
    }
  }

  void _handleOptionChangeAction(AccessorySimulationOptionChangeAction action) {
    if (_simulatedState == null) {
      _showSnack('먼저 악세사리를 제작해 주세요.');
      return;
    }
    if (_baseOptions.length == 1) {
      _showSnack('기본 옵션이 1개인 악세사리는 옵션 확장 및 변경을 할 수 없습니다.');
      return;
    }

    setState(() {
      _selectedAction = action;
    });
    _performOptionChange();
  }

  void _performOptionChange() {
    if (_simulatedState == null || _selectedAccessory == null) return;

    final current = List<AccessoryOption>.from(_currentOptions);

    setState(() {
      switch (_selectedAction) {
        case AccessorySimulationOptionChangeAction.none:
          break;
        case AccessorySimulationOptionChangeAction.expandToThird:
          if (current.length < 3) {
            current.add(
                _generateRandomOption(forSlot: 2, existingOptions: current));
            _totalRainbowAnvilsConsumed++;
          }
          break;
        case AccessorySimulationOptionChangeAction.changeThird:
          if (current.length >= 3) {
            current[2] =
                _generateRandomOption(forSlot: 2, existingOptions: current);
            _totalSoulStonesConsumed += 100;
          }
          break;
        case AccessorySimulationOptionChangeAction.expandToFourth:
          if (current.length < 4 && current.length >= 3) {
            current.add(
                _generateRandomOption(forSlot: 3, existingOptions: current));
            _total9EnhanceAccessoriesConsumed++;
          }
          break;
        case AccessorySimulationOptionChangeAction.changeFourth:
          if (current.length >= 4) {
            current[3] =
                _generateRandomOption(forSlot: 3, existingOptions: current);
            _totalSoulStonesConsumed += 100;
            _totalGrindstonesConsumed += 300;
          }
          break;
      }

      _simulatedState = _simulatedState!.copyWith(currentOptions: current);
      _selectedAction = AccessorySimulationOptionChangeAction.none;
      _syncSelectedOptionCount();
    });
  }

  List<AccessoryOption> _availableChangeableOptions() {
    return _defaultChangeableOptions;
  }

  int _getOptionWeight(String optionName) {
    if (optionName == AccessoryOptionNames.rabbitMaxHpChancePercent ||
        optionName == AccessoryOptionNames.spaceTravelReturnChancePercent ||
        optionName == AccessoryOptionNames.hpRegenPerTurn) {
      return 5;
    }

    if (optionName.contains('%') ||
        optionName == AccessoryOptionNames.critChanceFlat ||
        optionName == AccessoryOptionNames.critDamageFlat ||
        optionName == AccessoryOptionNames.critResistFlat ||
        optionName == AccessoryOptionNames.accuracyFlat ||
        optionName == AccessoryOptionNames.evasionFlat) {
      return 40;
    }

    return 100;
  }

  AccessoryOption _generateRandomOption({
    required int forSlot,
    required List<AccessoryOption> existingOptions,
  }) {
    final accessory = _selectedAccessory;
    if (accessory == null) {
      return _defaultChangeableOptions.first;
    }
    final availablePool = _availableChangeableOptions();
    final excludedOptionNames = <String>{};

    if (forSlot == 2) {
      if (existingOptions.isNotEmpty) {
        excludedOptionNames.add(existingOptions[0].optionName);
      }
      if (existingOptions.length > 1) {
        excludedOptionNames.add(existingOptions[1].optionName);
      }
      if (existingOptions.length > 3) {
        excludedOptionNames.add(existingOptions[3].optionName);
      }
    }

    final availableOptions = availablePool
        .where((option) => !excludedOptionNames.contains(option.optionName))
        .toList(growable: false);
    final pool = availableOptions.isEmpty ? availablePool : availableOptions;

    var totalWeight = 0;
    for (final option in pool) {
      totalWeight += _getOptionWeight(option.optionName);
    }

    var randomValue = _random.nextInt(max(1, totalWeight));
    for (final option in pool) {
      randomValue -= _getOptionWeight(option.optionName);
      if (randomValue < 0) {
        final (minValue, maxValue) = _resolveOptionRange(option);
        final optionValue = accessory.randomOptionConfig == null
            ? maxValue
            : _randInt(_random, minValue, maxValue);
        return AccessoryOption(
          optionName: option.optionName,
          optionValue: optionValue.toString(),
          minNormalValue: minValue,
          maxNormalValue: maxValue,
        );
      }
    }
    final fallback = pool.last;
    final (minValue, maxValue) = _resolveOptionRange(fallback);
    final optionValue = accessory.randomOptionConfig == null
        ? maxValue
        : _randInt(_random, minValue, maxValue);
    return AccessoryOption(
      optionName: fallback.optionName,
      optionValue: optionValue.toString(),
      minNormalValue: minValue,
      maxNormalValue: maxValue,
    );
  }

  (int, int) _resolveOptionRange(AccessoryOption option) {
    final isRandomAccessory = _selectedAccessory?.randomOptionConfig != null;
    if (isRandomAccessory) {
      final tableRange = _randomOptionValueRangeTable[option.optionName];
      if (tableRange != null && tableRange.length == 2) {
        return (tableRange[0], tableRange[1]);
      }
    }

    final parsedValue = int.tryParse(option.optionValue) ?? 1;
    final rawMin = option.minNormalValue ?? max(1, (parsedValue * 0.6).round());
    final rawMax = option.maxNormalValue ?? parsedValue;
    final minValue = min(rawMin, rawMax);
    final maxValue = max(rawMin, rawMax);
    return (minValue, maxValue);
  }

  void _performRemodel() {
    if (_simulatedState == null || _selectedAccessory == null) {
      _showSnack('먼저 악세사리를 제작해 주세요.');
      return;
    }
    if (!_canRemodelCurrentAccessory()) {
      _showSnack('개조는 수치 범위가 있는 랜덤 악세사리만 가능합니다.');
      return;
    }

    final grade = _pickWeightedString(
      _useGoldMoruForRemodel
          ? RandomAccessoryRepository.goldMoruGradeProbabilities
          : RandomAccessoryRepository.silverMoruGradeProbabilities,
      _random,
    );

    final remodeledOptions = _currentOptions.map((option) {
      final source =
          _findSourceOptionByName(_selectedAccessory!, option.optionName)!;
      final range = _gradeRange(
        source.minNormalValue!,
        source.maxNormalValue!,
        grade,
      );
      final rolled = _randInt(_random, range.$1, range.$2);
      return AccessoryOption(
        optionName: option.optionName,
        optionValue: rolled.toString(),
        minNormalValue: source.minNormalValue,
        maxNormalValue: source.maxNormalValue,
      );
    }).toList(growable: false);

    final baseCount = _baseOptions.length;
    setState(() {
      _simulatedState = _simulatedState!.copyWith(
        grade: grade,
        baseOptions: remodeledOptions.take(baseCount).toList(growable: false),
        currentOptions: remodeledOptions,
      );
      if (_useGoldMoruForRemodel) {
        _goldMoruConsumed++;
        _totalRemodelGoldConsumed += _goldRemodelGoldCost;
      } else {
        _silverMoruConsumed++;
        _totalRemodelGoldConsumed += _silverRemodelGoldCost;
      }
      _syncSelectedOptionCount();
    });
  }

  bool _canRemodelCurrentAccessory() {
    if (_selectedAccessory?.randomOptionConfig == null ||
        _simulatedState == null) {
      return false;
    }
    for (final option in _currentOptions) {
      final source =
          _findSourceOptionByName(_selectedAccessory!, option.optionName);
      if (source?.minNormalValue == null || source?.maxNormalValue == null) {
        return false;
      }
    }
    return true;
  }

  String _pickWeightedString(Map<String, double> weights, Random rng) {
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var pick = rng.nextDouble() * total;
    for (final entry in weights.entries) {
      pick -= entry.value;
      if (pick <= 0) return entry.key;
    }
    return weights.keys.last;
  }

  int _randInt(Random rng, int minValue, int maxValue) {
    if (maxValue <= minValue) return minValue;
    return minValue + rng.nextInt(maxValue - minValue + 1);
  }

  (int, int) _gradeRange(int minValue, int maxValue, String grade) {
    final span = maxValue - minValue;
    final accessoryConst = max(1, (span / 3).ceil());

    final yellowMin = minValue;
    final yellowMax = max(minValue, maxValue - accessoryConst * 2);

    final greenMin = min(maxValue, yellowMax + 1);
    final greenMax = max(greenMin, maxValue - accessoryConst);

    final blueMin = min(maxValue, greenMax + 1);
    final blueMax = maxValue;

    if (grade == RandomAccessoryRepository.gradeBlue) {
      return (blueMin, blueMax);
    }
    if (grade == RandomAccessoryRepository.gradeGreen) {
      return (greenMin, greenMax);
    }
    return (yellowMin, yellowMax);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accessory = _selectedAccessory;
    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.accessorySimulation),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('악세사리 시뮬레이션'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '현재 악세 리셋',
            onPressed: accessory == null
                ? null
                : () => _updateSelectedAccessory(accessory),
          ),
        ],
      ),
      body: accessory == null
          ? const Center(child: Text('악세사리 데이터가 없습니다.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopAccessorySelector(context),
                  const SizedBox(height: 12),
                  _buildModeSelector(),
                  const SizedBox(height: 12),
                  if (_hasSimulatedItem &&
                      _selectedMode != AccessorySimulationMode.craft) ...[
                    _buildSimulatedAccessoryCard(context),
                    const SizedBox(height: 12),
                  ],
                  _buildModeContent(context),
                ],
              ),
            ),
    );
  }

  Widget _buildTopAccessorySelector(BuildContext context) {
    final accessory = _selectedAccessory;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _selectAccessory(context),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: accessory == null
                    ? const Icon(Icons.image_not_supported_outlined)
                    : CachedNetworkImage(
                        imageUrl: accessory.imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_not_supported_outlined),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accessory?.name ?? '선택된 악세사리 없음',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '${accessory?.part ?? '-'} / ${accessory?.restrictions ?? '-'}'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _selectAccessory(context),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('악세 선택'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return SegmentedButton<AccessorySimulationMode>(
      segments: const [
        ButtonSegment<AccessorySimulationMode>(
          value: AccessorySimulationMode.craft,
          label: Text('제작'),
        ),
        ButtonSegment<AccessorySimulationMode>(
          value: AccessorySimulationMode.enhance,
          label: Text('강화'),
        ),
        ButtonSegment<AccessorySimulationMode>(
          value: AccessorySimulationMode.optionChange,
          label: Text('옵션변경'),
        ),
        ButtonSegment<AccessorySimulationMode>(
          value: AccessorySimulationMode.remodel,
          label: Text('개조'),
        ),
      ],
      selected: {_selectedMode},
      onSelectionChanged: (value) {
        setState(() {
          _selectedMode = value.first;
        });
      },
    );
  }

  Widget _buildModeContent(BuildContext context) {
    switch (_selectedMode) {
      case AccessorySimulationMode.craft:
        return _buildCraftSection(context);
      case AccessorySimulationMode.enhance:
        return _buildEnhancementSection(context);
      case AccessorySimulationMode.optionChange:
        return _buildOptionChangeSection(context);
      case AccessorySimulationMode.remodel:
        return _buildRemodelSection(context);
    }
  }

  Widget _buildCraftSection(BuildContext context) {
    final accessory = _selectedAccessory!;
    final isRandom = accessory.randomOptionConfig != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제작', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _craftSelectedAccessory,
                    icon: const Icon(Icons.precision_manufacturing_rounded),
                    label: Text(isRandom ? '랜덤 악세 제작' : '악세 제작'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_craftLogs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '제작 기록',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._craftLogs.map((entry) => _buildCraftLogCard(context, entry)),
        ],
      ],
    );
  }

  Widget _buildEnhancementSection(BuildContext context) {
    if (!_hasSimulatedItem) {
      return _buildInfoCard('먼저 제작에서 현재 악세를 생성해 주세요.');
    }

    _syncSelectedOptionCount();
    return AccessoryEnhancementScreenUI(
      embedded: true,
      selectedAccessory: _simulatedState?.accessory,
      onSelectAccessoryPressed: () => _selectAccessory(context),
      currentEnhancementLevel: _currentEnhancementLevel,
      onCurrentEnhancementLevelChanged: (value) {
        if (value == null) return;
        setState(() {
          _currentEnhancementLevel = value;
          if (_targetEnhancementLevel != null &&
              _targetEnhancementLevel! <= value) {
            _targetEnhancementLevel = null;
          }
        });
      },
      targetEnhancementLevel: _targetEnhancementLevel,
      onTargetEnhancementLevelChanged: (value) {
        setState(() {
          _targetEnhancementLevel = value;
        });
      },
      selectedEnhancementAid: _selectedEnhancementAid,
      enhancementAidOptions: _enhancementAids,
      onEnhancementAidChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedEnhancementAid = value;
        });
      },
      isAutoEnhanceMode: _isAutoEnhanceMode,
      onAutoEnhanceModeChanged: (value) {
        setState(() {
          _isAutoEnhanceMode = value;
          if (!value) {
            _targetEnhancementLevel = null;
          }
        });
      },
      isAutoEnhancing: _isAutoEnhancing,
      onEnhanceButtonPressed: _handleEnhanceButtonPressed,
      onStopAutoEnhancePressed: () {
        setState(() {
          _isAutoEnhancing = false;
          _isAutoEnhanceMode = false;
        });
      },
      attemptCount: _enhancementAttemptCount,
      successCount: _enhancementSuccessCount,
      failKeepCount: _enhancementFailKeepCount,
      failDowngradeCount: _enhancementFailDowngradeCount,
      totalConsumedStones: _totalConsumedStones,
      totalConsumedGold: _totalConsumedGold,
      onResetScreenPressed: () {
        setState(() {
          _resetEnhancementState();
          _syncSelectedOptionCount();
        });
      },
      selectedOptionCount: _selectedOptionCount,
      onOptionCountChanged: (_) {},
      consumedAidsCount: _consumedAidsCount,
    );
  }

  Widget _buildOptionChangeSection(BuildContext context) {
    if (!_hasSimulatedItem) {
      return _buildInfoCard('먼저 제작에서 현재 악세를 생성해 주세요.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('현재 옵션', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: List.generate(4, _buildOptionRowByIndex),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('소모 재화', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('영혼석: ${_numberFormat.format(_totalSoulStonesConsumed)}개'),
                Text(
                    '숫돌이: ${_numberFormat.format(_totalGrindstonesConsumed)}개'),
                Text(
                    '무지개 모루: ${_numberFormat.format(_totalRainbowAnvilsConsumed)}개'),
                Text(
                    '3옵 9강 악세: ${_numberFormat.format(_total9EnhanceAccessoriesConsumed)}개'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRowByIndex(int index) {
    final theme = Theme.of(context);
    final currentOptionCount = _currentOptions.length;
    final baseOptionCount = _baseOptions.length;
    final slot = index + 1;
    final isFilled = index < currentOptionCount;
    final isBaseSlot = index < baseOptionCount;

    String optionName = '비어있음';
    String optionValue = '';
    Color? optionColor = theme.hintColor;
    String? actionLabel;
    VoidCallback? action;

    if (isFilled) {
      optionName = _currentOptions[index].optionName;
      optionValue = _formatOptionValueWithRange(_currentOptions[index]);
      optionColor = isBaseSlot ? Colors.grey : theme.textTheme.bodyLarge?.color;

      if (!isBaseSlot) {
        if (index == 2) {
          actionLabel = '변경';
          action = () => _handleOptionChangeAction(
                AccessorySimulationOptionChangeAction.changeThird,
              );
        } else if (index == 3) {
          actionLabel = '변경';
          action = () => _handleOptionChangeAction(
                AccessorySimulationOptionChangeAction.changeFourth,
              );
        }
      }
    } else {
      if (index == 2 && baseOptionCount < 3) {
        actionLabel = '확장';
        action = () => _handleOptionChangeAction(
              AccessorySimulationOptionChangeAction.expandToThird,
            );
      } else if (index == 3 && currentOptionCount >= 3) {
        actionLabel = '확장';
        action = () => _handleOptionChangeAction(
              AccessorySimulationOptionChangeAction.expandToFourth,
            );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('${slot}옵')),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isBaseSlot
                    ? Colors.grey.withAlpha(20)
                    : Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      optionName,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: optionColor),
                    ),
                  ),
                  if (optionValue.isNotEmpty)
                    Text(
                      optionValue,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: optionColor),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: actionLabel == null
                ? const SizedBox.shrink()
                : OutlinedButton(
                    onPressed: action,
                    child: Text(actionLabel),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemodelSection(BuildContext context) {
    if (!_hasSimulatedItem) {
      return _buildInfoCard('먼저 제작에서 현재 악세를 생성해 주세요.');
    }
    if (!_canRemodelCurrentAccessory()) {
      return _buildInfoCard('개조는 수치 범위가 정의된 랜덤 악세사리만 가능합니다.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('개조', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: false, label: Text('은모루')),
                    ButtonSegment<bool>(value: true, label: Text('금모루')),
                  ],
                  selected: {_useGoldMoruForRemodel},
                  onSelectionChanged: (value) {
                    setState(() {
                      _useGoldMoruForRemodel = value.first;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '등급 확률: ${_gradeProbText(_useGoldMoruForRemodel ? RandomAccessoryRepository.goldMoruGradeProbabilities : RandomAccessoryRepository.silverMoruGradeProbabilities)}',
                ),
                const SizedBox(height: 8),
                _buildSimpleCostCard(_currentRemodelCost),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _performRemodel,
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('개조 실행'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('누적 소모', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('은모루: ${_numberFormat.format(_silverMoruConsumed)}개'),
                Text('금모루: ${_numberFormat.format(_goldMoruConsumed)}개'),
                Text('골드: ${_numberFormat.format(_totalRemodelGoldConsumed)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatedAccessoryCard(BuildContext context) {
    final state = _simulatedState!;
    final borderColor = _borderColorForGrade(state.grade, Theme.of(context));

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccessoryIcon(
              imageUrl: state.accessory.imageUrl,
              grade: state.grade,
              size: 72,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.accessory.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(state.grade == null ? '고정옵션 악세' : '테두리: ${state.grade}'),
                  Text('현재 옵션 수: ${state.currentOptions.length}개'),
                  Text('강화: ${_currentEnhancementLevel}강'),
                  const SizedBox(height: 8),
                  ...state.currentOptions.map(
                    (option) => _buildCompactOptionLine(context, option),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCostCard(Map<String, int> cost) {
    return Column(
      children: cost.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text(_numberFormat.format(entry.value)),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildInfoCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }

  Widget _buildCraftLogCard(
    BuildContext context,
    CraftedAccessoryLogEntry entry,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAccessory = entry.accessory;
          _simulatedState = SimulatedAccessoryState(
            accessory: entry.accessory,
            baseOptions: List<AccessoryOption>.from(entry.options),
            currentOptions: List<AccessoryOption>.from(entry.options),
            grade: entry.grade,
          );
          _resetEnhancementState();
          _resetOptionChangeState();
          _resetRemodelState();
          _syncSelectedOptionCount();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccessoryIcon(
                imageUrl: entry.accessory.imageUrl,
                grade: entry.grade,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${entry.attempt}회차 · ${entry.accessory.name}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(entry.grade == null ? '고정옵션' : '테두리: ${entry.grade}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...entry.options.map(
                      (option) => _buildCompactOptionLine(context, option),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactOptionLine(BuildContext context, AccessoryOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 11,
            child: Text(
              option.optionName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 9,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildOptionValueWidget(context, option),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryIcon({
    required String imageUrl,
    required String? grade,
    required double size,
  }) {
    final colors = _gradientColorsForGrade(grade);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withAlpha(90),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) =>
                const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionValueWidget(BuildContext context, AccessoryOption option) {
    final isMaxRoll = _isMaxRollOption(option);
    final text = _formatOptionValueWithRange(option);
    if (!isMaxRoll) {
      return Text(
        text,
        textAlign: TextAlign.right,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.pink.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200.withAlpha(160),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withAlpha(180)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }

  String _formatOptionValueWithRange(AccessoryOption option) {
    final minValue = option.minNormalValue;
    final maxValue = option.maxNormalValue;
    if (minValue == null || maxValue == null) {
      return option.optionValue;
    }
    return '${option.optionValue} ($minValue~$maxValue)';
  }

  bool _isMaxRollOption(AccessoryOption option) {
    final maxValue = option.maxNormalValue;
    final currentValue = int.tryParse(option.optionValue);
    return maxValue != null && currentValue != null && currentValue == maxValue;
  }

  String _gradeProbText(Map<String, double> probs) {
    final blue = probs[RandomAccessoryRepository.gradeBlue] ?? 0;
    final green = probs[RandomAccessoryRepository.gradeGreen] ?? 0;
    final yellow = probs[RandomAccessoryRepository.gradeYellow] ?? 0;
    return '파랑 ${blue.toStringAsFixed(0)}%, 초록 ${green.toStringAsFixed(0)}%, 노랑 ${yellow.toStringAsFixed(0)}%';
  }

  Color _borderColorForGrade(String? grade, ThemeData theme) {
    if (grade == RandomAccessoryRepository.gradeBlue) {
      return Colors.blue.shade400;
    }
    if (grade == RandomAccessoryRepository.gradeGreen) {
      return Colors.green.shade500;
    }
    if (grade == RandomAccessoryRepository.gradeYellow) {
      return Colors.amber.shade700;
    }
    return theme.dividerColor;
  }

  List<Color> _gradientColorsForGrade(String? grade) {
    if (grade == RandomAccessoryRepository.gradeBlue) {
      return [Colors.lightBlueAccent.shade100, Colors.blue.shade700];
    }
    if (grade == RandomAccessoryRepository.gradeGreen) {
      return [Colors.lightGreenAccent.shade100, Colors.green.shade700];
    }
    if (grade == RandomAccessoryRepository.gradeYellow) {
      return [Colors.amber.shade200, Colors.orange.shade700];
    }
    return [Colors.blueGrey.shade200, Colors.blueGrey.shade500];
  }
}
