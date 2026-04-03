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
    '스테이지 설정': Icons.tune_rounded,
    '골드 효율 계산기': Icons.paid_rounded,
    '데미지 계산기_ Beta': Icons.flash_on_rounded,
    '악세사리 도감': Icons.diamond_outlined,
    '일지': Icons.calendar_month_rounded,
    '상자 기대값 계산기': Icons.inventory_2_rounded,
    '악세 강화 시뮬': Icons.auto_awesome_rounded,
    '악세 옵변 시뮬': Icons.swap_horiz_rounded,
    '탐 옵션 시뮬': Icons.explore_rounded,
    '주머니 시뮬': Icons.workspaces_outline,
  };

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

  // 작은 런처 버튼으로 밀도를 높여 한 화면에 보기 쉽게 배치
  Widget _buildMenuButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required double itemWidth,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: itemWidth,
      child: GlassPanel(
        onTap: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _menuIcons[text] ?? Icons.apps_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
    final int columns = screenSize.width >= 900
        ? 6
        : screenSize.width >= 650
            ? 5
            : screenSize.width >= 420
                ? 4
                : 3;
    const double horizontalInset = 20;
    const double menuGap = 8;
    final double availableWidth =
        screenSize.width - (horizontalInset * 2) - (menuGap * (columns - 1));
    final double menuItemWidth = availableWidth / columns;

    final List<Map<String, dynamic>> menuButtonConfigs = [
      {'text': '루프 계산기', 'onPressed': widget.onCalculatorPressed},
      {'text': '스테이지 설정', 'onPressed': widget.onStageSettingsPressed},
      {'text': '골드 효율 계산기', 'onPressed': widget.onGoldCalculatorPressed},
      {'text': '데미지 계산기_ Beta', 'onPressed': widget.onDamageCalculatorPressed},
      {'text': '악세사리 도감', 'onPressed': widget.onAccessoryPressed},
      {'text': '일지', 'onPressed': widget.onJournalPressed},
      if (EventManager.isEventPeriodActive())
        {'text': '상자 기대값 계산기', 'onPressed': widget.onBoxCalculatorPressed},
      {'text': '악세 강화 시뮬', 'onPressed': widget.onAccessoryEnhancementPressed},
      {'text': '악세 옵변 시뮬', 'onPressed': widget.onAccessoryOptionChangePressed},
      {
        'text': '탐 옵션 시뮬',
        'onPressed': widget.onExplorationOptionSimulationPressed
      },
      {'text': '주머니 시뮬', 'onPressed': widget.onPouchSimulationPressed},
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
                top: topPadding + 10,
                left: horizontalInset,
                right: horizontalInset,
                child: Row(
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
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      horizontalInset, 0, horizontalInset, 14 + bottomPadding),
                  child: GlassPanel(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Wrap(
                      spacing: menuGap,
                      runSpacing: menuGap,
                      children: menuButtonConfigs.map((config) {
                        return _buildMenuButton(
                          context: context,
                          text: config['text'] as String,
                          onPressed: config['onPressed'] as VoidCallback,
                          itemWidth: menuItemWidth,
                        );
                      }).toList(),
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
