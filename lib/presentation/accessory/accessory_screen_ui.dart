// lib/presentation/accessory/accessory_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../data/models/accessory.dart'; // Accessory 모델 클래스를 import 합니다.
import '../../core/constants/box_constants.dart'; // AppScreen enum을 위해 추가
import '../../core/widgets/app_drawer.dart'; // 공통 Drawer 사용

class AccessoryScreenUI extends StatelessWidget {
  final TextEditingController searchController;
  final List<Accessory> filteredAccessories;
  final String? selectedPartFilter;
  final List<String> partFilterOptions;
  final ValueChanged<String?> onPartFilterChanged;
  final Function(BuildContext context, Accessory accessory) onAccessoryTap;
  final VoidCallback? onClearSearch;
  final String currentSearchQuery;

  const AccessoryScreenUI({
    super.key,
    required this.searchController,
    required this.filteredAccessories,
    required this.selectedPartFilter,
    required this.partFilterOptions,
    required this.onPartFilterChanged,
    required this.onAccessoryTap,
    required this.currentSearchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 110.0;
    final int crossAxisCount = (screenWidth / itemWidth).floor().clamp(2, 6);
    final theme = Theme.of(context);
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final TextStyle? titleStyle = appBarTheme.titleTextStyle;

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.accessory),
      appBar: AppBar(
        title: Text(
          '악세사리 목록',
          style: titleStyle?.copyWith(
            fontSize: (titleStyle.fontSize ?? 20) + 2.0, // 기존 폰트 크기에서 2.0 증가
          ),
        ),
      ),
      body: SafeArea( // 네비게이션 바와 겹침 방지
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '이름, 옵션, 부위 검색...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                        suffixIcon: currentSearchQuery.isNotEmpty && onClearSearch != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: onClearSearch,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 48,
                        width: 130,
                         decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          color: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                        ),
                      ),
                      hint: Container(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '부위 필터',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                             softWrap: false,
                          ),
                        ),
                      ),
                      items: partFilterOptions
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ))
                          .toList(),
                      value: selectedPartFilter ?? '전체',
                      onChanged: onPartFilterChanged,
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 250,
                         decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        offset: const Offset(0, -4),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: WidgetStateProperty.all(6),
                          thumbVisibility: WidgetStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      selectedItemBuilder: (context) {
                          return partFilterOptions.map((item) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color),
                                  softWrap: false,
                                ),
                              ),
                            );
                          }).toList();
                        },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredAccessories.isEmpty
                  ? Center(
                      child: Text(
                        searchController.text.isEmpty && (selectedPartFilter == null || selectedPartFilter == '전체')
                            ? '악세사리 데이터를 로드 중이거나, 데이터가 없습니다.'
                            : '검색 결과가 없습니다.',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredAccessories.length,
                      itemBuilder: (context, index) {
                        final accessory = filteredAccessories[index];
                        return InkWell(
                          onTap: () => onAccessoryTap(context, accessory),
                          borderRadius: BorderRadius.circular(8.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      accessory.imagePath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[400]));
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                                  child: SizedBox(
                                    height: 36,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                      child: Text(
                                        accessory.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
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
        ),
      ),
    );
  }
}