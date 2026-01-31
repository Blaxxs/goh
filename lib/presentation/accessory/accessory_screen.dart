import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 네트워크 이미지 캐싱 패키지
import '../../data/models/accessory.dart';
import '../../core/constants/accessory_constants.dart';
import '../../core/services/database_service.dart';
import 'accessory_screen_ui.dart';

class AccessoryScreen extends StatefulWidget {
  final bool isPickerMode; // 강화 화면 등에서 선택 모드로 사용할 때 true
  const AccessoryScreen({super.key, this.isPickerMode = false});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService(); // DB 서비스 인스턴스

  String? _selectedPartFilter;
  String _searchQuery = "";
  late List<String> _partFilterOptions;
  String _sortOption = '기본';
  final List<String> _sortOptions = ['기본', '이름 (가나다순)', '이름 (ABC순)'];

  @override
  void initState() {
    super.initState();
    // 필터 옵션 초기화 (accessoryParts 상수는 constants 파일에 정의됨)
    _partFilterOptions = ['전체', ...accessoryParts.toSet()];
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

  void _handleSortChanged(String? newValue) {
    setState(() {
      _sortOption = newValue ?? '기본';
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  // --- 상세 정보 표시 다이얼로그 (네트워크 이미지 적용) ---
  void _showAccessoryDetails(BuildContext context, Accessory accessory) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation1, animation2) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                accessory.name, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- 이미지 표시 부분 (CachedNetworkImage 사용) ---
                    if (accessory.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: accessory.imageUrl,
                        height: 100,
                        fit: BoxFit.contain,
                        // 로딩 중 표시할 위젯
                        placeholder: (context, url) => const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        // 에러 발생 시 표시할 위젯
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image, 
                          size: 100, 
                          color: Colors.grey
                        ),
                      )
                    else
                      // URL이 없는 경우 기본 아이콘
                      const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                    
                    const SizedBox(height: 15),
                    
                    _buildDetailRowDialog('부위:', accessory.part),
                    _buildDetailRowDialog('착용 제한:', accessory.restrictions),
                    const Divider(),
                    const Text('옵션', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    ...accessory.options.map((opt) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text('${opt.optionName}: ${opt.optionValue}'),
                        )),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                TextButton(
                  child: const Text('닫기'),
                  onPressed: () => Navigator.of(buildContext).pop(),
                ),
                // 선택 모드일 경우 '선택' 버튼 표시
                if (widget.isPickerMode)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(accessory); // 선택된 객체 반환
                    },
                    child: const Text('선택'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRowDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder를 사용하여 Firebase 데이터 변경을 실시간 감지
    return StreamBuilder<List<Accessory>>(
      stream: _dbService.getAccessoriesStream(),
      builder: (context, snapshot) {
        // 1. 로딩 상태 처리
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        // 2. 에러 상태 처리
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("데이터 로드 중 오류가 발생했습니다: ${snapshot.error}")));
        }

        // 3. 데이터 가져오기 (없으면 빈 리스트)
        final accessories = snapshot.data ?? [];

        // 4. 검색 및 필터링 로직 적용
        List<Accessory> displayList = accessories.where((acc) {
          final matchesSearch = acc.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesPart = _selectedPartFilter == null || 
                             _selectedPartFilter == '전체' || 
                             acc.part == _selectedPartFilter;
          return matchesSearch && matchesPart;
        }).toList();

        // 5. 정렬 로직 적용
        if (_sortOption == '이름 (가나다순)') {
          displayList.sort((a, b) => a.name.compareTo(b.name));
        } else if (_sortOption == '이름 (ABC순)') {
          displayList.sort((a, b) => a.id.compareTo(b.id));
        }

        // 6. UI 위젯에 가공된 데이터 전달
        return AccessoryScreenUI(
          searchController: _searchController,
          filteredAccessories: displayList,
          selectedPartFilter: _selectedPartFilter,
          partFilterOptions: _partFilterOptions,
          onPartFilterChanged: _handlePartFilterChanged,
          // 탭 이벤트 처리 (선택 모드일 때 바로 반환할지, 상세를 보여줄지 결정)
          onAccessoryTap: (ctx, acc) {
            if (widget.isPickerMode) {
              Navigator.of(context).pop(acc); // 바로 선택하고 닫기
            } else {
              _showAccessoryDetails(ctx, acc); // 상세 정보 보여주기
            }
          },
          currentSearchQuery: _searchQuery,
          onClearSearch: _clearSearch,
          sortOption: _sortOption,
          sortOptions: _sortOptions,
          onSortChanged: _handleSortChanged,
        );
      },
    );
  }
}