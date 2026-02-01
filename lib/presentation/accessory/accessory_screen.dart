import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/accessory.dart';
import '../../core/constants/accessory_constants.dart';
import 'accessory_screen_ui.dart';

class AccessoryScreen extends StatefulWidget {
  final bool isPickerMode;
  const AccessoryScreen({super.key, this.isPickerMode = false});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedPartFilter;
  String _searchQuery = "";
  late List<String> _partFilterOptions;
  String _sortOption = '이름 (ABC순)';
  final List<String> _sortOptions = ['이름 (ABC순)', '기본', '이름 (가나다순)'];
  String _searchOption = '이름';
  final List<String> _searchOptions = ['이름', '옵션'];

  @override
  void initState() {
    super.initState();
    // 데이터 매니저에서 부위 목록을 가져와 필터 옵션을 초기화합니다.
    _partFilterOptions = [
      '전체',
      ...AccessoryDataManager().accessoryParts.toSet()
    ];
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

  @override
  Widget build(BuildContext context) {
    // AccessoryDataManager에서 미리 로드된 데이터를 가져옵니다.
    final List<Accessory> accessories = AccessoryDataManager().allAccessories;

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
      return matchesSearch && matchesPart;
    }).toList();

    // 정렬 로직을 적용합니다.
    if (_sortOption == '이름 (가나다순)' || _sortOption == '기본') {
      displayList.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortOption == '이름 (ABC순)') {
      displayList.sort((a, b) => a.id.compareTo(b.id));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickerMode ? '악세사리 선택' : '악세사리 도감'),
      ),
      body: AccessoryScreenUI(
        searchController: _searchController,
        filteredAccessories: displayList,
        selectedPartFilter: _selectedPartFilter,
        partFilterOptions: _partFilterOptions,
        onPartFilterChanged: _handlePartFilterChanged,
        onAccessoryTap: (ctx, acc) {
          if (widget.isPickerMode) {
            Navigator.of(context).pop(acc);
          } else {
            _showAccessoryDetails(ctx, acc);
          }
        },
        currentSearchQuery: _searchQuery,
        onClearSearch: _clearSearch,
        sortOption: _sortOption,
        sortOptions: _sortOptions,
        onSortChanged: (val) => setState(() => _sortOption = val!),
        searchOption: _searchOption,
        searchOptions: _searchOptions,
        onSearchOptionChanged: _handleSearchOptionChanged,
      ),
    );
  }
}

// 세트 옵션 단계 네비게이션을 지원하는 상세 다이얼로그
class _AccessoryDetailDialog extends StatefulWidget {
  final Accessory accessory;

  const _AccessoryDetailDialog({required this.accessory});

  @override
  State<_AccessoryDetailDialog> createState() => _AccessoryDetailDialogState();
}

class _AccessoryDetailDialogState extends State<_AccessoryDetailDialog> {
  late Map<String, int> _stageIndexMap; // 각 세트 옵션의 현재 단계 인덱스 저장 (setId -> stageIndex)

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
            const Text('기본 옵션',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.accessory.options.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text('${option.optionName}: ${option.optionValue}'),
                )),
            // 세트 옵션 표시
            if (widget.accessory.setOptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const Text('세트 옵션',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange)),
              const SizedBox(height: 12),
              ...widget.accessory.setOptions.map((setOption) {
                int currentStageIndex = _stageIndexMap[setOption.setId] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 세트 옵션 이름
                        Text(
                          setOption.setName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 필요한 악세사리 이미지들
                        if (setOption.requiredAccessoryImages.isNotEmpty)
                          SizedBox(
                            height: 60,
                            width: double.maxFinite,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  setOption.requiredAccessoryImages.length,
                              itemBuilder: (context, index) {
                                final imageUrl =
                                    setOption.requiredAccessoryImages[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.orange[300]!,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                      errorWidget:
                                          (context, url, error) {
                                        debugPrint('[SetOption] Image load failed for URL: $url, Error: $error');
                                        return const Center(
                                          child: Icon(
                                              Icons.broken_image,
                                              size: 20,
                                              color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '설정된 세트 악세사리 이미지 없음',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        // 세트 효과들
                        ...setOption.effects.map((effect) {
                          String currentValue = '';
                          
                          // 0부터 18까지 단계별로 값을 찾기
                          if (effect.stageValues.isNotEmpty) {
                            // 현재 선택된 단계의 값 가져오기
                            currentValue = effect.stageValues[currentStageIndex.toString()] ?? '-';
                            
                            // 값이 없으면 빈 문자열이므로 '-' 표시
                            if (currentValue.isEmpty) {
                              currentValue = '-';
                            }
                          } else {
                            currentValue = '-';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  effect.optionName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // 좌우 화살표 네비게이션
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 좌측 화살표 (이전 단계)
                                    IconButton(
                                      onPressed: currentStageIndex > 0
                                          ? () {
                                              setState(() {
                                                _stageIndexMap[
                                                        setOption.setId] =
                                                    currentStageIndex - 1;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.arrow_left),
                                      iconSize: 20,
                                      splashRadius: 16,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                    // 중앙: 현재 단계와 수치
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$currentStageIndex단계',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          currentValue,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 우측 화살표 (다음 단계)
                                    IconButton(
                                      onPressed: currentStageIndex < 18
                                          ? () {
                                              setState(() {
                                                _stageIndexMap[
                                                        setOption.setId] =
                                                    currentStageIndex + 1;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.arrow_right),
                                      iconSize: 20,
                                      splashRadius: 16,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                  ],
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

