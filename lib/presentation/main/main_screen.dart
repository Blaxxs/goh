// lib/main_screen.dart
import 'package:flutter/material.dart';
import '../calculator/calculator_screen.dart';
import '../stage_settings/settings_screen.dart'; // 스테이지 설정 화면
import 'main_screen_ui.dart';
import '../app_settings/app_settings_screen.dart'; // 앱 설정 화면 import
import '../../core/services/settings_service.dart'; // SettingsService import

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // 필수 설정 확인 함수
  bool _areEssentialSettingsSet() {
    final settings = SettingsService.instance.stageSettings;
    return settings.teamLevel != null && settings.teamLevel!.isNotEmpty &&
           settings.dalgijiLevel != null && settings.dalgijiLevel!.isNotEmpty &&
           settings.vipLevel != null && settings.vipLevel!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // final double currentFontSizeMultiplier = SettingsService.instance.fontSizeNotifier.value;
    // MainScreen은 MaterialApp에서 제공하는 테마를 상속받으므로, 여기서 Theme 위젯으로 감쌀 필요가 없습니다.
    // 폰트 크기 배율은 main.dart에서 이미 적용됩니다.
    return MainScreenUI(
        onStartPressed: () {
          if (_areEssentialSettingsSet()) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalculatorScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen(isSetupMode: true)), // isSetupMode 추가
            ).then((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('팀 레벨, 달기지 레벨, VIP 등급을 먼저 설정해주세요.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
          }
        },
        onAppSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
          );
        },
        settingsService: SettingsService.instance,
      );
  }
}