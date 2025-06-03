// lib/gold_calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'presentation/gold_calculator/gold_calculator_screen_ui.dart';
import 'gold_calculator_logic.dart';
import 'services/settings_service.dart';
import 'constants/drop_item_constants.dart';
import 'constants/leader_constants.dart';
import 'constants/stage_constants.dart';

// 정렬 옵션 Enum
enum GoldSortOption { stageName, totalGold }

class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});

  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  final GoldCalculatorLogic _logic = GoldCalculatorLogic();
  List<GoldEfficiencyResult> _results = [];
  bool _isLoading = false;

  List<TimeOption> _timeOptions = [];
  TimeOption? _selectedTimeOption; // 5. 시간 선택 기본값을 null로 (선택 안된 상태)
  final TextEditingController _manualTimeController = TextEditingController();
  final FocusNode _manualTimeFocusNode = FocusNode();
  int _currentSelectedMinutes = 180; // 계산을 위한 기본 분 값은 유지 (예: 180분)

  late String? _selectedLeader;
  late bool _goldHotTime;
  late bool _goldBoost;
  bool _sellGoldDemons = false;
  final TextEditingController _boostDurationController = TextEditingController();

  final NumberFormat _integerFormatter = NumberFormat('#,##0');
  GoldSortOption _selectedSortOption = GoldSortOption.stageName;

  @override
  void initState() {
    super.initState();
    _generateTimeOptions();

    // 5. 시간 선택 드롭다운의 기본값을 null로 설정
    _selectedTimeOption = null;
    // 수동 입력 필드에는 기본 계산 분(_currentSelectedMinutes)을 표시
    _manualTimeController.text = _currentSelectedMinutes.toString();

    final calculatorSettings = SettingsService.instance.calculatorSettings;
    // 4. 리더 선택 기본값을 "리더 없음"으로 설정 (leaderList[0]이 "리더 없음"이라고 가정)
    _selectedLeader = calculatorSettings.selectedLeader ?? (leaderList.isNotEmpty ? leaderList[0] : null);
    _goldHotTime = calculatorSettings.goldHotTime;
    _goldBoost = calculatorSettings.goldBoost;

    _manualTimeFocusNode.addListener(_onManualTimeFocusChange);
    // _manualTimeController 리스너에서 실시간 계산 호출 제거 (Request 2, 3)
    _manualTimeController.addListener(_onManualTimeInputChanged);
    _boostDurationController.addListener(_onBoostDurationChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _calculateEfficiencies(); // 초기 계산 실행
      }
    });
  }

  @override
  void dispose() {
    _manualTimeController.removeListener(_onManualTimeInputChanged);
    _manualTimeFocusNode.removeListener(_onManualTimeFocusChange);
    _boostDurationController.removeListener(_onBoostDurationChanged);
    _manualTimeController.dispose();
    _manualTimeFocusNode.dispose();
    _boostDurationController.dispose();
    _saveCurrentSettings();
    super.dispose();
  }

  void _saveCurrentSettings() {
    final currentSettings = SettingsService.instance.calculatorSettings.copyWith(
        selectedLeader: _selectedLeader,
        goldHotTime: _goldHotTime,
        goldBoost: _goldBoost,
    );
    SettingsService.instance.saveCalculatorSettings(currentSettings);
  }

  void _generateTimeOptions() {
    List<TimeOption> options = [];
    for (int i = 1; i <= 48; i++) {
      int minutes = i * 30;
      String display;
      if (minutes < 60) {
        display = '$minutes분';
      } else {
        int hours = minutes ~/ 60;
        int remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          display = '$hours시간';
        } else {
          display = '$hours시간 $remainingMinutes분';
        }
      }
      options.add(TimeOption(display: display, minutes: minutes));
    }
    _timeOptions = options;
  }

  void _onBoostDurationChanged() {
     _calculateEfficiencies();
  }

  // 분 입력 필드 포커스 변경 시 (Request 3)
  void _onManualTimeFocusChange() {
    if (!_manualTimeFocusNode.hasFocus) {
      // 포커스가 해제될 때 최종 값으로 계산 실행
      _updateMinutesFromManualInput(triggerRecalculate: true);
    }
  }

  // 분 입력 필드 내용 변경 시 (실시간 계산 방지) (Request 2)
  void _onManualTimeInputChanged() {
    if (mounted) {
      final currentText = _manualTimeController.text;
      final currentMinutesFromText = int.tryParse(currentText);

      // 수동 입력값이 시간 선택 옵션과 다르면, 시간 선택 옵션을 null로 변경
      if (_selectedTimeOption != null && currentMinutesFromText != _selectedTimeOption!.minutes) {
         if (mounted) {
            setState(() => _selectedTimeOption = null);
         }
      }
      // 여기서 _calculateEfficiencies()를 호출하지 않음
    }
  }

  // 수동 입력으로부터 분 업데이트 및 계산 트리거 (Request 3)
  void _updateMinutesFromManualInput({bool triggerRecalculate = false}) {
    final String inputText = _manualTimeController.text;
    int? manualMinutes = int.tryParse(inputText);
    bool changed = false;

    if (manualMinutes != null && manualMinutes > 0) {
      if (_currentSelectedMinutes != manualMinutes) {
        _currentSelectedMinutes = manualMinutes;
        changed = true;
      }
      // 입력된 분과 일치하는 TimeOption이 있는지 확인하고, 있다면 선택 (선택적)
      TimeOption? matchingOption;
      for (final option in _timeOptions) {
        if (option.minutes == manualMinutes) {
          matchingOption = option;
          break;
        }
      }
      if (_selectedTimeOption != matchingOption) {
         if (mounted) { // setState는 mounted 확인 후 호출
            setState(() {
              _selectedTimeOption = matchingOption;
            });
         }
        // _selectedTimeOption = matchingOption; // setState 밖에서 직접 변경 X
        changed = true; // selectedTimeOption 변경도 UI 변경으로 간주
      }
    } else if (inputText.isEmpty && _selectedTimeOption != null) {
       // 입력값이 비워졌지만, 이전에 TimeOption이 선택된 경우 해당 값으로 복원
       if (_currentSelectedMinutes != _selectedTimeOption!.minutes) {
         _currentSelectedMinutes = _selectedTimeOption!.minutes;
         _manualTimeController.text = _currentSelectedMinutes.toString(); // 컨트롤러도 업데이트
         changed = true;
       }
    } else if (inputText.isEmpty && _selectedTimeOption == null) {
        // 입력값이 비워지고, TimeOption도 선택 안된 경우 기본값 (예: 180)으로 설정
        const defaultMinutes = 180; // 기본값 설정
        if (_currentSelectedMinutes != defaultMinutes) {
            _currentSelectedMinutes = defaultMinutes;
            _manualTimeController.text = _currentSelectedMinutes.toString();
            // 기본값에 해당하는 TimeOption이 있다면 선택 (선택적)
            TimeOption? defaultOption;
            for (final option in _timeOptions) { if (option.minutes == defaultMinutes) { defaultOption = option; break; } }
             if (mounted) {
                setState(() {
                  _selectedTimeOption = defaultOption;
                });
             }
            changed = true;
        }
    }

    if (changed && mounted) {
      setState(() {}); // UI 업데이트가 필요한 경우 (예: _selectedTimeOption 변경 시)
    }

    if (triggerRecalculate && changed) {
      _calculateEfficiencies();
    } else if (triggerRecalculate && manualMinutes == null && inputText.isNotEmpty) {
      // 유효하지 않은 입력(숫자가 아님)이고 계산을 트리거해야 하는 경우,
      // 이전 유효한 값으로 계산하거나 오류 메시지 표시
      // 여기서는 현재 _currentSelectedMinutes 값으로 계산 시도 (또는 마지막 유효값으로)
      _calculateEfficiencies();
    }
  }

  void _handleManualTimeSubmitted() {
    // 키보드의 완료 버튼(엔터 등)을 눌렀을 때 호출
    _manualTimeFocusNode.unfocus(); // 포커스를 해제하여 _onManualTimeFocusChange가 호출되도록 함
                                     // 또는 여기서 직접 _updateMinutesFromManualInput(triggerRecalculate: true); 호출 가능
  }


  void _calculateEfficiencies() {
    // 분 입력 필드가 포커스를 가지고 있다면, 계산 전 포커스 해제하여 최종값 반영
    // if (_manualTimeFocusNode.hasFocus) {
    //   _manualTimeFocusNode.unfocus();
    //   // 포커스 해제 후 _onManualTimeFocusChange에서 _updateMinutesFromManualInput이 호출되고,
    //   // 그 안에서 _calculateEfficiencies가 다시 호출될 수 있으므로 중복 호출 방지 로직 필요할 수 있음
    //   // 여기서는 _updateMinutesFromManualInput을 직접 호출하여 제어 흐름을 명확히 함
    //   _updateMinutesFromManualInput(triggerRecalculate: false); // 값만 업데이트, 계산은 아래에서
    // }

    // 현재 _currentSelectedMinutes는 _updateMinutesFromManualInput 또는 시간 선택 드롭다운에서 이미 업데이트 되었다고 가정
    final int durationToCalculate = _currentSelectedMinutes;

    if (durationToCalculate <= 0) {
       if (mounted) { // UI 업데이트 전 mounted 확인
           ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계산할 시간을 1분 이상 입력해주세요.'))
            );
           setState(() => _results = []);
       }
       return;
    }

    if (mounted) setState(() => _isLoading = true);

    final stageSettings = SettingsService.instance.stageSettings;
    final currentBonusSettings = SettingsService.instance.calculatorSettings.copyWith(
      selectedLeader: _selectedLeader,
      goldHotTime: _goldHotTime,
      goldBoost: _goldBoost,
    );

    int? boostDurationForCalc;
    if (_goldBoost) {
      boostDurationForCalc = int.tryParse(_boostDurationController.text);
      if (boostDurationForCalc != null && boostDurationForCalc <= 0) {
        boostDurationForCalc = null;
      }
    }

    // 비동기 작업을 Future.delayed 없이 직접 호출
    // UI 업데이트는 setState 내에서 동기적으로 발생
    var calculatedResults = _logic.calculateForAllStages(
      selectedDurationMinutes: durationToCalculate,
      stageSettings: stageSettings,
      bonusSettings: currentBonusSettings,
      sellGoldDemons: _sellGoldDemons,
      boostDurationMinutesFromUI: boostDurationForCalc,
    );

    calculatedResults.sort((a, b) {
      switch (_selectedSortOption) {
        case GoldSortOption.totalGold:
          bool isASettingsIncomplete = a.clearTimeSeconds == null || a.clearTimeSeconds! <= 0;
          bool isBSettingsIncomplete = b.clearTimeSeconds == null || b.clearTimeSeconds! <= 0;

          if (isASettingsIncomplete && !isBSettingsIncomplete) return 1;
          if (!isASettingsIncomplete && isBSettingsIncomplete) return -1;
          if (isASettingsIncomplete && isBSettingsIncomplete) return 0;
          return b.totalExpectedGold.compareTo(a.totalExpectedGold);
        case GoldSortOption.stageName:
          int indexA = stageNameList.indexOf(a.stageName);
          int indexB = stageNameList.indexOf(b.stageName);
          if (indexA == -1 && indexB != -1) return 1;
          if (indexA != -1 && indexB == -1) return -1;
          if (indexA == -1 && indexB == -1) return a.stageName.compareTo(b.stageName);
          return indexA.compareTo(indexB);
      }
    });

    if (mounted) {
      setState(() {
        _results = calculatedResults;
        _isLoading = false;
      });
    }
  }

  void _handleSortOptionChanged(GoldSortOption? newValue) {
    if (newValue != null && _selectedSortOption != newValue) {
      if (mounted) { // setState 호출 전 mounted 확인
        setState(() {
          _selectedSortOption = newValue;
        });
      }
      _calculateEfficiencies();
    }
  }

  void _showStageDetailDialog(GoldEfficiencyResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String demonDetails = result.expectedDemonCounts.entries.map((entry) {
          String demonName = entry.key;
          if (entry.key == goldDemon2Star) demonName = '2성 돈악마';
          if (entry.key == goldDemon3Star) demonName = '3성 돈악마';
          int sellPrice = goldDemonSellPrices[entry.key] ?? 0;
          double expectedGoldFromThisDemonType = entry.value * sellPrice;
          return '$demonName: ${entry.value.toStringAsFixed(2)}개 (예상 ${_integerFormatter.format(expectedGoldFromThisDemonType.round())}골드)';
        }).join('\n');

        if (result.expectedDemonCounts.isEmpty) demonDetails = '해당 스테이지 돈악마 드랍 정보 없음';

        String clearTimeDisplay;
        if (result.clearTimeSeconds != null && result.clearTimeSeconds! > 0) {
          clearTimeDisplay = '${result.clearTimeSeconds!.toStringAsFixed(2)}초';
        } else {
          clearTimeDisplay = '미설정';
        }

        return AlertDialog(
          title: Text('${result.stageName} 상세 정보'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailDialogRow('스테이지 위치:', result.location),
                _buildDetailDialogRow('클리어 시간:', clearTimeDisplay),
                _buildDetailDialogRow('기본 골드(1회):', _integerFormatter.format(result.baseStageGold.round())),
                _buildDetailDialogRow('최종 골드(1회, 현재보너스):', _integerFormatter.format(result.finalGoldPerSingleRunWithBonus.round())),
                _buildDetailDialogRow('설정 시간 내 클리어 횟수:', '${_integerFormatter.format(result.runsOverSelectedDuration.round())}회'),
                const SizedBox(height: 8),
                const Text('돈악마 드랍 기대값:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(demonDetails),
                _buildDetailDialogRow('총 돈악마 판매 예상 골드:', _integerFormatter.format(result.expectedGoldFromDemons.round())),
                 const Divider(height: 16),
                _buildDetailDialogRow('총 예상 스테이지 골드:', _integerFormatter.format(result.expectedGoldFromStage.round())),
                 _buildDetailDialogRow('총 예상 최종 골드:', _integerFormatter.format(result.totalExpectedGold.round()), isBold: true),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailDialogRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoldEfficiencyCalculatorScreenUI(
      timeOptions: _timeOptions,
      selectedTimeOption: _selectedTimeOption,
      onTimeOptionChanged: (TimeOption? newValue) {
        if (mounted) {
          bool needsRecalculate = false;
          setState(() {
            if (_selectedTimeOption != newValue) {
               _selectedTimeOption = newValue;
               // needsRecalculate = true; // 시간 선택 변경 시 즉시 계산하도록 유지
            }
            if (newValue != null) {
              if (_currentSelectedMinutes != newValue.minutes) {
                _currentSelectedMinutes = newValue.minutes;
                _manualTimeController.text = newValue.minutes.toString(); // 수동 입력 필드도 업데이트
                needsRecalculate = true;
              }
              if (_manualTimeFocusNode.hasFocus) {
                _manualTimeFocusNode.unfocus();
              }
            } else { // newValue가 null이면 (예: "시간 선택"을 누르거나 수동 입력 시작)
                // _currentSelectedMinutes는 현재 manualTimeController의 값 또는 기본값으로 유지
                // _manualTimeController.clear(); // 이렇게 하면 사용자가 수동 입력 시작 시 비워짐
            }
          });
          if (needsRecalculate) _calculateEfficiencies();
        }
      },
      manualTimeController: _manualTimeController,
      manualTimeFocusNode: _manualTimeFocusNode,
      // Request 3: onSubmitted 또는 onEditingComplete 추가
      onManualTimeSubmitted: _handleManualTimeSubmitted,
      sellGoldDemons: _sellGoldDemons,
      onSellGoldDemonsChanged: (bool value) {
        if (mounted) {
          setState(() => _sellGoldDemons = value);
          _calculateEfficiencies();
        }
      },
      selectedLeader: _selectedLeader,
      onLeaderChanged: (String? newValue) {
        if (mounted) {
          setState(() => _selectedLeader = newValue);
          _calculateEfficiencies();
        }
      },
      goldHotTime: _goldHotTime,
      onGoldHotTimeChanged: (bool value) {
        if (mounted) {
          setState(() => _goldHotTime = value);
          if (value) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('골드 핫타임은 12:00~14:00까지 진행되며, 계산 시 최대 120분까지만 적용됩니다.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          _calculateEfficiencies();
        }
      },
      goldBoost: _goldBoost,
      onGoldBoostChanged: (bool value) {
        if (mounted) {
          setState(() => _goldBoost = value);
           _calculateEfficiencies();
        }
      },
      boostDurationController: _boostDurationController,
      results: _results,
      isLoading: _isLoading,
      onStageNameTap: _showStageDetailDialog,
      selectedSortOption: _selectedSortOption,
      onSortOptionChanged: _handleSortOptionChanged,
    );
  }
}

// TimeOption 클래스
class TimeOption {
  final String display;
  final int minutes;
  TimeOption({required this.display, required this.minutes});

  // DropdownButtonFormField2에서 비교를 위해 == 와 hashCode 오버라이드 (선택적이지만 권장)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOption &&
          runtimeType == other.runtimeType &&
          display == other.display &&
          minutes == other.minutes;

  @override
  int get hashCode => display.hashCode ^ minutes.hashCode;
}