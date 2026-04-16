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
  final Function(BuildContext, Accessory) onAccessoryTap;
  final String currentSearchQuery;
  final VoidCallback onClearSearch;
  final String searchOption;
  final List<String> searchOptions;
  final ValueChanged<String?> onSearchOptionChanged;
  final bool compareMode;
  final List<Accessory> compareList;

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
    required this.onAccessoryTap,
    required this.currentSearchQuery,
    required this.onClearSearch,
    required this.searchOption,
    required this.searchOptions,
    required this.onSearchOptionChanged,
    this.compareMode = false,
    this.compareList = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  // --- 검색 + 필터 (대중적인 검색바 + 칩 UI) ---
                  Row(
                    children: [
                      SizedBox(
                        width: 112,
                        child: DropdownButtonFormField<String>(
                          value: searchOption,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.blueGrey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          items: searchOptions
                              .map(
                                (value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      )),
                                ),
                              )
                              .toList(),
                          onChanged: onSearchOptionChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: TextField(
                            controller: searchController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: '악세 이름/옵션 검색',
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.blueGrey[50],
                              prefixIcon: Icon(Icons.search,
                                  color:
                                      isDark ? Colors.white54 : Colors.black54),
                              suffixIcon: currentSearchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: onClearSearch,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '옵션',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              ...optionTypeFilterOptions.map((type) {
                                final selected = selectedOptionTypeFilter == type;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(type),
                                    selected: selected,
                                    onSelected: (_) =>
                                        onOptionTypeFilterChanged(type),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '부위',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color:
                                        isDark ? Colors.white70 : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        ...partFilterOptions.map((part) {
                          final selected = (selectedPartFilter ?? '전체') == part;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(part),
                              selected: selected,
                              onSelected: (_) => onPartFilterChanged(part),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- 악세사리 리스트 (그리드 뷰) ---
        Expanded(
          child: filteredAccessories.isEmpty
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
