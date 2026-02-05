// lib/presentation/simulator/exploration_option_simulation_screen_ui.dart
import 'package:flutter/material.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/constants/box_constants.dart';
import 'exploration_option_simulation_screen.dart';

/// 탐 옵션 시뮬레이션 화면 UI
class ExplorationOptionSimulationScreenUI extends StatelessWidget {
  final String? selectedExploration;
  final List<String> currentOptions;
  final int totalResourceConsumed;
  final List<String> simulationLog;
  final bool isSimulating;
  final Map<ExplorationOptionGrade, int> gradeCount;
  final VoidCallback onSelectExploration;
  final VoidCallback onRunSimulation;
  final VoidCallback onResetSimulation;

  const ExplorationOptionSimulationScreenUI({
    super.key,
    this.selectedExploration,
    required this.currentOptions,
    required this.totalResourceConsumed,
    required this.simulationLog,
    required this.isSimulating,
    required this.gradeCount,
    required this.onSelectExploration,
    required this.onRunSimulation,
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
            // 탐 선택 섹션
            _buildExplorationSelectionCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 등급별 확률 표시
            _buildGradeProbabilityCard(context, theme, isDark),
            const SizedBox(height: 16),

            // 현재 옵션 표시 섹션
            if (selectedExploration != null) ...[
              _buildCurrentOptionsCard(context, theme, isDark),
              const SizedBox(height: 16),
            ],

            // 시뮬레이션 컨트롤 섹션
            if (selectedExploration != null) ...[
              _buildSimulationControlCard(context, theme, isDark),
              const SizedBox(height: 16),
            ],

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
              '현재 옵션',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (currentOptions.isEmpty)
              Text(
                '옵션이 없습니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              )
            else
              ...currentOptions.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
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
