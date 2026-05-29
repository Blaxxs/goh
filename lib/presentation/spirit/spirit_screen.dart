import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
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
  bool _isLoading = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> _allSpirits = [];

  @override
  void initState() {
    super.initState();
    _loadSpirits();
  }

  Future<void> _loadSpirits() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('spirits').get();
      if (!mounted) {
        return;
      }

      final raw = snapshot.value;
      final parsed = <Map<String, dynamic>>[];

      if (raw is Map) {
        raw.forEach((key, value) {
          final map = _toSpiritMap(value, key.toString());
          if (map != null) {
            parsed.add(map);
          }
        });
      } else if (raw is List) {
        for (var i = 0; i < raw.length; i++) {
          final map = _toSpiritMap(raw[i], i.toString());
          if (map != null) {
            parsed.add(map);
          }
        }
      }

      parsed.sort((a, b) {
        final aName = (a['name'] ?? '').toString();
        final bName = (b['name'] ?? '').toString();
        return aName.compareTo(bName);
      });

      setState(() {
        _allSpirits
          ..clear()
          ..addAll(parsed);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = '스피릿 데이터를 불러오지 못했습니다.';
      });
    }
  }

  Map<String, dynamic>? _toSpiritMap(dynamic raw, String fallbackId) {
    if (raw == null) {
      return null;
    }

    Map<String, dynamic> map;
    if (raw is Map) {
      map = Map<String, dynamic>.from(raw);
    } else {
      try {
        final decoded = jsonDecode(jsonEncode(raw));
        if (decoded is! Map) {
          return null;
        }
        map = Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }

    final englishName = (map['englishName'] ?? '').toString();
    final explicitId = (map['id'] ?? '').toString();
    final resolvedId = explicitId.isNotEmpty
        ? explicitId
        : (englishName.isNotEmpty ? englishName : fallbackId);
    map['id'] = resolvedId;

    final imageUrl = (map['imageUrl'] ?? '').toString();
    final imageName = (map['imageName'] ?? '').toString();
    if (imageUrl.isEmpty && imageName.isNotEmpty) {
      final encodedName = Uri.encodeComponent(imageName);
      map['imageUrl'] =
          'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/spirit%2F$encodedName?alt=media';
    }

    return map;
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = null;
                                  });
                                  _loadSpirits();
                                },
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _allSpirits.isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '스피릿 데이터가 없습니다.\nRealtime Database의 spirits 노드를 확인해 주세요.',
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
                                  final name =
                                      (spirit['name'] ?? '이름 없음').toString();
                                  final imageUrl =
                                      (spirit['imageUrl'] ?? '').toString();

                                  return Card(
                                    child: ListTile(
                                      leading: imageUrl.isEmpty
                                          ? const CircleAvatar(
                                              child: Icon(
                                                Icons.auto_awesome_rounded,
                                              ),
                                            )
                                          : CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(imageUrl),
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
