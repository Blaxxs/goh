// lib/presentation/simulator/exploration_option_simulation_screen_ui.dart
import 'package:flutter/material.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/box_constants.dart';
import 'exploration_option_simulation_screen.dart';

/// 탐 옵션 시뮬레이션 화면 UI - 1탐~10탐 멀티슬롯 시뮬레이션
class ExplorationOptionSimulationScreenUI extends StatelessWidget {
  final int explorationLevel;
  final List<ExplorationOption?> slotOptions;
  final List<ExplorationOptionGrade?> slotGrades;
  final List<bool> slotLocked;
  final int totalResourceConsumed;
  final List<String> simulationLog;
  final bool isSimulating;
  final Map<ExplorationOptionGrade, int> gradeCount;
  final Function(int) onSetExplorationLevel;
  final Function(int) onToggleSlotLock;
  final VoidCallback onRunAllSlotsSimulation;
  final VoidCallback onResetSimulation;

  const ExplorationOptionSimulationScreenUI({
    super.key,
    required this.explorationLevel,
    required this.slotOptions,
    required this.slotGrades,
    required this.slotLocked,
    required this.totalResourceConsumed,
    required this.simulationLog,
    required this.isSimulating,
    required this.gradeCount,
    required this.onSetExplorationLevel,
    required this.onToggleSlotLock,
    required this.onRunAllSlotsSimulation,
    required this.onResetSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final int lockedCount = slotLocked.where((locked) => locked).length;
    final bool allLocked =
        slotLocked.isNotEmpty && lockedCount == slotLocked.length;

    return Scaffold(
      drawer:
          const AppDrawer(currentScreen: AppScreen.explorationOptionSimulation),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('탐 옵션 시뮬레이션'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildExplorationLevelCard(context, theme, isDark),
            const SizedBox(height: 16),
            _buildOptionSlotsCard(context, theme, isDark),
            const SizedBox(height: 16),
            _buildSimulationControlCard(context, theme, isDark,
                lockedCount: lockedCount, allLocked: allLocked),
            if (gradeCount.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildGradeResultCard(context, theme, isDark),
            ],
            if (totalResourceConsumed > 0) ...[
              const SizedBox(height: 16),
              _buildResourceConsumptionCard(context, theme, isDark),
            ],
            if (simulationLog.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSimulationLogCard(context, theme, isDark),
            ],
            const SizedBox(height: 16),
            _buildGradeProbabilityCard(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  /// 탐 레벨 선택 카드 (축소)
  Widget _buildExplorationLevelCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '탐 단계',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${explorationLevel}탐',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '탐 아이콘(추후 추가 예정)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: explorationLevel > 1
                      ? () => onSetExplorationLevel(explorationLevel - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: explorationLevel.toDouble(),
                    label: '${explorationLevel}탐',
                    onChanged: (value) =>
                        onSetExplorationLevel(value.round()),
                  ),
                ),
                IconButton(
                  onPressed: explorationLevel < 10
                      ? () => onSetExplorationLevel(explorationLevel + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text(
              '옵션 ${explorationLevel}칸',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 등급별 확률 카드 (하단 배치)
  Widget _buildGradeProbabilityCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '등급별 확률',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: '확률 보기',
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showGradeProbabilityDialog(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeProbabilityDialog(BuildContext context, ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('등급별 확률 (각 옵션당)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ExplorationOptionGrade.values.map((grade) {
              final percentage = (grade.probability).toStringAsFixed(4);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      grade.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  /// 옵션 슬롯 카드
  Widget _buildOptionSlotsCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '옵션 슬롯 (${explorationLevel}칸)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(explorationLevel, (index) {
              final option = slotOptions[index];
              final grade = slotGrades[index];
              final isLocked = slotLocked[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: option != null
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: isLocked
                                    ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 1.2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (grade != null)
                                    Text(
                                      grade.label,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (isLocked)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '잠금 유지',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: Text(
                                '미설정',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          onPressed: isSimulating
                              ? null
                              : () => onToggleSlotLock(index),
                          icon: Icon(
                            isLocked
                                ? Icons.lock
                                : Icons.lock_open_outlined,
                            color: isLocked
                                ? theme.colorScheme.primary
                                : Colors.grey,
                          ),
                          tooltip: isLocked ? '잠금 해제' : '잠금',
                        ),
                        Text(
                          isLocked ? '잠금' : '해제',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLocked
                                ? theme.colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 시뮬레이션 제어 카드
  Widget _buildSimulationControlCard(
      BuildContext context, ThemeData theme, bool isDark,
      {required int lockedCount, required bool allLocked}) {
    final int cost = 50 + (lockedCount * 50);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '시뮬레이션 제어',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '옵션 변경 비용: ',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '$cost 탐의 편린',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '잠금 ${lockedCount}칸 (잠금 1칸당 +50)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            if (allLocked) ...[
              const SizedBox(height: 6),
              Text(
                '모든 옵션이 잠겨 있어 옵션 변경이 불가합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (isSimulating || allLocked)
                        ? null
                        : onRunAllSlotsSimulation,
                    icon: isSimulating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(isSimulating ? '실행 중...' : '옵션 변경'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSimulating ? null : onResetSimulation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('초기화'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 등급별 결과 카드
  Widget _buildGradeResultCard(
      BuildContext context, ThemeData theme, bool isDark) {
    final totalCount = gradeCount.values.fold<int>(0, (a, b) => a + b);

    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '시뮬레이션 결과',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '총 $totalCount회',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...ExplorationOptionGrade.values.map((grade) {
              final count = gradeCount[grade] ?? 0;
              final percentage = totalCount > 0
                  ? (count / totalCount * 100).toStringAsFixed(1)
                  : '0.0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        grade.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count회',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '$percentage%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 재화 소모량 카드
  Widget _buildResourceConsumptionCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '누적 재화 소모',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 탐의 편린 소모:',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '$totalResourceConsumed',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 시뮬레이션 로그 카드
  Widget _buildSimulationLogCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '시뮬레이션 로그',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${simulationLog.length}건',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: simulationLog.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      simulationLog[index],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
