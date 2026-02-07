import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/box_constants.dart';
import '../../core/widgets/app_drawer.dart';
import 'pouch_simulation_screen.dart';

class PouchSimulationScreenUI extends StatelessWidget {
  final PouchType selectedType;
  final List<int> drawCountOptions;
  final int selectedDrawCount;
  final bool isSimulating;
  final ValueChanged<PouchType?> onTypeChanged;
  final ValueChanged<int> onDrawCountChanged;
  final VoidCallback onRunSimulation;
  final VoidCallback onResetSimulation;

  PouchSimulationScreenUI({
    super.key,
    required this.selectedType,
    required this.drawCountOptions,
    required this.selectedDrawCount,
    required this.isSimulating,
    required this.onTypeChanged,
    required this.onDrawCountChanged,
    required this.onRunSimulation,
    required this.onResetSimulation,
  });

  final NumberFormat _numberFormat = NumberFormat('#,##0');

  String _getPouchImagePath(PouchType type) {
    switch (type) {
      case PouchType.soulStone:
        return 'assets/images/pouch/soulStone.png';
      case PouchType.gold:
        return 'assets/images/pouch/gold.png';
      case PouchType.stamina:
        return 'assets/images/pouch/stamina.png';
    }
  }

  String _getResultPouchImagePath(PouchType type) {
    switch (type) {
      case PouchType.soulStone:
        return 'assets/images/inpouch/soulStone.png';
      case PouchType.gold:
        return 'assets/images/inpouch/gold.png';
      case PouchType.stamina:
        return 'assets/images/inpouch/stamina.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주머니 시뮬레이션'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '결과 초기화',
            onPressed: onResetSimulation,
          ),
        ],
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.pouchSimulation),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '시뮬레이션 설정',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Image.asset(
                _getPouchImagePath(selectedType),
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PouchType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: '주머니 선택',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: PouchType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ))
                  .toList(),
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: 12),
            Text(
              '1회당 개봉 개수',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: drawCountOptions.map((count) {
                final isSelected = count == selectedDrawCount;
                return ChoiceChip(
                  label: Text('${_numberFormat.format(count)}회'),
                  selected: isSelected,
                  onSelected: (_) => onDrawCountChanged(count),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSimulating ? null : onRunSimulation,
                    icon: isSimulating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: const Text('시뮬레이션 실행'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onResetSimulation,
                  child: const Text('초기화'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PouchResultDialog extends StatelessWidget {
  final PouchType pouchType;
  final List<int> results;

  const PouchResultDialog({
    super.key,
    required this.pouchType,
    required this.results,
  });

  String _getResultPouchImagePath(PouchType type) {
    switch (type) {
      case PouchType.soulStone:
        return 'assets/images/inpouch/soulStone.png';
      case PouchType.gold:
        return 'assets/images/inpouch/gold.png';
      case PouchType.stamina:
        return 'assets/images/inpouch/stamina.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat numberFormat = NumberFormat('#,##0');
    final imagePath = _getResultPouchImagePath(pouchType);

    return AlertDialog(
      title: const Text('주머니 개봉 결과', textAlign: TextAlign.center),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: results.map((amount) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numberFormat.format(amount),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
