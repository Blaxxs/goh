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
  final VoidCallback onDamageCalculatorPressed;
  final VoidCallback onJournalPressed;
  final VoidCallback onBoxCalculatorPressed;
  final VoidCallback onAccessoryEnhancementPressed;
  final VoidCallback onAccessoryOptionChangePressed;
  final VoidCallback onExplorationOptionSimulationPressed;
  final VoidCallback onPouchSimulationPressed;
  final VoidCallback onStageSettingsPressed;
  final VoidCallback onAppSettingsPressed;

  const MainScreenUI({
    super.key,
    required this.onCalculatorPressed,
    required this.onGoldCalculatorPressed,
    required this.onAccessoryPressed,
    required this.onDamageCalculatorPressed,
    required this.onJournalPressed,
    required this.onBoxCalculatorPressed,
    required this.onAccessoryEnhancementPressed,
    required this.onAccessoryOptionChangePressed,
    required this.onExplorationOptionSimulationPressed,
    required this.onPouchSimulationPressed,
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

  static const Map<String, IconData> _menuIcons = {
    '루프 계산기': Icons.calculate_rounded,
    '골드 효율 계산기': Icons.paid_rounded,
    '데미지 계산기_ Beta': Icons.flash_on_rounded,
    '악세사리 도감': Icons.diamond_outlined,
    '일지': Icons.calendar_month_rounded,
    '상자 기대값 계산기': Icons.inventory_2_rounded,
    '악세 강화 시뮬': Icons.auto_awesome_rounded,
    '악세 옵변 시뮬': Icons.swap_horiz_rounded,
    '탐 옵션 시뮬': Icons.explore_rounded,
    '주머니 시뮬': Icons.workspaces_outline,
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
      case 'journal':
        return widget.onJournalPressed;
      case 'box':
        return isEventActive ? widget.onBoxCalculatorPressed : null;
      case 'enhancement':
        return widget.onAccessoryEnhancementPressed;
      case 'optionChange':
        return widget.onAccessoryOptionChangePressed;
      case 'exploration':
        return widget.onExplorationOptionSimulationPressed;
      case 'pouch':
        return widget.onPouchSimulationPressed;
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

  void _toggleSectionExpanded(String sectionId) {
    final idx = _menuSections.indexWhere((section) => section.id == sectionId);
    if (idx == -1) return;
    setState(() {
      _menuSections[idx].expanded = !_menuSections[idx].expanded;
    });
  }

  void _moveSection(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= _menuSections.length) return;
    setState(() {
      final section = _menuSections.removeAt(fromIndex);
      _menuSections.insert(toIndex, section);
    });
  }

  void _moveEntryWithinSection(String sectionId, int fromIndex, int toIndex) {
    final sectionIndex =
        _menuSections.indexWhere((section) => section.id == sectionId);
    if (sectionIndex == -1) return;
    final items = _menuSections[sectionIndex].items;
    if (toIndex < 0 || toIndex >= items.length) return;
    setState(() {
      final entry = items.removeAt(fromIndex);
      items.insert(toIndex, entry);
    });
  }

  void _toggleFavorite(String entryKey) {
    setState(() {
      if (_favoriteEntryKeys.contains(entryKey)) {
        _favoriteEntryKeys.remove(entryKey);
      } else {
        _favoriteEntryKeys.add(entryKey);
      }
    });
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
          const _MenuEntry(key: 'gold', text: '골드 효율 계산기', subtitle: '루프 대비 수익'),
          const _MenuEntry(key: 'damage', text: '데미지 계산기_ Beta', subtitle: '대미지 검증'),
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
            key: 'enhancement',
            text: '악세 강화 시뮬',
            subtitle: '강화 기대값 계산',
          ),
          const _MenuEntry(
            key: 'optionChange',
            text: '악세 옵변 시뮬',
            subtitle: '옵션 변경 시뮬',
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

  // 액션 타일 버튼 (활성/비활성 지원)
  Widget _buildActionTile({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required double itemWidth,
    String? subtitle,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isEnabled = onPressed != null;

    final Color borderColor = isEnabled
      ? colorScheme.outline.withAlpha(isDark ? 150 : 125)
      : colorScheme.outline.withAlpha(90);
    final Color iconColor = isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(125);
    final Color titleColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withAlpha(130);

    final List<Color> backgroundColors = isEnabled
        ? (isDark
        ? [const Color(0xD9172537), const Color(0xCC122032)]
        : [const Color(0xE6FFFFFF), const Color(0xDBF4F8FF)])
        : (isDark
        ? [const Color(0xB8141D2A), const Color(0xB2101823)]
        : [const Color(0xDFF8FAFC), const Color(0xD8F0F4F8)]);

    Widget button = SizedBox(
      width: itemWidth,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(isEnabled ? 34 : 18)
                  : const Color(0xFF90A4C0).withAlpha(isEnabled ? 36 : 20),
              blurRadius: isEnabled ? 8 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(isDark ? 22 : 18),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      _menuIcons[text] ?? Icons.apps_rounded,
                      size: 14,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) - 0.1,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            height: 1.1,
                          ),
                      ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: titleColor.withAlpha(160),
                              height: 1.1,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: iconColor.withAlpha(isEnabled ? 170 : 90),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && !isEnabled) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required List<_MenuEntry> items,
    required double panelWidth,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    const double innerGap = 8;
    final int columns = panelWidth >= 640 ? 3 : 2;
    final double innerWidth = panelWidth - 20;
    final double tileWidth =
        (innerWidth - (innerGap * (columns - 1))).clamp(100.0, innerWidth) /
            columns;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withAlpha(10)
            : theme.colorScheme.surface.withAlpha(140),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(24)
              : theme.colorScheme.outline.withAlpha(72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(context, title),
          const SizedBox(height: 2),
          Wrap(
            spacing: innerGap,
            runSpacing: innerGap,
            children: items
                .map(
                  (entry) => _buildActionTile(
                    context: context,
                    text: entry.text,
                    subtitle: entry.subtitle,
                    onPressed: entry.onPressed,
                    itemWidth: tileWidth,
                    tooltip: entry.tooltip,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // 섹션 헤더 위젯
  Widget _buildSectionHeader(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2, left: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 상단 우측에 사용하는 아이콘 전용 버튼 (메뉴 버튼과 시각적 통일성 유지)
  Widget _buildTopIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 56,
      height: 56,
      child: GlassPanel(
        onTap: onPressed,
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Center(
          child: Icon(icon,
              color: Theme.of(context).colorScheme.primary, size: 24),
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

    // 섹션별 버튼 그룹
    final List<_MenuEntry> calculatorButtons = [
      _MenuEntry(text: '루프 계산기', subtitle: '스테이지 반복 계산', onPressed: widget.onCalculatorPressed),
      _MenuEntry(text: '골드 효율 계산기', subtitle: '루프 대비 수익', onPressed: widget.onGoldCalculatorPressed),
      _MenuEntry(text: '데미지 계산기_ Beta', subtitle: '대미지 검증', onPressed: widget.onDamageCalculatorPressed),
    ];
    final List<_MenuEntry> toolButtons = [
      _MenuEntry(text: '악세사리 도감', subtitle: '옵션 및 세트 확인', onPressed: widget.onAccessoryPressed),
      _MenuEntry(text: '일지', subtitle: '기록 및 추이 확인', onPressed: widget.onJournalPressed),
      _MenuEntry(
        text: '상자 기대값 계산기',
        subtitle: '이벤트 상자 기대값',
        onPressed: isEventActive ? widget.onBoxCalculatorPressed : null,
        tooltip: '이벤트 기간에만 사용 가능합니다',
      ),
    ];
    final List<_MenuEntry> simulatorButtons = [
      _MenuEntry(text: '악세 강화 시뮬', subtitle: '강화 기대값 계산', onPressed: widget.onAccessoryEnhancementPressed),
      _MenuEntry(text: '악세 옵변 시뮬', subtitle: '옵션 변경 시뮬', onPressed: widget.onAccessoryOptionChangePressed),
      _MenuEntry(text: '탐 옵션 시뮬', subtitle: '탐험 옵션 실험', onPressed: widget.onExplorationOptionSimulationPressed),
      _MenuEntry(text: '주머니 시뮬', subtitle: '주머니 획득 시뮬', onPressed: widget.onPouchSimulationPressed),
    ];
    final List<_MenuEntry> settingButtons = [
      _MenuEntry(text: '스테이지 설정', subtitle: '팀/달기지/VIP 설정', onPressed: widget.onStageSettingsPressed),
    ];

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
                            child: GlassPanel(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
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
                        child: GlassPanel(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
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
                    child: GlassPanel(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCategoryCard(
                              context: context,
                              title: '계산기',
                              items: calculatorButtons,
                              panelWidth: panelWidth,
                            ),
                            _buildCategoryCard(
                              context: context,
                              title: '도구 / 기록',
                              items: toolButtons,
                              panelWidth: panelWidth,
                            ),
                            _buildCategoryCard(
                              context: context,
                              title: '시뮬레이터',
                              items: simulatorButtons,
                              panelWidth: panelWidth,
                            ),
                            _buildCategoryCard(
                              context: context,
                              title: '설정',
                              items: settingButtons,
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

class _MenuEntry {
  final String text;
  final String subtitle;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _MenuEntry({
    required this.text,
    required this.subtitle,
    required this.onPressed,
    this.tooltip,
  });
}
