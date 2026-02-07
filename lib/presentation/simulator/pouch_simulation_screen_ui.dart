import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/box_constants.dart';
import '../../core/widgets/app_drawer.dart';
import 'pouch_simulation_screen.dart';

class PouchSimulationScreenUI extends StatelessWidget {
  final PouchType selectedType;
  final List<int> drawCountOptions;
  final int selectedDrawCount;
  final TextEditingController simulationCountController;
  final bool isSimulating;
  final PouchSimulationResult? result;
  final ValueChanged<PouchType?> onTypeChanged;
  final ValueChanged<int> onDrawCountChanged;
  final VoidCallback onRunSimulation;
  final VoidCallback onResetSimulation;

  PouchSimulationScreenUI({
    super.key,
    required this.selectedType,
    required this.drawCountOptions,
    required this.selectedDrawCount,
    required this.simulationCountController,
    required this.isSimulating,
    required this.result,
    required this.onTypeChanged,
    required this.onDrawCountChanged,
    required this.onRunSimulation,
    required this.onResetSimulation,
  });

  final NumberFormat _numberFormat = NumberFormat('#,##0');
  final NumberFormat _decimalFormat = NumberFormat('#,##0.00');

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
            const SizedBox(height: 12),
            TextField(
              controller: simulationCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '시뮬레이션 횟수',
                border: OutlineInputBorder(),
                isDense: true,
              ),
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
            const SizedBox(height: 20),
            if (result != null) ...[
              Text(
                '시뮬레이션 결과',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '총 ${_numberFormat.format(result!.trials)}회, '
                        '1회당 ${_numberFormat.format(result!.drawsPerTrial)}개',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '평균 획득량: ${_decimalFormat.format(result!.mean)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '분산: ${_decimalFormat.format(result!.variance)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '최소/최대: '
                        '${_numberFormat.format(result!.min)} '
                        '/ ${_numberFormat.format(result!.max)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '상위 히스토그램(Top 10)',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...result!.topHistogram.map((entry) {
                        final percent =
                            (entry.value / result!.trials) * 100.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${_numberFormat.format(entry.key)}: '
                            '${_numberFormat.format(entry.value)}회 '
                            '(${_decimalFormat.format(percent)}%)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                '시뮬레이션을 실행하면 결과가 표시됩니다.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
