import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // [추가]
import 'package:goh_calculator/core/services/settings_service.dart';
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

  // [수정] 가시성을 높이고 반응형 디자인을 적용한 버튼 빌더
  Widget _buildMenuButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // ignore: deprecated_member_use
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: BorderSide(
          // ignore: deprecated_member_use
          color: colorScheme.secondary.withOpacity(0.7),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true, // 텍스트가 길 경우 자동으로 줄바꿈
        style: TextStyle(
          fontSize: 15, // 모든 버튼의 폰트 사이즈를 15로 통일
          fontWeight: FontWeight.bold,
          color: colorScheme.secondary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // ignore: deprecated_member_use
          backgroundColor: colorScheme.surface.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(
            // ignore: deprecated_member_use
            color: colorScheme.secondary.withOpacity(0.7),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, color: colorScheme.secondary, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final Color iconColor unused removed; top buttons use unified style
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> menuButtonConfigs = [
      {'text': '루프 계산기', 'onPressed': widget.onCalculatorPressed},
      {'text': '골드 효율 계산기', 'onPressed': widget.onGoldCalculatorPressed},
      {'text': '데미지 계산기', 'onPressed': widget.onDamageCalculatorPressed},
      {'text': '악세사리 도감', 'onPressed': widget.onAccessoryPressed},
      {'text': '일지', 'onPressed': widget.onJournalPressed},
      if (EventManager.isEventPeriodActive())
        {'text': '상자 기대값 계산기', 'onPressed': widget.onBoxCalculatorPressed},
      {'text': '악세 강화 시뮬', 'onPressed': widget.onAccessoryEnhancementPressed},
      {'text': '악세 옵변 시뮬', 'onPressed': widget.onAccessoryOptionChangePressed},
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/main_logo.png',
            fit: BoxFit.contain,
          ),

          // [추가] 실시간 공지사항 영역 (화면 상단)
          if (_noticeMessage.isNotEmpty)
            Positioned(
              top: topPadding + 10,
              left: 16,
              right: 100, // 설정 아이콘들과 겹치지 않게 여백 확보
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                    child: Text(
                      _noticeMessage,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis, // 길면 생략
                    ),
                  ),
                ),
              ),
            ),

          // 하단 버튼 영역
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.05 + bottomPadding,
                left: 20.0,
                right: 20.0,
              ),
              child: Wrap(
                spacing: 12.0, // 버튼 사이의 가로 간격
                runSpacing: 12.0, // 버튼 사이의 세로 간격
                alignment: WrapAlignment.center,
                children: menuButtonConfigs.map((config) {
                  return _buildMenuButton(
                    context: context,
                    text: config['text'],
                    onPressed: config['onPressed'],
                  );
                }).toList(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding + 10.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 통일된 스타일의 작은 아이콘 버튼 사용
                  _buildTopIconButton(
                    context: context,
                    icon: Icons.settings_suggest,
                    onPressed: widget.onStageSettingsPressed,
                  ),
                  const SizedBox(width: 8),
                  _buildTopIconButton(
                    context: context,
                    icon: Icons.settings_applications_outlined,
                    onPressed: widget.onAppSettingsPressed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
