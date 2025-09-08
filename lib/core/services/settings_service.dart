// lib/services/settings_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart'; // StartingDayOfWeek enum 사용
import 'package:flutter/material.dart'; // ThemeMode, ValueNotifier 사용
import 'package:shared_preferences/shared_preferences.dart'; // 웹과 모바일 모두에서 동작하는 shared_preferences를 사용합니다.
import '../constants/leader_constants.dart';
import '../../data/models/journal_entry.dart'; // JournalEntry 모델 import
import '../constants/stage_constants.dart'; // stageNameList 사용

// --- AppSettings 클래스 정의 수정 ---
class AppSettings {
  final bool isDarkModeEnabled;
  final double fontSizeMultiplier; // 글꼴 크기 배율 추가
  final bool hideUnconfiguredStagesInCalculator; // 계산기 화면에서 미설정 스테이지 숨기기 여부
  final bool hideUnconfiguredStagesInGoldCalculator; // 골드 계산기 화면에서 미설정 스테이지 숨기기 여부
  final StartingDayOfWeek startingDayOfWeek; // 캘린더 시작 요일 추가

  AppSettings({
    this.isDarkModeEnabled = false,
    this.fontSizeMultiplier = 1.0, // 기본값 1.0 (100%)
    this.hideUnconfiguredStagesInCalculator = false, // 기본값 false (모두 표시)
    this.hideUnconfiguredStagesInGoldCalculator = false, // 기본값 false
    this.startingDayOfWeek = StartingDayOfWeek.sunday, // 기본값 일요일
  });

  AppSettings copyWith({
    bool? isDarkModeEnabled,
    double? fontSizeMultiplier, // copyWith에 추가
    bool? hideUnconfiguredStagesInCalculator, // copyWith에 추가
    bool? hideUnconfiguredStagesInGoldCalculator, // copyWith에 파라미터 추가
    StartingDayOfWeek? startingDayOfWeek, // copyWith에 추가
  }) {
    return AppSettings(
      isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier, // 추가
      hideUnconfiguredStagesInCalculator: hideUnconfiguredStagesInCalculator ?? this.hideUnconfiguredStagesInCalculator,
      hideUnconfiguredStagesInGoldCalculator: hideUnconfiguredStagesInGoldCalculator ?? this.hideUnconfiguredStagesInGoldCalculator, // 새 파라미터 사용
      startingDayOfWeek: startingDayOfWeek ?? this.startingDayOfWeek, // startingDayOfWeek 파라미터를 올바르게 사용
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // startingDayOfWeek를 String으로 읽고 StartingDayOfWeek enum으로 변환
    String? dayString = json['startingDayOfWeek'] as String?;
    StartingDayOfWeek day = StartingDayOfWeek.values.firstWhere((e) => e.toString() == dayString, orElse: () => StartingDayOfWeek.sunday);
    return AppSettings(
      isDarkModeEnabled: json['isDarkModeEnabled'] as bool? ?? false,
      fontSizeMultiplier: (json['fontSizeMultiplier'] as num?)?.toDouble() ?? 1.0,
      hideUnconfiguredStagesInCalculator: json['hideUnconfiguredStagesInCalculator'] as bool? ?? false,
      hideUnconfiguredStagesInGoldCalculator: json['hideUnconfiguredStagesInGoldCalculator'] as bool? ?? false,
      startingDayOfWeek: day,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkModeEnabled': isDarkModeEnabled,
      'fontSizeMultiplier': fontSizeMultiplier, // toJson에 추가
      'hideUnconfiguredStagesInCalculator': hideUnconfiguredStagesInCalculator,
      'hideUnconfiguredStagesInGoldCalculator': hideUnconfiguredStagesInGoldCalculator,
      'startingDayOfWeek': startingDayOfWeek.toString(), // enum을 String으로 변환하여 저장
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
  final int? goldCalculatorSelectedMinutes; // 골드 계산기용 선택 시간(분) 추가
  final int? goldBoostDurationMinutes; // 골드 부스트 적용 시간(분) 추가
  final bool sellGoldDemons; // 돈악마 판매 여부 추가
  final String? goldCalculatorSortOption; // 골드 계산기 정렬 옵션 추가
  final String? calculatorSortOption; // 루프 계산기 정렬 옵션 추가

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
    this.goldCalculatorSelectedMinutes, // 기본값 null
    this.goldBoostDurationMinutes, // 기본값 null
    this.sellGoldDemons = false, // 기본값 false
    this.goldCalculatorSortOption, // 기본값 null
    this.calculatorSortOption, // 기본값 null
  });

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      expHotTime: json['expHotTime'] as bool? ?? false,
      goldHotTime: json['goldHotTime'] as bool? ?? false,
      expBoost: json['expBoost'] as bool? ?? false,
      goldBoost: json['goldBoost'] as bool? ?? false,
      pass: json['pass'] as bool? ?? false,
      reverseElement: json['reverseElement'] as bool? ?? false,
      selectedLeader: leaderList.contains(json['selectedLeader'])
                          ? json['selectedLeader']
                          : leaderList[0],
      selectedMonsterName: json['selectedMonsterName'],
      selectedMonsterGrade: json['selectedMonsterGrade'],
      goldCalculatorSelectedMinutes: json['goldCalculatorSelectedMinutes'] as int?,
      goldBoostDurationMinutes: json['goldBoostDurationMinutes'] as int?,
      sellGoldDemons: json['sellGoldDemons'] as bool? ?? false, // 이미 null 처리 되어 있음
      goldCalculatorSortOption: json['goldCalculatorSortOption'] as String?,
      calculatorSortOption: json['calculatorSortOption'] as String?,
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
      'goldCalculatorSelectedMinutes': goldCalculatorSelectedMinutes,
      'goldBoostDurationMinutes': goldBoostDurationMinutes,
      'sellGoldDemons': sellGoldDemons,
      'goldCalculatorSortOption': goldCalculatorSortOption,
      'calculatorSortOption': calculatorSortOption,
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
      int? goldCalculatorSelectedMinutes,
      int? goldBoostDurationMinutes,
      bool? sellGoldDemons,
      String? goldCalculatorSortOption,
      String? calculatorSortOption,
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
        goldCalculatorSelectedMinutes: goldCalculatorSelectedMinutes ?? this.goldCalculatorSelectedMinutes,
        goldBoostDurationMinutes: goldBoostDurationMinutes ?? this.goldBoostDurationMinutes,
        sellGoldDemons: sellGoldDemons ?? this.sellGoldDemons,
        goldCalculatorSortOption: goldCalculatorSortOption ?? this.goldCalculatorSortOption,
        calculatorSortOption: calculatorSortOption ?? this.calculatorSortOption,
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
  Map<DateTime, List<JournalEntry>> _journalEntries = {}; // 일지 데이터 저장 맵 추가

  // --- 테마 및 글꼴 크기 관리를 위한 ValueNotifier 추가 ---
  ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
  ValueNotifier<double> fontSizeNotifier = ValueNotifier(1.0); // 글꼴 크기 배율 notifier 추가
  ValueNotifier<StartingDayOfWeek> startingDayOfWeekNotifier = ValueNotifier(StartingDayOfWeek.sunday); // 시작 요일 notifier 추가

  CalculatorSettings get calculatorSettings => _calculatorSettings;
  StageSettings get stageSettings => _stageSettings;
  AppSettings get appSettings => _appSettings;
  // 일지 데이터는 직접 노출하지 않고, 접근 메소드를 통해 제공

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // --- AppSettings 로드 함수 수정 ---
  Future<void> _loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('app_settings');
      if (jsonString != null) {
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
    startingDayOfWeekNotifier.value = _appSettings.startingDayOfWeek; // 시작 요일 notifier 업데이트
  }

  // --- AppSettings 저장 함수 수정 ---
  Future<void> saveAppSettings(AppSettings settings) async {
    _appSettings = settings;
    // 변경된 설정을 notifier에 즉시 반영
    themeModeNotifier.value = _appSettings.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    fontSizeNotifier.value = _appSettings.fontSizeMultiplier; // 글꼴 크기 notifier 업데이트
    startingDayOfWeekNotifier.value = _appSettings.startingDayOfWeek; // 시작 요일 notifier 업데이트
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', jsonEncode(settings.toJson()));
      if (kDebugMode) { print('앱 설정 저장됨.'); }
    } catch (e) {
      if (kDebugMode) { print('앱 설정 저장 오류: $e'); }
    }
  }

  // AppSettings 부분 업데이트를 위한 메서드 (예시)
  // 특정 설정만 변경하고 싶을 때 사용합니다.
  Future<void> updateAppSettings({
    bool? isDarkModeEnabled,
    double? fontSizeMultiplier,
    bool? hideUnconfiguredStagesInCalculator,
    bool? hideUnconfiguredStagesInGoldCalculator,
    StartingDayOfWeek? startingDayOfWeek,
  }) async {
    final newSettings = _appSettings.copyWith(
      isDarkModeEnabled: isDarkModeEnabled,
      fontSizeMultiplier: fontSizeMultiplier,
      hideUnconfiguredStagesInCalculator: hideUnconfiguredStagesInCalculator,
      hideUnconfiguredStagesInGoldCalculator: hideUnconfiguredStagesInGoldCalculator, // AppSettings.copyWith에 이 필드 추가 필요
      startingDayOfWeek: startingDayOfWeek, // copyWith에 startingDayOfWeek 전달
    );
    await saveAppSettings(newSettings);
  }

  // 계산기 설정 로드 (내부용, 변경 없음)
  Future<void> _loadCalculatorSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('calculator_settings');
      if (jsonString != null) {
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
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('stage_settings');
      if (jsonString != null) {
        _stageSettings = StageSettings.fromJson(jsonDecode(jsonString));
      } else {
        _stageSettings = StageSettings();
      }
    } catch (e) {
      if (kDebugMode) { print('스테이지 설정 로딩 오류: $e'); }
      _stageSettings = StageSettings();
    }
  }

  // --- 일지 데이터 로드 함수 추가 ---
  Future<void> _loadJournalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('journal_entries');
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        _journalEntries = {}; // 기존 데이터 초기화
        jsonMap.forEach((dateString, entryListJson) {
          try {
            final date = DateTime.parse(dateString); // 문자열 키를 DateTime으로 파싱
            final List<dynamic> entryList = entryListJson as List<dynamic>;
            _journalEntries[date] = entryList.map((entryJson) => JournalEntry.fromJson(entryJson as Map<String, dynamic>)).toList();
          } catch (e) {
            if (kDebugMode) { print('일지 항목 파싱 오류 (날짜: $dateString): $e'); }
            // 특정 날짜의 데이터 로딩 실패 시 해당 날짜만 건너뛰고 나머지 로드 시도
          }
        });
      } else {
        _journalEntries = {}; // 파일 없으면 빈 맵으로 초기화
      }
    } catch (e) {
      if (kDebugMode) { print('일지 데이터 로딩 오류: $e'); }
      _journalEntries = {}; // 오류 시 빈 맵으로 초기화
    }
  }

  // --- 일지 데이터 저장 함수 추가 ---
  Future<void> saveJournalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Map<DateTime, List<JournalEntry>>를 Map<String, List<Map<String, dynamic>>>으로 변환하여 저장
      final jsonMap = _journalEntries.map((date, entries) => MapEntry(date.toIso8601String(), entries.map((e) => e.toJson()).toList()));
      await prefs.setString('journal_entries', jsonEncode(jsonMap));
      if (kDebugMode) { print('일지 데이터 저장됨.'); }
    } catch (e) {
      if (kDebugMode) { print('일지 데이터 저장 오류: $e'); }
    }
  }

  // 모든 설정 로드 함수 수정
  Future<void> loadAllSettings() async {
    if (_isInitialized) return;

    try {
      await _loadCalculatorSettings();
      await _loadStageSettings();
      await _loadAppSettings(); // 앱 설정 로드 (내부에서 notifier 업데이트 포함)
      await _loadJournalEntries(); // 일지 데이터 로드 추가

      _isInitialized = true;
      if (kDebugMode) { print('모든 설정 로딩 완료.'); }

    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) { print('전체 설정 로딩 중 오류: $e'); }
      // 오류 발생 시 모든 설정을 기본값으로 재설정
      _calculatorSettings = CalculatorSettings(selectedLeader: leaderList[0]);
      _stageSettings = StageSettings();
      _appSettings = AppSettings();
      _journalEntries = {}; // 일지 데이터도 초기화
      // Notifier들도 기본값으로 설정
      themeModeNotifier.value = _appSettings.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
      fontSizeNotifier.value = _appSettings.fontSizeMultiplier;
      startingDayOfWeekNotifier.value = _appSettings.startingDayOfWeek;
    }
  }

  // 계산기 설정 저장 (변경 없음)
  Future<void> saveCalculatorSettings(CalculatorSettings settings) async {
      _calculatorSettings = settings;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('calculator_settings', jsonEncode(settings.toJson()));
        if (kDebugMode) { print('계산기 설정 저장됨.'); }
      } catch (e) {
        if (kDebugMode) { print('계산기 설정 저장 오류: $e'); }
      }
  }

  // 스테이지 설정 저장 (변경 없음)
  Future<void> saveStageSettings(StageSettings settings) async {
      _stageSettings = settings;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('stage_settings', jsonEncode(settings.toJson()));
        if (kDebugMode) { print('스테이지 설정 저장됨.'); }
      } catch (e) {
        if (kDebugMode) { print('스테이지 설정 저장 오류: $e'); }
      }
  }

  // --- 일지 데이터 추가 및 저장 함수 추가 ---
  void addJournalEntry(JournalEntry entry) {
    final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day); // 날짜 정규화
    if (kDebugMode) { debugPrint('[SettingsService] Attempting to add entry for date: $normalizedDate'); }
    if (_journalEntries.containsKey(normalizedDate)) {
      _journalEntries[normalizedDate]!.add(entry);
      if (kDebugMode) { debugPrint('[SettingsService] Added entry to existing list for $normalizedDate. Total entries: ${_journalEntries[normalizedDate]!.length}'); }
    } else {
      _journalEntries[normalizedDate] = [entry];
      if (kDebugMode) { debugPrint('[SettingsService] Created new list for $normalizedDate. Total entries: 1'); }
    }
    saveJournalEntries(); // 추가 후 즉시 저장
  }

  // --- 일지 데이터 가져오기 함수 추가 ---
  List<JournalEntry> getEntriesForDay(DateTime day) {
     final normalizedDate = DateTime(day.year, day.month, day.day); // 날짜 정규화
     if (kDebugMode) { debugPrint('[SettingsService] Getting entries for date: $normalizedDate. Found: ${_journalEntries[normalizedDate]?.length ?? 0} entries.'); }
     return _journalEntries[normalizedDate] ?? [];
  }

  // 모든 일지 항목을 가져오는 함수 추가
  List<JournalEntry> getAllJournalEntries() {
    return _journalEntries.values.expand((list) => list).toList();
  }

  // --- 일지 데이터 삭제 함수 추가 ---
  void removeJournalEntry(DateTime day, JournalEntry entryToRemove) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    if (_journalEntries.containsKey(normalizedDate)) {
      // 리스트에서 특정 인스턴스 제거
      final bool removed = _journalEntries[normalizedDate]!.remove(entryToRemove);

      if (removed) {
        if (kDebugMode) {
          print('[SettingsService] Removed entry: ${entryToRemove.stage} on $normalizedDate');
        }
        // 만약 해당 날짜의 리스트가 비게 되면 맵에서 키 자체를 제거
        if (_journalEntries[normalizedDate]!.isEmpty) {
          _journalEntries.remove(normalizedDate);
          if (kDebugMode) {
            print('[SettingsService] Removed empty list for date: $normalizedDate');
          }
        }
        saveJournalEntries(); // 변경사항 저장
      } else {
        if (kDebugMode) { print('[SettingsService] Failed to remove entry (not found by identity): ${entryToRemove.stage} on $normalizedDate');}
      }
    }
  }

  void updateCalculatorSettingsInMemory(CalculatorSettings newSettings) {
      _calculatorSettings = newSettings;
  }
  void updateStageSettingsInMemory(StageSettings newSettings) {
      _stageSettings = newSettings;
  }
}