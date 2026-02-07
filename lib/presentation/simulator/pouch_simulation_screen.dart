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
  final int trials;
  final int drawsPerTrial;
  final double mean;
  final double variance;
  final int min;
  final int max;
  final List<MapEntry<int, int>> topHistogram;

  const PouchSimulationResult({
    required this.trials,
    required this.drawsPerTrial,
    required this.mean,
    required this.variance,
    required this.min,
    required this.max,
    required this.topHistogram,
  });
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
  final TextEditingController _simulationCountController =
      TextEditingController(text: '10000');
  bool _isSimulating = false;
  PouchSimulationResult? _result;

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

    final trials = int.tryParse(_simulationCountController.text.trim());
    if (trials == null || trials <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시뮬레이션 횟수를 확인해주세요.')),
      );
      return;
    }

    setState(() {
      _isSimulating = true;
    });

    final random = Random();
    final items = _currentItems;

    double sum = 0.0;
    double sumSquares = 0.0;
    int? minTotal;
    int? maxTotal;
    final Map<int, int> histogram = {};

    for (int i = 0; i < trials; i++) {
      int total = 0;
      for (int j = 0; j < _selectedDrawCount; j++) {
        total += _drawOnce(random, items);
      }

      sum += total;
      sumSquares += total * total;
      minTotal = (minTotal == null) ? total : min(minTotal, total);
      maxTotal = (maxTotal == null) ? total : max(maxTotal, total);
      histogram[total] = (histogram[total] ?? 0) + 1;
    }

    final mean = sum / trials;
    final variance = (sumSquares / trials) - (mean * mean);

    final entries = histogram.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });

    final result = PouchSimulationResult(
      trials: trials,
      drawsPerTrial: _selectedDrawCount,
      mean: mean,
      variance: variance,
      min: minTotal ?? 0,
      max: maxTotal ?? 0,
      topHistogram: entries.take(10).toList(),
    );

    if (!mounted) return;

    setState(() {
      _result = result;
      _isSimulating = false;
    });
  }

  void _resetSimulation() {
    setState(() {
      _result = null;
      _isSimulating = false;
    });
  }

  @override
  void dispose() {
    _simulationCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PouchSimulationScreenUI(
      selectedType: _selectedType,
      drawCountOptions: _drawCountOptions,
      selectedDrawCount: _selectedDrawCount,
      simulationCountController: _simulationCountController,
      isSimulating: _isSimulating,
      result: _result,
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
