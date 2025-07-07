// lib/accessory_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/accessory.dart'; // Accessory 모델 클래스를 직접 import 합니다.
import '../../core/constants/accessory_constants.dart'; // Accessory 클래스 포함
import 'accessory_screen_ui.dart';

class AccessoryScreen extends StatefulWidget {
  final bool isPickerMode; // Add this
  const AccessoryScreen({super.key, this.isPickerMode = false}); // Initialize

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Accessory> _filteredAccessories = [];
  String? _selectedPartFilter;
  String _searchQuery = "";
  late List<String> _partFilterOptions;

  @override
  void initState() {
    super.initState();
    _partFilterOptions = ['전체', ...accessoryParts.toSet()];
    _filteredAccessories = List.from(allAccessories);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
       setState(() {
         _searchQuery = _searchController.text;
         _filterAccessories();
       });
    }
  }

  void _clearSearch() {
     _searchController.clear();
  }

  void _filterAccessories() {
    List<Accessory> results = List.from(allAccessories);

    // 부위 필터
    if (_selectedPartFilter != null && _selectedPartFilter != '전체') {
      results = results.where((acc) => acc.part == _selectedPartFilter).toList();
    }
    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      String query = _searchQuery.toLowerCase();
      results = results.where((acc) {
        if (acc.name.toLowerCase().contains(query)) return true;
        if (acc.part.toLowerCase().contains(query)) return true;
        for (var option in acc.options) {
          if (option.optionName.toLowerCase().contains(query)) return true;
          if (option.optionValue.toLowerCase().contains(query)) return true;
        }
        return false;
      }).toList();
    }
    _filteredAccessories = results; // setState는 _onSearchChanged 등에서 호출됨
  }

  void _handlePartFilterChanged(String? newValue) {
    setState(() {
      _selectedPartFilter = (newValue == '전체') ? null : newValue;
      _filterAccessories();
    });
  }

  // --- 악세사리 상세 정보 표시 (애니메이션 추가) ---
  void _showAccessoryDetails(BuildContext context, Accessory accessory) {
    // If in picker mode, pop with the selected accessory
    if (widget.isPickerMode) {
      Navigator.of(context).pop(accessory);
      return;
    }

    // Otherwise, show the details dialog
    const Duration transitionDuration = Duration(milliseconds: 300); // 애니메이션 시간

    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 배경 탭하여 닫기 활성화
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54, // 반투명 배경
      transitionDuration: transitionDuration,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        // 다이얼로그 내용 구성
        return ScaleTransition( // 확대/축소 애니메이션
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: FadeTransition( // 페이드 인/아웃 애니메이션
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: AlertDialog(
              title: Text(accessory.name, textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        accessory.imagePath,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRowDialog('부위:', accessory.part),
                    _buildDetailRowDialog('착용 제한:', accessory.restrictions),
                    const Divider(height: 20),
                    Text('옵션:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (accessory.options.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('옵션 없음', style: TextStyle(fontStyle: FontStyle.italic)),
                      )
                    else
                      ...accessory.options.map((opt) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                            child: Text('• ${opt.optionName}: ${opt.optionValue}'),
                          )),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                TextButton(
                  child: const Text('닫기'),
                  onPressed: () {
                    Navigator.of(buildContext).pop(); // 여기서 buildContext 사용
                  },
                ),
              ],
            ),
          ),
        );
      },
      // transitionBuilder는 pageBuilder 내에서 처리했으므로 여기서는 제거 가능
      // transitionBuilder: (context, animation, secondaryAnimation, child) {
      //   return FadeTransition( // 기본 페이드 전환 (선택적)
      //     opacity: animation,
      //     child: child,
      //   );
      // },
    );
  }
  // --- 상세 정보 표시 끝 ---

  // 다이얼로그 내용 행 빌더 (변경 없음)
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
    return AccessoryScreenUI(
      searchController: _searchController,
      filteredAccessories: _filteredAccessories,
      selectedPartFilter: _selectedPartFilter,
      partFilterOptions: _partFilterOptions,
      onPartFilterChanged: _handlePartFilterChanged,
      onAccessoryTap: _showAccessoryDetails, // 애니메이션 적용된 함수 전달
      currentSearchQuery: _searchQuery,
      onClearSearch: _clearSearch,
    );
  }
}