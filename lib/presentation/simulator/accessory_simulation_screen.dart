import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/accessory_constants.dart';
import '../../core/constants/box_constants.dart';
import '../../core/constants/random_accessory_constants.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/models/accessory.dart';
import 'accessory_enhancement_screen_ui.dart';

const _silverRemodelGoldCost = 20000;
const _goldRemodelGoldCost = 3000;
const _autoEnhanceBatchSize = 15;
const _maxCraftLogCount = 80;
const _lastSelectedAccessoryIdKey = 'accessory_sim_last_selected_id';

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

  bool _isAutoOptionChanging = false;
  int _autoOptionTargetSlot = 3;
  String? _autoOptionTargetName;
  int _autoOptionChangeAttempts = 0;
  bool _autoOptionRequireNextHit = false;
  int _totalSoulStonesConsumed = 0;
  int _totalGrindstonesConsumed = 0;
  int _totalRainbowAnvilsConsumed = 0;
  int _total9EnhanceAccessoriesConsumed = 0;

  bool _useGoldMoruForRemodel = false;
  int _silverMoruConsumed = 0;
  int _goldMoruConsumed = 0;
  int _totalRemodelGoldConsumed = 0;
  int _totalRemodelSoulStonesConsumed = 0;
  int _remodelAttemptCount = 0;
  int _totalRemodelAttemptCount = 0;
  int _craftAttemptCount = 0;
  final List<CraftedAccessoryLogEntry> _craftLogs = [];

  // 악세 선택 바텀시트 필터 상태 (사용자가 바꾸기 전까지 유지)
  String? _accessoryPickerSelectedPart;
  bool? _accessoryPickerSelectedRandomType;
  String _accessoryPickerSearchQuery = '';

  @override
  void initState() {
    super.initState();
    final allAccessories = AccessoryDataManager().allAccessories;
    if (allAccessories.isNotEmpty) {
      _selectedAccessory = allAccessories.first;
    }
    _syncSelectedOptionCount();
    _loadLastSelectedAccessory();
  }

  Future<void> _loadLastSelectedAccessory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_lastSelectedAccessoryIdKey);
      if (savedId == null || savedId.isEmpty) {
        return;
      }

      final allAccessories = AccessoryDataManager().allAccessories;
      if (allAccessories.isEmpty) {
        return;
      }

      Accessory? matched;
      for (final acc in allAccessories) {
        if (acc.id == savedId) {
          matched = acc;
          break;
        }
      }
      if (matched == null || !mounted) {
        return;
      }

      setState(() {
        _selectedAccessory = matched;
        _simulatedState = null;
        _craftAttemptCount = 0;
        _craftLogs.clear();
        _resetEnhancementState();
        _resetOptionChangeState();
        _resetRemodelState();
        _syncSelectedOptionCount();
        _selectedMode = AccessorySimulationMode.craft;
      });
    } catch (_) {
      // Ignore persistence load failures and keep current in-memory selection.
    }
  }

  Future<void> _saveLastSelectedAccessory(String accessoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSelectedAccessoryIdKey, accessoryId);
    } catch (_) {
      // Ignore persistence save failures; simulation should still work.
    }
  }

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
        '영혼석': _currentRemodelSoulStoneCost,
      };

  int get _currentRemodelSoulStoneCost {
    final nextAttempt = _remodelAttemptCount + 1;
    if (nextAttempt <= 5) {
      return 0;
    }
    return (nextAttempt - 5) * 20;
  }

  bool get _canAttemptRemodelByCount => _remodelAttemptCount < 15;

  void _selectAccessory(BuildContext context) {
    final allAccessories = AccessoryDataManager().allAccessories;
    if (allAccessories.isEmpty) return;

    final parts = allAccessories.map((a) => a.part).toSet().toList()..sort();
    final searchController = TextEditingController(
      text: _accessoryPickerSearchQuery,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final colorScheme = Theme.of(ctx).colorScheme;
            final filtered = allAccessories.where((a) {
              final matchesPart = _accessoryPickerSelectedPart == null ||
                  a.part == _accessoryPickerSelectedPart;
              final isRandom = a.randomOptionConfig != null;
              final matchesOptionType =
                  _accessoryPickerSelectedRandomType == null
                      ? true
                      : isRandom == _accessoryPickerSelectedRandomType;
              final query = _accessoryPickerSearchQuery.toLowerCase();
              final matchesSearch =
                  query.isEmpty || a.name.toLowerCase().contains(query);
              return matchesPart && matchesOptionType && matchesSearch;
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
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...parts.map(
                                    (part) => Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: FilterChip(
                                        label: Text(part),
                                        showCheckmark: false,
                                        selected:
                                            _accessoryPickerSelectedPart ==
                                                part,
                                        selectedColor:
                                            colorScheme.primaryContainer,
                                        backgroundColor: colorScheme.surface
                                            .withValues(alpha: 0.65),
                                        side: BorderSide(
                                          color: _accessoryPickerSelectedPart ==
                                                  part
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                  .withValues(alpha: 0.28),
                                          width: _accessoryPickerSelectedPart ==
                                                  part
                                              ? 1.3
                                              : 1,
                                        ),
                                        labelStyle: Theme.of(ctx)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color:
                                                  _accessoryPickerSelectedPart ==
                                                          part
                                                      ? colorScheme
                                                          .onPrimaryContainer
                                                      : colorScheme.onSurface,
                                              fontWeight:
                                                  _accessoryPickerSelectedPart ==
                                                          part
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                            ),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onSelected: (_) => setSheetState(
                                          () => _accessoryPickerSelectedPart =
                                              _accessoryPickerSelectedPart ==
                                                      part
                                                  ? null
                                                  : part,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (parts.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Theme.of(ctx).dividerColor,
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  FilterChip(
                                    label: const Text('고정옵션'),
                                    showCheckmark: false,
                                    selected:
                                        _accessoryPickerSelectedRandomType ==
                                            false,
                                    selectedColor: colorScheme.primaryContainer,
                                    backgroundColor: colorScheme.surface
                                        .withValues(alpha: 0.65),
                                    side: BorderSide(
                                      color:
                                          _accessoryPickerSelectedRandomType ==
                                                  false
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                  .withValues(alpha: 0.28),
                                      width:
                                          _accessoryPickerSelectedRandomType ==
                                                  false
                                              ? 1.3
                                              : 1,
                                    ),
                                    labelStyle: Theme.of(ctx)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color:
                                              _accessoryPickerSelectedRandomType ==
                                                      false
                                                  ? colorScheme
                                                      .onPrimaryContainer
                                                  : colorScheme.onSurface,
                                          fontWeight:
                                              _accessoryPickerSelectedRandomType ==
                                                      false
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                        ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) => setSheetState(
                                      () => _accessoryPickerSelectedRandomType =
                                          _accessoryPickerSelectedRandomType ==
                                                  false
                                              ? null
                                              : false,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  FilterChip(
                                    label: const Text('랜덤옵션'),
                                    showCheckmark: false,
                                    selected:
                                        _accessoryPickerSelectedRandomType ==
                                            true,
                                    selectedColor: colorScheme.primaryContainer,
                                    backgroundColor: colorScheme.surface
                                        .withValues(alpha: 0.65),
                                    side: BorderSide(
                                      color:
                                          _accessoryPickerSelectedRandomType ==
                                                  true
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                  .withValues(alpha: 0.28),
                                      width:
                                          _accessoryPickerSelectedRandomType ==
                                                  true
                                              ? 1.3
                                              : 1,
                                    ),
                                    labelStyle: Theme.of(ctx)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color:
                                              _accessoryPickerSelectedRandomType ==
                                                      true
                                                  ? colorScheme
                                                      .onPrimaryContainer
                                                  : colorScheme.onSurface,
                                          fontWeight:
                                              _accessoryPickerSelectedRandomType ==
                                                      true
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                        ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) => setSheetState(
                                      () => _accessoryPickerSelectedRandomType =
                                          _accessoryPickerSelectedRandomType ==
                                                  true
                                              ? null
                                              : true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 108,
                            child: TextField(
                              controller: searchController,
                              onChanged: (v) => setSheetState(
                                () => _accessoryPickerSearchQuery = v,
                              ),
                              decoration: const InputDecoration(
                                hintText: '검색',
                                prefixIcon: Icon(Icons.search, size: 18),
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
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
    ).whenComplete(searchController.dispose);
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
    _saveLastSelectedAccessory(accessory.id);
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
    _isAutoOptionChanging = false;
    _autoOptionTargetSlot = 3;
    _autoOptionTargetName = null;
    _autoOptionChangeAttempts = 0;
    _autoOptionRequireNextHit = false;
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
    _totalRemodelSoulStonesConsumed = 0;
    _remodelAttemptCount = 0;
    _totalRemodelAttemptCount = 0;
  }

  void _resetRemodelAttemptCount() {
    setState(() {
      _remodelAttemptCount = 0;
    });
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
    if (_craftLogs.length > _maxCraftLogCount) {
      _craftLogs.removeRange(_maxCraftLogCount, _craftLogs.length);
    }
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
      bool reachedTarget = false;
      for (int i = 0; i < _autoEnhanceBatchSize; i++) {
        if (!_isAutoEnhancing || !mounted) {
          break;
        }
        _performSingleEnhancement();
        if (_currentEnhancementLevel >= 9 ||
            (_targetEnhancementLevel != null &&
                _currentEnhancementLevel >= _targetEnhancementLevel!)) {
          reachedTarget = true;
          break;
        }
      }
      if (reachedTarget) {
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

    if (_isAutoOptionChanging) {
      setState(() {
        _isAutoOptionChanging = false;
      });
    }

    final changed = _performOptionChange(action: action);
    if (!changed) {
      _showSnack('현재 상태에서는 해당 옵션 변경을 진행할 수 없습니다.');
    }
  }

  bool _performOptionChange({
    required AccessorySimulationOptionChangeAction action,
    bool countAsAutoAttempt = false,
  }) {
    if (_simulatedState == null || _selectedAccessory == null) return false;

    final current = List<AccessoryOption>.from(_currentOptions);
    final baseOptionCount = _baseOptions.length;
    final isRandomAccessory = _selectedAccessory?.randomOptionConfig != null;
    var changed = false;

    setState(() {
      switch (action) {
        case AccessorySimulationOptionChangeAction.none:
          break;
        case AccessorySimulationOptionChangeAction.expandToThird:
          if (current.length < 3) {
            current.add(
                _generateRandomOption(forSlot: 2, existingOptions: current));
            _totalRainbowAnvilsConsumed++;
            changed = true;
          }
          break;
        case AccessorySimulationOptionChangeAction.changeThird:
          // 고정 3옵은 변경 불가, 랜덤 제작 3옵 또는 확장 3옵은 변경 가능
          if (current.length >= 3 &&
              (isRandomAccessory || baseOptionCount < 3)) {
            current[2] =
                _generateRandomOption(forSlot: 2, existingOptions: current);
            _totalSoulStonesConsumed += 100;
            changed = true;
          }
          break;
        case AccessorySimulationOptionChangeAction.expandToFourth:
          if (current.length < 4 && current.length >= 3) {
            current.add(
                _generateRandomOption(forSlot: 3, existingOptions: current));
            _total9EnhanceAccessoriesConsumed++;
            changed = true;
          }
          break;
        case AccessorySimulationOptionChangeAction.changeFourth:
          if (current.length >= 4) {
            current[3] =
                _generateRandomOption(forSlot: 3, existingOptions: current);
            _totalSoulStonesConsumed += 100;
            _totalGrindstonesConsumed += 300;
            changed = true;
          }
          break;
      }

      if (changed && countAsAutoAttempt) {
        _autoOptionChangeAttempts++;
      }

      _simulatedState = _simulatedState!.copyWith(currentOptions: current);
      _syncSelectedOptionCount();
    });

    return changed;
  }

  AccessorySimulationOptionChangeAction _actionForAutoTargetSlot() {
    return _autoOptionTargetSlot == 4
        ? AccessorySimulationOptionChangeAction.changeFourth
        : AccessorySimulationOptionChangeAction.changeThird;
  }

  bool _canChangeTargetSlot() {
    final action = _actionForAutoTargetSlot();
    if (action == AccessorySimulationOptionChangeAction.changeFourth) {
      return _currentOptions.length >= 4;
    }
    final isRandomAccessory = _selectedAccessory?.randomOptionConfig != null;
    return _currentOptions.length >= 3 &&
        (isRandomAccessory || _baseOptions.length < 3);
  }

  int _targetSlotIndex() => _autoOptionTargetSlot - 1;

  String? _currentTargetSlotOptionName() {
    final index = _targetSlotIndex();
    if (index < 0 || index >= _currentOptions.length) {
      return null;
    }
    return _currentOptions[index].optionName;
  }

  List<String> _autoTargetOptionNames() {
    final names = _availableChangeableOptions()
        .map((option) => option.optionName)
        .toSet();

    if (_autoOptionTargetSlot == 3) {
      if (_currentOptions.isNotEmpty) {
        names.remove(_currentOptions[0].optionName);
      }
      if (_currentOptions.length > 1) {
        names.remove(_currentOptions[1].optionName);
      }
      if (_currentOptions.length > 3) {
        names.remove(_currentOptions[3].optionName);
      }
    }

    final sorted = names.toList()..sort();
    return sorted;
  }

  void _startAutoOptionChange() {
    if (_simulatedState == null) {
      _showSnack('먼저 악세사리를 제작해 주세요.');
      return;
    }
    if (!_canChangeTargetSlot()) {
      _showSnack('선택한 슬롯은 현재 옵션 변경이 불가능합니다.');
      return;
    }

    final targetName = _autoOptionTargetName;
    if (targetName == null || targetName.isEmpty) {
      _showSnack('원하는 옵션을 선택해 주세요.');
      return;
    }

    final currentName = _currentTargetSlotOptionName();

    setState(() {
      _isAutoOptionChanging = true;
      _autoOptionChangeAttempts = 0;
      // 이미 원하는 옵션인 상태에서 다시 시작하면,
      // 한 번 벗어난 뒤 "다음 등장" 시점에 멈추도록 처리한다.
      _autoOptionRequireNextHit = currentName == targetName;
    });

    _runAutoOptionChangeLoop();
  }

  Future<void> _runAutoOptionChangeLoop() async {
    final action = _actionForAutoTargetSlot();
    var waitForNextHit = _autoOptionRequireNextHit;
    var reachedTarget = false;

    while (_isAutoOptionChanging && mounted) {
      if (_selectedMode != AccessorySimulationMode.optionChange ||
          !_canChangeTargetSlot()) {
        break;
      }

      final targetName = _autoOptionTargetName;
      if (targetName == null || targetName.isEmpty) {
        break;
      }

      var reachedTargetInBatch = false;
      for (int i = 0; i < _autoEnhanceBatchSize; i++) {
        if (!_isAutoOptionChanging || !mounted) {
          break;
        }
        final changed = _performOptionChange(
          action: action,
          countAsAutoAttempt: true,
        );
        if (!changed) {
          _isAutoOptionChanging = false;
          break;
        }

        final currentName = _currentTargetSlotOptionName();
        if (waitForNextHit) {
          if (currentName != targetName) {
            waitForNextHit = false;
          }
        } else if (currentName == targetName) {
          reachedTarget = true;
          reachedTargetInBatch = true;
          break;
        }
      }

      if (reachedTargetInBatch) {
        break;
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    if (!mounted) {
      return;
    }

    final targetName = _autoOptionTargetName;
    final success = reachedTarget &&
        targetName != null &&
        targetName.isNotEmpty &&
        _currentTargetSlotOptionName() == targetName;

    setState(() {
      _isAutoOptionChanging = false;
      _autoOptionRequireNextHit = false;
    });

    if (success) {
      _showSnack('원하는 옵션이 등장했습니다. (시도: $_autoOptionChangeAttempts회)');
    }
  }

  void _stopAutoOptionChange() {
    if (!_isAutoOptionChanging) return;
    setState(() {
      _isAutoOptionChanging = false;
      _autoOptionRequireNextHit = false;
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
    if (!_canAttemptRemodelByCount) {
      _showSnack('개조가 불가능합니다.');
      return;
    }

    final grade = _pickWeightedString(
      _useGoldMoruForRemodel
          ? RandomAccessoryRepository.goldMoruGradeProbabilities
          : RandomAccessoryRepository.silverMoruGradeProbabilities,
      _random,
    );

    final remodelableCount = min(2, _currentOptions.length);
    final remodeledOptions = List<AccessoryOption>.generate(
      _currentOptions.length,
      (index) {
        final option = _currentOptions[index];
        if (index >= remodelableCount) {
          return option;
        }

        final minValue = option.minNormalValue;
        final maxValue = option.maxNormalValue;
        if (minValue == null || maxValue == null) {
          return option;
        }

        final range = _gradeRange(minValue, maxValue, grade);
        final rolled = _randInt(_random, range.$1, range.$2);
        return AccessoryOption(
          optionName: option.optionName,
          optionValue: rolled.toString(),
          minNormalValue: minValue,
          maxNormalValue: maxValue,
        );
      },
      growable: false,
    );

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
      _totalRemodelSoulStonesConsumed += _currentRemodelSoulStoneCost;
      _remodelAttemptCount++;
      _totalRemodelAttemptCount++;
      _syncSelectedOptionCount();
    });
  }

  bool _canRemodelCurrentAccessory() {
    if (_selectedAccessory?.randomOptionConfig == null ||
        _simulatedState == null) {
      return false;
    }
    final remodelableCount = min(2, _currentOptions.length);
    if (remodelableCount == 0) {
      return false;
    }
    for (int index = 0; index < remodelableCount; index++) {
      final option = _currentOptions[index];
      if (option.minNormalValue == null || option.maxNormalValue == null) {
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
    final displayOptions = _simulatedState?.accessory.id == accessory?.id
        ? _currentOptions
        : (accessory?.options ?? const <AccessoryOption>[]);
    // 행 수는 원본 옵션 수로 고정 (제작 결과 옵션 수 변화에도 레이아웃 유지)
    final fixedRowCount = accessory?.options.length ?? displayOptions.length;
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
                  if (fixedRowCount > 0) ...[
                    const SizedBox(height: 8),
                    // 헤더 행
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '수치',
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 64,
                            child: Text(
                              '등장 범위',
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: List.generate(fixedRowCount, (i) {
                        final baseOption = i < (accessory?.options.length ?? 0)
                            ? accessory!.options[i]
                            : null;
                        // 등장 여부: baseOption의 이름이 displayOptions에 있는지 확인
                        final appearedOption = baseOption == null
                            ? null
                            : displayOptions
                                .where((o) =>
                                    o.optionName == baseOption.optionName)
                                .firstOrNull;
                        final appeared = appearedOption != null;
                        final minVal = baseOption?.minNormalValue;
                        final maxVal = baseOption?.maxNormalValue;
                        final hasRange = minVal != null && maxVal != null;
                        // 등장 시 등급 색상
                        final grade = _simulatedState?.grade;
                        final highlightColor = appeared
                            ? _borderColorForGrade(grade, Theme.of(context))
                                .withOpacity(0.18)
                            : null;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          decoration: highlightColor != null
                              ? BoxDecoration(
                                  color: highlightColor,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  baseOption?.optionName ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: appeared
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                        color: appeared
                                            ? _borderColorForGrade(
                                                grade, Theme.of(context))
                                            : null,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  appeared
                                      ? _formatOptionValueForSummary(
                                          appearedOption)
                                      : '-',
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: appeared
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                        color: appeared
                                            ? _borderColorForGrade(
                                                grade, Theme.of(context))
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  hasRange ? '$minVal~$maxVal' : '-',
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _selectAccessory(context),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('악세 선택'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
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
        final nextMode = value.first;
        setState(() {
          if (_selectedMode == AccessorySimulationMode.optionChange &&
              nextMode != AccessorySimulationMode.optionChange) {
            _isAutoOptionChanging = false;
          }
          _selectedMode = nextMode;
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
          ..._craftLogs
              .take(_maxCraftLogCount)
              .map((entry) => _buildCraftLogCard(context, entry)),
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

    final targetOptionNames = _autoTargetOptionNames();
    final selectedTargetName = targetOptionNames.contains(_autoOptionTargetName)
        ? _autoOptionTargetName
        : null;
    final canChangeThird = _currentOptions.length >= 3 &&
        ((_selectedAccessory?.randomOptionConfig != null) ||
            _baseOptions.length < 3);
    final canChangeFourth = _currentOptions.length >= 4;
    final autoChangeCard = _buildAutoOptionChangeCard(
      context,
      targetOptionNames: targetOptionNames,
      selectedTargetName: selectedTargetName,
      canChangeThird: canChangeThird,
      canChangeFourth: canChangeFourth,
    );

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
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 150,
                      maxWidth: 240,
                    ),
                    child: _buildOptionChangeCostCard(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: autoChangeCard),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionChangeCostCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('소모 재화', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text('영혼석: ${_numberFormat.format(_totalSoulStonesConsumed)}개'),
            Text('숫돌이: ${_numberFormat.format(_totalGrindstonesConsumed)}개'),
            Text(
                '무지개 모루: ${_numberFormat.format(_totalRainbowAnvilsConsumed)}개'),
            Text(
                '3옵 9강 악세: ${_numberFormat.format(_total9EnhanceAccessoriesConsumed)}개'),
          ],
        ),
      ),
    );
  }

  Future<void> _showAutoOptionTargetMenu(
    BuildContext buttonContext,
    List<String> targetOptionNames,
  ) async {
    if (_isAutoOptionChanging || targetOptionNames.isEmpty) {
      return;
    }

    final overlayBox =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox?;
    final buttonBox = buttonContext.findRenderObject() as RenderBox?;
    if (overlayBox == null || buttonBox == null) {
      return;
    }

    final buttonTopLeft =
        buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final buttonBottomRight = buttonBox.localToGlobal(
      buttonBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    final menuWidth = buttonBox.size.width.clamp(120.0, 180.0);
    final menuHeight = min(300.0, targetOptionNames.length * 40.0 + 16.0);
    final left = (buttonBottomRight.dx - menuWidth).clamp(
      0.0,
      overlayBox.size.width - menuWidth,
    );
    final right = overlayBox.size.width - left - menuWidth;
    final top = (buttonTopLeft.dy - menuHeight).clamp(
      0.0,
      overlayBox.size.height - buttonBox.size.height,
    );

    final selected = await showMenu<String>(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
        left,
        top,
        right,
        overlayBox.size.height - buttonTopLeft.dy,
      ),
      items: targetOptionNames
          .map(
            (name) => PopupMenuItem<String>(
              value: name,
              height: 36,
              child: SizedBox(
                width: menuWidth - 16,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );

    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _autoOptionTargetName = selected;
    });
  }

  Widget _buildAutoOptionChangeCard(
    BuildContext context, {
    required List<String> targetOptionNames,
    required String? selectedTargetName,
    required bool canChangeThird,
    required bool canChangeFourth,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('자동 변경', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            SegmentedButton<int>(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: [
                ButtonSegment<int>(
                  value: 3,
                  label: const Text('3옵'),
                  enabled: canChangeThird,
                ),
                ButtonSegment<int>(
                  value: 4,
                  label: const Text('4옵'),
                  enabled: canChangeFourth,
                ),
              ],
              selected: {_autoOptionTargetSlot},
              onSelectionChanged: (value) {
                if (_isAutoOptionChanging) return;
                setState(() {
                  _autoOptionTargetSlot = value.first;
                  final nextOptions = _autoTargetOptionNames();
                  if (!nextOptions.contains(_autoOptionTargetName)) {
                    _autoOptionTargetName = null;
                  }
                });
              },
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 120,
                  maxWidth: 180,
                ),
                child: Builder(
                  builder: (buttonContext) {
                    final enabled = !_isAutoOptionChanging &&
                        targetOptionNames.isNotEmpty;
                    final displayText = selectedTargetName ?? '옵션 선택';
                    final colorScheme = Theme.of(context).colorScheme;

                    return InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: enabled
                          ? () => _showAutoOptionTargetMenu(
                                buttonContext,
                                targetOptionNames,
                              )
                          : null,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                displayText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: enabled
                                    ? null
                                    : TextStyle(
                                        color: colorScheme.onSurface
                                            .withAlpha(140),
                                      ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: enabled
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface.withAlpha(110),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        _isAutoOptionChanging ? null : _startAutoOptionChange,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('시작'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isAutoOptionChanging ? _stopAutoOptionChange : null,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('중지'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '자동 시도 횟수: ${_numberFormat.format(_autoOptionChangeAttempts)}회',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isAutoOptionChanging = false;
    super.dispose();
  }

  Widget _buildOptionRowByIndex(int index) {
    final theme = Theme.of(context);
    final currentOptionCount = _currentOptions.length;
    final baseOptionCount = _baseOptions.length;
    final isRandomAccessory = _selectedAccessory?.randomOptionConfig != null;
    final slot = index + 1;
    final isFilled = index < currentOptionCount;
    final isBaseSlot = index < baseOptionCount;
    final isRandomThirdChangeableSlot =
        isRandomAccessory && index == 2 && isFilled;
    final useFixedSlotStyle = isBaseSlot && !isRandomThirdChangeableSlot;

    String optionName = '비어있음';
    String optionValue = '';
    Color? optionColor = theme.hintColor;
    String? actionLabel;
    VoidCallback? action;

    if (isFilled) {
      optionName = _currentOptions[index].optionName;
      optionValue = _formatOptionValueWithRange(_currentOptions[index]);
      optionColor =
          useFixedSlotStyle ? Colors.grey : theme.textTheme.bodyLarge?.color;

      if (index == 2 && (!isBaseSlot || isRandomAccessory)) {
        actionLabel = '변경';
        action = () => _handleOptionChangeAction(
              AccessorySimulationOptionChangeAction.changeThird,
            );
      } else if (!isBaseSlot && index == 3) {
        actionLabel = '변경';
        action = () => _handleOptionChangeAction(
              AccessorySimulationOptionChangeAction.changeFourth,
            );
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
          SizedBox(width: 48, child: Text('$slot옵')),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: useFixedSlotStyle
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
                _buildSimpleCostCard(_currentRemodelCost),
                const SizedBox(height: 6),
                Text(
                  '개조 횟수: $_remodelAttemptCount/15',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _resetRemodelAttemptCount,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('개조 횟수 초기화'),
                  ),
                ),
                if (!_canAttemptRemodelByCount)
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: '개조가 '),
                        TextSpan(
                          text: '불가능',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const TextSpan(text: ' 합니다.'),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        _canAttemptRemodelByCount ? _performRemodel : null,
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
                Text(
                    '개조 횟수: ${_numberFormat.format(_totalRemodelAttemptCount)}회'),
                Text('은모루: ${_numberFormat.format(_silverMoruConsumed)}개'),
                Text('금모루: ${_numberFormat.format(_goldMoruConsumed)}개'),
                Text('골드: ${_numberFormat.format(_totalRemodelGoldConsumed)}'),
                Text(
                    '영혼석: ${_numberFormat.format(_totalRemodelSoulStonesConsumed)}개'),
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
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAccessoryIcon(
              imageUrl: state.accessory.imageUrl,
              grade: state.grade,
              size: 56,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
        _saveLastSelectedAccessory(entry.accessory.id);
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    option.optionName,
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 112,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: _buildOptionValueWidget(context, option),
                  ),
                ),
              ],
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
    final text = option.optionValue;
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final baseFontSize = baseStyle?.fontSize ?? 14;
    return SizedBox(
      height: 22,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (isMaxRoll
                  ? baseStyle?.copyWith(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w900,
                      fontSize: baseFontSize + 1,
                      height: 1.0,
                    )
                  : baseStyle)
              ?.copyWith(height: 1.0),
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
    if (option.optionValue == '$minValue~$maxValue') {
      return option.optionValue;
    }
    return '${option.optionValue} ($minValue~$maxValue)';
  }

  String _formatOptionValueForSummary(AccessoryOption option) {
    final minValue = option.minNormalValue;
    final maxValue = option.maxNormalValue;
    if (minValue != null && maxValue != null) {
      if (option.optionValue == '$minValue~$maxValue') {
        return option.optionValue;
      }
      return option.optionValue;
    }
    return option.optionValue;
  }

  bool _isMaxRollOption(AccessoryOption option) {
    final maxValue = option.maxNormalValue;
    final currentValue = int.tryParse(option.optionValue);
    return maxValue != null && currentValue != null && currentValue == maxValue;
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
