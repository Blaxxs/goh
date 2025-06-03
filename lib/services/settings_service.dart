// lib/services/settings_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // ThemeMode, ValueNotifier 사용
import 'package:path_provider/path_provider.dart';
import '../constants/leader_constants.dart';
import '../constants/stage_constants.dart'; // stageNameList 사용

// --- AppSettings 클래스 정의 수정 ---
class AppSettings {
  final bool isDarkModeEnabled;
  final double fontSizeMultiplier; // 글꼴 크기 배율 추가

  AppSettings({
    this.isDarkModeEnabled = false,
    this.fontSizeMultiplier = 1.0, // 기본값 1.0 (100%)
  });

  AppSettings copyWith({
    bool? isDarkModeEnabled,
    double? fontSizeMultiplier, // copyWith에 추가
  }) {
    return AppSettings(
      isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier, // 추가
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkModeEnabled: json['isDarkModeEnabled'] as bool? ?? false,
      // JSON에서 double로 읽고, 없거나 타입 안맞으면 기본값 1.0
      fontSizeMultiplier: (json['fontSizeMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkModeEnabled': isDarkModeEnabled,
      'fontSizeMultiplier': fontSizeMultiplier, // toJson에 추가
    };
  }
}
// --- AppSettings 클래스 정의 끝 ---

// CalculatorSettings 클래스 (변경 없음)
class CalculatorSettings {
  final bool expHotTime;
  final bool goldHotTime;
  final bool expBoost;
  final bool goldBoost;
  final bool pass;
  final bool reverseElement;
  final String? selectedLeader;
  final String? selectedMonsterName;
  final String? selectedMonsterGrade;

  CalculatorSettings({
    this.expHotTime = false,
    this.goldHotTime = false,
    this.expBoost = false,
    this.goldBoost = false,
    this.pass = false,
    this.reverseElement = false,
    this.selectedLeader,
    this.selectedMonsterName,
    this.selectedMonsterGrade,
  });

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      expHotTime: json['expHotTime'] ?? false,
      goldHotTime: json['goldHotTime'] ?? false,
      expBoost: json['expBoost'] ?? false,
      goldBoost: json['goldBoost'] ?? false,
      pass: json['pass'] ?? false,
      reverseElement: json['reverseElement'] ?? false,
      selectedLeader: leaderList.contains(json['selectedLeader'])
                          ? json['selectedLeader']
                          : leaderList[0],
      selectedMonsterName: json['selectedMonsterName'],
      selectedMonsterGrade: json['selectedMonsterGrade'],
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'expHotTime': expHotTime,
      'goldHotTime': goldHotTime,
      'expBoost': expBoost,
      'goldBoost': goldBoost,
      'pass': pass,
      'reverseElement': reverseElement,
      'selectedLeader': selectedLeader,
      'selectedMonsterName': selectedMonsterName,
      'selectedMonsterGrade': selectedMonsterGrade,
    };
  }

    CalculatorSettings copyWith({
      bool? expHotTime,
      bool? goldHotTime,
      bool? expBoost,
      bool? goldBoost,
      bool? pass,
      bool? reverseElement,
      String? selectedLeader,
      ValueGetter<String?>? selectedMonsterName, // Nullable Getter 사용
      ValueGetter<String?>? selectedMonsterGrade, // Nullable Getter 사용
    }) {
      return CalculatorSettings(
        expHotTime: expHotTime ?? this.expHotTime,
        goldHotTime: goldHotTime ?? this.goldHotTime,
        expBoost: expBoost ?? this.expBoost,
        goldBoost: goldBoost ?? this.goldBoost,
        pass: pass ?? this.pass,
        reverseElement: reverseElement ?? this.reverseElement,
        selectedLeader: selectedLeader ?? this.selectedLeader,
        // Nullable Getter를 호출하여 값 업데이트, 없으면 기존 값 유지
        selectedMonsterName: selectedMonsterName != null ? selectedMonsterName() : this.selectedMonsterName,
        selectedMonsterGrade: selectedMonsterGrade != null ? selectedMonsterGrade() : this.selectedMonsterGrade,
      );
    }
}

// StageSettings 클래스 (변경 없음)
class StageSettings {
  final String? teamLevel;
  final String? dalgijiLevel;
  final String? vipLevel;
  final Map<String, String?> stageClearTimes;
  final Map<String, String?> stageJjolCounts;

  // stageNameList를 사용하여 기본 맵 생성
  StageSettings({
    this.teamLevel = '',
    this.dalgijiLevel = '',
    this.vipLevel,
    Map<String, String?>? stageClearTimes,
    Map<String, String?>? stageJjolCounts,
  }) : stageClearTimes = stageClearTimes ?? _getDefaultStageMap<String?>(''),
       stageJjolCounts = stageJjolCounts ?? _getDefaultStageMap<String?>(null); // 기본값 null

  // stageNameList 기반 기본 맵 생성 헬퍼
  static Map<String, T> _getDefaultStageMap<T>(T defaultValue) {
      return { for (var stage in stageNameList) stage: defaultValue };
  }

  factory StageSettings.fromJson(Map<String, dynamic> json) {
    // 기본 맵 생성 (모든 stageNameList 포함)
    Map<String, String?> clearTimes = _getDefaultStageMap('');
    Map<String, String?> jjolCounts = _getDefaultStageMap(null); // 기본값 null

    final stagesData = json['stages'] as Map<String, dynamic>?;
    if (stagesData != null) {
      // 저장된 데이터로 덮어쓰기 (stageNameList에 있는 키만 처리)
      for (var stage in stageNameList) {
          if (stagesData.containsKey(stage)) {
            clearTimes[stage] = stagesData[stage]?['clearTime'] ?? '';
            jjolCounts[stage] = stagesData[stage]?['jjolCount']; // null 가능
          }
      }
    }

    return StageSettings(
      teamLevel: json['teamLevel'] ?? '',
      dalgijiLevel: json['dalgijiLevel'] ?? '',
      vipLevel: json['vipLevel'],
      stageClearTimes: clearTimes,
      stageJjolCounts: jjolCounts,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> stageData = {};
      // stageNameList에 있는 모든 스테이지 정보 저장
      for (var stage in stageNameList) {
        stageData[stage] = {
          'clearTime': stageClearTimes[stage] ?? '',
          'jjolCount': stageJjolCounts[stage], // null 저장 가능
        };
      }
      return {
        'teamLevel': teamLevel,
        'dalgijiLevel': dalgijiLevel,
        'vipLevel': vipLevel,
        'stages': stageData,
      };
  }
}


// SettingsService 싱글톤 클래스 수정
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  static SettingsService get instance => _instance;

  CalculatorSettings _calculatorSettings = CalculatorSettings(selectedLeader: leaderList[0]);
  StageSettings _stageSettings = StageSettings();
  AppSettings _appSettings = AppSettings(); // AppSettings 인스턴스 (fontSizeMultiplier 포함)

  // --- 테마 및 글꼴 크기 관리를 위한 ValueNotifier 추가 ---
  ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
  ValueNotifier<double> fontSizeNotifier = ValueNotifier(1.0); // 글꼴 크기 배율 notifier 추가

  CalculatorSettings get calculatorSettings => _calculatorSettings;
  StageSettings get stageSettings => _stageSettings;
  AppSettings get appSettings => _appSettings;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 파일 경로 getter (변경 없음)
  Future<String> get _calculatorSettingsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/calculator_settings.json';
  }
  Future<String> get _stageSettingsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/stage_settings.json';
  }
  Future<String> get _appSettingsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/app_settings.json';
  }

  // --- AppSettings 로드 함수 수정 ---
  Future<void> _loadAppSettings() async {
    try {
      final path = await _appSettingsPath;
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        _appSettings = AppSettings.fromJson(jsonDecode(jsonString));
      } else {
        _appSettings = AppSettings(); // 파일 없으면 기본값
      }
    } catch (e) {
      if (kDebugMode) { print('앱 설정 로딩 오류: $e'); }
      _appSettings = AppSettings(); // 오류 시 기본값
    }
    // 로드된 설정을 기반으로 notifier 업데이트
    themeModeNotifier.value = _appSettings.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    fontSizeNotifier.value = _appSettings.fontSizeMultiplier; // 글꼴 크기 notifier 업데이트
  }

  // --- AppSettings 저장 함수 수정 ---
  Future<void> saveAppSettings(AppSettings settings) async {
    _appSettings = settings;
    // 변경된 설정을 notifier에 즉시 반영
    themeModeNotifier.value = _appSettings.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    fontSizeNotifier.value = _appSettings.fontSizeMultiplier; // 글꼴 크기 notifier 업데이트
    try {
      final path = await _appSettingsPath;
      final file = File(path);
      await file.writeAsString(jsonEncode(settings.toJson()));
      if (kDebugMode) { print('앱 설정 저장됨.'); }
    } catch (e) {
      if (kDebugMode) { print('앱 설정 저장 오류: $e'); }
    }
  }

  // 계산기 설정 로드 (내부용, 변경 없음)
  Future<void> _loadCalculatorSettings() async {
    try {
      final calcPath = await _calculatorSettingsPath;
      final calcFile = File(calcPath);
      if (await calcFile.exists()) {
        final jsonString = await calcFile.readAsString();
        _calculatorSettings = CalculatorSettings.fromJson(jsonDecode(jsonString));
      } else {
        _calculatorSettings = CalculatorSettings(selectedLeader: leaderList[0]);
      }
    } catch (e) {
       if (kDebugMode) { print('계산기 설정 로딩 오류: $e'); }
      _calculatorSettings = CalculatorSettings(selectedLeader: leaderList[0]);
    }
  }
  // 스테이지 설정 로드 (내부용, 변경 없음)
  Future<void> _loadStageSettings() async {
    try {
      final stagePath = await _stageSettingsPath;
      final stageFile = File(stagePath);
      if (await stageFile.exists()) {
        final jsonString = await stageFile.readAsString();
        _stageSettings = StageSettings.fromJson(jsonDecode(jsonString));
      } else {
        _stageSettings = StageSettings();
      }
    } catch (e) {
      if (kDebugMode) { print('스테이지 설정 로딩 오류: $e'); }
      _stageSettings = StageSettings();
    }
  }


  // 모든 설정 로드 함수 수정
  Future<void> loadAllSettings() async {
    if (_isInitialized) return;

    try {
      await _loadCalculatorSettings();
      await _loadStageSettings();
      await _loadAppSettings(); // 앱 설정 로드 (내부에서 notifier 업데이트 포함)

      _isInitialized = true;
      if (kDebugMode) { print('모든 설정 로딩 완료.'); }

    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) { print('전체 설정 로딩 중 오류: $e'); }
      // 오류 발생 시 모든 설정을 기본값으로 재설정
      _calculatorSettings = CalculatorSettings(selectedLeader: leaderList[0]);
      _stageSettings = StageSettings();
      _appSettings = AppSettings();
      // Notifier들도 기본값으로 설정
      themeModeNotifier.value = _appSettings.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
      fontSizeNotifier.value = _appSettings.fontSizeMultiplier;
    }
  }

  // 계산기 설정 저장 (변경 없음)
  Future<void> saveCalculatorSettings(CalculatorSettings settings) async {
      _calculatorSettings = settings;
      try {
        final path = await _calculatorSettingsPath;
        final file = File(path);
        await file.writeAsString(jsonEncode(settings.toJson()));
        if (kDebugMode) { print('계산기 설정 저장됨.'); }
      } catch (e) {
        if (kDebugMode) { print('계산기 설정 저장 오류: $e'); }
      }
  }

  // 스테이지 설정 저장 (변경 없음)
  Future<void> saveStageSettings(StageSettings settings) async {
      _stageSettings = settings;
      try {
        final path = await _stageSettingsPath;
        final file = File(path);
        await file.writeAsString(jsonEncode(settings.toJson()));
        if (kDebugMode) { print('스테이지 설정 저장됨.'); }
      } catch (e) {
        if (kDebugMode) { print('스테이지 설정 저장 오류: $e'); }
      }
  }

  // 메모리 내 설정 업데이트 함수 (변경 없음)
  void updateCalculatorSettingsInMemory(CalculatorSettings newSettings) {
      _calculatorSettings = newSettings;
  }
  void updateStageSettingsInMemory(StageSettings newSettings) {
      _stageSettings = newSettings;
  }
  // AppSettings 메모리 내 업데이트 및 notifier 갱신 (saveAppSettings 사용으로 대체 가능)
  // void updateAppSettingsInMemory(AppSettings newSettings) {
  //   _appSettings = newSettings;
  //   themeModeNotifier.value = _appSettings.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
  //   fontSizeNotifier.value = _appSettings.fontSizeMultiplier;
  // }
}