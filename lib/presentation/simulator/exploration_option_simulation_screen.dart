// lib/presentation/simulator/exploration_option_simulation_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'exploration_option_simulation_screen_ui.dart';

/// 탐 옵션 등급
enum ExplorationOptionGrade {
  c('C등급', 50.0),
  b('B등급', 30.0),
  a('A등급', 15.0),
  s('S등급', 4.0),
  ss('SS등급', 1.0);

  final String label;
  final double probability; // 각 옵션당 개별 확률 (%)

  const ExplorationOptionGrade(this.label, this.probability);
}

/// 탐 옵션 데이터 모델
class ExplorationOption {
  final String name;
  final String description;
  final Map<ExplorationOptionGrade, int> gradeValues;

  const ExplorationOption({
    required this.name,
    required this.description,
    required this.gradeValues,
  });

  int? valueForGrade(ExplorationOptionGrade? grade) {
    if (grade == null) return null;
    return gradeValues[grade];
  }
}

/// 탐 옵션 목록 및 확률 관리
class ExplorationOptionData {
  static const List<ExplorationOption> options = [
    ExplorationOption(
      name: '공격력',
      description: '공격력',
      gradeValues: {
        ExplorationOptionGrade.c: 150,
        ExplorationOptionGrade.b: 300,
        ExplorationOptionGrade.a: 600,
        ExplorationOptionGrade.s: 1200,
        ExplorationOptionGrade.ss: 2500,
      },
    ),
    ExplorationOption(
      name: '체력',
      description: '체력',
      gradeValues: {
        ExplorationOptionGrade.c: 300,
        ExplorationOptionGrade.b: 600,
        ExplorationOptionGrade.a: 1200,
        ExplorationOptionGrade.s: 2400,
        ExplorationOptionGrade.ss: 5000,
      },
    ),
    ExplorationOption(
      name: '크리티컬 데미지',
      description: '크리티컬 데미지',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 16,
        ExplorationOptionGrade.ss: 35,
      },
    ),
    ExplorationOption(
      name: '크리티컬',
      description: '크리티컬',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 16,
        ExplorationOptionGrade.ss: 35,
      },
    ),
    ExplorationOption(
      name: '크리티컬 저항',
      description: '크리티컬 저항',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '명중',
      description: '명중',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 16,
        ExplorationOptionGrade.ss: 35,
      },
    ),
    ExplorationOption(
      name: '회피',
      description: '회피',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '공격 스킬 피해 증가',
      description: '공격 스킬 피해 증가',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '받는 공격 스킬 피해 감소',
      description: '받는 공격 스킬 피해 감소',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '일반 공격 피해 증가',
      description: '일반 공격 피해 증가',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '받는 일반 공격 피해 감소',
      description: '받는 일반 공격 피해 감소',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '지속 피해 증가',
      description: '지속 피해 증가',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '받는 지속 피해 감소',
      description: '받는 지속 피해 감소',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '모든 나쁜 효과 저항',
      description: '모든 나쁜 효과 저항',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 20,
      },
    ),
    ExplorationOption(
      name: '소환수 공격력',
      description: '소환수 공격력',
      gradeValues: {
        ExplorationOptionGrade.c: 2000,
        ExplorationOptionGrade.b: 4000,
        ExplorationOptionGrade.a: 8000,
        ExplorationOptionGrade.s: 15000,
        ExplorationOptionGrade.ss: 30000,
      },
    ),
    ExplorationOption(
      name: '반격 확률',
      description: '반격 확률',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '우주여행 돌아올 확률',
      description: '우주여행 돌아올 확률',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '매턴 체력 회복',
      description: '매턴 체력 회복',
      gradeValues: {
        ExplorationOptionGrade.c: 2000,
        ExplorationOptionGrade.b: 4000,
        ExplorationOptionGrade.a: 6000,
        ExplorationOptionGrade.s: 8000,
        ExplorationOptionGrade.ss: 12000,
      },
    ),
    ExplorationOption(
      name: '모든 피해 감소',
      description: '모든 피해 감소',
      gradeValues: {
        ExplorationOptionGrade.c: 1,
        ExplorationOptionGrade.b: 2,
        ExplorationOptionGrade.a: 4,
        ExplorationOptionGrade.s: 6,
        ExplorationOptionGrade.ss: 10,
      },
    ),
    ExplorationOption(
      name: '미니게임 스킬 피해 증가',
      description: '미니게임 스킬 피해 증가',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '회복 효과 증가',
      description: '회복 효과 증가',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 4,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '공격력 %',
      description: '공격력 %',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '체력 %',
      description: '체력 %',
      gradeValues: {
        ExplorationOptionGrade.c: 5,
        ExplorationOptionGrade.b: 10,
        ExplorationOptionGrade.a: 15,
        ExplorationOptionGrade.s: 25,
        ExplorationOptionGrade.ss: 40,
      },
    ),
    ExplorationOption(
      name: '관통 저항',
      description: '관통 저항',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '관통 확률',
      description: '관통 확률',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 12,
        ExplorationOptionGrade.ss: 25,
      },
    ),
    ExplorationOption(
      name: '불속성 캐릭터에게 주는 피해 증가',
      description: '불속성 피해',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '물속성 캐릭터에게 주는 피해 증가',
      description: '물속성 피해',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '나무속성 캐릭터에게 주는 피해 증가',
      description: '나무속성 피해',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '빛속성 캐릭터에게 주는 피해 증가',
      description: '빛속성 피해',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '어둠속성 캐릭터에게 주는 피해 증가',
      description: '어둠속성 피해',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 4,
        ExplorationOptionGrade.a: 8,
        ExplorationOptionGrade.s: 15,
        ExplorationOptionGrade.ss: 30,
      },
    ),
    ExplorationOption(
      name: '최종 피해 증가',
      description: '최종 피해 증가',
      gradeValues: {
        ExplorationOptionGrade.c: 2,
        ExplorationOptionGrade.b: 3,
        ExplorationOptionGrade.a: 6,
        ExplorationOptionGrade.s: 10,
        ExplorationOptionGrade.ss: 15,
      },
    ),
    ExplorationOption(
      name: '최종 피해 감소',
      description: '최종 피해 감소',
      gradeValues: {
        ExplorationOptionGrade.c: 1,
        ExplorationOptionGrade.b: 2,
        ExplorationOptionGrade.a: 4,
        ExplorationOptionGrade.s: 6,
        ExplorationOptionGrade.ss: 9,
      },
    ),
  ];

  /// 각 옵션당 정확히 1개가 나올 때의 확률
  /// 모든 옵션의 확률을 합치면 약 62.5%
  static double getTotalOptionProbability() {
    return ExplorationOptionGrade.values
        .fold<double>(0, (sum, grade) => sum + grade.probability) *
        options.length;
  }

  static ExplorationOption? getOptionByIndex(int index) {
    if (index >= 0 && index < options.length) {
      return options[index];
    }
    return null;
  }
}

/// 탐 옵션 시뮬레이션 화면
/// 기능 및 세부 로직은 추후 구현 예정
class ExplorationOptionSimulationScreen extends StatefulWidget {
  const ExplorationOptionSimulationScreen({super.key});

  @override
  State<ExplorationOptionSimulationScreen> createState() =>
      _ExplorationOptionSimulationScreenState();
}

class _ExplorationOptionSimulationScreenState
    extends State<ExplorationOptionSimulationScreen> {
  // 현재 선택된 탐 레벨 (1~10)
  int _explorationLevel = 1;

  // 옵션 보호 등급
  ExplorationOptionGrade _protectionGrade = ExplorationOptionGrade.ss;

  // 자동 옵션 변경 목표 등급
  ExplorationOptionGrade _autoTargetGrade = ExplorationOptionGrade.a;

  // 자동 옵션 변경 실행 여부
  bool _isAutoRunning = false;

  // 각 슬롯별 옵션 결과
  List<ExplorationOption?> _slotOptions = [];

  // 각 슬롯별 등급 결과
  List<ExplorationOptionGrade?> _slotGrades = [];

  // 각 슬롯별 잠금 상태
  List<bool> _slotLocked = [];

  // 누적 소모 재화
  int _totalResourceConsumed = 0;

  // 시뮬레이션 상태
  bool _isSimulating = false;

  // 시뮬레이션 결과 로그
  List<String> _simulationLog = [];

  // 등급별 결과 카운트 (전체)
  Map<ExplorationOptionGrade, int> _gradeCount = {
    ExplorationOptionGrade.c: 0,
    ExplorationOptionGrade.b: 0,
    ExplorationOptionGrade.a: 0,
    ExplorationOptionGrade.s: 0,
    ExplorationOptionGrade.ss: 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeSlots();
  }

  /// 슬롯 초기화
  void _initializeSlots() {
    _slotOptions = List<ExplorationOption?>.filled(_explorationLevel, null);
    _slotGrades = List<ExplorationOptionGrade?>.filled(_explorationLevel, null);
    _slotLocked = List<bool>.filled(_explorationLevel, false);
  }

  /// 탐 레벨 변경
  void _setExplorationLevel(int level) {
    if (level < 1 || level > 10) return;

    setState(() {
      _explorationLevel = level;
      _initializeSlots();
    });
  }

  void _setProtectionGrade(ExplorationOptionGrade grade) {
    setState(() {
      _protectionGrade = grade;
    });
  }

  void _setAutoTargetGrade(ExplorationOptionGrade grade) {
    setState(() {
      _autoTargetGrade = grade;
    });
  }

  void _startAutoChange() {
    if (_isAutoRunning) return;
    setState(() {
      _isAutoRunning = true;
    });
    _autoTick();
  }

  void _stopAutoChange() {
    if (!_isAutoRunning) return;
    setState(() {
      _isAutoRunning = false;
    });
  }

  void _autoTick() {
    if (!_isAutoRunning || !mounted) return;
    if (_allSlotsLocked) {
      _stopAutoChange();
      return;
    }

    _runAllSlotsSimulation();

    if (_hasUnlockedAtOrAbove(_autoTargetGrade)) {
      _stopAutoChange();
      return;
    }

    Future.delayed(const Duration(milliseconds: 2), () {
      _autoTick();
    });
  }

  bool _hasUnlockedAtOrAbove(ExplorationOptionGrade target) {
    final grades = ExplorationOptionGrade.values;
    final targetIndex = grades.indexOf(target);
    for (int i = 0; i < _slotGrades.length; i++) {
      if (_slotLocked[i]) continue;
      final grade = _slotGrades[i];
      if (grade == null) continue;
      if (grades.indexOf(grade) >= targetIndex) {
        return true;
      }
    }
    return false;
  }

  void _toggleSlotLock(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _explorationLevel) return;
    setState(() {
      _slotLocked[slotIndex] = !_slotLocked[slotIndex];
    });
  }

  bool get _allSlotsLocked =>
      _slotLocked.isNotEmpty && _slotLocked.every((locked) => locked);

  /// 랜덤 옵션 선택
  ExplorationOption _selectRandomOption() {
    final random = Random();
    final index = random.nextInt(ExplorationOptionData.options.length);
    return ExplorationOptionData.options[index];
  }

  /// 확률에 기반하여 등급 선택
  ExplorationOptionGrade _selectGradeByProbability() {
    final random = Random().nextDouble() * 100; // 0~100 사이의 난수
    double cumulativeProbability = 0.0;

    for (final grade in ExplorationOptionGrade.values) {
      cumulativeProbability += grade.probability;
      if (random < cumulativeProbability) {
        return grade;
      }
    }
    return ExplorationOptionGrade.c; // 폴백
  }

  /// 전체 슬롯 옵션 변경
  void _runAllSlotsSimulation() {
    if (_isSimulating) return;
    if (_allSlotsLocked) return;

    final unlockedIndices = <int>[];
    for (int i = 0; i < _explorationLevel; i++) {
      if (!_slotLocked[i]) {
        unlockedIndices.add(i);
      }
    }

    if (unlockedIndices.isEmpty) return;

    final lockedCount = _slotLocked.where((locked) => locked).length;
    final cost = 50 + (lockedCount * 50);

    setState(() {
      _isSimulating = true;
      _totalResourceConsumed += cost;

      for (final slotIndex in unlockedIndices) {
        final option = _selectRandomOption();
        final grade = _selectGradeByProbability();

        _slotOptions[slotIndex] = option;
        _slotGrades[slotIndex] = grade;

        _gradeCount[grade] = (_gradeCount[grade] ?? 0) + 1;
      }

      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        final totalValuesText = unlockedIndices.map((slotIndex) {
        final option = _slotOptions[slotIndex];
        final grade = _slotGrades[slotIndex];
        final value = option?.valueForGrade(grade);
        return value != null ? '${slotIndex + 1}칸:${option?.name} $value' : '${slotIndex + 1}칸:${option?.name}';
        }).join(', ');
        _simulationLog.add(
          '$timeStr - 옵션 변경 완료 (잠금 $lockedCount칸, 소모 $cost 탐의 편린) | $totalValuesText');

      _isSimulating = false;
    });
  }

  /// 시뮬레이션 초기화
  void _resetSimulation() {
    setState(() {
      _isAutoRunning = false;
      _slotOptions = List<ExplorationOption?>.filled(_explorationLevel, null);
      _slotGrades = List<ExplorationOptionGrade?>.filled(_explorationLevel, null);
      _slotLocked = List<bool>.filled(_explorationLevel, false);
      _totalResourceConsumed = 0;
      _simulationLog = [];
      _isSimulating = false;
      _gradeCount = {
        ExplorationOptionGrade.c: 0,
        ExplorationOptionGrade.b: 0,
        ExplorationOptionGrade.a: 0,
        ExplorationOptionGrade.s: 0,
        ExplorationOptionGrade.ss: 0,
      };
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExplorationOptionSimulationScreenUI(
        explorationLevel: _explorationLevel,
        slotOptions: _slotOptions,
        slotGrades: _slotGrades,
        slotLocked: _slotLocked,
        protectionGrade: _protectionGrade,
        autoTargetGrade: _autoTargetGrade,
        totalResourceConsumed: _totalResourceConsumed,
        simulationLog: _simulationLog,
        isSimulating: _isSimulating,
        isAutoRunning: _isAutoRunning,
        gradeCount: _gradeCount,
        onSetExplorationLevel: _setExplorationLevel,
        onSetProtectionGrade: _setProtectionGrade,
        onSetAutoTargetGrade: _setAutoTargetGrade,
        onStartAutoChange: _startAutoChange,
        onStopAutoChange: _stopAutoChange,
        onToggleSlotLock: _toggleSlotLock,
        onRunAllSlotsSimulation: _runAllSlotsSimulation,
        onResetSimulation: _resetSimulation,
      ),
    );
  }
}
