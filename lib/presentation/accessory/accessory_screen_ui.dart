import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 패키지 import 필수
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../data/models/accessory.dart';

class AccessoryScreenUI extends StatelessWidget {
  final TextEditingController searchController;
  final List<Accessory> filteredAccessories;
  final String? selectedPartFilter;
  final List<String> partFilterOptions;
  final ValueChanged<String?> onPartFilterChanged;
  final Function(BuildContext, Accessory) onAccessoryTap;
  final String currentSearchQuery;
  final VoidCallback onClearSearch;
  final String sortOption;
  final List<String> sortOptions;
  final ValueChanged<String?> onSortChanged;
  final String searchOption;
  final List<String> searchOptions;
  final ValueChanged<String?> onSearchOptionChanged;

  const AccessoryScreenUI({
    super.key,
    required this.searchController,
    required this.filteredAccessories,
    required this.selectedPartFilter,
    required this.partFilterOptions,
    required this.onPartFilterChanged,
    required this.onAccessoryTap,
    required this.currentSearchQuery,
    required this.onClearSearch,
    required this.sortOption,
    required this.sortOptions,
    required this.onSortChanged,
    required this.searchOption,
    required this.searchOptions,
    required this.onSearchOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // --- 검색 영역 ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                          ),
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            value: searchOption,
                            items: searchOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black87)),
                              );
                            }).toList(),
                            onChanged: onSearchOptionChanged,
                            iconStyleData: IconStyleData(
                              icon: Icon(Icons.keyboard_arrow_down, 
                                  color: isDark ? Colors.white70 : Colors.black54),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              offset: const Offset(0, 0),
                            ),
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                            ),
                            underline: const SizedBox(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: '검색어를 입력하세요...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.blueGrey[50],
                            prefixIcon: Icon(Icons.search, 
                                color: isDark ? Colors.white54 : Colors.black54),
                            suffixIcon: currentSearchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: onClearSearch,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // --- 필터 및 정렬 영역 ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                          ),
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            value: selectedPartFilter ?? '전체',
                            items: partFilterOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black87)),
                              );
                            }).toList(),
                            onChanged: onPartFilterChanged,
                            iconStyleData: IconStyleData(
                              icon: Icon(Icons.keyboard_arrow_down, 
                                  color: isDark ? Colors.white70 : Colors.black54),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              offset: const Offset(0, 0),
                            ),
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                            ),
                            underline: const SizedBox(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                          ),
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            value: sortOption,
                            items: sortOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black87)),
                              );
                            }).toList(),
                            onChanged: onSortChanged,
                            iconStyleData: IconStyleData(
                              icon: Icon(Icons.keyboard_arrow_down, 
                                  color: isDark ? Colors.white70 : Colors.black54),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              offset: const Offset(0, 0),
                            ),
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                            ),
                            underline: const SizedBox(),
                          ),
                        ),
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
          child: filteredAccessories.isEmpty
              ? const Center(child: Text("검색 결과가 없습니다."))
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

                    return GestureDetector(
                      onTap: () => onAccessoryTap(context, accessory),
                      child: Card(
                        clipBehavior: Clip.antiAlias, // 이미지가 카드의 경계를 넘지 않도록
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. 이미지 영역
                            Expanded(
                              child: Container(
                                color: Colors.grey[200],
                                padding: const EdgeInsets.all(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: accessory.imageUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
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
                                  horizontal: 8.0, vertical: 6.0),
                              child: Column(
                                children: [
                                  Text(
                                    accessory.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    accessory.part,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}