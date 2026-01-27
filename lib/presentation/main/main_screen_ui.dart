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

  // 기존 버튼 빌더 함수 (그대로 유지)
  Widget _buildBlurredButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    double fontSize = 16,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha((0.4 * 255).round()),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: colorScheme.secondary.withAlpha((0.5 * 255).round()))
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.8);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> menuButtonConfigs = [
      {'text': '루프 계산기', 'onPressed': widget.onCalculatorPressed, 'fontSize': 16.0},
      {'text': '골드 효율 계산기', 'onPressed': widget.onGoldCalculatorPressed, 'fontSize': 16.0},
      {'text': '데미지 계산기', 'onPressed': widget.onDamageCalculatorPressed, 'fontSize': 16.0},
      {'text': '악세사리 도감', 'onPressed': widget.onAccessoryPressed, 'fontSize': 16.0},
      {'text': '일지', 'onPressed': widget.onJournalPressed, 'fontSize': 16.0},
      if (EventManager.isEventPeriodActive())
        {'text': '상자 기대값 계산기', 'onPressed': widget.onBoxCalculatorPressed, 'fontSize': 16.0},
      {'text': '악세 강화 시뮬', 'onPressed': widget.onAccessoryEnhancementPressed, 'fontSize': 14.0},
      {'text': '악세 옵변 시뮬', 'onPressed': widget.onAccessoryOptionChangePressed, 'fontSize': 14.0},
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: Colors.black.withOpacity(0.3),
                    child: Text(
                      _noticeMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
              child: SizedBox(
                height: screenHeight * 0.45,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: menuButtonConfigs.length,
                  itemBuilder: (context, index) {
                    final config = menuButtonConfigs[index];
                    return _buildBlurredButton(
                      context: context,
                      text: config['text'],
                      onPressed: config['onPressed'],
                      fontSize: config['fontSize'],
                    );
                  },
                ),
              ),
            ),
          ),
          
          // 상단 설정 버튼 영역
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
                  IconButton(
                    icon: Icon(Icons.settings_suggest, color: iconColor, size: 30),
                    onPressed: widget.onStageSettingsPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_applications_outlined, color: iconColor, size: 30),
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