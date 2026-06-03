import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/box_constants.dart';
import '../../core/widgets/app_drawer.dart';

class SpiritScreen extends StatefulWidget {
  const SpiritScreen({super.key});

  @override
  State<SpiritScreen> createState() => _SpiritScreenState();
}

enum _SpiritSearchScope {
  all,
  passive,
  active,
  name,
}

class _SpiritSearchTargets {
  const _SpiritSearchTargets({
    required this.nameTargets,
    required this.activeTargets,
    required this.passiveTargets,
  });

  final List<String> nameTargets;
  final List<String> activeTargets;
  final List<String> passiveTargets;
}

class _SpiritScreenState extends State<SpiritScreen> {
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const String _diskCacheDataKey = 'spirit_cache_data_v1';
  static const String _diskCacheUpdatedAtKey = 'spirit_cache_updated_at_v1';
  static List<Map<String, dynamic>>? _spiritsCache;
  static DateTime? _spiritsCacheUpdatedAt;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _SpiritSearchScope _searchScope = _SpiritSearchScope.all;
  bool _isLoading = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> _allSpirits = [];

  @override
  void initState() {
    super.initState();
    _initializeSpirits();
  }

  Future<void> _initializeSpirits() async {
    _restoreFromCache();

    if (!_hasFreshCache) {
      await _restoreFromDiskCache();
    }

    if (!mounted) {
      return;
    }

    await _loadSpirits(forceNetwork: !_hasFreshCache);
  }

  bool get _hasFreshCache {
    final cached = _spiritsCache;
    final updatedAt = _spiritsCacheUpdatedAt;
    if (cached == null || cached.isEmpty || updatedAt == null) {
      return false;
    }
    return DateTime.now().difference(updatedAt) <= _cacheTtl;
  }

  void _restoreFromCache() {
    final cached = _spiritsCache;
    if (cached == null || cached.isEmpty) {
      return;
    }

    _allSpirits
      ..clear()
      ..addAll(cached.map((e) => Map<String, dynamic>.from(e)));
    _isLoading = false;
    _errorMessage = null;
  }

  Future<void> _restoreFromDiskCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_diskCacheDataKey);
      final updatedAtMillis = prefs.getInt(_diskCacheUpdatedAtKey);

      if (rawJson == null || rawJson.isEmpty) {
        return;
      }

      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        return;
      }

      final cached = <Map<String, dynamic>>[];
      for (final item in decoded) {
        if (item is Map) {
          cached.add(Map<String, dynamic>.from(item));
        }
      }

      if (cached.isEmpty) {
        return;
      }

      _spiritsCache = cached;
      _spiritsCacheUpdatedAt = updatedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtMillis)
          : DateTime.now();

      if (!mounted) {
        return;
      }

      setState(() {
        _allSpirits
          ..clear()
          ..addAll(cached.map((e) => Map<String, dynamic>.from(e)));
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      // 디스크 캐시 로드 실패 시 네트워크 로딩으로 계속 진행.
    }
  }

  Future<void> _saveDiskCache(List<Map<String, dynamic>> parsed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = jsonEncode(parsed);
      await prefs.setString(_diskCacheDataKey, serialized);
      await prefs.setInt(
        _diskCacheUpdatedAtKey,
        (_spiritsCacheUpdatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      );
    } catch (_) {
      // 디스크 캐시 저장 실패는 무시하고 UI 동작은 유지.
    }
  }

  Future<void> _loadSpirits({bool forceNetwork = true}) async {
    if (!forceNetwork && _hasFreshCache) {
      return;
    }

    if (mounted && _allSpirits.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final snapshot = await FirebaseDatabase.instance.ref('spirits').get();
      if (!mounted) {
        return;
      }

      final raw = snapshot.value;
      final parsed = <Map<String, dynamic>>[];

      if (raw is Map) {
        // Allow either `/spirits/{id}` collection shape or a single-spirit object.
        if (_isSingleSpiritMap(raw)) {
          final map = _toSpiritMap(raw, 'spirit');
          if (map != null) {
            parsed.add(map);
          }
        } else {
          dynamic candidateCollection = raw;
          if (raw['spirits'] is Map || raw['spirits'] is List) {
            candidateCollection = raw['spirits'];
          }

          if (candidateCollection is Map) {
            candidateCollection.forEach((key, value) {
              final map = _toSpiritMap(value, key.toString());
              if (map != null) {
                parsed.add(map);
              }
            });
          } else if (candidateCollection is List) {
            for (var i = 0; i < candidateCollection.length; i++) {
              final map = _toSpiritMap(candidateCollection[i], i.toString());
              if (map != null) {
                parsed.add(map);
              }
            }
          }
        }
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

      _spiritsCache = parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      _spiritsCacheUpdatedAt = DateTime.now();
      _saveDiskCache(_spiritsCache!);

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
      final errorText = e.toString().toLowerCase();
      final isPermissionDenied = errorText.contains('permission-denied') ||
          errorText.contains('permission denied');
      setState(() {
        _isLoading = false;
        _errorMessage = isPermissionDenied
            ? '스피릿 데이터 읽기 권한이 없습니다.\nRealtime Database rules에서 spirits 읽기를 허용해 주세요.'
            : '스피릿 데이터를 불러오지 못했습니다.';
      });
    }
  }

  bool _isSingleSpiritMap(Map raw) {
    final hasTopLevelFields = raw.containsKey('name') ||
        raw.containsKey('englishName') ||
        raw.containsKey('imageName') ||
        raw.containsKey('imageUrl');
    final hasSkillBlock =
        raw.containsKey('active') || raw.containsKey('passive');
    return hasTopLevelFields && hasSkillBlock;
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
    final imageName = (map['imageName'] ?? '').toString();
    final name = (map['name'] ?? '').toString().trim();

    // Skip nested blocks such as `active` or `passive` when malformed JSON is provided.
    if (name.isEmpty &&
        englishName.isEmpty &&
        explicitId.isEmpty &&
        imageName.isEmpty) {
      return null;
    }

    final resolvedId = explicitId.isNotEmpty
        ? explicitId
        : (englishName.isNotEmpty ? englishName : fallbackId);
    map['id'] = resolvedId;
    if (name.isEmpty) {
      map['name'] = englishName.isNotEmpty ? englishName : resolvedId;
    }

    final imageUrl = (map['imageUrl'] ?? '').toString();
    if (imageUrl.isEmpty && imageName.isNotEmpty) {
      final encodedName = Uri.encodeComponent(imageName);
      map['imageUrl'] =
          'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/spirit%2F$encodedName?alt=media';
      map['fallbackImageUrl'] =
          'https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/spirits%2F$encodedName?alt=media';
    } else if (imageUrl.contains('/spirit%2F')) {
      map['fallbackImageUrl'] =
          imageUrl.replaceFirst('/spirit%2F', '/spirits%2F');
    } else if (imageUrl.contains('/spirits%2F')) {
      map['fallbackImageUrl'] =
          imageUrl.replaceFirst('/spirits%2F', '/spirit%2F');
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
    final normalizedQuery = _searchQuery.trim();
    final filteredSpirits = _allSpirits.where((spirit) {
      return _matchesSpiritSearch(normalizedQuery, spirit);
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
        title: const Text('스피릿 도감 TEST'),
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
                    hintText: '이름/효과/패시브 검색 (예: 크리, 크증, 관저)',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildScopeChip(_SpiritSearchScope.all, '전체 검색'),
                _buildScopeChip(_SpiritSearchScope.passive, '패시브 검색'),
                _buildScopeChip(_SpiritSearchScope.active, '효과 검색'),
                _buildScopeChip(_SpiritSearchScope.name, '이름 검색'),
              ],
            ),
          ),
          const SizedBox(height: 6),
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
                                  _loadSpirits(forceNetwork: true);
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
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 150,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: filteredSpirits.length,
                                itemBuilder: (context, index) {
                                  final spirit = filteredSpirits[index];
                                  final name =
                                      (spirit['name'] ?? '이름 없음').toString();
                                  final imageUrl =
                                      (spirit['imageUrl'] ?? '').toString();
                                  final fallbackImageUrl =
                                      (spirit['fallbackImageUrl'] ?? '')
                                          .toString();
                                  final isDark = Theme.of(context).brightness ==
                                      Brightness.dark;

                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () => _showSpiritDetails(spirit),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              color: isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                              padding: const EdgeInsets.all(6),
                                              child: _SpiritThumbnail(
                                                imageUrl: imageUrl,
                                                fallbackImageUrl:
                                                    fallbackImageUrl.isEmpty
                                                        ? null
                                                        : fallbackImageUrl,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                            child: Text(
                                              name,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildScopeChip(_SpiritSearchScope scope, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _searchScope == scope,
      onSelected: (_) {
        setState(() {
          _searchScope = scope;
        });
      },
      visualDensity: VisualDensity.compact,
    );
  }

  bool _matchesSpiritSearch(String query, Map<String, dynamic> spirit) {
    if (query.trim().isEmpty) {
      return true;
    }

    final normalizedQuery = _normalizeSearchText(query);
    final expandedQueries = _expandSearchQueries(normalizedQuery);

    final targets = _collectSearchTargetsByScope(spirit);
    final selectedTargets = switch (_searchScope) {
      _SpiritSearchScope.all => [
          ...targets.nameTargets,
          ...targets.activeTargets,
          ...targets.passiveTargets,
        ],
      _SpiritSearchScope.passive => targets.passiveTargets,
      _SpiritSearchScope.active => targets.activeTargets,
      _SpiritSearchScope.name => targets.nameTargets,
    };

    for (final target in selectedTargets) {
      final aliases = _searchAliasesForTarget(target);
      for (final expandedQuery in expandedQueries) {
        if (expandedQuery.isEmpty) {
          continue;
        }
        for (final alias in aliases) {
          if (alias.contains(expandedQuery)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  _SpiritSearchTargets _collectSearchTargetsByScope(
      Map<String, dynamic> spirit) {
    final nameTargets = <String>[
      (spirit['name'] ?? '').toString(),
      (spirit['englishName'] ?? '').toString(),
      (spirit['id'] ?? '').toString(),
      (spirit['attribute'] ?? '').toString(),
    ];

    final active = spirit['active'] is Map
        ? Map<String, dynamic>.from(spirit['active'])
        : <String, dynamic>{};
    final passive = spirit['passive'] is Map
        ? Map<String, dynamic>.from(spirit['passive'])
        : <String, dynamic>{};

    final activeTargets = _collectBlockSearchTargets(active);
    final passiveTargets = _collectBlockSearchTargets(passive);

    return _SpiritSearchTargets(
      nameTargets: nameTargets,
      activeTargets: activeTargets,
      passiveTargets: passiveTargets,
    );
  }

  List<String> _collectBlockSearchTargets(Map<String, dynamic> block) {
    if (block.isEmpty) {
      return const [];
    }

    final targets = <String>[];
    targets.add((block['baseDescription'] ?? '').toString());

    final skillType = block['skillType'];
    if (skillType != null) {
      targets.add(skillType.toString());
    }

    final applyCharacters = block['applyCharacters'];
    if (applyCharacters is List) {
      for (final c in applyCharacters) {
        targets.add(c.toString());
      }
    }

    final fixedTurns = block['skillTurns'];
    if (fixedTurns != null) {
      targets.add(fixedTurns.toString());
      targets.add('턴');
    }

    final turnsByLevel = _normalizeLevelContainer(block['skillTurnsByLevel']);
    for (final value in turnsByLevel.values) {
      targets.add(value.toString());
    }

    final valuesByLevel = _normalizeLevelContainer(block['valuesByLevel']);
    for (final entry in valuesByLevel.entries) {
      final value = entry.value;
      if (value is Map) {
        value.forEach((k, v) {
          targets.add(k.toString());
          targets.add(v.toString());
        });
      }
    }

    final extraByLevel = _normalizeLevelContainer(block['extraEffectsByLevel']);
    for (final value in extraByLevel.values) {
      if (value is! List) {
        continue;
      }
      for (final effect in value) {
        if (effect is String) {
          targets.add(effect);
        } else if (effect is Map) {
          targets.add((effect['description'] ?? '').toString());
          final values = effect['values'];
          if (values is Map) {
            values.forEach((k, v) {
              targets.add(k.toString());
              targets.add(v.toString());
            });
          }
        }
      }
    }

    return targets.where((e) => e.trim().isNotEmpty).toList();
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^0-9a-z가-힣]'), '');
  }

  Set<String> _expandSearchQueries(String normalizedQuery) {
    final expanded = <String>{normalizedQuery};
    for (final entry in _searchSynonyms.entries) {
      final canonical = entry.key;
      final synonyms = entry.value;
      if (canonical.contains(normalizedQuery) ||
          synonyms.contains(normalizedQuery)) {
        expanded.add(canonical);
        expanded.addAll(synonyms);
      }
    }
    return expanded;
  }

  Set<String> _searchAliasesForTarget(String target) {
    final normalized = _normalizeSearchText(target);
    final aliases = <String>{normalized};

    for (final entry in _searchSynonyms.entries) {
      final canonical = entry.key;
      final synonyms = entry.value;
      if (normalized.contains(canonical) ||
          synonyms.any((syn) => normalized.contains(syn))) {
        aliases.add(canonical);
        aliases.addAll(synonyms);
      }
    }

    return aliases;
  }

  static const Map<String, Set<String>> _searchSynonyms = {
    '크리티컬증가': {'크리', '크증'},
    '크리티컬데미지증가': {'크뎀', '크뎀증'},
    '관통확률저항증가': {'관통저항', '저항', '관저'},
    '관통저항확률증가': {'관통저항', '저항', '관저'},
    '명중증가': {'명중', '힛'},
  };

  void _showSpiritDetails(Map<String, dynamic> spirit) {
    final name = (spirit['name'] ?? '이름 없음').toString();
    final attribute = (spirit['attribute'] ?? '-').toString();
    final imageUrl = (spirit['imageUrl'] ?? '').toString();
    final fallbackImageUrl = (spirit['fallbackImageUrl'] ?? '').toString();
    final active = spirit['active'] is Map
        ? Map<String, dynamic>.from(spirit['active'])
        : <String, dynamic>{};
    final passive = spirit['passive'] is Map
        ? Map<String, dynamic>.from(spirit['passive'])
        : <String, dynamic>{};

    final hasLevels = _hasLevelData(active) || _hasLevelData(passive);

    showDialog<void>(
      context: context,
      builder: (context) {
        int selectedLevel = 1;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final activeDesc =
                _resolveDescriptionForLevel(active, selectedLevel);
            final passiveDesc =
                _resolveDescriptionForLevel(passive, selectedLevel);
            final activeTurnText =
                _resolveSkillTurnsForLevel(active, selectedLevel);
            final passiveTurnText =
                _resolveSkillTurnsForLevel(passive, selectedLevel);
            final activeExtras = _resolveExtraEffects(active, selectedLevel);
            final passiveExtras = _resolveExtraEffects(passive, selectedLevel);
            final activeCharacters = _resolveApplyCharacters(active);
            final passiveCharacters = _resolveApplyCharacters(passive);

            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _SpiritThumbnail(
                          imageUrl: imageUrl,
                          fallbackImageUrl: fallbackImageUrl.isEmpty
                              ? null
                              : fallbackImageUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('속성: $attribute'),
                    if (hasLevels) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('강화 단계'),
                          const SizedBox(width: 8),
                          Text('$selectedLevel강'),
                        ],
                      ),
                      Slider(
                        value: selectedLevel.toDouble(),
                        min: 1,
                        max: 9,
                        divisions: 8,
                        label: '$selectedLevel강',
                        onChanged: (value) {
                          setDialogState(() {
                            selectedLevel = value.round();
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                    _buildSkillSection(
                      context: context,
                      label: '효과 스킬',
                      turnText: activeTurnText,
                      description: activeDesc,
                      extras: activeExtras,
                      applyCharacters: activeCharacters,
                    ),
                    const SizedBox(height: 10),
                    _buildSkillSection(
                      context: context,
                      label: '패시브 스킬',
                      turnText: passiveTurnText,
                      description: passiveDesc,
                      extras: passiveExtras,
                      applyCharacters: passiveCharacters,
                    ),
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
      },
    );
  }

  Widget _buildSkillSection({
    required BuildContext context,
    required String label,
    required String description,
    required List<String> extras,
    required List<String> applyCharacters,
    String? turnText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (turnText != null && turnText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(turnText),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(description),
          if (extras.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...extras.map((e) => Text('• $e')),
          ],
          const SizedBox(height: 8),
          Text(
            '적용 캐릭터: ${applyCharacters.isEmpty ? '-' : applyCharacters.join(', ')}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _resolveApplyCharacters(Map<String, dynamic> block) {
    final raw = block['applyCharacters'];
    if (raw is! List) {
      return const [];
    }
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  bool _hasLevelData(Map<String, dynamic> block) {
    final valuesByLevel = _normalizeLevelContainer(block['valuesByLevel']);
    final turnsByLevel = _normalizeLevelContainer(block['skillTurnsByLevel']);
    return valuesByLevel.isNotEmpty || turnsByLevel.isNotEmpty;
  }

  String _resolveDescriptionForLevel(Map<String, dynamic> block, int level) {
    final base = (block['baseDescription'] ?? '-').toString();
    final valuesByLevel = _normalizeLevelContainer(block['valuesByLevel']);
    if (valuesByLevel.isEmpty) {
      return base;
    }

    final resolvedValues = _resolveLevelMap(valuesByLevel, level);
    var output = base;
    resolvedValues.forEach((key, value) {
      final keyText = key.toString();
      output = output.replaceAll('{$keyText}', value.toString());
    });
    return output;
  }

  String? _resolveSkillTurnsForLevel(Map<String, dynamic> block, int level) {
    // 1) Fixed turn field: "skillTurns": 4
    final fixedTurns = block['skillTurns'];
    if (fixedTurns != null && fixedTurns.toString().trim().isNotEmpty) {
      return '스킬 턴: ${fixedTurns.toString()}턴';
    }

    // 2) Variable turn field: "skillTurnsByLevel": {"1": 5, ...}
    final turnsByLevel = _normalizeLevelContainer(block['skillTurnsByLevel']);
    if (turnsByLevel.isEmpty) {
      return null;
    }

    final value = _resolveLevelValue(turnsByLevel, level);
    if (value == null) {
      return null;
    }
    return '스킬 턴: $value턴';
  }

  List<String> _resolveExtraEffects(Map<String, dynamic> block, int level) {
    final extraByLevel = _normalizeLevelContainer(block['extraEffectsByLevel']);
    if (extraByLevel.isEmpty) {
      return const [];
    }

    final latestById = <String, String>{};
    final plainEffects = <String>[];

    for (var lv = 1; lv <= level; lv++) {
      final key = lv.toString();
      final levelEffects = extraByLevel[key];
      if (levelEffects is! List) {
        continue;
      }

      for (final raw in levelEffects) {
        if (raw is String) {
          plainEffects.add(raw);
          continue;
        }
        if (raw is! Map) {
          continue;
        }

        final map = Map<String, dynamic>.from(raw);
        var desc = (map['description'] ?? '').toString();
        final values = map['values'];
        if (values is Map) {
          values.forEach((k, v) {
            desc = desc.replaceAll('{${k.toString()}}', v.toString());
          });
        }

        if (desc.isEmpty) {
          continue;
        }

        final id = (map['id'] ?? '').toString();
        if (id.isEmpty) {
          plainEffects.add(desc);
        } else {
          latestById[id] = desc;
        }
      }
    }

    return [
      ...latestById.values,
      ...plainEffects,
    ];
  }

  Map<String, dynamic> _resolveLevelMap(Map valuesByLevel, int level) {
    final value = _resolveLevelValue(valuesByLevel, level);
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.toString()] = v;
      });
      return result;
    }
    return <String, dynamic>{};
  }

  dynamic _resolveLevelValue(Map valuesByLevel, int level) {
    // Direct hit for either String or int key.
    if (valuesByLevel.containsKey(level.toString())) {
      return valuesByLevel[level.toString()];
    }
    if (valuesByLevel.containsKey(level)) {
      return valuesByLevel[level];
    }

    int? closest;
    dynamic closestKey;
    for (final key in valuesByLevel.keys) {
      final k = int.tryParse(key.toString());
      if (k == null || k > level) {
        continue;
      }
      if (closest == null || k > closest) {
        closest = k;
        closestKey = key;
      }
    }

    if (closestKey != null) {
      return valuesByLevel[closestKey];
    }

    return null;
  }

  Map<String, dynamic> _normalizeLevelContainer(dynamic raw) {
    if (raw is Map) {
      final result = <String, dynamic>{};
      raw.forEach((k, v) {
        result[k.toString()] = v;
      });
      return result;
    }

    if (raw is List) {
      final result = <String, dynamic>{};
      for (var i = 0; i < raw.length; i++) {
        final value = raw[i];
        if (value == null) {
          continue;
        }
        result[i.toString()] = value;
      }
      return result;
    }

    return <String, dynamic>{};
  }
}

class _SpiritThumbnail extends StatefulWidget {
  const _SpiritThumbnail({
    required this.imageUrl,
    this.fallbackImageUrl,
  });

  final String imageUrl;
  final String? fallbackImageUrl;

  @override
  State<_SpiritThumbnail> createState() => _SpiritThumbnailState();
}

class _SpiritThumbnailState extends State<_SpiritThumbnail> {
  bool _useFallback = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.imageUrl.trim();
    final fallback = widget.fallbackImageUrl?.trim();
    final currentUrl = _useFallback ? (fallback ?? primary) : primary;

    if (currentUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      );
    }

    return Image.network(
      currentUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (!_useFallback && fallback != null && fallback.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _useFallback = true;
              });
            }
          });
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
