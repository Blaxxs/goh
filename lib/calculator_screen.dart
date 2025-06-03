// lib/calculator_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
// import 'dart:math'; // 사용되지 않으므로 제거
import 'package:intl/intl.dart';

import 'calculator_logic.dart';
import 'constants/stage_constants.dart'; // stageNameList 사용
import 'constants/leader_constants.dart';
import 'stage_calculation_service.dart';
import 'presentation/calculator/calculator_screen_ui.dart'; // StageDisplayData 클래스 정의 포함
import 'services/settings_service.dart';

// 정렬 옵션 Enum 정의
enum CalculatorSortOption { stageName, soulStone, gold }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  CalculatorSettings _currentCalcSettings = CalculatorSettings(selectedLeader: leaderList[0]);

  int _calculatedMaxStamina = 0;
  int _calculatedAutoSwapSlots = 0;
  int? _requiredMonsterExp;
  List<StageDisplayData> _stageDisplayResults = [];
  double? _maxPositiveSoulStoneValue; // 가장 높은 양수 영혼석 값을 저장할 변수

  String _selectedTimeFormat = '시/분';
  final List<String> _timeFormatOptions = const ['시/분', '분', '초'];
  bool _showSoulStonesPerMinute = false;
  bool _showGoldPerMinute = false;
  bool _isLoading = false;

  final CalculatorLogic _calculatorLogic = CalculatorLogic();
  final StageCalculationService _stageCalculationService = StageCalculationService();
  Timer? _dialogCloseTimer;

  final NumberFormat _integerFormatter = NumberFormat('#,##0');
  final NumberFormat _decimalFormatter = NumberFormat('#,##0.00');

  CalculatorSortOption _selectedSortOption = CalculatorSortOption.stageName; // 기본 정렬 옵션

  @override
  void initState() {
    super.initState();
    _currentCalcSettings = SettingsService.instance.calculatorSettings;
    _selectedTimeFormat = '시/분';
    _selectedSortOption = CalculatorSortOption.stageName; // 초기 정렬 상태 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateDerivedData();
      }
    });
  }

  @override
  void dispose() {
    _dialogCloseTimer?.cancel();
    // 계산기 설정 저장 (메모리 -> 파일)
    SettingsService.instance.saveCalculatorSettings(_currentCalcSettings);
    super.dispose();
  }

  // 기본 정보 알림창 표시
  void _showInfoAlert() {
    _dialogCloseTimer?.cancel();
    final stageSettings = SettingsService.instance.stageSettings;
    final requiredMonsterExpStr = _requiredMonsterExp != null
        ? _integerFormatter.format(_requiredMonsterExp)
        : '몬스터 선택 필요';
    final calculatedMaxStaminaStr = _integerFormatter.format(_calculatedMaxStamina);
    final calculatedAutoSwapSlotsStr = _integerFormatter.format(_calculatedAutoSwapSlots);

    const fadeDuration = Duration(milliseconds: 300);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: fadeDuration,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setState) {
            if (_dialogCloseTimer == null || !_dialogCloseTimer!.isActive) {
                _dialogCloseTimer = Timer(const Duration(seconds: 3), () {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                });
              }
            return AlertDialog(
              title: const Text("기본 정보"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('팀 레벨: ${stageSettings.teamLevel ?? '미설정'}'),
                    const SizedBox(height: 4),
                    Text('달기지 레벨: ${stageSettings.dalgijiLevel ?? '미설정'}'),
                    const SizedBox(height: 4),
                    Text('VIP 등급: ${stageSettings.vipLevel ?? '미설정'}'),
                    const SizedBox(height: 10),
                    Text('계산된 최대 스테미너: $calculatedMaxStaminaStr'),
                    const SizedBox(height: 4),
                    Text('계산된 자동 교체 슬롯: $calculatedAutoSwapSlotsStr'),
                    const SizedBox(height: 10),
                    Text('선택된 몬스터 필요경험치: $requiredMonsterExpStr'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('닫기'),
                  onPressed: () {
                    _dialogCloseTimer?.cancel();
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          }
        );
      },
      transitionBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      }
    ).whenComplete(() {
      _dialogCloseTimer?.cancel();
      _dialogCloseTimer = null;
    });
  }

  // 스테이지 위치 스낵바 표시
  void _showStageLocationSnackBar(String location) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text('위치: $location'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 스테이지 상세 정보 다이얼로그 표시
  void _showStageDetailDialog(StageDisplayData data) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${data.stageName} 상세 정보'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('기본 경험치:', data.baseExpStr),
                _buildDetailRow('최종 경험치 (루프 당):', data.finalExpPerLoopStr),
                const SizedBox(height: 8),
                _buildDetailRow('기본 골드:', data.baseGoldStr),
                _buildDetailRow('최종 골드 (루프 당):', data.finalGoldPerSingleLoopStr),
                const SizedBox(height: 8),
                 _buildDetailRow('클리어 시간 설정:', data.configuredClearTime), // 설정값 표시 추가
                 _buildDetailRow('쫄 개수 설정:', data.configuredJjolCount), // 설정값 표시 추가
                 const SizedBox(height: 8),
                _buildDetailRow('쫄 1마리 만렙까지 클리어:', data.runsToMaxStr),
                _buildDetailRow('전체 루프 종료까지 클리어:', data.totalLoopsStr),
                _buildDetailRow('총 소모 스테미너:', data.totalStaminaStr),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // 다이얼로그 내용 행 위젯 빌더
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // 계산된 데이터 업데이트 (스테미너, 슬롯, 필요경험치 및 스테이지 결과 목록 + 정렬 적용)
  Future<void> _updateDerivedData({bool updateStageResults = true}) async {
    if (!mounted) return; // 위젯이 마운트되지 않았으면 중단

    setState(() { _isLoading = true; });

    final stageSettings = SettingsService.instance.stageSettings;
    _calculatedMaxStamina = _calculatorLogic.calculateMaxStamina(stageSettings.teamLevel, stageSettings.vipLevel);
    _calculatedAutoSwapSlots = _calculatorLogic.calculateAutoSwapSlots(stageSettings.vipLevel, stageSettings.dalgijiLevel);
    _requiredMonsterExp = _stageCalculationService.getMonsterRequiredExp(_currentCalcSettings.selectedMonsterName, _currentCalcSettings.selectedMonsterGrade);

    List<StageDisplayData>? newStageResultsData;
    double? newMaxPositiveSoulStoneValue;

    if (updateStageResults) {
      // 스테이지 결과 데이터 준비 (비동기 처리 될 수 있음)
      newStageResultsData = await _prepareStageDisplayData(requiredExp: _requiredMonsterExp, autoSwapSlots: _calculatedAutoSwapSlots);
      // 최대 양수 영혼석 값 계산
      newMaxPositiveSoulStoneValue = _findMaxPositiveSoulStone(newStageResultsData);

      // --- 정렬 로직 적용 ---
      newStageResultsData.sort((a, b) {
        switch (_selectedSortOption) {
          case CalculatorSortOption.soulStone:
            double? valA = _showSoulStonesPerMinute ? a.soulStonesPerMinValue : a.soulStonesValue;
            double? valB = _showSoulStonesPerMinute ? b.soulStonesPerMinValue : b.soulStonesValue;
            if (a.settingsIncomplete && !b.settingsIncomplete) return 1;
            if (!a.settingsIncomplete && b.settingsIncomplete) return -1;
            if (a.settingsIncomplete && b.settingsIncomplete) return 0;
            if (valA == null && valB != null) return 1;
            if (valA != null && valB == null) return -1;
            if (valA == null && valB == null) return 0;
            return valB!.compareTo(valA!);
          case CalculatorSortOption.gold:
            double? valA = _showGoldPerMinute ? _parseGoldString(a.goldPerMinStr) : _parseGoldString(a.loopGoldStr);
            double? valB = _showGoldPerMinute ? _parseGoldString(b.goldPerMinStr) : _parseGoldString(b.loopGoldStr);
            if (a.settingsIncomplete && !b.settingsIncomplete) return 1;
            if (!a.settingsIncomplete && b.settingsIncomplete) return -1;
            if (a.settingsIncomplete && b.settingsIncomplete) return 0;
            if (valA == null && valB != null) return 1;
            if (valA != null && valB == null) return -1;
            if (valA == null && valB == null) return 0;
            return valB!.compareTo(valA!);
          case CalculatorSortOption.stageName:
            int indexA = stageNameList.indexOf(a.stageName);
            int indexB = stageNameList.indexOf(b.stageName);
            if (indexA == -1 && indexB != -1) return 1;
            if (indexA != -1 && indexB == -1) return -1;
            if (indexA == -1 && indexB == -1) return a.stageName.compareTo(b.stageName);
            return indexA.compareTo(indexB);
        }
        // 이 부분은 Enum의 모든 케이스가 위에서 처리되므로 도달하지 않아야 합니다.
        // return 0; // 컴파일러 경고를 피하기 위해 추가 (만약 switch가 모든 enum 값을 커버하지 않는다고 판단될 경우)
      });
      // --- 정렬 로직 끝 ---
    }

    // 위젯이 여전히 마운트 상태인지 확인 후 상태 업데이트
    if (mounted) {
      setState(() {
        if (newStageResultsData != null) {
          _stageDisplayResults = newStageResultsData;
        }
        _maxPositiveSoulStoneValue = newMaxPositiveSoulStoneValue ?? _findMaxPositiveSoulStone(_stageDisplayResults);
        _isLoading = false;
      });
    }
  }

  // 골드 문자열을 double로 파싱 (쉼표 제거)
  double? _parseGoldString(String goldStr) {
    if (goldStr == '-') return null;
    return double.tryParse(goldStr.replaceAll(',', ''));
  }


   // 결과 리스트에서 가장 높은 양수 영혼석 값 찾기 (루프 또는 분당)
  double? _findMaxPositiveSoulStone(List<StageDisplayData> results) {
    double? maxVal;
    for (var data in results) {
      if (data.settingsIncomplete) continue;
      double? currentValue = _showSoulStonesPerMinute
          ? data.soulStonesPerMinValue
          : data.soulStonesValue;
      if (currentValue != null && currentValue > 0) {
        if (maxVal == null || currentValue > maxVal) {
          maxVal = currentValue;
        }
      }
    }
    return maxVal;
  }

  // 계산기 설정 업데이트 및 파생 데이터 재계산
  void _updateCalcSettings(CalculatorSettings newSettings) {
    if (!mounted) return;
    SettingsService.instance.updateCalculatorSettingsInMemory(newSettings);
    setState(() {
       _currentCalcSettings = newSettings;
    });
    _updateDerivedData();
  }

  // 몬스터 이름 변경 처리 (등급 초기화 포함)
  void _handleMonsterNameChanged(String? newMonsterName) {
    if (!mounted) return;
    final currentGrade = _currentCalcSettings.selectedMonsterGrade;
    String? finalGrade = currentGrade;
    bool gradeResetNeeded = false;
    if (newMonsterName != null && currentGrade == '6성' &&
        (newMonsterName == '까마귀' || newMonsterName == '요원')) {
      finalGrade = null;
      gradeResetNeeded = true;
    } else if (newMonsterName == null) {
      finalGrade = null;
    }
    final newSettings = _currentCalcSettings.copyWith(
      selectedMonsterName: () => newMonsterName,
      selectedMonsterGrade: () => finalGrade,
    );
    _updateCalcSettings(newSettings);
    if (gradeResetNeeded) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('선택한 몬스터는 6성이 없습니다. 등급을 다시 선택해주세요.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // 스테이지 결과 표시 데이터 준비 (비동기 처리 가능)
  Future<List<StageDisplayData>> _prepareStageDisplayData({ required int? requiredExp, required int autoSwapSlots}) async {
      List<StageDisplayData> results = [];
      final stageSettings = SettingsService.instance.stageSettings;
      final calcSettings = _currentCalcSettings;
      int stageCounter = 0;

      for (String stageName in stageNameList) {
          final currentStageBaseData = stageBaseData;
          final currentClearTimeStr = stageSettings.stageClearTimes[stageName];
          final jjolCountPerStageStr = stageSettings.stageJjolCounts[stageName];
          final bool settingsIncomplete = (currentClearTimeStr == null || currentClearTimeStr.isEmpty || double.tryParse(currentClearTimeStr) == null || double.parse(currentClearTimeStr) <= 0) ||
                                        (jjolCountPerStageStr == null || jjolCountPerStageStr.isEmpty);
          final finalExpPerLoop = _calculatorLogic.calculateFinalExpPerLoop( stageName, calcSettings.expHotTime, calcSettings.expBoost, calcSettings.pass, calcSettings.reverseElement, stageSettings.vipLevel);
          final finalGoldPerSingleLoop = _calculatorLogic.calculateFinalGoldPerLoop( stageName, calcSettings.goldHotTime, calcSettings.goldBoost, stageSettings.vipLevel, calcSettings.selectedLeader);
          final runsToMax = _stageCalculationService.calculateRunsToMax( finalExpPerLoop, requiredExp);
          final totalLoops = _stageCalculationService.calculateTotalLoops( autoSwapSlots, jjolCountPerStageStr, runsToMax);
          double? batchesNeeded;
          int? jjolCount = int.tryParse(jjolCountPerStageStr ?? '');
          if (jjolCount != null && jjolCount > 0 && autoSwapSlots >= 0) { double totalMonsters = (autoSwapSlots + jjolCount).toDouble(); batchesNeeded = (totalMonsters / jjolCount).ceilToDouble(); }
          double? totalLoopGold; if (runsToMax != null && batchesNeeded != null) { totalLoopGold = runsToMax * batchesNeeded * finalGoldPerSingleLoop; }
          double? totalTimeInSeconds; double? clearTimeDouble = double.tryParse(currentClearTimeStr ?? ''); if (totalLoops != null && clearTimeDouble != null && clearTimeDouble > 0) { totalTimeInSeconds = totalLoops * clearTimeDouble; }
          final staminaCost = (currentStageBaseData[stageName]?['staminaCost'] as num?)?.toDouble() ?? 0.0; final totalStamina = (runsToMax != null && batchesNeeded != null && staminaCost > 0) ? (runsToMax * batchesNeeded * staminaCost) : null;
          final double receivedValueFromLogic = _calculatorLogic.calculateSoulStonesPerEffectiveLoop(stageName: stageName, selectedMonsterGrade: calcSettings.selectedMonsterGrade, jjolCountPerStageStr: jjolCountPerStageStr, autoSwapSlots: autoSwapSlots, finalExpPerLoop: finalExpPerLoop, requiredMonsterExp: requiredExp, clearTimeStr: currentClearTimeStr, teamLevel: stageSettings.teamLevel, vipLevel: stageSettings.vipLevel);
          final double? calculatedSoulStones; const double sentinelNullReceived = -999999.0; if (receivedValueFromLogic == sentinelNullReceived) { calculatedSoulStones = null; } else { calculatedSoulStones = receivedValueFromLogic; }
          final double goldPerMin = _calculatorLogic.calculateGoldPerMin(stageName, calcSettings.goldHotTime, calcSettings.goldBoost, currentClearTimeStr, stageSettings.vipLevel, calcSettings.selectedLeader);
          double? soulStonesPerMin; if (calculatedSoulStones != null && totalTimeInSeconds != null && totalTimeInSeconds > 0) { soulStonesPerMin = calculatedSoulStones / (totalTimeInSeconds / 60.0); }
          final double expPerMin = _calculatorLogic.calculateExpPerMin(stageName, calcSettings.expHotTime, calcSettings.expBoost, calcSettings.pass, calcSettings.reverseElement, currentClearTimeStr, stageSettings.vipLevel);
          final totalTimeStr = _formatDurationByUnit(totalTimeInSeconds, _selectedTimeFormat);
          final String soulStonesStr = calculatedSoulStones == null ? '-' : _integerFormatter.format(calculatedSoulStones.round());
          final String loopGoldStr = totalLoopGold == null ? '-' : _integerFormatter.format(totalLoopGold.round());
          String soulStonesPerMinStr; if (soulStonesPerMin == null || soulStonesPerMin.isNaN || soulStonesPerMin.isInfinite) { soulStonesPerMinStr = '-'; } else { soulStonesPerMinStr = _decimalFormatter.format(soulStonesPerMin); }
          final String goldPerMinStr = (goldPerMin <= 0 || goldPerMin.isNaN || goldPerMin.isInfinite) ? '-' : _integerFormatter.format(goldPerMin.round());
          final location = currentStageBaseData[stageName]?['location'] ?? '-'; final configuredClearTime = stageSettings.stageClearTimes[stageName]?.isNotEmpty == true ? '${stageSettings.stageClearTimes[stageName]} 초' : '미설정'; final configuredJjolCount = stageSettings.stageJjolCounts[stageName] ?? '미설정';
          final baseExpStr = currentStageBaseData[stageName]?['baseClearRewardExp'] != null ? _integerFormatter.format(currentStageBaseData[stageName]?['baseClearRewardExp']) : '-'; final baseGoldStr = currentStageBaseData[stageName]?['baseClearRewardGold'] != null ? _integerFormatter.format(currentStageBaseData[stageName]?['baseClearRewardGold']) : '-'; final finalExpPerLoopStr = _integerFormatter.format(finalExpPerLoop.round()); final finalGoldPerSingleLoopStr = _integerFormatter.format(finalGoldPerSingleLoop.round()); final expPerMinStrOutput = (expPerMin.isNaN || expPerMin.isInfinite) ? '-' : _integerFormatter.format(expPerMin.round()); final runsToMaxStrOutput = (runsToMax == null || runsToMax.isNaN || runsToMax.isInfinite) ? '-' : _integerFormatter.format(runsToMax.round()); final totalLoopsStrOutput = (totalLoops == null || totalLoops.isNaN || totalLoops.isInfinite) ? '-' : _integerFormatter.format(totalLoops.round()); final totalStaminaStrOutput = (totalStamina == null || totalStamina.isNaN || totalStamina.isInfinite) ? '-' : _integerFormatter.format(totalStamina.round());

          results.add(StageDisplayData(
              stageName: stageName, totalTimeStr: totalTimeStr, soulStonesStr: soulStonesStr, loopGoldStr: loopGoldStr, soulStonesPerMinStr: soulStonesPerMinStr, goldPerMinStr: goldPerMinStr, location: location, configuredClearTime: configuredClearTime, configuredJjolCount: configuredJjolCount, baseExpStr: baseExpStr, baseGoldStr: baseGoldStr, finalExpPerLoopStr: finalExpPerLoopStr, finalGoldPerSingleLoopStr: finalGoldPerSingleLoopStr, expPerMinStr: expPerMinStrOutput, runsToMaxStr: runsToMaxStrOutput, totalLoopsStr: totalLoopsStrOutput, totalStaminaStr: totalStaminaStrOutput,
              settingsIncomplete: settingsIncomplete,
              soulStonesValue: calculatedSoulStones,
              soulStonesPerMinValue: soulStonesPerMin,
          ));
          stageCounter++;
          if (stageCounter % 5 == 0) { await Future.delayed(Duration.zero); if (!mounted) break; }
      }
      await Future.delayed(Duration.zero);
      return results;
  }

  // 시간을 선택된 단위로 포맷팅하는 함수
  String _formatDurationByUnit(double? totalSeconds, String format) {
      if (totalSeconds == null || totalSeconds.isNaN || totalSeconds.isInfinite) {
          return '-';
      }
      if (totalSeconds <= 0) {
        switch (format) {
          case '초': return '0초';
          case '분': return '0분';
          case '시/분': return '00분';
        }
      }
      switch (format) {
          case '초':
              return '${_integerFormatter.format(totalSeconds.ceil())}초';
          case '분':
              final int roundedMinutes = (totalSeconds / 60.0).round();
              return '${_integerFormatter.format(roundedMinutes)}분';
          case '시/분':
              int roundedTotalMinutes = (totalSeconds / 60.0).round();
              int totalHours = roundedTotalMinutes ~/ 60;
              int minutes = roundedTotalMinutes % 60;
              String minutesStr = minutes.toString().padLeft(2, '0');
              if (totalHours == 0) {
                return '$minutesStr분';
              } else {
                String hoursStr = totalHours.toString();
                return '$hoursStr시간 $minutesStr분';
              }
      }
      return '-';
  }

   // 정렬 옵션 변경 핸들러
  void _handleSortOptionChanged(CalculatorSortOption? newValue) {
    if (newValue != null && _selectedSortOption != newValue) {
      setState(() {
        _selectedSortOption = newValue;
      });
      _updateDerivedData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CalculatorScreenUI(
          expHotTime: _currentCalcSettings.expHotTime,
          goldHotTime: _currentCalcSettings.goldHotTime,
          expBoost: _currentCalcSettings.expBoost,
          goldBoost: _currentCalcSettings.goldBoost,
          pass: _currentCalcSettings.pass,
          reverseElement: _currentCalcSettings.reverseElement,
          selectedLeader: _currentCalcSettings.selectedLeader,
          selectedMonsterName: _currentCalcSettings.selectedMonsterName,
          selectedMonsterGrade: _currentCalcSettings.selectedMonsterGrade,
          selectedTimeFormat: _selectedTimeFormat,
          timeFormatOptions: _timeFormatOptions,
          stageResults: _stageDisplayResults,
          showSoulStonesPerMinute: _showSoulStonesPerMinute,
          showGoldPerMinute: _showGoldPerMinute,
          maxPositiveSoulStoneValue: _maxPositiveSoulStoneValue,
          onShowInfoAlertPressed: _showInfoAlert,
          onStageNameTap: _showStageLocationSnackBar,
          onInfoButtonTap: _showStageDetailDialog,
          onToggleSoulStoneView: () {
            if (mounted) {
              setState(() => _showSoulStonesPerMinute = !_showSoulStonesPerMinute);
              _updateDerivedData(updateStageResults: false);
            }
          },
          onToggleGoldView: () {
             if (mounted) {
               setState(() => _showGoldPerMinute = !_showGoldPerMinute);
               _updateDerivedData(updateStageResults: false);
             }
          },
          onExpHotTimeChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(expHotTime: value)),
          onGoldHotTimeChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(goldHotTime: value)),
          onExpBoostChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(expBoost: value)),
          onGoldBoostChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(goldBoost: value)),
          onPassChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(pass: value)),
          onReverseElementChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(reverseElement: value)),
          onLeaderChanged: (value) => _updateCalcSettings(_currentCalcSettings.copyWith(selectedLeader: value ?? leaderList[0])),
          onMonsterNameChanged: _handleMonsterNameChanged,
          onMonsterGradeChanged: (value) {
              _updateCalcSettings(_currentCalcSettings.copyWith(
                  selectedMonsterGrade: () => value
              ));
          },
          onTimeFormatChanged: (value) {
              if(mounted) {
                setState(() {
                  _selectedTimeFormat = value ?? '시/분';
                });
                 _updateDerivedData();
              }
          },
          selectedSortOption: _selectedSortOption,
          onSortOptionChanged: _handleSortOptionChanged,
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withAlpha((0.5 * 255).round()), // withOpacity(0.5) 대신 withAlpha 사용
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}