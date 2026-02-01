import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/accessory.dart';
import '../../core/constants/accessory_constants.dart';
import 'accessory_screen_ui.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/box_constants.dart';

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
      drawer: const AppDrawer(currentScreen: AppScreen.accessory),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 세트 이름(각 컨테이너 상단)
                          Text(setOption.setName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),

                          // 이미지
                          if (setOption.requiredAccessoryImages.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 100,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: setOption.requiredAccessoryImages
                                      .map((imageUrl) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
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

                          // 효과들을 '효과 : 수치' 형식으로 나열
                          ...setOption.effects.map((effect) {
                            String currentValue =
                                effect.stageValues[currentStageIndex.toString()] ??
                                    '-';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text('${effect.optionName} : $currentValue'),
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
                          const SizedBox(height: 8),
                          // 필요한 악세사리 이미지들 (가로 스크롤, 화면 전체 가운데 정렬)
                          if (setOption.requiredAccessoryImages.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 100,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: setOption.requiredAccessoryImages
                                      .map((imageUrl) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
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
                          // 세트 효과들 (효과:수치 형식)
                          ...setOption.effects.map((effect) {
                            String currentValue =
                                effect.stageValues[currentStageIndex.toString()] ??
                                    '-';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text('${effect.optionName} : $currentValue'),
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

