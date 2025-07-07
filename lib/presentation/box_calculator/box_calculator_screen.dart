// lib/presentation/box_calculator/box_calculator_screen.dart
import 'package:flutter/material.dart';
import '../../domain/logic/box_calculator_logic.dart';
import 'box_calculator_screen_ui.dart';

class BoxCalculatorScreen extends StatefulWidget {
  const BoxCalculatorScreen({super.key});

  @override
  State<BoxCalculatorScreen> createState() => _BoxCalculatorScreenState();
}

class _BoxCalculatorScreenState extends State<BoxCalculatorScreen> {
  // 각 상자 종류에 대한 TextEditingController를 생성합니다.
  final _normalBoxCountController = TextEditingController();
  final _rareBoxCountController = TextEditingController();
  final _legendaryBoxCountController = TextEditingController();

  final _logic = BoxCalculatorLogic();
  List<ExpectedValueResult> _results = [];
  int _totalGoldCost = 0;

  @override
  void dispose() {
    // 모든 컨트롤러를 dispose 처리합니다.
    _normalBoxCountController.dispose();
    _rareBoxCountController.dispose();
    _legendaryBoxCountController.dispose();
    super.dispose();
  }

  void _calculate() {
    // 각 입력 필드에서 상자 개수를 가져옵니다.
    final int normalBoxCount = int.tryParse(_normalBoxCountController.text) ?? 0;
    final int rareBoxCount = int.tryParse(_rareBoxCountController.text) ?? 0;
    final int legendaryBoxCount = int.tryParse(_legendaryBoxCountController.text) ?? 0;

    // 참고: 이 변경에 따라 BoxCalculatorLogic의 계산 메서드도 수정이 필요할 수 있습니다.
    // 예를 들어, 아래와 같이 세 가지 상자 개수를 모두 받아
    // 결과 목록과 총 골드 비용을 함께 반환하는 형태가 되어야 합니다.
    final calculationResult = _logic.calculate(
      normalBoxCount: normalBoxCount,
      rareBoxCount: rareBoxCount,
      legendaryBoxCount: legendaryBoxCount,
    );

    setState(() {
      // 계산 결과를 상태에 반영합니다.
      _results = calculationResult.results;
      _totalGoldCost = calculationResult.totalGoldCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    // BoxCalculatorScreenUI에 필요한 모든 데이터를 전달합니다.
    return BoxCalculatorScreenUI(
      normalBoxCountController: _normalBoxCountController,
      rareBoxCountController: _rareBoxCountController,
      legendaryBoxCountController: _legendaryBoxCountController,
      results: _results,
      totalGoldCost: _totalGoldCost,
      onCalculatePressed: () {
        _calculate(); // 계산 로직 호출
        FocusScope.of(context).unfocus(); // 계산 버튼을 눌렀을 때만 키보드 숨기기
      },
    );
  }
}