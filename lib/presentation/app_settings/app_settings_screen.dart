// lib/app_settings_screen.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/services/settings_service.dart';
import 'app_settings_screen_ui.dart'; // UI 파일 import

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

  Future<String> _readWebVersionFromManifest() async {
    if (!kIsWeb) {
      return '버전 정보를 가져올 수 없습니다.';
    }

    try {
      final response = await http.get(Uri.base.resolve('version.json'));
      if (response.statusCode != 200) {
        return '버전 정보를 가져올 수 없습니다.';
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final version = (decoded['version'] ?? '').toString().trim();
      final buildNumber = (decoded['build_number'] ?? '').toString().trim();
      if (version.isEmpty) {
        return '버전 정보를 가져올 수 없습니다.';
      }

      return buildNumber.isEmpty ? version : '$version ($buildNumber)';
    } catch (_) {
      return '버전 정보를 가져올 수 없습니다.';
    }
  }

  // 앱 버전 정보를 비동기적으로 로드하는 함수
  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final versionText = packageInfo.version.trim();
      final buildText = packageInfo.buildNumber.trim();
      final resolvedVersion = versionText.isEmpty
          ? '버전 정보를 가져올 수 없습니다.'
          : buildText.isEmpty
              ? versionText
              : '$versionText ($buildText)';

      if (mounted) {
        setState(() {
          _appVersion = resolvedVersion;
        });
      }
      return;
    } catch (_) {
      // 웹 배포 환경에서는 version.json이 더 안정적인 값 소스가 될 수 있습니다.
    }

    final fallbackVersion = await _readWebVersionFromManifest();
    if (mounted) {
      setState(() {
        _appVersion = fallbackVersion;
      });
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
