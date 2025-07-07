// lib/presentation/main/main_screen_ui.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:goh_calculator/core/services/settings_service.dart';

class MainScreenUI extends StatelessWidget {
  final VoidCallback onStartPressed;
  // final VoidCallback onStageSettingsPressed; // 제거됨
  final VoidCallback onAppSettingsPressed;

  const MainScreenUI({
    super.key,
    required this.onStartPressed,
    // required this.onStageSettingsPressed, // 제거됨
    required this.onAppSettingsPressed, required SettingsService settingsService,
  });

  Widget _buildBlurredButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: buttonWidth,
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha((0.4 * 255).round()),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: colorScheme.secondary.withAlpha((0.5 * 255).round()))
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, // 기본 폰트 크기 (main.dart에서 배율 적용됨)
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
    // ignore: deprecated_member_use
    final Color iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.8);
    final double bottomPadding = MediaQuery.of(context).padding.bottom; // 시스템 하단 패딩
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/main_logo.png',
            fit: BoxFit.contain,
          ),
          Align(
            // 버튼의 Y축 위치 조정 (0.0은 중앙, 1.0은 하단)
            // 예를 들어 0.6 정도로 설정하면 중앙보다 약간 아래, 이전보다는 위로 이동합니다.
            // 또는 SizedBox와 Spacer를 활용하여 위치를 조절할 수도 있습니다.
            // 여기서는 Padding의 bottom 값을 화면 높이의 일정 비율로 설정하여 위로 올립니다.
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                // 화면 높이의 예를 들어 20% 만큼을 하단 여백으로 설정 (버튼이 위로 올라감)
                // 기존 50.0 고정값 대신 화면 비율에 따라 조절
                bottom: screenHeight * 0.15 + bottomPadding, // 하단에서 화면 높이의 20% + 시스템 패딩만큼 위로
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBlurredButton(
                    context: context,
                    text: '시작하기',
                    onPressed: onStartPressed,
                  ),
                  // 만약 다른 버튼이 추가된다면 여기에 SizedBox 등으로 간격 조절
                ],
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
              child: IconButton(
                icon: Icon(Icons.settings_applications_outlined, color: iconColor, size: 30),
                tooltip: '앱 설정',
                onPressed: onAppSettingsPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}