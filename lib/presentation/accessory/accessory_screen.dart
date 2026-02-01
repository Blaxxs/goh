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
