import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/accessory.dart';
import '../../core/constants/accessory_constants.dart';
import '../../core/constants/random_accessory_constants.dart';
import 'accessory_screen_ui.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/box_constants.dart';
import '../simulator/random_accessory_simulator_screen.dart';

class AccessoryScreen extends StatefulWidget {
  final bool isPickerMode;
  const AccessoryScreen({super.key, this.isPickerMode = false});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedPartFilter;
  String _selectedOptionTypeFilter = '전체';
  String _searchQuery = "";
  String _searchOption = '이름';
  final List<String> _searchOptions = ['이름', '옵션'];
  final List<String> _optionTypeFilterOptions = ['전체', '고정옵션', '랜덤옵션'];

  // 비교 모드 상태
  bool _compareMode = false;
  final List<Accessory> _compareList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _handlePartFilterChanged(String? newValue) {
    setState(() {
      _selectedPartFilter = newValue;
    });
  }

  void _handleSearchOptionChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _searchOption = newValue;
      });
    }
  }

  void _handleOptionTypeFilterChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedOptionTypeFilter = newValue;
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  void _showAccessoryDetails(BuildContext context, Accessory accessory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AccessoryDetailDialog(accessory: accessory);
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
    List<Accessory> displayList = accessories.where((acc) {
      bool matchesSearch;
      if (_searchQuery.isEmpty) {
        matchesSearch = true;
      } else if (_searchOption == '이름') {
        matchesSearch =
            acc.name.toLowerCase().contains(_searchQuery.toLowerCase());
      } else if (_searchOption == '옵션') {
        matchesSearch = acc.options.any((option) =>
            option.optionName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            option.optionValue
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()));
      } else {
        matchesSearch = true;
      }

      final matchesPart = _selectedPartFilter == null ||
          _selectedPartFilter == '전체' ||
          acc.part == _selectedPartFilter;

      final bool isRandom = acc.randomOptionConfig != null;
      final bool matchesType = _selectedOptionTypeFilter == '전체' ||
          (_selectedOptionTypeFilter == '고정옵션' && !isRandom) ||
          (_selectedOptionTypeFilter == '랜덤옵션' && isRandom);

      return matchesSearch && matchesPart && matchesType;
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
      drawer: const AppDrawer(currentScreen: AppScreen.accessory),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(widget.isPickerMode ? '악세사리 선택' : '악세사리 도감'),
        actions: [
          if (!widget.isPickerMode) ...[
            if (_compareMode && _compareList.length == 2)
              TextButton.icon(
                onPressed: _showCompareDialog,
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('비교'),
              ),
            IconButton(
              icon: Icon(
                _compareMode ? Icons.close_rounded : Icons.compare_rounded,
              ),
              tooltip: _compareMode ? '비교 모드 끄기' : '비교 모드 켜기',
              onPressed: () {
                setState(() {
                  _compareMode = !_compareMode;
                  _compareList.clear();
                });
              },
            ),
          ],
        ],
      ),
      body: AccessoryScreenUI(
        searchController: _searchController,
        filteredAccessories: displayList,
        selectedPartFilter: _selectedPartFilter,
        partFilterOptions: partFilterOptions,
        onPartFilterChanged: _handlePartFilterChanged,
        selectedOptionTypeFilter: _selectedOptionTypeFilter,
        optionTypeFilterOptions: _optionTypeFilterOptions,
        onOptionTypeFilterChanged: _handleOptionTypeFilterChanged,
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
        currentSearchQuery: _searchQuery,
        onClearSearch: _clearSearch,
        searchOption: _searchOption,
        searchOptions: _searchOptions,
        onSearchOptionChanged: _handleSearchOptionChanged,
        compareMode: _compareMode,
        compareList: _compareList,
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
      ),
    );
  }

  // TODO: 세트 빌더 - 추후 재추가 예정
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

  const _AccessoryDetailDialog({required this.accessory});

  @override
  State<_AccessoryDetailDialog> createState() => _AccessoryDetailDialogState();
}

class _AccessoryDetailDialogState extends State<_AccessoryDetailDialog> {
  late Map<String, int>
      _stageIndexMap; // 각 세트 옵션의 현재 단계 인덱스 저장 (setId -> stageIndex)
  // 공통 단계 인덱스 (세트 옵션이 2개일 때 통합 제어에 사용)
  int _sharedStageIndex = 0;

  @override
  void initState() {
    super.initState();
    // 각 세트 옵션별로 초기 단계 (0단계)를 설정합니다.
    _stageIndexMap = {};
    for (var setOption in widget.accessory.setOptions) {
      _stageIndexMap[setOption.setId] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final randomConfig = widget.accessory.randomOptionConfig;
    return AlertDialog(
      title: Text(widget.accessory.name,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
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
                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('부위', widget.accessory.part),
            _buildDetailRow('착용 제한', widget.accessory.restrictions),
            const Divider(),
            const Text('기본 옵션', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.accessory.options.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text('${option.optionName}: ${option.optionValue}'),
                )),
            if (randomConfig != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RandomAccessorySimulatorScreen(
                          initialAccessory: widget.accessory,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('랜덤악세 시뮬레이터로 이동'),
                ),
              ),
            ],
            // 세트 옵션 표시
            if (widget.accessory.setOptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              Text(
                '세트 옵션 : ${widget.accessory.setOptions.map((s) => s.setName).join(' / ')}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              const SizedBox(height: 12),

              // 두 개의 세트 옵션이 있는 경우, 상하(수직) 배치 및 단계 컨트롤 통합
              if (widget.accessory.setOptions.length == 2) ...[
                // 통합 단계 컨트롤
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _sharedStageIndex > 0
                          ? () => setState(() => _sharedStageIndex--)
                          : null,
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Column(
                      children: [
                        Text('$_sharedStageIndex단계',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('단계값 표시',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.transparent)),
                      ],
                    ),
                    IconButton(
                      onPressed: _sharedStageIndex < 18
                          ? () => setState(() => _sharedStageIndex++)
                          : null,
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 두 세트를 위아래로 각각 컨테이너에 렌더
                ...widget.accessory.setOptions.map((setOption) {
                  // 공유 인덱스 사용
                  int currentStageIndex = _sharedStageIndex;

                  final theme = Theme.of(context);
                  final bool isDark = theme.brightness == Brightness.dark;
                  final cardColor =
                      isDark ? Colors.grey[850] : Colors.orange[50];
                  final borderColor =
                      isDark ? Colors.grey[700] : Colors.orange[300];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 세트 이름(각 컨테이너 상단)
                          Text(setOption.setName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),

                          // 이미지
                          if (setOption.requiredAccessoryImages.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 92,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: setOption.requiredAccessoryImages
                                      .map((imageUrl) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: SizedBox(
                                              width: 72,
                                              height: 72,
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.contain,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 28,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // 효과들을 '효과 : 수치' 형식으로 나열 (명칭/값 분리하여 가독성 향상)
                          ...setOption.effects.map((effect) {
                            final currentValue =
                                _resolveSparseStageValue(effect, currentStageIndex);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      effect.optionName,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withAlpha((0.9 * 255).round()),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white12
                                          : theme.colorScheme.primary
                                              .withAlpha((0.12 * 255).round()),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      currentValue,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                        fontSize: 13,
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
                // 세트 옵션이 1개 혹은 3개 이상일 때 기존 방식(각 세트별 개별 단계 컨트롤 유지)
                ...widget.accessory.setOptions.map((setOption) {
                  int currentStageIndex = _stageIndexMap[setOption.setId] ?? 0;

                  final theme = Theme.of(context);
                  final bool isDark = theme.brightness == Brightness.dark;
                  final cardColor =
                      isDark ? Colors.grey[850] : Colors.orange[50];
                  final borderColor =
                      isDark ? Colors.grey[700] : Colors.orange[300];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 세트 이름
                          Text(setOption.setName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          // 필요한 악세사리 이미지들 (가로 스크롤, 화면 전체 가운데 정렬)
                          if (setOption.requiredAccessoryImages.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 92,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: setOption.requiredAccessoryImages
                                      .map((imageUrl) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: SizedBox(
                                              width: 72,
                                              height: 72,
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  width: 64,
                                                  height: 64,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget:
                                                      (context, url, error) =>
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
                                          ))
                                      .toList(),
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(height: 10),
                          // 세트 효과들 (명칭/값 분리하여 가독성 향상)
                          ...setOption.effects.map((effect) {
                            final currentValue =
                                _resolveSparseStageValue(effect, currentStageIndex);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      effect.optionName,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withAlpha((0.9 * 255).round()),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white12
                                          : theme.colorScheme.primary
                                              .withAlpha((0.12 * 255).round()),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      currentValue,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 8),
                          // 개별 단계 컨트롤
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: currentStageIndex > 0
                                    ? () {
                                        setState(() {
                                          _stageIndexMap[setOption.setId] =
                                              currentStageIndex - 1;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.arrow_left),
                              ),
                              Text('$currentStageIndex단계',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              IconButton(
                                onPressed: currentStageIndex < 18
                                    ? () {
                                        setState(() {
                                          _stageIndexMap[setOption.setId] =
                                              currentStageIndex + 1;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.arrow_right),
                              ),
                            ],
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
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
}

// 악세사리 비교 다이얼로그
class _AccessoryCompareDialog extends StatelessWidget {
  final Accessory a;
  final Accessory b;

  const _AccessoryCompareDialog({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 두 악세사리의 모든 옵션 이름 합집합
    final allOptionNames = <String>{
      ...a.options.map((o) => o.optionName),
      ...b.options.map((o) => o.optionName),
    }.toList();

    Map<String, String> aMap = {
      for (var o in a.options) o.optionName: o.optionValue
    };
    Map<String, String> bMap = {
      for (var o in b.options) o.optionName: o.optionValue
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
    return effect.stageValues[stage.toString()] ??
        effect.stageValues['0'] ??
        '-';
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
