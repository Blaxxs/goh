import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/box_constants.dart';
import '../../core/widgets/app_drawer.dart';
import 'pouch_simulation_screen.dart';

class PouchSimulationScreenUI extends StatelessWidget {
  final PouchType selectedType;
  final List<int> drawCountOptions;
  final int selectedDrawCount;
  final bool useCustomDrawCount;
  final TextEditingController customDrawCountController;
  final bool isSimulating;
  final List<int> lastResults;
  final ValueChanged<PouchType?> onTypeChanged;
  final ValueChanged<int> onDrawCountChanged;
  final VoidCallback onSelectCustomDrawCount;
  final VoidCallback onRunSimulation;
  final VoidCallback onResetSimulation;

  PouchSimulationScreenUI({
    super.key,
    required this.selectedType,
    required this.drawCountOptions,
    required this.selectedDrawCount,
    required this.useCustomDrawCount,
    required this.customDrawCountController,
    required this.isSimulating,
    required this.lastResults,
    required this.onTypeChanged,
    required this.onDrawCountChanged,
    required this.onSelectCustomDrawCount,
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
              decoration: InputDecoration(
                labelText: '주머니 선택',
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
              items: PouchType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ))
                  .toList(),
              onChanged: onTypeChanged,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            const SizedBox(height: 12),
            Text(
              '개봉 개수',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: drawCountOptions.map((count) {
                final isSelected = count == selectedDrawCount && !useCustomDrawCount;
                return ChoiceChip(
                  label: Text('${_numberFormat.format(count)}개'),
                  selected: isSelected,
                  onSelected: (_) => onDrawCountChanged(count),
                );
              }).toList()
                ..add(
                  ChoiceChip(
                    label: const Text('직접 입력'),
                    selected: useCustomDrawCount,
                    onSelected: (_) => onSelectCustomDrawCount(),
                  ),
                ),
            ),
            if (useCustomDrawCount) ...[
              const SizedBox(height: 8),
              TextField(
                controller: customDrawCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '개봉 개수 직접 입력',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ],
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
                        : const Icon(Icons.inventory_2_outlined),
                    label: const Text('개봉'),
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
            Text(
              '개봉 결과',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (lastResults.isEmpty)
              Text(
                '아직 개봉 결과가 없습니다.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: lastResults.map((amount) {
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          children: [
                            Image.asset(
                              _getResultPouchImagePath(selectedType),
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Text(
                                _numberFormat.format(amount),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
