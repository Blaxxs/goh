// lib/main_screen.dart
import 'package:flutter/material.dart';
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
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenUI(
        onCalculatorPressed: () {
          _navigateToScreen(context, const CalculatorScreen());
        },
        onGoldCalculatorPressed: () {
          _navigateToScreen(context, const GoldCalculatorScreen());
        },
        onAccessoryPressed: () {
          _navigateToScreen(context, const AccessoryScreen());
        },
        onDamageCalculatorPressed: () {
          _navigateToScreen(context, const DamageCalculatorScreen());
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
      );
  }
}
