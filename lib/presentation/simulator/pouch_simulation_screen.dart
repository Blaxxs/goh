import 'dart:math';

import 'package:flutter/material.dart';

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

class PouchSimulationResult {
  const PouchSimulationResult();
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
  bool _isSimulating = false;

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

    setState(() {
      _isSimulating = true;
    });

    final random = Random();
    final items = _currentItems;

    final results = <int>[];
    for (int j = 0; j < _selectedDrawCount; j++) {
      results.add(_drawOnce(random, items));
    }

    if (!mounted) return;

    setState(() {
      _isSimulating = false;
    });

    _showResultDialog(results);
  }

  void _resetSimulation() {
    setState(() {
      _isSimulating = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PouchSimulationScreenUI(
      selectedType: _selectedType,
      drawCountOptions: _drawCountOptions,
      selectedDrawCount: _selectedDrawCount,
      isSimulating: _isSimulating,
      onTypeChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedType = value;
        });
      },
      onDrawCountChanged: (value) {
        setState(() {
          _selectedDrawCount = value;
        });
      },
      onRunSimulation: _runSimulation,
      onResetSimulation: _resetSimulation,
    );
  }
}
