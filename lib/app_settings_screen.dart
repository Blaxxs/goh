// lib/app_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // package_info_plus 임포트
import 'services/settings_service.dart';
import 'presentation/app_settings/app_settings_screen_ui.dart'; // UI 파일 import

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late bool _isDarkModeEnabled;
  late double _fontSizeMultiplier;
  String _appVersion = '버전 정보 로딩 중...'; // 앱 버전 상태 변수 추가

  @override
  void initState() {
    super.initState();
    final currentAppSettings = SettingsService.instance.appSettings;
    _isDarkModeEnabled = currentAppSettings.isDarkModeEnabled;
    _fontSizeMultiplier = currentAppSettings.fontSizeMultiplier;
    _loadAppVersion(); // 앱 버전 로드 함수 호출
  }

  // 앱 버전 정보를 비동기적으로 로드하는 함수
  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) { // 위젯이 여전히 마운트 상태인지 확인
        setState(() {
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
// print('앱 버전 정보를 가져오는 데 실패했습니다: $e');
      if (mounted) {
        setState(() {
          _appVersion = '버전 정보를 가져올 수 없습니다.';
        });
      }
    }
  }

  void _handleDarkModeChange(bool value) {
    setState(() {
      _isDarkModeEnabled = value;
    });
    final newAppSettings = SettingsService.instance.appSettings.copyWith(
      isDarkModeEnabled: value,
    );
    SettingsService.instance.saveAppSettings(newAppSettings);
  }

  void _handleFontSizeChange(double value) {
    setState(() {
      _fontSizeMultiplier = value;
    });
    final newAppSettings = SettingsService.instance.appSettings.copyWith(
      fontSizeMultiplier: value,
    );
    SettingsService.instance.saveAppSettings(newAppSettings);
  }

  @override
  Widget build(BuildContext context) {
    // 여기서 UI 위젯인 AppSettingsScreenUI를 사용합니다.
    return AppSettingsScreenUI(
      isDarkModeEnabled: _isDarkModeEnabled,
      onDarkModeChanged: _handleDarkModeChange,
      currentFontSizeMultiplier: _fontSizeMultiplier,
      onFontSizeMultiplierChanged: _handleFontSizeChange,
      appVersion: _appVersion, // 로드된 앱 버전 정보를 UI 위젯에 전달
    );
  }
}