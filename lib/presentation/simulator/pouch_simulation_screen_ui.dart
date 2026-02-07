import 'dart:math';
import 'dart:ui';

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
  final List<String> openLogs;
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
    required this.openLogs,
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
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.pouchSimulation),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (context) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;
                    final Offset offset =
                        button.localToGlobal(Offset.zero, ancestor: overlay);
                    final double menuWidth = button.size.width;
                    final RelativeRect position = RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy + button.size.height,
                      overlay.size.width - offset.dx - menuWidth,
                      overlay.size.height - offset.dy - button.size.height,
                    );

                    final PouchType? selected = await showMenu<PouchType>(
                      context: context,
                      position: position,
                      constraints: BoxConstraints.tightFor(width: menuWidth),
                      items: PouchType.values
                          .map(
                            (type) => PopupMenuItem<PouchType>(
                              value: type,
                              child: Row(
                                children: [
                                  Image.asset(
                                    _getPouchImagePath(type),
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      type.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );

                    if (selected != null) {
                      onTypeChanged(selected);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '주머니 선택',
                      isDense: false,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 20),
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedType.label,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.2),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                );
              },
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
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '개봉 로그',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (openLogs.isEmpty)
              Text(
                '아직 개봉 로그가 없습니다.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: openLogs.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: theme.dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        openLogs[index],
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onResetSimulation,
              icon: const Icon(Icons.delete_outline),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.onSurface
                    : null,
                side: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.dividerColor,
                ),
              ),
              label: const Text('로그 초기화'),
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
    final double amountFontSize =
      pouchType == PouchType.gold ? 11 : 15;

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
            const double tileSize = 52;
            final double maxCrossAxisExtent = tileSize + spacing;
            final int columns =
              (maxWidth / maxCrossAxisExtent).floor().clamp(5, 100);
          final int rows = (count / columns).ceil().clamp(1, 20);
          final double gridHeight =
              rows * tileSize + (rows - 1) * spacing;
          final double dialogHeight = min(maxHeight, gridHeight);
          return SizedBox(
            width: double.maxFinite,
            child: SizedBox(
              height: dialogHeight,
              child: GridView.builder(
                physics: const ClampingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final amount = results[index];
                  return LayoutBuilder(
                    builder: (context, cellConstraints) {
                      final double cellSize =
                          min(cellConstraints.maxWidth, cellConstraints.maxHeight);
                      final double renderSize = min(tileSize, cellSize);
                      return Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: renderSize,
                          height: renderSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                imagePath,
                                width: renderSize,
                                height: renderSize,
                                fit: BoxFit.contain,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width: renderSize,
                                  child: Text(
                                    'x${numberFormat.format(amount)}',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: amountFontSize,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
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
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
