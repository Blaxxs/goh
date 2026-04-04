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

  @override
  void initState() {
    super.initState();
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

  // 메뉴 버튼 (활성/비활성 지원)
  Widget _buildMenuButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required double itemWidth,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isEnabled = onPressed != null;

    final Color borderColor = isEnabled
        ? colorScheme.primary.withAlpha(isDark ? 170 : 155)
        : colorScheme.outline.withAlpha(95);
    final Color iconColor = isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(125);
    final Color titleColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withAlpha(130);

    final List<Color> backgroundColors = isEnabled
        ? (isDark
            ? [const Color(0xFF1A2A43), const Color(0xFF16263D)]
            : [const Color(0xFFFDFEFF), const Color(0xFFF0F6FF)])
        : (isDark
            ? [const Color(0xFF131D2D), const Color(0xFF101927)]
            : [const Color(0xFFF7F9FC), const Color(0xFFEFF3F8)]);

    Widget button = SizedBox(
      width: itemWidth,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(isEnabled ? 60 : 26)
                  : const Color(0xFF8EA2C5).withAlpha(isEnabled ? 80 : 38),
              blurRadius: isEnabled ? 14 : 8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(isDark ? 34 : 28),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _menuIcons[text] ?? Icons.apps_rounded,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) - 0.3,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: iconColor.withAlpha(isEnabled ? 220 : 110),
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
    const double panelMaxWidth = 700;
    const double horizontalInset = 20;
    const double menuGap = 6;
    const double panelHorizontalPadding = 18;
    const double targetTileWidth = 164;
    final double panelWidth =
      (screenSize.width - (horizontalInset * 2)).clamp(280.0, panelMaxWidth);
    final double panelContentWidth = panelWidth - panelHorizontalPadding;
    final int rawColumns =
      ((panelContentWidth + menuGap) / (targetTileWidth + menuGap)).floor();
    final int columns = rawColumns < 2 ? 2 : (rawColumns > 4 ? 4 : rawColumns);
    final double availableWidth =
      panelWidth - panelHorizontalPadding - (menuGap * (columns - 1));
    final double menuItemWidth = availableWidth / columns;

    final bool isEventActive = EventManager.isEventPeriodActive();
    final bool settingsComplete = _areEssentialSettingsSet();

    // 섹션별 버튼 그룹
    final List<Map<String, dynamic>> calculatorButtons = [
      {'text': '루프 계산기', 'onPressed': widget.onCalculatorPressed, 'needsSettings': true},
      {'text': '골드 효율 계산기', 'onPressed': widget.onGoldCalculatorPressed, 'needsSettings': true},
      {'text': '데미지 계산기_ Beta', 'onPressed': widget.onDamageCalculatorPressed, 'needsSettings': true},
    ];
    final List<Map<String, dynamic>> toolButtons = [
      {'text': '악세사리 도감', 'onPressed': widget.onAccessoryPressed, 'needsSettings': false},
      {'text': '일지', 'onPressed': widget.onJournalPressed, 'needsSettings': false},
      {
        'text': '상자 기대값 계산기',
        'onPressed': isEventActive ? widget.onBoxCalculatorPressed : null,
        'tooltip': '이벤트 기간에만 사용 가능합니다',
        'needsSettings': false,
      },
    ];
    final List<Map<String, dynamic>> simulatorButtons = [
      {'text': '악세 강화 시뮬', 'onPressed': widget.onAccessoryEnhancementPressed, 'needsSettings': false},
      {'text': '악세 옵변 시뮬', 'onPressed': widget.onAccessoryOptionChangePressed, 'needsSettings': false},
      {'text': '탐 옵션 시뮬', 'onPressed': widget.onExplorationOptionSimulationPressed, 'needsSettings': false},
      {'text': '주머니 시뮬', 'onPressed': widget.onPouchSimulationPressed, 'needsSettings': false},
    ];
    final List<Map<String, dynamic>> settingButtons = [
      {'text': '스테이지 설정', 'onPressed': widget.onStageSettingsPressed, 'needsSettings': false},
    ];

    Widget buildSection(String label, List<Map<String, dynamic>> buttons) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(context, label),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: menuGap,
            runSpacing: menuGap,
            children: buttons.map((config) {
              final VoidCallback? onPressed = config['onPressed'] as VoidCallback?;
              return _buildMenuButton(
                context: context,
                text: config['text'] as String,
                onPressed: onPressed,
                itemWidth: menuItemWidth,
                tooltip: config['tooltip'] as String?,
              );
            }).toList(),
          ),
        ],
      );
    }

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
                                Colors.black.withAlpha(76),
                              ]
                            : [
                                Colors.transparent,
                                Colors.black.withAlpha(28),
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
                  child: SizedBox(
                    width: panelWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withAlpha(40)
                              : theme.colorScheme.outline.withAlpha(120),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black.withAlpha(55)
                                : Colors.black.withAlpha(24),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: GlassPanel(
                        padding: const EdgeInsets.fromLTRB(9, 4, 9, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSection('계산기', calculatorButtons),
                            buildSection('도구 / 기록', toolButtons),
                            buildSection('시뮬레이터', simulatorButtons),
                            buildSection('설정', settingButtons),
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

class _MenuTileMetrics {
  final double height;
  final int maxLines;
  final TextStyle textStyle;

  _MenuTileMetrics({
    required this.height,
    required this.maxLines,
    required this.textStyle,
  });
}
