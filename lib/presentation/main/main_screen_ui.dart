// lib/presentation/main/main_screen_ui.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:goh_calculator/core/services/settings_service.dart';
import '../../core/services/event_manager.dart';

class MainScreenUI extends StatelessWidget {
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

  Widget _buildBlurredButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    double fontSize = 18, // 폰트 크기 조절을 위한 파라미터 추가
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonWidth = MediaQuery.of(context).size.width * 0.6;

    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: buttonWidth,
            constraints: const BoxConstraints(minHeight: 40),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha((0.4 * 255).round()),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: colorScheme.secondary.withAlpha((0.5 * 255).round()))
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize, // 파라미터로 받은 폰트 크기 사용
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withAlpha((0.5 * 255).round()),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
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
    final double screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> menuButtons = [
      _buildBlurredButton(context: context, text: '루프 계산기', onPressed: onCalculatorPressed),
      const SizedBox(height: 12),
      _buildBlurredButton(context: context, text: '골드 효율 계산기', onPressed: onGoldCalculatorPressed),
      const SizedBox(height: 12),
      _buildBlurredButton(context: context, text: '데미지 계산기', onPressed: onDamageCalculatorPressed),
      const SizedBox(height: 12),
      _buildBlurredButton(context: context, text: '악세사리 도감', onPressed: onAccessoryPressed),
      const SizedBox(height: 12),
      _buildBlurredButton(context: context, text: '일지', onPressed: onJournalPressed),
      if (EventManager.isEventPeriodActive()) ...[
        const SizedBox(height: 12),
        _buildBlurredButton(context: context, text: '상자 기대값 계산기', onPressed: onBoxCalculatorPressed),
      ],
      const SizedBox(height: 12),
      _buildBlurredButton(context: context, text: '악세사리 강화 시뮬레이터', onPressed: onAccessoryEnhancementPressed, fontSize: 16),
      const SizedBox(height: 12),
      _buildBlurredButton(context: context, text: '악세사리 옵션 변경 시뮬레이터', onPressed: onAccessoryOptionChangePressed, fontSize: 16),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/main_logo.png',
            fit: BoxFit.contain,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.1 + bottomPadding,
                left: 20.0,
                right: 20.0,
              ),
              child: SizedBox(
                height: screenHeight * 0.5, // 버튼 목록이 차지할 최대 높이
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: menuButtons,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.settings_suggest, color: iconColor, size: 30),
                    tooltip: '스테이지 설정',
                    onPressed: onStageSettingsPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_applications_outlined, color: iconColor, size: 30),
                    tooltip: '앱 설정',
                    onPressed: onAppSettingsPressed,
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