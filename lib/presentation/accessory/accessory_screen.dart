import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/accessory.dart';
import '../../core/constants/accessory_constants.dart';
import 'accessory_screen_ui.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/liquid_glass.dart';
import '../../core/constants/box_constants.dart';
import '../../core/services/settings_service.dart';
import '../simulator/accessory_simulation_screen.dart';

class AccessoryScreen extends StatefulWidget {
  final bool isPickerMode;
  final String collectionTitle;
  final String pickerTitle;
  final AppScreen currentScreen;

  const AccessoryScreen({
    super.key,
    this.isPickerMode = false,
    this.collectionTitle = '악세사리 도감',
    this.pickerTitle = '악세사리 선택',
    this.currentScreen = AppScreen.accessory,
  });

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const Duration _searchDebounceDelay = Duration(milliseconds: 150);

  String? _selectedPartFilter;
  String _selectedOptionTypeFilter = '전체';
  bool _selectedSetOnlyFilter = false;
  String _searchQuery = "";
  final List<String> _optionTypeFilterOptions = ['전체', '고정옵션', '랜덤옵션'];

  // 비교 모드 상태
  bool _compareMode = false;
  final List<Accessory> _compareList = [];
  bool _isAccessoryDataLoading = false;
  Timer? _accessoryReloadTimer;
  Timer? _searchDebounceTimer;
  bool _showMaxEnhancementValues = true;

  @override
  void initState() {
    super.initState();
    _ensureAccessoryDataReady();
    _startAccessoryRecoveryPolling();
  }

  Future<void> _ensureAccessoryDataReady() async {
    if (_isAccessoryDataLoading) return;

    final manager = AccessoryDataManager();
    if (manager.allAccessories.isNotEmpty) {
      return;
    }

    setState(() {
      _isAccessoryDataLoading = true;
    });

    const retryDelays = [200, 500, 900, 1300];
    for (int i = 0; i < retryDelays.length; i++) {
      await manager.loadAccessories(waitForRemote: true);
      if (manager.allAccessories.isNotEmpty) {
        break;
      }
      await Future<void>.delayed(Duration(milliseconds: retryDelays[i]));
    }

    if (!mounted) return;

    setState(() {
      _isAccessoryDataLoading = false;
    });
  }

  void _startAccessoryRecoveryPolling() {
    _accessoryReloadTimer?.cancel();
    _accessoryReloadTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;
        final hasData = AccessoryDataManager().allAccessories.isNotEmpty;
        if (hasData) {
          _accessoryReloadTimer?.cancel();
          if (_isAccessoryDataLoading) {
            setState(() {
              _isAccessoryDataLoading = false;
            });
          } else {
            setState(() {});
          }
          return;
        }
        _ensureAccessoryDataReady();
      },
    );
  }

  @override
  void dispose() {
    _accessoryReloadTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _commitSearchQuery(String value) {
    final nextQuery = value.trim();
    if (!mounted || _searchQuery == nextQuery) return;

    setState(() {
      _searchQuery = nextQuery;
    });
  }

  void _applySearchQuery(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      if (!mounted) return;
      _commitSearchQuery(_searchController.text);
    });
  }

  void _submitSearchNow(String value) {
    _searchDebounceTimer?.cancel();
    _commitSearchQuery(value);
  }

  void _handlePartFilterChanged(String? newValue) {
    setState(() {
      _selectedPartFilter = newValue;
    });
  }

  void _handleOptionTypeFilterChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedOptionTypeFilter = newValue;
    });
  }

  void _handleSetOnlyFilterChanged(bool enabled) {
    setState(() {
      _selectedSetOnlyFilter = enabled;
    });
  }

  void _showAccessoryDetails(BuildContext context, Accessory accessory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AccessoryDetailDialog(
          accessory: accessory,
          parentContext: this.context,
          initialEnhancementLevel: _showMaxEnhancementValues ? 9 : 0,
          showMaxSetOptionValues: _showMaxEnhancementValues,
        );
      },
    );
  }

  int _scriptRank(String value) {
    final trimmed = value.trimLeft();
    if (trimmed.isEmpty) return 2;

    for (final codePoint in trimmed.runes) {
      final ch = String.fromCharCode(codePoint);
      if (RegExp(r'[\u4E00-\u9FFF\u3400-\u4DBF\uF900-\uFAFF]').hasMatch(ch)) {
        return 0; // Han first
      }
      if (RegExp(r'[A-Za-z]').hasMatch(ch)) {
        return 1; // Latin second
      }
      if (ch.trim().isNotEmpty) {
        return 2; // Others
      }
    }
    return 2;
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^0-9a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]'), '');
  }

  Set<String> _searchAliasesForTarget(String target) {
    final normalized = _normalizeSearchText(target);
    final aliases = <String>{normalized};

    if (normalized == '관통확률저항증가') {
      aliases.addAll({'관저'});
    }
    if (normalized == '관통확률증가') {
      aliases.addAll({'관증'});
    }
    if (normalized == '체력증가') {
      aliases.addAll({'체증'});
    }
    if (normalized == '공격스킬피해증가') {
      aliases.addAll({'스증'});
    }
    if (normalized == '미니게임스킬피해증가') {
      aliases.addAll({'미겜증'});
    }
    if (normalized == '지속피해증가') {
      aliases.addAll({'지피증'});
    }
    if (normalized == '모든나쁜효과저항증가') {
      aliases.addAll({'모나저'});
    }
    if (normalized == '스킬쿨타임증가저항증가') {
      aliases.addAll({'스쿨저'});
    }
    if (normalized == '크리티컬증가') {
      aliases.addAll({'크증'});
    }
    if (normalized == '크리티컬저항증가') {
      aliases.addAll({'크저', '크리티컬저항'});
    }
    if (normalized == '크리티컬데미지증가') {
      aliases.addAll({'크뎀', '크뎀증'});
    }
    if (normalized == '회피증가') {
      aliases.addAll({'닷지'});
    }
    if (normalized == '명중증가') {
      aliases.addAll({'힛'});
    }
    if (normalized == '매턴체력회복') {
      aliases.addAll({'매체회'});
    }
    if (normalized == '모든피해감소') {
      aliases.addAll({'모피감'});
    }

    return aliases;
  }

  bool _matchesSearchQuery(String query, Accessory accessory) {
    if (query.isEmpty) {
      return true;
    }

    final normalizedQuery = _normalizeSearchText(query);

    final searchTargets = <String>[
      accessory.name,
      accessory.id,
      accessory.part,
      ...accessory.options.expand((option) => [
            option.optionName,
            option.optionValue,
          ]),
    ];

    for (final target in searchTargets) {
      final lowerTarget = target.toLowerCase();
      if (lowerTarget.contains(query)) {
        return true;
      }

      final normalizedTarget = _normalizeSearchText(target);
      if (normalizedQuery.isNotEmpty &&
          normalizedTarget.contains(normalizedQuery)) {
        return true;
      }

      if (normalizedQuery.isNotEmpty) {
        for (final alias in _searchAliasesForTarget(target)) {
          if (alias.contains(normalizedQuery)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Accessory> accessories = AccessoryDataManager().allAccessories;
    final parts = accessories
        .map((a) => a.part)
        .where((part) => part.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final partFilterOptions = ['전체', ...parts];

    // 필터링 로직을 적용합니다.
    final query = _searchQuery.trim().toLowerCase();
    List<Accessory> displayList = accessories.where((acc) {
      final bool matchesSearch = _matchesSearchQuery(query, acc);

      final matchesPart = _selectedPartFilter == null ||
          _selectedPartFilter == '전체' ||
          acc.part == _selectedPartFilter;

      final bool isRandom = acc.randomOptionConfig != null;
      final bool hasSetOptions = acc.setOptions.isNotEmpty;
      final bool matchesType = _selectedOptionTypeFilter == '전체' ||
          (_selectedOptionTypeFilter == '고정옵션' && !isRandom) ||
          (_selectedOptionTypeFilter == '랜덤옵션' && isRandom);
      final bool matchesSet = !_selectedSetOnlyFilter || hasSetOptions;

      return matchesSearch && matchesPart && matchesType && matchesSet;
    }).toList();

    // 기본 정렬: tam 최우선 -> 한자 -> 영문 알파벳 -> 기타, 그룹 내 id 순
    displayList.sort((a, b) {
      if (a.id.toLowerCase() == 'tam') return -1;
      if (b.id.toLowerCase() == 'tam') return 1;
      final rankA = _scriptRank(a.id);
      final rankB = _scriptRank(b.id);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.id.compareTo(b.id);
    });

    return Scaffold(
      drawer: AppDrawer(currentScreen: widget.currentScreen),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: 46,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 20),
            tooltip: '메뉴',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            style: IconButton.styleFrom(
              minimumSize: const Size(34, 34),
              fixedSize: const Size(34, 34),
              padding: EdgeInsets.zero,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withAlpha(160),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(52),
              ),
            ),
          ),
        ),
        title: Text(
          widget.isPickerMode ? widget.pickerTitle : widget.collectionTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (!widget.isPickerMode) ...[
            ValueListenableBuilder<ThemeMode>(
              valueListenable: SettingsService.instance.themeModeNotifier,
              builder: (context, themeMode, _) {
                final isDark = themeMode == ThemeMode.dark;
                return IconButton(
                  tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
                  onPressed: () {
                    final nextSettings = SettingsService.instance.appSettings
                        .copyWith(isDarkModeEnabled: !isDark);
                    SettingsService.instance.saveAppSettings(nextSettings);
                  },
                  icon: Icon(
                    isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(34, 34),
                    fixedSize: const Size(34, 34),
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withAlpha(160),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color:
                          Theme.of(context).colorScheme.outline.withAlpha(52),
                    ),
                  ),
                );
              },
            ),
            if (_compareMode && _compareList.length == 2)
              TextButton.icon(
                onPressed: _showCompareDialog,
                icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                label: const Text('비교'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor:
                      Theme.of(context).colorScheme.surface.withAlpha(150),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                _compareMode ? Icons.close_rounded : Icons.compare_rounded,
                size: 18,
              ),
              tooltip: _compareMode ? '비교 모드 끄기' : '비교 모드 켜기',
              onPressed: () {
                setState(() {
                  _compareMode = !_compareMode;
                  _compareList.clear();
                });
              },
              style: IconButton.styleFrom(
                minimumSize: const Size(34, 34),
                fixedSize: const Size(34, 34),
                padding: EdgeInsets.zero,
                backgroundColor:
                    Theme.of(context).colorScheme.surface.withAlpha(160),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(52),
                ),
              ),
            ),
          ],
        ],
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: AccessoryScreenUI(
            searchController: _searchController,
            filteredAccessories: displayList,
            isDataLoading: _isAccessoryDataLoading,
            hasSourceData: accessories.isNotEmpty,
            selectedPartFilter: _selectedPartFilter,
            partFilterOptions: partFilterOptions,
            onPartFilterChanged: _handlePartFilterChanged,
            selectedOptionTypeFilter: _selectedOptionTypeFilter,
            optionTypeFilterOptions: _optionTypeFilterOptions,
            onOptionTypeFilterChanged: _handleOptionTypeFilterChanged,
            selectedSetOnlyFilter: _selectedSetOnlyFilter,
            onSetOnlyFilterChanged: _handleSetOnlyFilterChanged,
            onAccessoryTap: (ctx, acc) {
              if (widget.isPickerMode) {
                AccessoryDataManager().markAccessoryAsRecentlyUsed(acc.id);
                Navigator.of(context).pop(acc);
              } else if (_compareMode) {
                setState(() {
                  if (_compareList.contains(acc)) {
                    _compareList.remove(acc);
                  } else if (_compareList.length < 2) {
                    _compareList.add(acc);
                  } else {
                    _compareList[1] = acc;
                  }
                });
              } else {
                AccessoryDataManager().markAccessoryAsRecentlyUsed(acc.id);
                _showAccessoryDetails(ctx, acc);
              }
            },
            onSubmitSearch: _applySearchQuery,
            onSearchSubmitted: _submitSearchNow,
            compareMode: _compareMode,
            compareList: _compareList,
            onRetryLoad: _ensureAccessoryDataReady,
            showMaxEnhancementValues: _showMaxEnhancementValues,
            onShowMaxEnhancementValuesChanged: (value) {
              setState(() {
                _showMaxEnhancementValues = value;
              });
            },
          ),
        ),
      ),
    );
  }

  void _showCompareDialog() {
    if (_compareList.length != 2) return;
    showDialog(
      context: context,
      builder: (_) => _AccessoryCompareDialog(
        a: _compareList[0],
        b: _compareList[1],
        initialEnhancementLevel: _showMaxEnhancementValues ? 9 : 0,
      ),
    );
  }

  // 세트 빌더 - 추후 재추가 예정
  // void _showSetBuilderDialog() {
  //   final accessories = AccessoryDataManager().allAccessories;
  //   if (accessories.isEmpty) return;
  //   showDialog(
  //     context: context,
  //     builder: (_) => _AccessorySetBuilderDialog(allAccessories: accessories),
  //   );
  // }
}

// 세트 옵션 단계 네비게이션을 지원하는 상세 다이얼로그
class _AccessoryDetailDialog extends StatefulWidget {
  final Accessory accessory;
  final BuildContext parentContext;
  final int initialEnhancementLevel;
  final bool showMaxSetOptionValues;

  const _AccessoryDetailDialog({
    required this.accessory,
    required this.parentContext,
    required this.initialEnhancementLevel,
    this.showMaxSetOptionValues = false,
  });

  @override
  State<_AccessoryDetailDialog> createState() => _AccessoryDetailDialogState();
}

class _AccessoryDetailDialogState extends State<_AccessoryDetailDialog> {
  late Map<String, int>
      _stageIndexMap; // 각 세트 옵션의 현재 단계 인덱스 저장 (setId -> stageIndex)
  // 공통 단계 인덱스 (세트 옵션이 2개일 때 통합 제어에 사용)
  int _sharedStageIndex = 0;
  late int _enhancementLevel;

  void _openLinkedAccessoryDetail(String accessoryIdOrName) {
    final query = accessoryIdOrName.trim();
    if (query.isEmpty) return;

    final allAccessories = AccessoryDataManager().allAccessories;
    Accessory? target;
    for (final accessory in allAccessories) {
      if (accessory.id == query || accessory.name == query) {
        target = accessory;
        break;
      }
    }
    if (target == null) return;

    Navigator.of(context).pop();
    showDialog(
      context: widget.parentContext,
      builder: (BuildContext context) {
        return _AccessoryDetailDialog(
          accessory: target!,
          parentContext: widget.parentContext,
          initialEnhancementLevel: widget.initialEnhancementLevel,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 각 세트 옵션별로 초기 단계 (0단계)를 설정합니다.
    _stageIndexMap = {};
    _enhancementLevel = widget.initialEnhancementLevel.clamp(0, 9);
    for (var setOption in widget.accessory.setOptions) {
      _stageIndexMap[setOption.setId] =
          widget.showMaxSetOptionValues ? setOption.maxStage : 0;
    }
    if (widget.showMaxSetOptionValues) {
      _sharedStageIndex = widget.accessory.setOptions
          .map((s) => s.maxStage)
          .fold<int>(0, (prev, cur) => cur > prev ? cur : prev);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedOptions =
        widget.accessory.optionsAtEnhancementLevel(_enhancementLevel);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 360 ? 300 : 320,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.accessory.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(widget.parentContext).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AccessorySimulationScreen(
                              initialAccessory: widget.accessory,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('시뮬레이터'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withAlpha(30)
                              : Colors.black.withAlpha(20),
                        ),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.accessory.imageUrl,
                        height: 150,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          height: 150,
                          child: Icon(Icons.broken_image,
                              size: 80, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('부위', widget.accessory.part),
                      _buildDetailRow('착용 제한', widget.accessory.restrictions),
                      const Divider(),
                      if (widget.accessory.hasEnhancementStageBonuses) ...[
                        Row(
                          children: [
                            const Text('강화 단계',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('$_enhancementLevel강',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        Slider(
                          value: _enhancementLevel.toDouble(),
                          min: 0,
                          max: 9,
                          divisions: 9,
                          label: '$_enhancementLevel강',
                          onChanged: (value) {
                            setState(() {
                              _enhancementLevel = value.round();
                            });
                          },
                        ),
                      ] else
                        Text(
                          '강화 단계별 수치 정보 없음',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      const Text('기본 옵션',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...displayedOptions.map((option) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                                '${option.optionName}: ${option.optionValue}'),
                          )),
                      if (widget.accessory.setOptions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        Text(
                          '세트 옵션 : ${widget.accessory.setOptions.map((s) => s.setName).join(' / ')}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFFB38A)
                                : Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.accessory.setOptions.length == 2) ...[
                          Builder(builder: (context) {
                            final sharedMaxStage = widget
                                .accessory.setOptions
                                .map((s) => s.maxStage)
                                .fold<int>(
                                    0, (prev, cur) => cur > prev ? cur : prev);
                            return Column(
                              children: [
                                Text('$_sharedStageIndex단계',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Slider(
                                  value: _sharedStageIndex
                                      .clamp(0, sharedMaxStage)
                                      .toDouble(),
                                  min: 0,
                                  max: sharedMaxStage.toDouble(),
                                  divisions:
                                      sharedMaxStage > 0 ? sharedMaxStage : null,
                                  label: '$_sharedStageIndex단계',
                                  onChanged: sharedMaxStage > 0
                                      ? (value) {
                                          setState(() {
                                            _sharedStageIndex = value.round();
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 8),
                          ...widget.accessory.setOptions.map((setOption) {
                            int currentStageIndex = _sharedStageIndex;
                            final theme = Theme.of(context);
                            final bool setIsDark =
                                theme.brightness == Brightness.dark;
                            final cardColor = setIsDark
                                ? const Color(0xFF121A25)
                                : const Color(0xFFFDF0E7);
                            final borderColor = setIsDark
                                ? Colors.white.withAlpha(16)
                                : Colors.orange.withAlpha(90);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(setOption.setName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color:
                                                theme.colorScheme.onSurface)),
                                    const SizedBox(height: 6),
                                    if (setOption
                                        .requiredAccessoryImages.isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        height: 78,
                                        alignment: Alignment.center,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: setOption
                                                .requiredAccessoryImages
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final imageIndex = entry.key;
                                              final imageUrl = entry.value;
                                              final linkedAccessory = imageIndex <
                                                      setOption
                                                          .requiredAccessories
                                                          .length
                                                  ? setOption
                                                          .requiredAccessories[
                                                      imageIndex]
                                                  : '';

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6.0),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: linkedAccessory.isEmpty
                                                      ? null
                                                      : () =>
                                                          _openLinkedAccessoryDetail(
                                                              linkedAccessory),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: CachedNetworkImage(
                                                      imageUrl: imageUrl,
                                                      width: 54,
                                                      height: 54,
                                                      fit: BoxFit.contain,
                                                      placeholder: (context,
                                                              url) =>
                                                          const Center(
                                                              child:
                                                                  CircularProgressIndicator()),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 24,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    ...setOption.effects.map((effect) {
                                      final currentValue =
                                          _resolveSparseStageValue(
                                              effect, currentStageIndex);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                effect.optionName,
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withAlpha(
                                                          (0.9 * 255).round()),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0,
                                                      horizontal: 7.0),
                                              decoration: BoxDecoration(
                                                color: setIsDark
                                                    ? Colors.white12
                                                    : theme.colorScheme.primary
                                                        .withAlpha((0.12 * 255)
                                                            .round()),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                currentValue,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ] else ...[
                          ...widget.accessory.setOptions.map((setOption) {
                            int currentStageIndex =
                                _stageIndexMap[setOption.setId] ?? 0;
                            final theme = Theme.of(context);
                            final bool setIsDark =
                                theme.brightness == Brightness.dark;
                            final cardColor = setIsDark
                                ? const Color(0xFF121A25)
                                : const Color(0xFFFDF0E7);
                            final borderColor = setIsDark
                                ? Colors.white.withAlpha(16)
                                : Colors.orange.withAlpha(90);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(setOption.setName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color:
                                                theme.colorScheme.onSurface)),
                                    const SizedBox(height: 8),
                                    if (setOption
                                        .requiredAccessoryImages.isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        height: 92,
                                        alignment: Alignment.center,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: setOption
                                                .requiredAccessoryImages
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final imageIndex = entry.key;
                                              final imageUrl = entry.value;
                                              final linkedAccessory = imageIndex <
                                                      setOption
                                                          .requiredAccessories
                                                          .length
                                                  ? setOption
                                                          .requiredAccessories[
                                                      imageIndex]
                                                  : '';

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  onTap: linkedAccessory.isEmpty
                                                      ? null
                                                      : () =>
                                                          _openLinkedAccessoryDetail(
                                                              linkedAccessory),
                                                  child: SizedBox(
                                                    width: 72,
                                                    height: 72,
                                                    child: Center(
                                                      child: CachedNetworkImage(
                                                        imageUrl: imageUrl,
                                                        width: 64,
                                                        height: 64,
                                                        fit: BoxFit.contain,
                                                        placeholder: (context,
                                                                url) =>
                                                            const Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 28,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    const SizedBox(height: 10),
                                    ...setOption.effects.map((effect) {
                                      final currentValue =
                                          _resolveSparseStageValue(
                                              effect, currentStageIndex);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                effect.optionName,
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withAlpha(
                                                          (0.9 * 255).round()),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                color: setIsDark
                                                    ? Colors.white12
                                                    : theme.colorScheme.primary
                                                        .withAlpha((0.12 * 255)
                                                            .round()),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                currentValue,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                    Text('$currentStageIndex단계',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    Slider(
                                      value: currentStageIndex
                                          .clamp(0, setOption.maxStage)
                                          .toDouble(),
                                      min: 0,
                                      max: setOption.maxStage.toDouble(),
                                      divisions: setOption.maxStage > 0
                                          ? setOption.maxStage
                                          : null,
                                      label: '$currentStageIndex단계',
                                      onChanged: setOption.maxStage > 0
                                          ? (value) {
                                              setState(() {
                                                _stageIndexMap[
                                                        setOption.setId] =
                                                    value.round();
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('닫기'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _resolveSparseStageValue(SetOptionEffect effect, int stage) {
    final exactValue = effect.stageValues[stage.toString()];
    if (exactValue != null && exactValue.isNotEmpty) {
      return exactValue;
    }

    final availableStages = effect.stageValues.keys
        .map(int.tryParse)
        .whereType<int>()
        .where((value) => value <= stage)
        .toList()
      ..sort();

    if (availableStages.isNotEmpty) {
      final fallbackValue = effect.stageValues[availableStages.last.toString()];
      if (fallbackValue != null && fallbackValue.isNotEmpty) {
        return fallbackValue;
      }
    }

    return effect.stageValues['0'] ?? '-';
  }
}

// 악세사리 비교 다이얼로그
class _AccessoryCompareDialog extends StatelessWidget {
  final Accessory a;
  final Accessory b;
  final int initialEnhancementLevel;

  const _AccessoryCompareDialog({
    required this.a,
    required this.b,
    required this.initialEnhancementLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 두 악세사리의 모든 옵션 이름 합집합
    final resolvedAOptions =
        a.optionsAtEnhancementLevel(initialEnhancementLevel);
    final resolvedBOptions =
        b.optionsAtEnhancementLevel(initialEnhancementLevel);
    final allOptionNames = <String>{
      ...resolvedAOptions.map((o) => o.optionName),
      ...resolvedBOptions.map((o) => o.optionName),
    }.toList();

    Map<String, String> aMap = {
      for (var o in resolvedAOptions) o.optionName: o.optionValue
    };
    Map<String, String> bMap = {
      for (var o in resolvedBOptions) o.optionName: o.optionValue
    };

    return AlertDialog(
      title:
          const Text('악세사리 비교', style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더 이미지 + 이름
              Row(
                children: [
                  _buildHeader(context, a),
                  const SizedBox(width: 8),
                  _buildHeader(context, b),
                ],
              ),
              if (initialEnhancementLevel > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '$initialEnhancementLevel강 적용 수치',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              const Divider(height: 16),
              // 기본 정보 비교
              _buildCompareRow(context, '부위', a.part, b.part, isDark),
              _buildCompareRow(
                  context, '착용 제한', a.restrictions, b.restrictions, isDark),
              if (allOptionNames.isNotEmpty) ...[
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('옵션 비교',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                ...allOptionNames.map((optName) {
                  final av = aMap[optName];
                  final bv = bMap[optName];
                  return _buildCompareRow(
                    context,
                    optName,
                    av ?? '없음',
                    bv ?? '없음',
                    isDark,
                    missingA: av == null,
                    missingB: bv == null,
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Accessory acc) {
    return Expanded(
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: acc.imageUrl,
            height: 60,
            fit: BoxFit.contain,
            placeholder: (_, __) => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 40),
          ),
          const SizedBox(height: 4),
          Text(
            acc.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompareRow(
    BuildContext context,
    String label,
    String valA,
    String valB,
    bool isDark, {
    bool missingA = false,
    bool missingB = false,
  }) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurface.withValues(alpha: 0.35);
    final highlightColor = theme.colorScheme.primary;
    // 수치 비교 (숫자 추출 후)
    final numA = double.tryParse(valA.replaceAll(RegExp(r'[^0-9.]'), ''));
    final numB = double.tryParse(valB.replaceAll(RegExp(r'[^0-9.]'), ''));
    final bool aWins = numA != null && numB != null && numA > numB;
    final bool bWins = numA != null && numB != null && numB > numA;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              valA,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: missingA ? dimColor : (aWins ? highlightColor : null),
                fontWeight: aWins ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              valB,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: missingB ? dimColor : (bWins ? highlightColor : null),
                fontWeight: bWins ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessorySetBuilderDialog extends StatefulWidget {
  final List<Accessory> allAccessories;

  const _AccessorySetBuilderDialog({required this.allAccessories});

  @override
  State<_AccessorySetBuilderDialog> createState() =>
      _AccessorySetBuilderDialogState();
}

class _AccessorySetBuilderDialogState
    extends State<_AccessorySetBuilderDialog> {
  late final List<String> _parts;
  late Map<String, Accessory?> _selectedByPart;
  int _setStage = 0;

  @override
  void initState() {
    super.initState();
    _parts = widget.allAccessories.map((e) => e.part).toSet().toList()..sort();
    _selectedByPart = {for (final part in _parts) part: null};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selectedByPart.values.whereType<Accessory>().toList();
    final optionSummary = _buildOptionSummary(selected);
    final setStatus = _buildSetStatus(selected);

    return AlertDialog(
      title: const Text('세트 빌더', style: TextStyle(fontWeight: FontWeight.bold)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('부위별 악세사리 선택', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ..._parts.map((part) {
                final partAcc = _selectedByPart[part];
                final partItems = widget.allAccessories
                    .where((a) => a.part == part)
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _showPartPickerSheet(context, part, partItems),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            child: Text(
                              part,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (partAcc != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: partAcc.imageUrl,
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                partAcc.name,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedByPart[part] = null),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(Icons.clear,
                                    size: 18, color: theme.hintColor),
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.add_circle_outline,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '선택 안함',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: theme.hintColor),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 18, color: theme.hintColor),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text('선택된 개수: ${selected.length}/${_parts.length}',
                  style: theme.textTheme.bodySmall),
              if (selected.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: selected
                      .map(
                        (acc) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: acc.imageUrl,
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 14),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(acc.name, style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const Divider(height: 20),
              Text('합산 옵션',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (optionSummary.isEmpty)
                Text('선택된 악세사리 옵션이 없습니다.', style: theme.textTheme.bodySmall)
              else
                ...optionSummary.take(12).map((row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(row.name,
                                  style: theme.textTheme.bodySmall)),
                          Text(row.displayValue,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )),
              const Divider(height: 20),
              Row(
                children: [
                  Text('세트 효과',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('단계: $_setStage', style: theme.textTheme.bodySmall),
                ],
              ),
              Slider(
                value: _setStage.toDouble(),
                min: 0,
                max: 18,
                divisions: 18,
                label: '$_setStage',
                onChanged: (v) => setState(() => _setStage = v.round()),
              ),
              if (setStatus.isEmpty)
                Text('관련 세트 옵션이 없습니다.', style: theme.textTheme.bodySmall)
              else
                ...setStatus.map((set) {
                  final color =
                      set.active ? Colors.green[700] : theme.hintColor;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                      color: set.active
                          ? theme.colorScheme.primary.withAlpha(20)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${set.setName} ${set.active ? '(발동)' : '(미발동)'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (!set.active && set.missingRequired.isNotEmpty)
                          Text(
                            '부족: ${set.missingRequired.join(', ')}',
                            style: theme.textTheme.bodySmall,
                          ),
                        const SizedBox(height: 4),
                        ...set.effects.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              '${e.optionName}: ${_resolveStageValue(e, _setStage)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  void _showPartPickerSheet(
      BuildContext context, String part, List<Accessory> partItems) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Text(
                        '$part 선택',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                        label: const Text('선택 안함'),
                        onPressed: () {
                          setState(() => _selectedByPart[part] = null);
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 90,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: partItems.length,
                    itemBuilder: (_, index) {
                      final acc = partItems[index];
                      final isSelected = _selectedByPart[part]?.id == acc.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedByPart[part] = acc);
                          Navigator.pop(sheetContext);
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(sheetContext)
                                          .colorScheme
                                          .primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: acc.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5)),
                                  ),
                                  errorWidget: (_, __, ___) => const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Icon(
                                        Icons.image_not_supported_outlined),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              acc.name,
                              style:
                                  Theme.of(sheetContext).textTheme.labelSmall,
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
  }

  List<_OptionSummary> _buildOptionSummary(List<Accessory> selected) {
    final sums = <String, double>{};
    final isPercent = <String, bool>{};

    for (final acc in selected) {
      for (final option in acc.options) {
        final value = _parseFirstNumber(option.optionValue);
        if (value == null) continue;
        sums[option.optionName] = (sums[option.optionName] ?? 0) + value;
        if (option.optionValue.contains('%')) {
          isPercent[option.optionName] = true;
        }
      }
    }

    final rows = sums.entries
        .map((e) => _OptionSummary(
              name: e.key,
              value: e.value,
              percent: isPercent[e.key] ?? false,
            ))
        .toList();
    rows.sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    return rows;
  }

  List<_SetStatus> _buildSetStatus(List<Accessory> selected) {
    final selectedKeys = <String>{
      ...selected.map((a) => a.id),
      ...selected.map((a) => a.name),
    };

    final map = <String, AccessorySetOption>{};
    for (final acc in selected) {
      for (final set in acc.setOptions) {
        map.putIfAbsent(set.setId, () => set);
      }
    }

    final result = <_SetStatus>[];
    for (final set in map.values) {
      final missing = set.requiredAccessories
          .where((req) => !selectedKeys.contains(req))
          .toList();
      result.add(_SetStatus(
        setName: set.setName,
        active: missing.isEmpty,
        missingRequired: missing,
        effects: set.effects,
      ));
    }
    result.sort((a, b) => b.active.toString().compareTo(a.active.toString()));
    return result;
  }

  String _resolveStageValue(SetOptionEffect effect, int stage) {
    final exactValue = effect.stageValues[stage.toString()];
    if (exactValue != null && exactValue.isNotEmpty) {
      return exactValue;
    }

    final availableStages = effect.stageValues.keys
        .map(int.tryParse)
        .whereType<int>()
        .where((value) => value <= stage)
        .toList()
      ..sort();

    if (availableStages.isNotEmpty) {
      return effect.stageValues[availableStages.last.toString()] ??
          effect.stageValues['0'] ??
          '-';
    }

    return effect.stageValues['0'] ?? '-';
  }

  double? _parseFirstNumber(String text) {
    final match =
        RegExp(r'[-+]?\d+(?:\.\d+)?').firstMatch(text.replaceAll(',', ''));
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }
}

class _OptionSummary {
  final String name;
  final double value;
  final bool percent;

  _OptionSummary({
    required this.name,
    required this.value,
    required this.percent,
  });

  String get displayValue {
    final rounded =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return percent ? '$rounded%' : rounded;
  }
}

class _SetStatus {
  final String setName;
  final bool active;
  final List<String> missingRequired;
  final List<SetOptionEffect> effects;

  _SetStatus({
    required this.setName,
    required this.active,
    required this.missingRequired,
    required this.effects,
  });
}
