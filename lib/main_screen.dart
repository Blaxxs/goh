// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'settings_screen.dart'; // 스테이지 설정 화면
import 'presentation/main/main_screen_ui.dart';
import 'app_settings_screen.dart'; // 앱 설정 화면 import
import 'services/settings_service.dart'; // SettingsService import

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // 필수 설정 확인 함수
  bool _areEssentialSettingsSet() {
    final settings = SettingsService.instance.stageSettings;
    return settings.teamLevel != null && settings.teamLevel!.isNotEmpty &&
           settings.dalgijiLevel != null && settings.dalgijiLevel!.isNotEmpty &&
           settings.vipLevel != null && settings.vipLevel!.isNotEmpty;
  }

  // Helper function to create a TextTheme with scaled font sizes
  TextTheme _buildScaledTextTheme(TextTheme baseTextTheme, double multiplier) {
    // 주요 텍스트 스타일들에 대해 fontSize를 명시적으로 계산하여 적용
    // null일 경우를 대비해 기본값을 사용하고, 그 값에 multiplier를 곱합니다.
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: (baseTextTheme.displayLarge?.fontSize ?? 96.0) * multiplier),
      displayMedium: baseTextTheme.displayMedium?.copyWith(fontSize: (baseTextTheme.displayMedium?.fontSize ?? 60.0) * multiplier),
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontSize: (baseTextTheme.displaySmall?.fontSize ?? 48.0) * multiplier),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 34.0) * multiplier),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 24.0) * multiplier),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 20.0) * multiplier),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22.0) * multiplier),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16.0) * multiplier),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14.0) * multiplier),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16.0) * multiplier),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14.0) * multiplier),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12.0) * multiplier),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14.0) * multiplier),
      labelMedium: baseTextTheme.labelMedium?.copyWith(fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12.0) * multiplier),
      labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: (baseTextTheme.labelSmall?.fontSize ?? 10.0) * multiplier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double currentFontSizeMultiplier = SettingsService.instance.fontSizeNotifier.value;

    // ThemeData.dark()를 가져온 후, 해당 TextTheme에 multiplier를 적용
    final ThemeData baseDarkTheme = ThemeData.dark();
    final TextTheme scaledDarkTextTheme = _buildScaledTextTheme(baseDarkTheme.textTheme, currentFontSizeMultiplier);

    final ThemeData mainScreenDarkTheme = baseDarkTheme.copyWith(
      textTheme: scaledDarkTextTheme,
      // 필요하다면 main.dart의 _buildTheme에서 사용한 특정 색상들을 여기에 추가로 copyWith 할 수 있습니다.
      // 예: colorScheme: baseDarkTheme.colorScheme.copyWith(secondary: YourAppSpecificDarkAccentColor),
    );

    return Theme(
      data: mainScreenDarkTheme,
      child: MainScreenUI(
        onStartPressed: () {
          if (_areEssentialSettingsSet()) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalculatorScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
      ),
    );
  }
}