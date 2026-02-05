// lib/presentation/simulator/exploration_option_simulation_screen_ui.dart
import 'package:flutter/material.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/box_constants.dart';
import 'exploration_option_simulation_screen.dart';

/// 탐 옵션 시뮬레이션 화면 UI
class ExplorationOptionSimulationScreenUI extends StatelessWidget {
  final int explorationLevel;
  final List<ExplorationOption?> slotOptions;
  final List<ExplorationOptionGrade?> slotGrades;
  final int totalResourceConsumed;
  final List<String> simulationLog;
  final bool isSimulating;
  final Map<ExplorationOptionGrade, int> gradeCount;
  final Function(int) onSetExplorationLevel;
  final Function(int) onRunSlotSimulation;
  final VoidCallback onRunAllSlotsSimulation;
  final VoidCallback onResetSimulation;

  const ExplorationOptionSimulationScreenUI({
    super.key,
    required this.explorationLevel,
    required this.slotOptions,
    required this.slotGrades,
    required this.totalResourceConsumed,
    required this.simulationLog,
    required this.isSimulating,
    required this.gradeCount,
    required this.onSetExplorationLevel,
    required this.onRunSlotSimulation,
    required this.onRunAllSlotsSimulation,
    required this.onResetSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.explorationOptionSimulation),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 탐 레벨 선택 카드
            _buildExplorationLevelCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 등급별 확률 표시
            _buildGradeProbabilityCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 옵션 슬롯 카드
            _buildOptionSlotsCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 시뮬레이션 제어 카드
            _buildSimulationControlCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 등급별 결과 표시
            if (gradeCount.values.any((count) => count > 0)) ...[
              _buildGradeResultCard(context, theme, isDark),
              const SizedBox(height: 16),
            ],

            // 누적 재화 소모 표시
            if (totalResourceConsumed > 0) ...[
              _buildResourceConsumptionCard(context, theme, isDark),
              const SizedBox(height: 16),
            ],

            // 시뮬레이션 로그 표시
            if (simulationLog.isNotEmpty) ...[
              _buildSimulationLogCard(context, theme, isDark),
            ],
          ],
        ),
      ),
    );
  }

  /// 탐 레벨 선택 카드
  Widget _buildExplorationLevelCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '탐 레벨 선택 (1탐 ~ 10탐)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '현재 탐 레벨: ${explorationLevel}탐 (옵션 ${explorationLevel}칸)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                final level = index + 1;
                final isSelected = explorationLevel == level;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    foregroundColor: isSelected ? Colors.white : Colors.grey[700],
                    elevation: isSelected ? 4 : 1,
                  ),
                  onPressed: () => onSetExplorationLevel(level),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$level',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '탐',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 등급별 확률 카드
  Widget _buildGradeProbabilityCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '등급별 확률 (각 옵션당)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ExplorationOptionGrade.values.map((grade) {
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
                        '$percentage%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
            }).toList(),
          ],
        ),
      ),
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
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (grade != null)
                                    Text(
                                      grade.label,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.grey,
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
                                  style: BorderStyle.solid,
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
                    ElevatedButton(
                      onPressed: isSimulating
                          ? null
                          : () => onRunSlotSimulation(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        '설정',
                        style: theme.textTheme.labelSmall,
                      ),
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
      BuildContext context, ThemeData theme, bool isDark) {
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
                  child: ElevatedButton.icon(
                    onPressed: isSimulating ? null : onRunAllSlotsSimulation,
                    icon: isSimulating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(isSimulating ? '실행 중...' : '전체 설정'),
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
              final percentage =
                  totalCount > 0 ? (count / totalCount * 100).toStringAsFixed(1) : '0.0';
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
                  '총 재화 소모:',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentScreen: AppScreen.explorationOptionSimulation),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 탐 레벨 선택 카드
            _buildExplorationLevelCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 등급별 확률 표시
            _buildGradeProbabilityCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 옵션 슬롯 카드
            _buildOptionSlotsCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 시뮬레이션 제어 카드
            _buildSimulationControlCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 등급별 결과 표시
            if (gradeCount.values.any((count) => count > 0)) ...[
              _buildGradeResultCard(context, theme, isDark),
              const SizedBox(height: 16),
            ],

            // 누적 재화 소모 표시
            if (totalResourceConsumed > 0) ...[
              _buildResourceConsumptionCard(context, theme, isDark),
              const SizedBox(height: 16),
            ],

            // 시뮬레이션 로그 표시
            if (simulationLog.isNotEmpty) ...[
              _buildSimulationLogCard(context, theme, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplorationSelectionCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '탐 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (selectedExploration != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedExploration!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onResetSimulation,
                      tooltip: '선택 해제',
                    ),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onSelectExploration,
                icon: const Icon(Icons.explore),
                label: const Text('탐 선택하기'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOptionsCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '옵션 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (selectedOption == null)
              Text(
                '아래에서 옵션을 선택하세요.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '선택됨:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedOption!.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onResetSimulation,
                      tooltip: '선택 해제',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSelectionCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '옵션 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExplorationOptionData.options.map((option) {
                final isSelected = selectedOption?.name == option.name;
                return FilterChip(
                  label: Text(option.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onSelectOption(option);
                    } else {
                      onSelectOption(option); // 토글
                    }
                  },
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: theme.colorScheme.primary.withAlpha(100),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeProbabilityCard(
      BuildContext context, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '등급별 확률',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ExplorationOptionGrade.values.map((grade) {
              final percentage = (grade.probability * 100).toStringAsFixed(1);
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
                        '$percentage%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationControlCard(
      BuildContext context, ThemeData theme, bool isDark) {
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
                  child: ElevatedButton.icon(
                    onPressed: isSimulating ? null : onRunSimulation,
                    icon: isSimulating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(isSimulating ? '실행 중...' : '시뮬레이션 실행'),
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
                  '전체 결과',
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
              final percentage =
                  totalCount > 0 ? (count / totalCount * 100).toStringAsFixed(1) : '0.0';
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
                );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionResultCard(
      BuildContext context, ThemeData theme, bool isDark) {
    if (selectedOption == null) {
      return const SizedBox.shrink();
    }

    final optionResults = optionGradeCount[selectedOption!.name] ?? {};
    final optionTotal = optionResults.values.fold<int>(0, (a, b) => a + b);

    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedOption!.name} 결과',
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
                    '총 $optionTotal회',
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
              final count = optionResults[grade] ?? 0;
              final percentage =
                  optionTotal > 0 ? (count / optionTotal * 100).toStringAsFixed(1) : '0.0';
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
                );
            }).toList(),
          ],
        ),
      ),
    );
  }

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
                  '총 재화 소모:',
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
                      '${index + 1}. ${simulationLog[index]}',
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
