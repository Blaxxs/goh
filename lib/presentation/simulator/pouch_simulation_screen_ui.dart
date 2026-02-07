import 'dart:math';

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
                isDense: false,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
              isExpanded: true,
              items: PouchType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.label,
                          overflow: TextOverflow.ellipsis,
                        ),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      content: Builder(
        builder: (context) {
          final int count = results.length;
          final Size screenSize = MediaQuery.of(context).size;
          final double maxWidth = screenSize.width * 0.9;
          final double maxHeight = screenSize.height * 0.6;
          final double spacing = 8;
          final int columns = (maxWidth / 52).floor().clamp(5, 12);
          final int rows = (count / columns).ceil().clamp(1, 20);
          final double tileByWidth =
              (maxWidth - (columns - 1) * spacing) / columns;
          final double tileByHeight =
              (maxHeight - (rows - 1) * spacing) / rows;
          final double tileSize =
              max(24, min(52, min(tileByWidth, tileByHeight)));
          final double gridHeight =
              rows * tileSize + (rows - 1) * spacing;
          return SizedBox(
            width: double.maxFinite,
            child: SizedBox(
              height: gridHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final amount = results[index];
                  return SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: Stack(
                      children: [
                        Image.asset(
                          imagePath,
                          width: tileSize,
                          height: tileSize,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Text(
                            numberFormat.format(amount),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
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
