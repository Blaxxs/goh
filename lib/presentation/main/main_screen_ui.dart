import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // [추가]
import 'package:goh_calculator/core/services/settings_service.dart';
import 'package:goh_calculator/core/widgets/liquid_glass.dart';
import '../../core/services/event_manager.dart';

// 실시간 공지사항을 위해 StatefulWidget으로 변경했습니다.
class MainScreenUI extends StatefulWidget {
  final VoidCallback onCalculatorPressed;
  final VoidCallback onGoldCalculatorPressed;
  final VoidCallback onAccessoryPressed;
  final VoidCallback onSpiritPressed;
  final VoidCallback onDamageCalculatorPressed;
  final VoidCallback onJournalPressed;
  final VoidCallback onBoxCalculatorPressed;
  final VoidCallback onAccessoryEnhancementPressed;
  final VoidCallback onAccessoryOptionChangePressed;
  final VoidCallback onAccessorySimulationPressed;
  final VoidCallback onExplorationOptionSimulationPressed;
  final VoidCallback onPouchSimulationPressed;
  final VoidCallback onRandomAccessorySimulatorPressed;
  final VoidCallback onStageSettingsPressed;
  final VoidCallback onAppSettingsPressed;

  const MainScreenUI({
    super.key,
    required this.onCalculatorPressed,
    required this.onGoldCalculatorPressed,
    required this.onAccessoryPressed,
    required this.onSpiritPressed,
    required this.onDamageCalculatorPressed,
    required this.onJournalPressed,
    required this.onBoxCalculatorPressed,
    required this.onAccessoryEnhancementPressed,
    required this.onAccessoryOptionChangePressed,
    required this.onAccessorySimulationPressed,
    required this.onExplorationOptionSimulationPressed,
    required this.onPouchSimulationPressed,
    required this.onRandomAccessorySimulatorPressed,
    required this.onStageSettingsPressed,
    required this.onAppSettingsPressed,
    required SettingsService settingsService,
  });

  @override
  State<MainScreenUI> createState() => _MainScreenUIState();
}

class _MainScreenUIState extends State<MainScreenUI> {
  // [추가] Firebase 데이터베이스 참조 및 데이터 변수
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("message");
  String _noticeMessage = "";
  bool _logoPrecached = false;
  bool _isEditMode = false;
  late final List<_MenuSection> _menuSections;
  final Set<String> _favoriteEntryKeys = <String>{};
  final Set<String> _hiddenEntryKeys = <String>{};
  int? _gridColumnsOverride;

  static const Map<String, IconData> _menuIcons = {
    '루프 계산기': Icons.calculate_rounded,
    '골드 효율 계산기': Icons.paid_rounded,
    '데미지 계산기_ Beta': Icons.flash_on_rounded,
    '악세사리 도감': Icons.diamond_outlined,
    '스피릿 도감': Icons.auto_awesome_rounded,
    '일지': Icons.calendar_month_rounded,
    '상자 기대값 계산기': Icons.inventory_2_rounded,
    '악세 강화 시뮬': Icons.auto_awesome_rounded,
    '악세 옵변 시뮬': Icons.swap_horiz_rounded,
    '악세사리 시뮬레이션': Icons.precision_manufacturing_rounded,
    '탐 옵션 시뮬': Icons.explore_rounded,
    '주머니 시뮬': Icons.workspaces_outline,
    '랜덤악세 시뮬': Icons.casino_rounded,
    '스테이지 설정': Icons.tune_rounded,
  };

  bool _areEssentialSettingsSet() {
    final settings = SettingsService.instance.stageSettings;
    return settings.teamLevel != null &&
        settings.teamLevel!.isNotEmpty &&
        settings.dalgijiLevel != null &&
        settings.dalgijiLevel!.isNotEmpty &&
        settings.vipLevel != null &&
        settings.vipLevel!.isNotEmpty;
  }

  VoidCallback? _resolveOnPressed(String entryKey, bool isEventActive) {
    switch (entryKey) {
      case 'loop':
        return widget.onCalculatorPressed;
      case 'gold':
        return widget.onGoldCalculatorPressed;
      case 'damage':
        return widget.onDamageCalculatorPressed;
      case 'accessory':
        return widget.onAccessoryPressed;
      case 'spirit':
        return widget.onSpiritPressed;
      case 'journal':
        return widget.onJournalPressed;
      case 'box':
        return isEventActive ? widget.onBoxCalculatorPressed : null;
      case 'enhancement':
        return widget.onAccessoryEnhancementPressed;
      case 'optionChange':
        return widget.onAccessoryOptionChangePressed;
      case 'accessorySimulation':
        return widget.onAccessorySimulationPressed;
      case 'exploration':
        return widget.onExplorationOptionSimulationPressed;
      case 'pouch':
        return widget.onPouchSimulationPressed;
      case 'randomAccessory':
        return widget.onRandomAccessorySimulatorPressed;
      case 'stageSettings':
        return widget.onStageSettingsPressed;
      default:
        return null;
    }
  }

  String? _resolveTooltip(_MenuEntry entry, bool isEventActive) {
    if (entry.key == 'box' && !isEventActive) {
      return entry.tooltip;
    }
    return null;
  }

  _MenuSection? _findSectionById(String sectionId) {
    final idx = _menuSections.indexWhere((section) => section.id == sectionId);
    if (idx == -1) return null;
    return _menuSections[idx];
  }

  List<_EntryRef> _visibleEntryRefs(bool isEventActive) {
    final refs = <_EntryRef>[];
    for (final section in _menuSections) {
      for (final indexed in section.items.asMap().entries) {
        if (indexed.value.key == 'box' && !isEventActive) continue;
        if (_hiddenEntryKeys.contains(indexed.value.key)) continue;
        refs.add(
          _EntryRef(
            sectionId: section.id,
            itemIndex: indexed.key,
            entry: indexed.value,
          ),
        );
      }
    }
    return refs;
  }

  void _moveEntryByStep(String entryKey, int step) {
    final refs = _visibleEntryRefs(EventManager.isEventPeriodActive());
    final currentIndex = refs.indexWhere((ref) => ref.entry.key == entryKey);
    if (currentIndex == -1) return;
    final targetIndex = currentIndex + step;
    if (targetIndex < 0 || targetIndex >= refs.length) return;

    final currentRef = refs[currentIndex];
    final targetRef = refs[targetIndex];

    final currentSection = _findSectionById(currentRef.sectionId);
    final targetSection = _findSectionById(targetRef.sectionId);
    if (currentSection == null || targetSection == null) return;

    setState(() {
      final currentEntry = currentSection.items[currentRef.itemIndex];
      final targetEntry = targetSection.items[targetRef.itemIndex];
      currentSection.items[currentRef.itemIndex] = targetEntry;
      targetSection.items[targetRef.itemIndex] = currentEntry;
    });
    _persistMenuLayout();
  }

  int _resolveGridColumns(double panelWidth) {
    final int maxSafeColumns = _maxSafeGridColumns(panelWidth);
    final int preferredColumns;
    if (_gridColumnsOverride != null) {
      preferredColumns = _gridColumnsOverride!;
    } else if (panelWidth >= 780) {
      preferredColumns = 5;
    } else if (panelWidth >= 620) {
      preferredColumns = 4;
    } else {
      preferredColumns = 3;
    }
    return preferredColumns.clamp(2, maxSafeColumns);
  }

  int _maxSafeGridColumns(double panelWidth) {
    const double gap = 8;
    const double horizontalPadding = 20;
    const double minTileWidth = 96;
    final double innerWidth = panelWidth - horizontalPadding;
    final int raw = ((innerWidth + gap) / (minTileWidth + gap)).floor();
    return raw.clamp(2, 5);
  }

  void _setGridColumnsOverride(int? columns) {
    setState(() {
      _gridColumnsOverride = columns;
    });
    _persistMenuLayout();
  }

  Future<void> _showGridModeSheet() async {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    const double panelMaxWidth = 820;
    const double horizontalInset = 20;
    final panelWidth =
        (screenWidth - (horizontalInset * 2)).clamp(280.0, panelMaxWidth);
    final int maxSafeColumns = _maxSafeGridColumns(panelWidth);

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('자동'),
                trailing: _gridColumnsOverride == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _setGridColumnsOverride(null);
                },
              ),
              ListTile(
                title: const Text('3열 고정'),
                trailing: _gridColumnsOverride == 3
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _setGridColumnsOverride(3);
                },
              ),
              if (maxSafeColumns >= 4)
                ListTile(
                  title: const Text('4열 고정'),
                  trailing: _gridColumnsOverride == 4
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _setGridColumnsOverride(4);
                  },
                ),
              if (maxSafeColumns >= 5)
                ListTile(
                  title: const Text('5열 고정'),
                  trailing: _gridColumnsOverride == 5
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _setGridColumnsOverride(5);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _toggleFavorite(String entryKey) {
    setState(() {
      if (_favoriteEntryKeys.contains(entryKey)) {
        _favoriteEntryKeys.remove(entryKey);
      } else {
        _favoriteEntryKeys.add(entryKey);
      }
    });
    _persistMenuLayout();
  }

  void _toggleHidden(String entryKey) {
    setState(() {
      if (_hiddenEntryKeys.contains(entryKey)) {
        _hiddenEntryKeys.remove(entryKey);
      } else {
        _hiddenEntryKeys.add(entryKey);
      }
    });
    _persistMenuLayout();
  }

  Map<String, dynamic> _buildMenuLayoutPayload() {
    return {
      'sections': _menuSections
          .map((section) => {
                'id': section.id,
                'itemKeys': section.items.map((item) => item.key).toList(),
              })
          .toList(),
      'favorites': _favoriteEntryKeys.toList(),
      'hidden': _hiddenEntryKeys.toList(),
      'gridColumns': _gridColumnsOverride,
    };
  }

  Future<void> _persistMenuLayout() async {
    final settingsService = SettingsService.instance;
    final current = settingsService.appSettings;
    final layoutJson = jsonEncode(_buildMenuLayoutPayload());
    await settingsService.saveAppSettings(
      current.copyWith(homeMenuLayoutJson: layoutJson),
    );
  }

  _MenuEntry? _findEntryByKey(String key) {
    for (final section in _menuSections) {
      for (final entry in section.items) {
        if (entry.key == key) return entry;
      }
    }
    return null;
  }

  void _applyStoredLayout(String layoutJson) {
    final decoded = jsonDecode(layoutJson);
    if (decoded is! Map<String, dynamic>) return;

    final Map<String, _MenuSection> sectionById = {
      for (final section in _menuSections) section.id: section,
    };

    final sectionsData = decoded['sections'];
    if (sectionsData is List) {
      final List<_MenuSection> reorderedSections = [];
      for (final sectionData in sectionsData) {
        if (sectionData is! Map) continue;
        final sectionId = sectionData['id']?.toString();
        if (sectionId == null || !sectionById.containsKey(sectionId)) continue;
        final section = sectionById.remove(sectionId)!;

        final itemKeys = sectionData['itemKeys'];
        if (itemKeys is List) {
          final Map<String, _MenuEntry> itemMap = {
            for (final item in section.items) item.key: item,
          };
          final List<_MenuEntry> reordered = [];
          for (final key in itemKeys) {
            final entry = itemMap.remove(key.toString());
            if (entry != null) reordered.add(entry);
          }
          reordered.addAll(itemMap.values);
          section.items
            ..clear()
            ..addAll(reordered);
        }

        reorderedSections.add(section);
      }
      reorderedSections.addAll(sectionById.values);
      _menuSections
        ..clear()
        ..addAll(reorderedSections);
    }

    _favoriteEntryKeys.clear();
    final favorites = decoded['favorites'];
    if (favorites is List) {
      for (final key in favorites) {
        final keyStr = key.toString();
        if (_findEntryByKey(keyStr) != null) {
          _favoriteEntryKeys.add(keyStr);
        }
      }
    }

    _hiddenEntryKeys.clear();
    final hidden = decoded['hidden'];
    if (hidden is List) {
      for (final key in hidden) {
        final keyStr = key.toString();
        if (_findEntryByKey(keyStr) != null) {
          _hiddenEntryKeys.add(keyStr);
        }
      }
    }

    final gridColumns = decoded['gridColumns'];
    if (gridColumns is int &&
        (gridColumns == 3 || gridColumns == 4 || gridColumns == 5)) {
      _gridColumnsOverride = gridColumns;
    } else {
      _gridColumnsOverride = null;
    }
  }

  Future<void> _loadStoredLayout() async {
    final layoutJson = SettingsService.instance.appSettings.homeMenuLayoutJson;
    if (layoutJson == null || layoutJson.isEmpty) return;
    try {
      _applyStoredLayout(layoutJson);
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // 저장 포맷이 깨진 경우 기본 레이아웃으로 유지
    }
  }

  @override
  void initState() {
    super.initState();
    _menuSections = [
      _MenuSection(
        id: 'calc',
        title: '계산기',
        items: [
          const _MenuEntry(key: 'loop', text: '루프 계산기', subtitle: '스테이지 반복 계산'),
          const _MenuEntry(
              key: 'gold', text: '골드 효율 계산기', subtitle: '루프 대비 수익'),
          const _MenuEntry(
              key: 'damage', text: '데미지 계산기_ Beta', subtitle: '대미지 검증'),
        ],
      ),
      _MenuSection(
        id: 'tools',
        title: '도구 / 기록',
        items: [
          const _MenuEntry(
            key: 'accessory',
            text: '악세사리 도감',
            subtitle: '옵션 및 세트 확인',
          ),
          const _MenuEntry(key: 'journal', text: '일지', subtitle: '기록 및 추이 확인'),
          const _MenuEntry(
            key: 'box',
            text: '상자 기대값 계산기',
            subtitle: '이벤트 상자 기대값',
            tooltip: '이벤트 기간에만 사용 가능합니다',
          ),
        ],
      ),
      _MenuSection(
        id: 'sim',
        title: '시뮬레이터',
        items: [
          const _MenuEntry(
            key: 'accessorySimulation',
            text: '악세사리 시뮬레이션',
            subtitle: '제작/강화/옵변/개조 통합',
          ),
          const _MenuEntry(
            key: 'exploration',
            text: '탐 옵션 시뮬',
            subtitle: '탐험 옵션 실험',
          ),
          const _MenuEntry(
            key: 'pouch',
            text: '주머니 시뮬',
            subtitle: '주머니 획득 시뮬',
          ),
        ],
      ),
      _MenuSection(
        id: 'settings',
        title: '설정',
        items: [
          const _MenuEntry(
            key: 'stageSettings',
            text: '스테이지 설정',
            subtitle: '팀/달기지/VIP 설정',
          ),
        ],
      ),
    ];
    _loadStoredLayout();
    // [추가] 실시간 데이터 감시
    _dbRef.onValue.listen((event) {
      if (mounted) {
        setState(() {
          _noticeMessage = event.snapshot.value?.toString() ?? "";
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_logoPrecached) {
      _logoPrecached = true;
      precacheImage(const AssetImage('assets/images/main_logo.png'), context);
    }
  }

  Widget _buildActionTile({
    required BuildContext context,
    required _MenuEntry entry,
    required VoidCallback? onPressed,
    required double itemWidth,
    required bool isEditMode,
    required bool isFavorite,
    required bool canMoveUp,
    required bool canMoveDown,
    required VoidCallback onMoveUp,
    required VoidCallback onMoveDown,
    required VoidCallback onToggleFavorite,
    required VoidCallback onToggleHidden,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final double fontScale =
        SettingsService.instance.appSettings.fontSizeMultiplier.clamp(0.8, 1.8);
    final double tileHeight = (96 * fontScale).clamp(86.0, 124.0);
    final double iconBoxSize = (34 * fontScale).clamp(26.0, 44.0);
    final double iconSize = (16 * fontScale).clamp(12.0, 22.0);
    final double labelFontSize = (11 * fontScale).clamp(9.0, 18.0);
    final double iconTextGap = (6 * fontScale).clamp(4.0, 10.0);
    final bool isEnabled = onPressed != null && !isEditMode;
    final bool isHidden = _hiddenEntryKeys.contains(entry.key);
    final Color titleColor = colorScheme.onSurface;
    final Color iconColor = (isEnabled && !isHidden)
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(145);
    final Color iconBorderColor = (isEnabled && !isHidden)
        ? colorScheme.outline.withAlpha(isDark ? 170 : 145)
        : colorScheme.outline.withAlpha(90);

    Widget button = SizedBox(
      width: itemWidth,
      height: tileHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEditMode
              ? onToggleHidden
              : (isEnabled && !isHidden ? onPressed : null),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xCC1E2A3B), Color(0xB3192434)],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xF8FFFFFF), Color(0xECEDF3FF)],
                          ),
                    border: Border.all(color: iconBorderColor, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      _menuIcons[entry.text] ?? Icons.apps_rounded,
                      size: iconSize,
                      color: iconColor,
                    ),
                  ),
                ),
                SizedBox(height: iconTextGap),
                Expanded(
                  child: Text(
                    entry.text,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isHidden ? titleColor.withAlpha(120) : titleColor,
                      height: 1.15,
                      fontSize: labelFontSize,
                      shadows: [
                        Shadow(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black.withAlpha(120)
                              : Colors.white.withAlpha(210),
                          blurRadius: 2,
                          offset: const Offset(0, 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isEditMode)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTinyIconButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        onTap: canMoveUp ? onMoveUp : null,
                      ),
                      _buildTinyIconButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        onTap: canMoveDown ? onMoveDown : null,
                      ),
                      _buildTinyIconButton(
                        icon: isHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        onTap: onToggleHidden,
                      ),
                      _buildTinyIconButton(
                        icon: isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        onTap: onToggleFavorite,
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && onPressed == null && !isEditMode && !isHidden) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildTinyIconButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 22,
      height: 22,
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 12,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(icon, size: 14),
      ),
    );
  }

  Widget _buildIconGrid({
    required BuildContext context,
    required bool isEventActive,
    required double panelWidth,
  }) {
    final visibleRefs = _visibleEntryRefs(isEventActive);
    const double gap = 8;
    final int columns = _resolveGridColumns(panelWidth);
    final double innerWidth = panelWidth - 20;
    final double tileWidth = ((innerWidth - (gap * (columns - 1))) / columns)
        .clamp(72.0, innerWidth);

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: visibleRefs.asMap().entries.map((indexedRef) {
        final int visibleIndex = indexedRef.key;
        final ref = indexedRef.value;
        final entry = ref.entry;
        final onPressed = _resolveOnPressed(entry.key, isEventActive);

        return _buildActionTile(
          context: context,
          entry: entry,
          onPressed: onPressed,
          itemWidth: tileWidth,
          isEditMode: _isEditMode,
          isFavorite: _favoriteEntryKeys.contains(entry.key),
          canMoveUp: visibleIndex > 0,
          canMoveDown: visibleIndex < visibleRefs.length - 1,
          onMoveUp: () => _moveEntryByStep(entry.key, -1),
          onMoveDown: () => _moveEntryByStep(entry.key, 1),
          onToggleFavorite: () => _toggleFavorite(entry.key),
          onToggleHidden: () => _toggleHidden(entry.key),
          tooltip: _resolveTooltip(entry, isEventActive),
        );
      }).toList(),
    );
  }

  // 상단 우측에 사용하는 아이콘 전용 버튼 (메뉴 버튼과 시각적 통일성 유지)
  Widget _buildTopIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: isDark
                  ? Colors.white.withAlpha(6)
                  : theme.colorScheme.surface.withAlpha(100),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(26)
                    : theme.colorScheme.outline.withAlpha(56),
              ),
            ),
            child: Center(
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;
    final double topPadding = mediaQuery.padding.top;
    final Size screenSize = MediaQuery.of(context).size;
    const double panelMaxWidth = 820;
    const double horizontalInset = 20;
    final double panelWidth =
        (screenSize.width - (horizontalInset * 2)).clamp(280.0, panelMaxWidth);

    final bool isEventActive = EventManager.isEventPeriodActive();
    final bool settingsComplete = _areEssentialSettingsSet();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity:
                          theme.brightness == Brightness.dark ? 0.56 : 0.68,
                      child: Image.asset(
                        'assets/images/main_logo.png',
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 220,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: theme.brightness == Brightness.dark
                            ? [
                                Colors.transparent,
                                Colors.black.withAlpha(42),
                              ]
                            : [
                                Colors.transparent,
                                Colors.black.withAlpha(14),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topPadding + 10,
                left: horizontalInset,
                right: horizontalInset,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (_noticeMessage.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withAlpha(6)
                                    : theme.colorScheme.surface.withAlpha(96),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white.withAlpha(24)
                                      : theme.colorScheme.outline.withAlpha(52),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.campaign_rounded,
                                    size: 15,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _noticeMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 10),
                        _buildTopIconButton(
                          context: context,
                          icon: _isEditMode
                              ? Icons.check_circle_outline_rounded
                              : Icons.edit_note_rounded,
                          onPressed: () {
                            setState(() {
                              _isEditMode = !_isEditMode;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildTopIconButton(
                          context: context,
                          icon: _gridColumnsOverride == null
                              ? Icons.grid_view_rounded
                              : Icons.grid_on_rounded,
                          onPressed: _showGridModeSheet,
                        ),
                        const SizedBox(width: 8),
                        _buildTopIconButton(
                          context: context,
                          icon: Icons.settings_applications_outlined,
                          onPressed: widget.onAppSettingsPressed,
                        ),
                      ],
                    ),
                    // 설정 미완료 배너
                    if (!settingsComplete) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: widget.onStageSettingsPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(14)),
                            color:
                                theme.colorScheme.errorContainer.withAlpha(130),
                            border: Border.all(
                              color: theme.colorScheme.error.withAlpha(95),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 15,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '스테이지 설정을 먼저 진행 해 주세요',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 14 + bottomPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: panelWidth,
                      maxHeight: screenSize.height * 0.64,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isEditMode && _hiddenEntryKeys.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 8, 10, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '숨긴 버튼 (탭해서 다시 표시)',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            color: theme.brightness ==
                                                    Brightness.dark
                                                ? Colors.black.withAlpha(120)
                                                : Colors.white.withAlpha(200),
                                            blurRadius: 2,
                                            offset: const Offset(0, 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children:
                                          _hiddenEntryKeys.map((entryKey) {
                                        final entry = _findEntryByKey(entryKey);
                                        if (entry == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return ActionChip(
                                          avatar: Icon(
                                            _menuIcons[entry.text] ??
                                                Icons.apps_rounded,
                                            size: 14,
                                          ),
                                          label: Text(entry.text),
                                          onPressed: () =>
                                              _toggleHidden(entryKey),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            _buildIconGrid(
                              context: context,
                              isEventActive: isEventActive,
                              panelWidth: panelWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection {
  final String id;
  final String title;
  final List<_MenuEntry> items;

  _MenuSection({
    required this.id,
    required this.title,
    required this.items,
  });
}

class _EntryRef {
  final String sectionId;
  final int itemIndex;
  final _MenuEntry entry;

  const _EntryRef({
    required this.sectionId,
    required this.itemIndex,
    required this.entry,
  });
}

class _MenuEntry {
  final String key;
  final String text;
  final String subtitle;
  final String? tooltip;

  const _MenuEntry({
    required this.key,
    required this.text,
    required this.subtitle,
    this.tooltip,
  });
}
