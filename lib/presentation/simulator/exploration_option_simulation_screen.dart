// lib/presentation/simulator/exploration_option_simulation_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'exploration_option_simulation_screen_ui.dart';

/// 탐 옵션 등급
enum ExplorationOptionGrade {
  c('C등급', 0.50),
  b('B등급', 0.30),
  a('A등급', 0.15),
  s('S등급', 0.04),
  ss('SS등급', 0.01);

  final String label;
  final double probability;

  const ExplorationOptionGrade(this.label, this.probability);
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

  // 현재 옵션 목록 (추후 구체화)
  List<String> _currentOptions = [];

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

  @override
  void initState() {
    super.initState();
    // 초기화 로직 (추후 구현)
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
        _currentOptions = ["옵션1", "옵션2"]; // 임시
      });
    }
  }

  /// 확률에 기반하여 등급 선택
  ExplorationOptionGrade _selectGradeByProbability() {
    final random = Random().nextDouble();
    double cumulativeProbability = 0.0;

    for (final grade in ExplorationOptionGrade.values) {
      cumulativeProbability += grade.probability;
      if (random < cumulativeProbability) {
        return grade;
      }
    }
    return ExplorationOptionGrade.c; // 폴백
  }

  /// 시뮬레이션 실행 (추후 구현)
  void _runSimulation() {
    if (_selectedExploration == null) return;

    setState(() {
      _isSimulating = true;
    });

    // 확률 기반 등급 선택
    final selectedGrade = _selectGradeByProbability();
    _gradeCount[selectedGrade] = (_gradeCount[selectedGrade] ?? 0) + 1;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSimulating = false;
          _totalResourceConsumed += 10; // 임시
          _simulationLog.add("${DateTime.now().toString().split('.').first} - ${selectedGrade.label} 획득");
        });
      }
    });
  }

  /// 시뮬레이션 초기화
  void _resetSimulation() {
    setState(() {
      _selectedExploration = null;
      _currentOptions = [];
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
