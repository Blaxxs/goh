import 'package:flutter/material.dart';

import '../../core/constants/box_constants.dart';
import '../../core/widgets/app_drawer.dart';

class SpiritScreen extends StatefulWidget {
  const SpiritScreen({super.key});

  @override
  State<SpiritScreen> createState() => _SpiritScreenState();
}

class _SpiritScreenState extends State<SpiritScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 데이터는 추후 Firebase Realtime Database의 spirits 노드에서 로드 예정
  final List<Map<String, dynamic>> _allSpirits = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredSpirits = _allSpirits.where((spirit) {
      if (normalizedQuery.isEmpty) {
        return true;
      }
      final name = (spirit['name'] ?? '').toString().toLowerCase();
      final id = (spirit['id'] ?? '').toString().toLowerCase();
      return name.contains(normalizedQuery) || id.contains(normalizedQuery);
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.spirit),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('스피릿 도감'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: '스피릿 이름/ID 검색',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _allSpirits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '스피릿 데이터 준비 중입니다.\n이미지는 Firebase Storage의 spirit 폴더,\n수치는 Realtime Database의 spirits JSON으로 연결 예정입니다.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : filteredSpirits.isEmpty
                    ? const Center(child: Text('검색 결과가 없습니다.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredSpirits.length,
                        itemBuilder: (context, index) {
                          final spirit = filteredSpirits[index];
                          final name = (spirit['name'] ?? '이름 없음').toString();
                          final imageUrl =
                              (spirit['imageUrl'] ?? '').toString();

                          return Card(
                            child: ListTile(
                              leading: imageUrl.isEmpty
                                  ? const CircleAvatar(
                                      child: Icon(Icons.auto_awesome_rounded),
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(imageUrl),
                                    ),
                              title: Text(name),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
