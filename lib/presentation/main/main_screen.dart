// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../calculator/calculator_screen.dart';
import '../stage_settings/settings_screen.dart'; // 스테이지 설정 화면
import 'main_screen_ui.dart';
import '../app_settings/app_settings_screen.dart'; // 앱 설정 화면 import
import '../../core/services/settings_service.dart'; // SettingsService import
import '../gold_calculator/gold_calculator_screen.dart';
import '../accessory/accessory_screen.dart';
import '../damage_calculator/damage_calculator_screen.dart';
import '../journal/journal_screen.dart';
import '../../core/services/event_manager.dart';
import '../box_calculator/box_calculator_screen.dart';
import '../simulator/accessory_enhancement_screen.dart';
import '../simulator/accessory_option_change_screen.dart';
import '../simulator/exploration_option_simulation_screen.dart';
import '../simulator/pouch_simulation_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime? _lastBackPressed;

  // 필수 설정 확인 함수
  bool _areEssentialSettingsSet() {
    final settings = SettingsService.instance.stageSettings;
    return settings.teamLevel != null &&
        settings.teamLevel!.isNotEmpty &&
        settings.dalgijiLevel != null &&
        settings.dalgijiLevel!.isNotEmpty &&
        settings.vipLevel != null &&
        settings.vipLevel!.isNotEmpty;
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showSettingsSnackbar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const SettingsScreen(isSetupMode: true)), // isSetupMode 추가
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 자동 pop 방지
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }

        final now = DateTime.now();
        const backPressDuration = Duration(seconds: 2);

        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > backPressDuration) {
          // 첫 번째 뒤로가기 또는 2초 이상 지남
          setState(() {
            _lastBackPressed = now;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('뒤로가기 버튼을 한 번 더 누르면 종료됩니다.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // 2초 이내 두 번째 뒤로가기 - 앱 종료
          SystemNavigator.pop();
        }
      },
      child: MainScreenUI(
        onCalculatorPressed: () {
          if (_areEssentialSettingsSet()) {
            _navigateToScreen(context, const CalculatorScreen());
          } else {
            _showSettingsSnackbar(context);
          }
        },
        onGoldCalculatorPressed: () {
          if (_areEssentialSettingsSet()) {
            _navigateToScreen(context, const GoldCalculatorScreen());
          } else {
            _showSettingsSnackbar(context);
          }
        },
        onAccessoryPressed: () {
          _navigateToScreen(context, const AccessoryScreen());
        },
        onDamageCalculatorPressed: () {
          if (_areEssentialSettingsSet()) {
            _navigateToScreen(context, const DamageCalculatorScreen());
          } else {
            _showSettingsSnackbar(context);
          }
        },
        onJournalPressed: () {
          _navigateToScreen(context, const JournalScreen());
        },
        onBoxCalculatorPressed: () {
          if (EventManager.isEventPeriodActive()) {
            _navigateToScreen(context, const BoxCalculatorScreen());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이벤트 기간이 아닙니다.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onAccessoryEnhancementPressed: () {
          _navigateToScreen(context, const AccessoryEnhancementScreen());
        },
        onAccessoryOptionChangePressed: () {
          _navigateToScreen(context, const AccessoryOptionChangeScreen());
        },
        onExplorationOptionSimulationPressed: () {
          _navigateToScreen(context, const ExplorationOptionSimulationScreen());
        },
        onPouchSimulationPressed: () {
          _navigateToScreen(context, const PouchSimulationScreen());
        },
        onStageSettingsPressed: () {
          _navigateToScreen(context, const SettingsScreen());
        },
        onAppSettingsPressed: () {
          _navigateToScreen(context, const AppSettingsScreen());
        },
        settingsService: SettingsService.instance,
      ),
    );
  }
}
