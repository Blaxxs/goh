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
  final ExplorationOptionGrade protectionGrade;
  final ExplorationOptionGrade autoTargetGrade;
  final int totalResourceConsumed;
  final List<String> simulationLog;
  final bool isSimulating;
  final bool isAutoRunning;
  final Map<ExplorationOptionGrade, int> gradeCount;
  final Function(int) onSetExplorationLevel;
  final Function(ExplorationOptionGrade) onSetProtectionGrade;
  final Function(ExplorationOptionGrade) onSetAutoTargetGrade;
  final VoidCallback onStartAutoChange;
  final VoidCallback onStopAutoChange;
  final Function(int) onToggleSlotLock;
  final VoidCallback onRunAllSlotsSimulation;
  final VoidCallback onResetSimulation;

  const ExplorationOptionSimulationScreenUI({
    super.key,
    required this.explorationLevel,
    required this.slotOptions,
    required this.slotGrades,
    required this.slotLocked,
    required this.protectionGrade,
    required this.autoTargetGrade,
    required this.totalResourceConsumed,
    required this.simulationLog,
    required this.isSimulating,
    required this.isAutoRunning,
    required this.gradeCount,
    required this.onSetExplorationLevel,
    required this.onSetProtectionGrade,
    required this.onSetAutoTargetGrade,
    required this.onStartAutoChange,
    required this.onStopAutoChange,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '탐 단계',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${explorationLevel}탐',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                IconButton(
                  onPressed: explorationLevel > 1
                      ? () => onSetExplorationLevel(explorationLevel - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
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
                ),
                IconButton(
                  onPressed: explorationLevel < 10
                      ? () => onSetExplorationLevel(explorationLevel + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                ),
              ],
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
          title: const Text('등급별 확률 (전체/옵션별)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ExplorationOptionGrade.values.map((grade) {
              final overall = grade.probability;
              final perOption =
                  overall / ExplorationOptionData.options.length.toDouble();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        grade.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${overall.toStringAsFixed(1)}% / ${perOption.toStringAsFixed(4)}%',
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
            ...List.generate(explorationLevel, (index) {
              final option = slotOptions[index];
              final grade = slotGrades[index];
              final isLocked = slotLocked[index];
              final Color gradeColor = _gradeColor(theme, grade);
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: grade != null
                            ? gradeColor
                            : (isDark ? Colors.grey[700] : Colors.grey[400]),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _gradeLetter(grade),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLocked
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                            width: isLocked ? 1.4 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option?.name ?? '미설정',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: option != null
                                      ? gradeColor
                                      : Colors.grey,
                                  fontStyle: option != null
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_optionValueText(option, grade) != null)
                              Text(
                                _optionValueText(option, grade)!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: gradeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
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
                            size: 18,
                            color: isLocked
                                ? theme.colorScheme.primary
                                : Colors.grey,
                          ),
                          tooltip: isLocked ? '잠금 해제' : '잠금',
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

  String _gradeLetter(ExplorationOptionGrade? grade) {
    if (grade == null) return '?';
    switch (grade) {
      case ExplorationOptionGrade.c:
        return 'C';
      case ExplorationOptionGrade.b:
        return 'B';
      case ExplorationOptionGrade.a:
        return 'A';
      case ExplorationOptionGrade.s:
        return 'S';
      case ExplorationOptionGrade.ss:
        return 'SS';
    }
  }

  Color _gradeColor(ThemeData theme, ExplorationOptionGrade? grade) {
    switch (grade) {
      case ExplorationOptionGrade.c:
        return Colors.grey;
      case ExplorationOptionGrade.b:
        return Colors.purple;
      case ExplorationOptionGrade.a:
        return Colors.blue;
      case ExplorationOptionGrade.s:
        return Colors.amber;
      case ExplorationOptionGrade.ss:
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _darkGreenColor() {
    return const Color(0xFF2E7D32);
  }

  String? _optionValueText(
      ExplorationOption? option, ExplorationOptionGrade? grade) {
    if (option == null || grade == null) return null;
    final value = option.valueForGrade(grade);
    if (value == null) return null;
    return '$value';
  }

  void _handleOptionChangePressed(BuildContext context, ThemeData theme) {
    final grades = ExplorationOptionGrade.values;
    final protectIndex = grades.indexOf(protectionGrade);

    final hasUnprotectedProtectedGrade = slotGrades.asMap().entries.any((entry) {
      final index = entry.key;
      final grade = entry.value;
      if (grade == null) return false;
      if (slotLocked[index]) return false;
      return grades.indexOf(grade) >= protectIndex;
    });

    if (!hasUnprotectedProtectedGrade) {
      onRunAllSlotsSimulation();
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            '잠겨 있지 않은 보호 등급 옵션이 존재합니다. 옵션 변경 시 해당 옵션의 등급이 하락 할 수 있습니다.\n\n옵션 변경을 시도하시겠습니까?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRunAllSlotsSimulation();
              },
              child: const Text('옵션 변경'),
            ),
          ],
        );
      },
    );
  }

  /// 시뮬레이션 제어 카드
  Widget _buildSimulationControlCard(
      BuildContext context, ThemeData theme, bool isDark,
      {required int lockedCount, required bool allLocked}) {
    final int cost = 50 + (lockedCount * 50);
    final grades = ExplorationOptionGrade.values;
    final protectionIndex = grades.indexOf(protectionGrade);
    final protectionPrev =
        grades[(protectionIndex - 1 + grades.length) % grades.length];
    final protectionNext = grades[(protectionIndex + 1) % grades.length];
    final autoIndex = grades.indexOf(autoTargetGrade);
    final autoPrev = grades[(autoIndex - 1 + grades.length) % grades.length];
    final autoNext = grades[(autoIndex + 1) % grades.length];
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
                Expanded(
                  child: Text(
                    '보호 등급',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onSetProtectionGrade(protectionPrev),
                  icon: const Icon(Icons.chevron_left),
                  visualDensity: VisualDensity.compact,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gradeColor(theme, protectionGrade),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    protectionGrade.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onSetProtectionGrade(protectionNext),
                  icon: const Icon(Icons.chevron_right),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '자동 변경 목표',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onSetAutoTargetGrade(autoPrev),
                  icon: const Icon(Icons.chevron_left),
                  visualDensity: VisualDensity.compact,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gradeColor(theme, autoTargetGrade),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    autoTargetGrade.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onSetAutoTargetGrade(autoNext),
                  icon: const Icon(Icons.chevron_right),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed:
                      isAutoRunning ? onStopAutoChange : onStartAutoChange,
                  child: Text(isAutoRunning ? '멈춤' : '자동 변경'),
                ),
              ],
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
                    color: _darkGreenColor(),
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
                        : () => _handleOptionChangePressed(
                              context,
                              theme,
                            ),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkGreenColor(),
                      side: BorderSide(color: _darkGreenColor()),
                    ),
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
                    color: _darkGreenColor().withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '총 $totalCount회',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _darkGreenColor(),
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
                color: _darkGreenColor(),
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
                    color: _darkGreenColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
