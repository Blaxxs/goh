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

  void _clearSearch() {
    _searchController.clear();
  }

  // 상세 정보 다이얼로그 (Firebase Storage 이미지 연동)
  void _showAccessoryDetails(BuildContext context, Accessory accessory) {
    // ID를 기반으로 Firebase Storage URL 생성
    final String storageUrl = 
        "https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F${accessory.id}.png?alt=media";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(accessory.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 네트워크 이미지 캐싱 적용
                CachedNetworkImage(
                  imageUrl: storageUrl,
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
                _buildDetailRow('부위', accessory.part),
                _buildDetailRow('착용 제한', accessory.restrictions),
                const Divider(),
                const Text('기본 옵션', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...accessory.options.map((option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text('${option.optionName}: ${option.optionValue}'),
                    )),
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
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickerMode ? '악세사리 선택' : '악세사리 도감'),
      ),
      body: StreamBuilder<List<Accessory>>(
        stream: _dbService.getAccessoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final accessories = snapshot.data ?? [];

          // 4. 필터링 로직 적용
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
          );
        },
      ),
    );
  }
}