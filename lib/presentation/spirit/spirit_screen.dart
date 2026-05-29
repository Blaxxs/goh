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
      final isPermissionDenied =
          errorText.contains('permission-denied') ||
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
    final hasTopLevelFields =
        raw.containsKey('name') ||
        raw.containsKey('englishName') ||
        raw.containsKey('imageName') ||
        raw.containsKey('imageUrl');
    final hasSkillBlock = raw.containsKey('active') || raw.containsKey('passive');
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
    if (name.isEmpty && englishName.isEmpty && explicitId.isEmpty && imageName.isEmpty) {
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
      map['fallbackImageUrl'] = imageUrl.replaceFirst('/spirit%2F', '/spirits%2F');
    } else if (imageUrl.contains('/spirits%2F')) {
      map['fallbackImageUrl'] = imageUrl.replaceFirst('/spirits%2F', '/spirit%2F');
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
                                      (spirit['fallbackImageUrl'] ?? '').toString();
                                  final isDark =
                                      Theme.of(context).brightness == Brightness.dark;

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

  void _showSpiritDetails(Map<String, dynamic> spirit) {
    final name = (spirit['name'] ?? '이름 없음').toString();
    final attribute = (spirit['attribute'] ?? '-').toString();
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
            final activeDesc = _resolveDescriptionForLevel(active, selectedLevel);
            final passiveDesc = _resolveDescriptionForLevel(passive, selectedLevel);
            final activeTurnText = _resolveSkillTurnsForLevel(active, selectedLevel);
            final passiveTurnText = _resolveSkillTurnsForLevel(passive, selectedLevel);
            final activeExtras = _resolveExtraEffects(active, selectedLevel);
            final passiveExtras = _resolveExtraEffects(passive, selectedLevel);

            return AlertDialog(
              title: Text(name),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    const SizedBox(height: 4),
                    const Text('액티브'),
                    if (activeTurnText != null) ...[
                      const SizedBox(height: 2),
                      Text(activeTurnText),
                    ],
                    const SizedBox(height: 4),
                    Text(activeDesc),
                    if (activeExtras.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...activeExtras.map((e) => Text('• $e')),
                    ],
                    const SizedBox(height: 10),
                    const Text('패시브'),
                    if (passiveTurnText != null) ...[
                      const SizedBox(height: 2),
                      Text(passiveTurnText),
                    ],
                    const SizedBox(height: 4),
                    Text(passiveDesc),
                    if (passiveExtras.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...passiveExtras.map((e) => Text('• $e')),
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
          },
        );
      },
    );
  }

  bool _hasLevelData(Map<String, dynamic> block) {
    final valuesByLevel = block['valuesByLevel'];
    final turnsByLevel = block['skillTurnsByLevel'];
    return valuesByLevel is Map || turnsByLevel is Map;
  }

  String _resolveDescriptionForLevel(Map<String, dynamic> block, int level) {
    final base = (block['baseDescription'] ?? '-').toString();
    final valuesByLevel = block['valuesByLevel'];
    if (valuesByLevel is! Map) {
      return base;
    }

    final resolvedValues = _resolveLevelMap(valuesByLevel, level);
    var output = base;
    resolvedValues.forEach((key, value) {
      output = output.replaceAll('{$key}', value.toString());
    });
    return output;
  }

  String? _resolveSkillTurnsForLevel(Map<String, dynamic> block, int level) {
    final turnsByLevel = block['skillTurnsByLevel'];
    if (turnsByLevel is! Map) {
      return null;
    }

    final value = _resolveLevelValue(turnsByLevel, level);
    if (value == null) {
      return null;
    }
    return '스킬 턴: $value턴';
  }

  List<String> _resolveExtraEffects(Map<String, dynamic> block, int level) {
    final extraByLevel = block['extraEffectsByLevel'];
    if (extraByLevel is! Map) {
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
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  dynamic _resolveLevelValue(Map valuesByLevel, int level) {
    final direct = valuesByLevel[level.toString()];
    if (direct != null) {
      return direct;
    }

    int? closest;
    for (final key in valuesByLevel.keys) {
      final k = int.tryParse(key.toString());
      if (k == null || k > level) {
        continue;
      }
      if (closest == null || k > closest!) {
        closest = k;
      }
    }

    if (closest != null) {
      return valuesByLevel[closest.toString()];
    }

    return null;
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
