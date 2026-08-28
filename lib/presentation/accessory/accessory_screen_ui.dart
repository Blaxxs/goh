import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/widgets/liquid_glass.dart';
import '../../core/widgets/search_text_field.dart';
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
  final ValueChanged<String> onSubmitSearch;
  final ValueChanged<String> onSearchSubmitted;
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
    required this.onSubmitSearch,
    required this.onSearchSubmitted,
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
            margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF7CA4FF).withAlpha(90),
                        const Color(0xFF6F79FF).withAlpha(90),
                      ]
                    : [
                        const Color(0xFF8AB5FF).withAlpha(180),
                        const Color(0xFF7EA7FF).withAlpha(180),
                      ],
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    compareList.isEmpty
                        ? '비교할 악세사리를 최대 2개 선택하세요'
                        : compareList.length == 1
                            ? '${compareList[0].name} 선택됨 · 하나 더 선택하세요'
                            : '${compareList[0].name} vs ${compareList[1].name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: GlassPanel(
            padding: const EdgeInsets.all(12.0),
            borderRadius: BorderRadius.circular(24),
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
                SearchTextField(
                  controller: searchController,
                  hintText: '이름/옵션 검색 (예: 크리, 크뎀, 관저)',
                  onChanged: onSubmitSearch,
                  onSubmitted: onSearchSubmitted,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
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
                          width: selectedOptionTypeFilter == '고정옵션' ? 1.3 : 1,
                        ),
                        labelStyle:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: selectedOptionTypeFilter == '고정옵션'
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                  fontWeight: selectedOptionTypeFilter == '고정옵션'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (_) => onOptionTypeFilterChanged(
                          selectedOptionTypeFilter == '고정옵션' ? '전체' : '고정옵션',
                        ),
                      ),
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
                          width: selectedOptionTypeFilter == '랜덤옵션' ? 1.3 : 1,
                        ),
                        labelStyle:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: selectedOptionTypeFilter == '랜덤옵션'
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                  fontWeight: selectedOptionTypeFilter == '랜덤옵션'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (_) => onOptionTypeFilterChanged(
                          selectedOptionTypeFilter == '랜덤옵션' ? '전체' : '랜덤옵션',
                        ),
                      ),
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
                          width: selectedSetOnlyFilter ? 1.3 : 1,
                        ),
                        labelStyle:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: selectedSetOnlyFilter
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                  fontWeight: selectedSetOnlyFilter
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (_) =>
                            onSetOnlyFilterChanged(!selectedSetOnlyFilter),
                      ),
                      ...partFilterOptions
                          .where((part) => part != '전체')
                          .map((part) {
                        final selected = selectedPartFilter == part;
                        return FilterChip(
                          label: Text(part),
                          showCheckmark: false,
                          selected: selected,
                          selectedColor: colorScheme.primaryContainer,
                          backgroundColor:
                              colorScheme.surface.withValues(alpha: 0.65),
                          side: BorderSide(
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.28),
                            width: selected ? 1.3 : 1,
                          ),
                          labelStyle:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
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
                          onSelected: (_) =>
                              onPartFilterChanged(selected ? null : part),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withAlpha(8),
                        Colors.white.withAlpha(4),
                      ]
                    : [
                        Colors.white.withAlpha(110),
                        Colors.white.withAlpha(82),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(18)
                    : colorScheme.primary.withAlpha(26),
                width: 1,
              ),
            ),
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
                            child: Text(
                              '검색 결과가 없습니다.',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: filteredAccessories.length,
                            itemBuilder: (context, index) {
                              final accessory = filteredAccessories[index];
                              final isSelected = compareMode &&
                                  compareList.contains(accessory);

                              return GestureDetector(
                                onTap: () => onAccessoryTap(context, accessory),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: isDark
                                              ? [
                                                  Colors.white.withAlpha(14),
                                                  Colors.white.withAlpha(8),
                                                ]
                                              : [
                                                  Colors.white.withAlpha(220),
                                                  Colors.white.withAlpha(180),
                                                ],
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary
                                                  .withAlpha(180)
                                              : isDark
                                                  ? Colors.white.withAlpha(20)
                                                  : Colors.white.withAlpha(160),
                                          width: isSelected ? 2.2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDark
                                                    ? Colors.black
                                                    : const Color(0xFF8FA7C5))
                                                .withAlpha(
                                                    isSelected ? 54 : 28),
                                            blurRadius: isSelected ? 18 : 10,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: isDark
                                                    ? Colors.grey[850]
                                                    : Colors.grey[200],
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: accessory.imageUrl,
                                                  fit: BoxFit.contain,
                                                  memCacheWidth: 256,
                                                  memCacheHeight: 256,
                                                  maxWidthDiskCache: 256,
                                                  maxHeightDiskCache: 256,
                                                  fadeInDuration: Duration.zero,
                                                  fadeOutDuration:
                                                      Duration.zero,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6.0,
                                                vertical: 4.0,
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    accessory.name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                    ),
                                    if (compareMode)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
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
        ),
      ],
    );
  }
}
