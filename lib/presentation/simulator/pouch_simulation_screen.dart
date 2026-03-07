import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/widgets/back_to_main_scope.dart';

import 'pouch_simulation_screen_ui.dart';

enum PouchType {
  soulStone,
  gold,
  stamina,
}

extension PouchTypeLabel on PouchType {
  String get label {
    switch (this) {
      case PouchType.soulStone:
        return '영혼석 주머니';
      case PouchType.gold:
        return '골드 주머니';
      case PouchType.stamina:
        return '스태미너 주머니';
    }
  }
}

class PouchItem {
  final int amount;
  final double probability;

  const PouchItem({required this.amount, required this.probability});
}

class PouchSimulationScreen extends StatefulWidget {
  const PouchSimulationScreen({super.key});

  @override
  State<PouchSimulationScreen> createState() => _PouchSimulationScreenState();
}

class _PouchSimulationScreenState extends State<PouchSimulationScreen> {
  static const List<int> _drawCountOptions = [1, 10, 50, 100];

  static const List<PouchItem> _soulStoneItems = [
    PouchItem(amount: 10, probability: 9.95),
    PouchItem(amount: 20, probability: 10),
    PouchItem(amount: 30, probability: 10),
    PouchItem(amount: 40, probability: 10),
    PouchItem(amount: 50, probability: 9),
    PouchItem(amount: 70, probability: 8.25),
    PouchItem(amount: 90, probability: 7.25),
    PouchItem(amount: 110, probability: 6.5),
    PouchItem(amount: 130, probability: 5.5),
    PouchItem(amount: 150, probability: 4.75),
    PouchItem(amount: 180, probability: 4.5),
    PouchItem(amount: 210, probability: 3.5),
    PouchItem(amount: 240, probability: 3),
    PouchItem(amount: 270, probability: 2.25),
    PouchItem(amount: 300, probability: 1.75),
    PouchItem(amount: 340, probability: 1.25),
    PouchItem(amount: 380, probability: 1),
    PouchItem(amount: 420, probability: 0.75),
    PouchItem(amount: 460, probability: 0.5),
    PouchItem(amount: 500, probability: 0.25),
    PouchItem(amount: 1000, probability: 0.05),
  ];

  static const List<PouchItem> _goldItems = [
    PouchItem(amount: 200000, probability: 2.5),
    PouchItem(amount: 400000, probability: 5),
    PouchItem(amount: 600000, probability: 7.5),
    PouchItem(amount: 800000, probability: 10),
    PouchItem(amount: 1000000, probability: 10),
    PouchItem(amount: 1400000, probability: 10),
    PouchItem(amount: 1800000, probability: 10),
    PouchItem(amount: 2200000, probability: 10),
    PouchItem(amount: 2600000, probability: 9),
    PouchItem(amount: 3000000, probability: 7.5),
    PouchItem(amount: 3600000, probability: 5),
    PouchItem(amount: 4200000, probability: 3.75),
    PouchItem(amount: 4800000, probability: 2.5),
    PouchItem(amount: 5400000, probability: 2),
    PouchItem(amount: 6000000, probability: 1.5),
    PouchItem(amount: 6800000, probability: 1.25),
    PouchItem(amount: 7600000, probability: 1),
    PouchItem(amount: 8400000, probability: 0.75),
    PouchItem(amount: 9200000, probability: 0.5),
    PouchItem(amount: 10000000, probability: 0.25),
  ];

  static const List<PouchItem> _staminaItems = [
    PouchItem(amount: 15, probability: 5),
    PouchItem(amount: 30, probability: 6.25),
    PouchItem(amount: 45, probability: 7.5),
    PouchItem(amount: 60, probability: 8.75),
    PouchItem(amount: 75, probability: 10),
    PouchItem(amount: 105, probability: 12.5),
    PouchItem(amount: 135, probability: 10),
    PouchItem(amount: 165, probability: 8.25),
    PouchItem(amount: 195, probability: 7),
    PouchItem(amount: 225, probability: 6),
    PouchItem(amount: 270, probability: 5.5),
    PouchItem(amount: 315, probability: 3.5),
    PouchItem(amount: 360, probability: 2.5),
    PouchItem(amount: 405, probability: 2),
    PouchItem(amount: 450, probability: 1.5),
    PouchItem(amount: 510, probability: 1.25),
    PouchItem(amount: 570, probability: 1),
    PouchItem(amount: 630, probability: 0.75),
    PouchItem(amount: 690, probability: 0.5),
    PouchItem(amount: 750, probability: 0.25),
  ];

  PouchType _selectedType = PouchType.soulStone;
  int _selectedDrawCount = _drawCountOptions.first;
  bool _useCustomDrawCount = false;
  final TextEditingController _customDrawCountController =
      TextEditingController();
  bool _isSimulating = false;
  final List<String> _openLogs = [];

  List<PouchItem> get _currentItems {
    switch (_selectedType) {
      case PouchType.soulStone:
        return _soulStoneItems;
      case PouchType.gold:
        return _goldItems;
      case PouchType.stamina:
        return _staminaItems;
    }
  }

  int _drawOnce(Random random, List<PouchItem> items) {
    final roll = random.nextDouble() * 100.0;
    double cumulative = 0.0;
    for (final item in items) {
      cumulative += item.probability;
      if (roll < cumulative) {
        return item.amount;
      }
    }
    return items.last.amount;
  }

  void _runSimulation() {
    if (_isSimulating) return;

    int drawCount = _selectedDrawCount;
    if (_useCustomDrawCount) {
      final parsed = int.tryParse(_customDrawCountController.text.trim());
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('개봉 개수를 확인해주세요.')),
        );
        return;
      }
      drawCount = parsed;
    }

    setState(() {
      _isSimulating = true;
    });

    final random = Random();
    final items = _currentItems;

    final results = <int>[];
    for (int j = 0; j < drawCount; j++) {
      results.add(_drawOnce(random, items));
    }

    final int totalAmount = results.fold(0, (sum, value) => sum + value);
    final double averageAmount =
      results.isEmpty ? 0 : totalAmount / results.length;
    final DateTime now = DateTime.now();
    final String timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    if (!mounted) return;

    setState(() {
      _isSimulating = false;
      _openLogs.insert(
        0,
        '$timeText | $drawCount개 | 합계 $totalAmount | 평균 ${averageAmount.toStringAsFixed(2)}',
      );
    });

    _showResultDialog(results);
  }

  void _resetSimulation() {
    setState(() {
      _isSimulating = false;
      _openLogs.clear();
    });
  }

  void _showResultDialog(List<int> results) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return PouchResultDialog(
          pouchType: _selectedType,
          results: results,
        );
      },
    );
  }

  @override
  void dispose() {
    _customDrawCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackToMainScope(
      child: PouchSimulationScreenUI(
        selectedType: _selectedType,
        drawCountOptions: _drawCountOptions,
        selectedDrawCount: _selectedDrawCount,
        useCustomDrawCount: _useCustomDrawCount,
        customDrawCountController: _customDrawCountController,
        isSimulating: _isSimulating,
        openLogs: _openLogs,
        onTypeChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedType = value;
        });
      },
      onDrawCountChanged: (value) {
        setState(() {
          _useCustomDrawCount = false;
          _selectedDrawCount = value;
        });
      },
      onSelectCustomDrawCount: () {
        setState(() {
          _useCustomDrawCount = true;
        });
      },
      onRunSimulation: _runSimulation,
      onResetSimulation: _resetSimulation,
      ),
    );
  }
}
