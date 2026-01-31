// lib/accessory_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/accessory.dart';
import '../../core/constants/accessory_constants.dart';
import '../../core/services/database_service.dart'; 
import 'accessory_screen_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccessoryScreen extends StatefulWidget {
  final bool isPickerMode;
  const AccessoryScreen({super.key, this.isPickerMode = false});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  String? _selectedPartFilter;
  String _searchQuery = "";
  late List<String> _partFilterOptions;
  String _sortOption = '기본';
  final List<String> _sortOptions = ['기본', '이름 (가나다순)', '이름 (ABC순)'];

  @override
  void initState() {
    super.initState();
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
              title: Text(accessory.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 이미지 404 에러 방지 처리
                    if (accessory.imagePath.isNotEmpty)
                      Image.asset(
                        accessory.imagePath,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      )
                    else
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
                if (widget.isPickerMode)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(accessory),
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
    return StreamBuilder<List<Accessory>>(
      stream: _dbService.getAccessoriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final accessories = snapshot.data ?? [];

        // 필터링 및 정렬 로직
        List<Accessory> displayList = accessories.where((acc) {
          final matchesSearch = acc.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesPart = _selectedPartFilter == null || 
                             _selectedPartFilter == '전체' || 
                             acc.part == _selectedPartFilter;
          return matchesSearch && matchesPart;
        }).toList();

        if (_sortOption == '이름 (가나다순)') {
          displayList.sort((a, b) => a.name.compareTo(b.name));
        } else if (_sortOption == '이름 (ABC순)') {
          displayList.sort((a, b) => a.id.compareTo(b.id));
        }

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
          onSortChanged: _handleSortChanged,
        );
      },
    );
  }
}