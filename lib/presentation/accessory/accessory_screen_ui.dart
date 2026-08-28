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
            borderRadius: BorderRadius.circular(22),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '풀강 수치로 보기',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.78,
                      child: Switch.adaptive(
                        value: showMaxEnhancementValues,
                        onChanged: onShowMaxEnhancementValuesChanged,
                      ),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...[
                        ('고정옵션', selectedOptionTypeFilter == '고정옵션'),
                        ('랜덤옵션', selectedOptionTypeFilter == '랜덤옵션'),
                        ('세트', selectedSetOnlyFilter),
                      ].map((item) {
                        final label = item.$1;
                        final selected = item.$2;
                        return Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) {
                              if (label == '고정옵션') {
                                onOptionTypeFilterChanged(
                                  selected ? '전체' : '고정옵션',
                                );
                              } else if (label == '랜덤옵션') {
                                onOptionTypeFilterChanged(
                                  selected ? '전체' : '랜덤옵션',
                                );
                              } else {
                                onSetOnlyFilterChanged(!selectedSetOnlyFilter);
                              }
                            },
                            selectedColor: isDark
                                ? const Color(0xFF7EA7FF).withAlpha(70)
                                : const Color(0xFFDDEBFF).withAlpha(200),
                            backgroundColor: isDark
                                ? const Color(0x0FFFFFFF)
                                : const Color(0xBFFFFFFF),
                            side: BorderSide(
                              color: selected
                                  ? (isDark
                                      ? Colors.white.withAlpha(32)
                                      : const Color(0xFFB8D3FF))
                                  : Colors.transparent,
                              width: 1,
                            ),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: selected
                                      ? (isDark ? Colors.white : const Color(0xFF1E3A8A))
                                      : (isDark ? Colors.white70 : Colors.black87),
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }),
                      ...partFilterOptions
                          .where((part) => part != '전체')
                          .map((part) {
                        final selected = selectedPartFilter == part;
                        return ChoiceChip(
                          label: Text(part),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) =>
                              onPartFilterChanged(selected ? null : part),
                          selectedColor: isDark
                              ? const Color(0xFF7EA7FF).withAlpha(70)
                              : const Color(0xFFDDEBFF).withAlpha(200),
                          backgroundColor: isDark
                              ? const Color(0x0FFFFFFF)
                              : const Color(0xBFFFFFFF),
                          side: BorderSide(
                            color: selected
                                ? (isDark ? Colors.white.withAlpha(32) : const Color(0xFFB8D3FF))
                                : Colors.transparent,
                            width: 1,
                          ),
                          labelStyle:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: selected
                                        ? (isDark ? Colors.white : const Color(0xFF1E3A8A))
                                        : (isDark ? Colors.white70 : Colors.black87),
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                  ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          visualDensity: VisualDensity.compact,
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
              color: isDark ? const Color(0x0FFFFFFF) : const Color(0x33FFFFFF),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(12)
                    : Colors.white.withAlpha(120),
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
                                        color: isDark
                                            ? const Color(0xFF0F1720).withAlpha(200)
                                            : const Color(0xF7FFFFFF),
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary.withAlpha(150)
                                              : isDark
                                                  ? Colors.white.withAlpha(12)
                                                  : Colors.black.withAlpha(10),
                                          width: isSelected ? 1.8 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDark
                                                    ? Colors.black
                                                    : const Color(0xFFB2BED1))
                                                .withAlpha(isSelected ? 44 : 20),
                                            blurRadius: isSelected ? 14 : 8,
                                            offset: const Offset(0, 6),
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
