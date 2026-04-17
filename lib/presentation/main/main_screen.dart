// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../calculator/calculator_screen.dart';
import '../stage_settings/settings_screen.dart'; // 스테이지 설정 화면
import 'main_screen_ui.dart';
import '../app_settings/app_settings_screen.dart'; // 앱 설정 화면 import
import '../../core/services/settings_service.dart'; // SettingsService import
import '../../core/constants/accessory_constants.dart';
import '../gold_calculator/gold_calculator_screen.dart';
import '../accessory/accessory_screen.dart';
import '../damage_calculator/damage_calculator_screen.dart';
import '../journal/journal_screen.dart';
import '../../core/services/event_manager.dart';
import '../box_calculator/box_calculator_screen.dart';
import '../simulator/accessory_enhancement_screen.dart';
import '../simulator/accessory_option_change_screen.dart';
import '../simulator/accessory_simulation_screen.dart';
import '../simulator/exploration_option_simulation_screen.dart';
import '../simulator/pouch_simulation_screen.dart';
import '../simulator/random_accessory_simulator_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _quickWarmupCount = 24;

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _openAccessoryScreenWithWarmup() async {
    final warmupFuture = _warmupAccessoryImageCache(limit: _quickWarmupCount);
    await Future.any<void>([
      warmupFuture,
      Future<void>.delayed(const Duration(milliseconds: 350)),
    ]);

    if (!mounted) return;
    _navigateToScreen(context, const AccessoryScreen());
  }

  Future<void> _warmupAccessoryImageCache({required int limit}) async {
    final urls = await AccessoryDataManager().getPrioritizedAccessoryImageUrls(
      limit: limit,
    );
    if (urls.isEmpty) return;

    await Future.wait(urls.map((url) async {
      try {
        await DefaultCacheManager().downloadFile(url);
      } catch (_) {
        // 선로딩 실패는 무시하고 실제 화면 렌더 시 재시도한다.
      }
    }));
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
        onAccessoryPressed: () async {
          await _openAccessoryScreenWithWarmup();
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
          _navigateToScreen(context, const AccessorySimulationScreen());
        },
        onAccessoryOptionChangePressed: () {
          _navigateToScreen(context, const AccessorySimulationScreen());
        },
        onExplorationOptionSimulationPressed: () {
          _navigateToScreen(context, const ExplorationOptionSimulationScreen());
        },
        onPouchSimulationPressed: () {
          _navigateToScreen(context, const PouchSimulationScreen());
        },
        onRandomAccessorySimulatorPressed: () {
          _navigateToScreen(context, const AccessorySimulationScreen());
        },
        onAccessorySimulationPressed: () {
          _navigateToScreen(context, const AccessorySimulationScreen());
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
