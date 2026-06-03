import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 패키지 import 필수
import '../../data/models/accessory.dart';

class AccessoryScreenUI extends StatelessWidget {
  final TextEditingController searchController;
  final List<Accessory> filteredAccessories;
  final String? selectedPartFilter;
  final List<String> partFilterOptions;
  final ValueChanged<String?> onPartFilterChanged;
  final String selectedOptionTypeFilter;
  final List<String> optionTypeFilterOptions;
  final ValueChanged<String?> onOptionTypeFilterChanged;
  final bool selectedSetOnlyFilter;
  final ValueChanged<bool> onSetOnlyFilterChanged;
  final Function(BuildContext, Accessory) onAccessoryTap;
  final String currentSearchQuery;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onSubmitSearch;
  final bool compareMode;
  final List<Accessory> compareList;
  final bool isDataLoading;
  final bool hasSourceData;
  final VoidCallback? onRetryLoad;
  final bool showMaxEnhancementValues;
  final ValueChanged<bool> onShowMaxEnhancementValuesChanged;

  const AccessoryScreenUI({
    super.key,
    required this.searchController,
    required this.filteredAccessories,
    required this.selectedPartFilter,
    required this.partFilterOptions,
    required this.onPartFilterChanged,
    required this.selectedOptionTypeFilter,
    required this.optionTypeFilterOptions,
    required this.onOptionTypeFilterChanged,
    required this.selectedSetOnlyFilter,
    required this.onSetOnlyFilterChanged,
    required this.onAccessoryTap,
    required this.currentSearchQuery,
    required this.onClearSearch,
    required this.onSubmitSearch,
    this.compareMode = false,
    this.compareList = const [],
    this.isDataLoading = false,
    this.hasSourceData = true,
    this.onRetryLoad,
    required this.showMaxEnhancementValues,
    required this.onShowMaxEnhancementValuesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        if (compareMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.compare_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    compareList.isEmpty
                        ? '비교할 악세사리를 최대 2개 선택하세요'
                        : compareList.length == 1
                            ? '${compareList[0].name} 선택됨 · 하나 더 선택하세요'
                            : '${compareList[0].name} vs ${compareList[1].name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '풀강 수치로 보기',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Switch.adaptive(
                        value: showMaxEnhancementValues,
                        onChanged: onShowMaxEnhancementValuesChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // --- 검색 + 필터 (토글 옆 작은 검색창 + 부위 칩) ---
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('고정옵션'),
                                showCheckmark: false,
                                selected: selectedOptionTypeFilter == '고정옵션',
                                selectedColor: colorScheme.primaryContainer,
                                backgroundColor:
                                    colorScheme.surface.withValues(alpha: 0.65),
                                side: BorderSide(
                                  color: selectedOptionTypeFilter == '고정옵션'
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withValues(alpha: 0.28),
                                  width:
                                      selectedOptionTypeFilter == '고정옵션' ? 1.3 : 1,
                                ),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: selectedOptionTypeFilter == '고정옵션'
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                      fontWeight:
                                          selectedOptionTypeFilter == '고정옵션'
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                    ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onSelected: (_) => onOptionTypeFilterChanged(
                                  selectedOptionTypeFilter == '고정옵션'
                                      ? '전체'
                                      : '고정옵션',
                                ),
                              ),
                              const SizedBox(width: 6),
                              FilterChip(
                                label: const Text('랜덤옵션'),
                                showCheckmark: false,
                                selected: selectedOptionTypeFilter == '랜덤옵션',
                                selectedColor: colorScheme.primaryContainer,
                                backgroundColor:
                                    colorScheme.surface.withValues(alpha: 0.65),
                                side: BorderSide(
                                  color: selectedOptionTypeFilter == '랜덤옵션'
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withValues(alpha: 0.28),
                                  width:
                                      selectedOptionTypeFilter == '랜덤옵션' ? 1.3 : 1,
                                ),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: selectedOptionTypeFilter == '랜덤옵션'
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                      fontWeight:
                                          selectedOptionTypeFilter == '랜덤옵션'
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                    ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onSelected: (_) => onOptionTypeFilterChanged(
                                  selectedOptionTypeFilter == '랜덤옵션'
                                      ? '전체'
                                      : '랜덤옵션',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: Theme.of(context).dividerColor,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('세트'),
                                showCheckmark: false,
                                selected: selectedSetOnlyFilter,
                                selectedColor: colorScheme.primaryContainer,
                                backgroundColor:
                                  colorScheme.surface.withValues(alpha: 0.65),
                                side: BorderSide(
                                  color: selectedSetOnlyFilter
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(alpha: 0.28),
                                  width:
                                    selectedSetOnlyFilter ? 1.3 : 1,
                                ),
                                labelStyle: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: selectedSetOnlyFilter
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                    fontWeight:
                                      selectedSetOnlyFilter
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                onSelected: (_) => onSetOnlyFilterChanged(
                                  !selectedSetOnlyFilter,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: Theme.of(context).dividerColor,
                              ),
                              const SizedBox(width: 8),
                              ...partFilterOptions
                                  .where((part) => part != '전체')
                                  .map((part) {
                                final selected = selectedPartFilter == part;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    label: Text(part),
                                    showCheckmark: false,
                                    selected: selected,
                                    selectedColor: colorScheme.primaryContainer,
                                    backgroundColor: colorScheme.surface
                                        .withValues(alpha: 0.65),
                                    side: BorderSide(
                                      color: selected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface
                                              .withValues(alpha: 0.28),
                                      width: selected ? 1.3 : 1,
                                    ),
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: selected
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurface,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onSelected: (_) => onPartFilterChanged(
                                      selected ? null : part,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AnimatedAccessorySearchField(
                        controller: searchController,
                        currentSearchQuery: currentSearchQuery,
                        onClearSearch: onClearSearch,
                        onSubmitSearch: onSubmitSearch,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- 악세사리 리스트 (그리드 뷰) ---
        Expanded(
          child: isDataLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('악세사리 데이터를 불러오는 중...'),
                    ],
                  ),
                )
              : !hasSourceData
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '악세사리 데이터를 아직 불러오지 못했습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: onRetryLoad,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('다시 불러오기'),
                          ),
                        ],
                      ),
                    )
              : filteredAccessories.isEmpty
              ? Center(
                  child: Text("검색 결과가 없습니다.",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      )))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150, // 각 아이템의 최대 너비
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7, // 아이템 비율 조정
                  ),
                  itemCount: filteredAccessories.length,
                  itemBuilder: (context, index) {
                    final accessory = filteredAccessories[index];
                    final isSelected =
                        compareMode && compareList.contains(accessory);

                    return GestureDetector(
                      onTap: () => onAccessoryTap(context, accessory),
                      child: Stack(
                        children: [
                          Card(
                            clipBehavior: Clip.antiAlias, // 이미지가 카드의 경계를 넘지 않도록
                            elevation: isSelected ? 4 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2.5,
                                    )
                                  : BorderSide.none,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. 이미지 영역
                                Expanded(
                                  child: Container(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    padding: const EdgeInsets.all(6.0),
                                    child: CachedNetworkImage(
                                      imageUrl: accessory.imageUrl,
                                      fit: BoxFit.contain,
                                      memCacheWidth: 256,
                                      memCacheHeight: 256,
                                      maxWidthDiskCache: 256,
                                      maxHeightDiskCache: 256,
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                // 2. 텍스트 정보 영역
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 4.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        accessory.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        accessory.part,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (compareMode)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      )
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

}

class _AnimatedAccessorySearchField extends StatefulWidget {
  final TextEditingController controller;
  final String currentSearchQuery;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onSubmitSearch;

  const _AnimatedAccessorySearchField({
    required this.controller,
    required this.currentSearchQuery,
    required this.onClearSearch,
    required this.onSubmitSearch,
  });

  @override
  State<_AnimatedAccessorySearchField> createState() =>
      _AnimatedAccessorySearchFieldState();
}

class _AnimatedAccessorySearchFieldState
    extends State<_AnimatedAccessorySearchField> {
  static const _animationDuration = Duration(milliseconds: 220);

  final FocusNode _focusNode = FocusNode();
  bool _expanded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _expand() async {
    if (_expanded) {
      _focusNode.requestFocus();
      return;
    }
    setState(() {
      _expanded = true;
    });
    // TextField가 트리에 붙은 뒤 포커스를 요청해야 Android에서 키보드가 안정적으로 열린다.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    _focusNode.requestFocus();
    if (!_focusNode.hasFocus) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      _focusNode.requestFocus();
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    _focusNode.unfocus();
    setState(() {
      _expanded = false;
      _isSubmitting = true;
    });
    await Future<void>.delayed(_animationDuration);
    if (!mounted) return;
    widget.onSubmitSearch(widget.controller.text);
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collapsedSize = 36.0;
    final expandedWidth = MediaQuery.of(context).size.width < 420 ? 188.0 : 232.0;

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeOutCubic,
      width: _expanded ? expandedWidth : collapsedSize,
      height: collapsedSize,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _expanded
            ? colorScheme.surface
            : colorScheme.surface.withValues(alpha: 0.65),
        // AnimatedContainer에서 shape<->borderRadius 전환 시 assert가 발생할 수 있어
        // 항상 rectangle + 고정 라운드(18)로 유지한다. 36x36에서는 원형으로 보인다.
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.28),
          width: _expanded ? 1.3 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: _expanded ? BorderRadius.circular(18) : null,
          customBorder: _expanded ? null : const CircleBorder(),
          onTap: _expanded ? null : _expand,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 애니메이션 경계 프레임(열림 직전/닫힘 직후)에서도 안전하도록
              // 충분한 폭이 확보되기 전까지는 아이콘-only 레이아웃만 사용.
              // 188px(소형 기기)에서도 TextField가 렌더링되도록 임계값을 낮춘다.
              final compact = !_expanded || constraints.maxWidth < 150;
              if (compact) {
                return Center(
                  child: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: colorScheme.onSurface,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        onChanged: (v) {
                          if (mounted) {
                            setState(() {});
                            widget.onSubmitSearch(v);
                          }
                        },
                        onSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          hintText: '이름/옵션',
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (widget.controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: widget.onClearSearch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
