// lib/presentation/simulator/exploration_option_simulation_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'exploration_option_simulation_screen_ui.dart';

/// 탐 옵션 등급
enum ExplorationOptionGrade {
  c('C등급', 1.5625),
  b('B등급', 0.9375),
  a('A등급', 0.46875),
  s('S등급', 0.125),
  ss('SS등급', 0.03125);

  final String label;
  final double probability; // 각 옵션당 개별 확률 (%)

  const ExplorationOptionGrade(this.label, this.probability);
}

/// 탐 옵션 데이터 모델
class ExplorationOption {
  final String name;
  final String description;

  const ExplorationOption({
    required this.name,
    required this.description,
  });
}

/// 탐 옵션 목록 및 확률 관리
class ExplorationOptionData {
  static const List<ExplorationOption> options = [
    ExplorationOption(name: '공격력', description: '공격력'),
    ExplorationOption(name: '체력', description: '체력'),
    ExplorationOption(name: '크리티컬 데미지', description: '크리티컬 데미지'),
    ExplorationOption(name: '크리티컬', description: '크리티컬'),
    ExplorationOption(name: '크리티컬 저항', description: '크리티컬 저항'),
    ExplorationOption(name: '명중', description: '명중'),
    ExplorationOption(name: '회피', description: '회피'),
    ExplorationOption(name: '공격 스킬 피해 증가', description: '공격 스킬 피해 증가'),
    ExplorationOption(name: '받는 공격 스킬 피해 감소', description: '받는 공격 스킬 피해 감소'),
    ExplorationOption(name: '일반 공격 피해 증가', description: '일반 공격 피해 증가'),
    ExplorationOption(name: '받는 일반 공격 피해 감소', description: '받는 일반 공격 피해 감소'),
    ExplorationOption(name: '지속 피해 증가', description: '지속 피해 증가'),
    ExplorationOption(name: '받는 지속 피해 감소', description: '받는 지속 피해 감소'),
    ExplorationOption(name: '모든 나쁜 효과 저항', description: '모든 나쁜 효과 저항'),
    ExplorationOption(name: '소환수 공격력', description: '소환수 공격력'),
    ExplorationOption(name: '반격 확률', description: '반격 확률'),
    ExplorationOption(name: '우주여행 돌아올 확률', description: '우주여행 돌아올 확률'),
    ExplorationOption(name: '매턴 체력 회복', description: '매턴 체력 회복'),
    ExplorationOption(name: '모든 피해 감소', description: '모든 피해 감소'),
    ExplorationOption(name: '미니게임 스킬 피해 증가', description: '미니게임 스킬 피해 증가'),
    ExplorationOption(name: '회복 효과 증가', description: '회복 효과 증가'),
    ExplorationOption(name: '공격력 %', description: '공격력 %'),
    ExplorationOption(name: '체력 %', description: '체력 %'),
    ExplorationOption(name: '관통 저항', description: '관통 저항'),
    ExplorationOption(name: '관통 확률', description: '관통 확률'),
    ExplorationOption(name: '불속성 캐릭터에게 주는 피해 증가', description: '불속성 피해'),
    ExplorationOption(name: '물속성 캐릭터에게 주는 피해 증가', description: '물속성 피해'),
    ExplorationOption(name: '나무속성 캐릭터에게 주는 피해 증가', description: '나무속성 피해'),
    ExplorationOption(name: '빛속성 캐릭터에게 주는 피해 증가', description: '빛속성 피해'),
    ExplorationOption(name: '어둠속성 캐릭터에게 주는 피해 증가', description: '어둠속성 피해'),
    ExplorationOption(name: '최종 피해 증가', description: '최종 피해 증가'),
    ExplorationOption(name: '최종 피해 감소', description: '최종 피해 감소'),
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
  // 현재 선택된 탐 (추후 모델 정의 필요)
  String? _selectedExploration;

  // 현재 선택된 옵션
  ExplorationOption? _selectedOption;

  // 누적 소모 재화 (추후 재화 종류 및 이름 확정 필요)
  int _totalResourceConsumed = 0;

  // 시뮬레이션 상태
  bool _isSimulating = false;

  // 시뮬레이션 결과 로그
  List<String> _simulationLog = [];

  // 등급별 결과 카운트
  Map<ExplorationOptionGrade, int> _gradeCount = {
    ExplorationOptionGrade.c: 0,
    ExplorationOptionGrade.b: 0,
    ExplorationOptionGrade.a: 0,
    ExplorationOptionGrade.s: 0,
    ExplorationOptionGrade.ss: 0,
  };

  // 옵션별 결과 카운트
  Map<String, Map<ExplorationOptionGrade, int>> _optionGradeCount = {};

  @override
  void initState() {
    super.initState();
    // 옵션별 카운트 초기화
    for (var option in ExplorationOptionData.options) {
      _optionGradeCount[option.name] = {
        ExplorationOptionGrade.c: 0,
        ExplorationOptionGrade.b: 0,
        ExplorationOptionGrade.a: 0,
        ExplorationOptionGrade.s: 0,
        ExplorationOptionGrade.ss: 0,
      };
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 탐 선택 (추후 구현)
  Future<void> _selectExploration() async {
    // TODO: 탐 선택 로직
    if (mounted) {
      setState(() {
        _selectedExploration = "샘플 탐"; // 임시
      });
    }
  }

  /// 옵션 선택
  void _selectOption(ExplorationOption option) {
    setState(() {
      _selectedOption = option;
    });
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

  /// 시뮬레이션 실행
  void _runSimulation() {
    if (_selectedOption == null) return;

    setState(() {
      _isSimulating = true;
    });

    // 확률 기반 등급 선택
    final selectedGrade = _selectGradeByProbability();
    
    setState(() {
      _gradeCount[selectedGrade] = (_gradeCount[selectedGrade] ?? 0) + 1;
      _optionGradeCount[_selectedOption!.name]![selectedGrade] =
          (_optionGradeCount[_selectedOption!.name]![selectedGrade] ?? 0) + 1;
      _totalResourceConsumed += 10; // 임시
      
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      _simulationLog.add('$timeStr - ${_selectedOption!.name} ${selectedGrade.label}');
      
      _isSimulating = false;
    });
  }

  /// 시뮬레이션 초기화
  void _resetSimulation() {
    setState(() {
      _selectedExploration = null;
      _selectedOption = null;
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
      
      // 옵션별 카운트 초기화
      for (var option in ExplorationOptionData.options) {
        _optionGradeCount[option.name] = {
          ExplorationOptionGrade.c: 0,
          ExplorationOptionGrade.b: 0,
          ExplorationOptionGrade.a: 0,
          ExplorationOptionGrade.s: 0,
          ExplorationOptionGrade.ss: 0,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExplorationOptionSimulationScreenUI(
      selectedExploration: _selectedExploration,
      currentOptions: _currentOptions,
      totalResourceConsumed: _totalResourceConsumed,
      simulationLog: _simulationLog,
      isSimulating: _isSimulating,
      gradeCount: _gradeCount,
      onSelectExploration: _selectExploration,
      onRunSimulation: _runSimulation,
      onResetSimulation: _resetSimulation,
    );
  }
}
