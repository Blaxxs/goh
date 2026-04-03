import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/stage_constants.dart';
import '../../core/constants/leader_constants.dart';
import '../../core/services/settings_service.dart';
import '../../domain/logic/calculator_logic.dart';
import '../stage_settings/settings_screen.dart';

enum ReverseCalcTarget { gold, stamina }

class ReverseCalculatorScreen extends StatefulWidget {
  const ReverseCalculatorScreen({super.key});

  @override
  State<ReverseCalculatorScreen> createState() =>
      _ReverseCalculatorScreenState();
}

class _ReverseCalculatorScreenState extends State<ReverseCalculatorScreen> {
  final _targetController = TextEditingController();
  final _calcLogic = CalculatorLogic();
  final _intFormat = NumberFormat('#,##0');

  ReverseCalcTarget _calcTarget = ReverseCalcTarget.gold;
  String? _selectedStage;
  String? _selectedLeader;
  bool _goldHotTime = false;
  bool _goldBoost = false;

  // 결과
  double? _goldPerLoop;
  int? _loopsNeeded;
  double? _timeNeeded; // 분
  int? _staminaNeeded;

  bool _areEssentialSettingsSet() {
    final settings = SettingsService.instance.stageSettings;
    return settings.teamLevel != null &&
        settings.teamLevel!.isNotEmpty &&
        settings.dalgijiLevel != null &&
        settings.dalgijiLevel!.isNotEmpty &&
        settings.vipLevel != null &&
        settings.vipLevel!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final settings = SettingsService.instance.stageSettings;
    final calcSettings = SettingsService.instance.calculatorSettings;
    _selectedLeader = calcSettings.selectedLeader ?? leaderList.first;
    _goldHotTime = calcSettings.goldHotTime;
    _goldBoost = calcSettings.goldBoost;
    // 설정된 스테이지 중 첫 번째를 기본 선택
    for (final stage in stageNameList) {
      final ct = settings.stageClearTimes[stage];
      if (ct != null && ct.isNotEmpty) {
        _selectedStage = stage;
        break;
      }
    }
    _selectedStage ??= stageNameList.isNotEmpty ? stageNameList.first : null;
    _targetController.addListener(_calculate);
  }

  @override
  void dispose() {
    _targetController.removeListener(_calculate);
    _targetController.dispose();
    super.dispose();
  }

  void _calculate() {
    final targetRaw = _targetController.text.replaceAll(',', '').trim();
    final target = double.tryParse(targetRaw);
    if (target == null || target <= 0 || _selectedStage == null) {
      setState(() {
        _goldPerLoop = null;
        _loopsNeeded = null;
        _timeNeeded = null;
        _staminaNeeded = null;
      });
      return;
    }

    final stageSettings = SettingsService.instance.stageSettings;
    final vipLevel = stageSettings.vipLevel;
    final clearTimeStr = stageSettings.stageClearTimes[_selectedStage];
    final clearTime = double.tryParse(clearTimeStr ?? '');
    final stageData = stageBaseData[_selectedStage];
    final staminaCost =
        (stageData?['staminaCost'] as num?)?.toDouble() ?? 0.0;

    if (_calcTarget == ReverseCalcTarget.gold) {
      final gpl = _calcLogic.calculateFinalGoldPerLoop(
          _selectedStage!, _goldHotTime, _goldBoost, vipLevel, _selectedLeader);
      if (gpl <= 0) {
        setState(() {
          _goldPerLoop = null;
          _loopsNeeded = null;
          _timeNeeded = null;
          _staminaNeeded = null;
        });
        return;
      }
      final loops = (target / gpl).ceil();
      final timeMin =
          (clearTime != null && clearTime > 0) ? (loops * clearTime / 60) : null;
      final stamina =
          staminaCost > 0 ? (loops * staminaCost).ceil() : null;
      setState(() {
        _goldPerLoop = gpl;
        _loopsNeeded = loops;
        _timeNeeded = timeMin;
        _staminaNeeded = stamina;
      });
    } else {
      // 스태미너: target = 필요 스태미너
      final targetStamina = target.toInt();
      if (staminaCost <= 0) {
        setState(() {
          _goldPerLoop = null;
          _loopsNeeded = null;
          _timeNeeded = null;
          _staminaNeeded = null;
        });
        return;
      }
      final loops = (targetStamina / staminaCost).ceil();
      final timeMin =
          (clearTime != null && clearTime > 0) ? (loops * clearTime / 60) : null;
      final goldPerLoop = _calcLogic.calculateFinalGoldPerLoop(
          _selectedStage!, _goldHotTime, _goldBoost, vipLevel, _selectedLeader);
      setState(() {
        _goldPerLoop = goldPerLoop > 0 ? goldPerLoop * loops : null;
        _loopsNeeded = loops;
        _timeNeeded = timeMin;
        _staminaNeeded = targetStamina;
      });
    }
  }

  String _formatTime(double minutes) {
    final h = (minutes / 60).floor();
    final m = (minutes % 60).floor();
    final s = ((minutes * 60) % 60).floor();
    if (h > 0) return '${h}시간 ${m}분';
    if (m > 0) return '${m}분 ${s}초';
    return '${s}초';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageSettings = SettingsService.instance.stageSettings;
    final settingsComplete = _areEssentialSettingsSet();

    return Scaffold(
      appBar: AppBar(title: const Text('역산 계산기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!settingsComplete)
              Card(
                color: theme.colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.warning_amber_rounded,
                      color: theme.colorScheme.error),
                  title: Text(
                    '스테이지 설정 전에는 정확한 결과를 볼 수 없습니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Text('설정하기'),
                  ),
                ),
              ),
            if (!settingsComplete) const SizedBox(height: 12),
            // 목표 선택 탭
            SegmentedButton<ReverseCalcTarget>(
              segments: const [
                ButtonSegment(
                  value: ReverseCalcTarget.gold,
                  label: Text('골드 목표'),
                  icon: Icon(Icons.paid_rounded),
                ),
                ButtonSegment(
                  value: ReverseCalcTarget.stamina,
                  label: Text('스태미너 소모'),
                  icon: Icon(Icons.bolt_rounded),
                ),
              ],
              selected: {_calcTarget},
              onSelectionChanged: (s) {
                setState(() {
                  _calcTarget = s.first;
                  _targetController.clear();
                  _goldPerLoop = null;
                  _loopsNeeded = null;
                  _timeNeeded = null;
                  _staminaNeeded = null;
                });
              },
            ),
            const SizedBox(height: 16),
            // 목표 입력
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: _calcTarget == ReverseCalcTarget.gold
                    ? '목표 골드'
                    : '소모 스태미너',
                hintText: _calcTarget == ReverseCalcTarget.gold
                    ? '예: 10000000'
                    : '예: 500',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(_calcTarget == ReverseCalcTarget.gold
                    ? Icons.paid_rounded
                    : Icons.bolt_rounded),
              ),
            ),
            const SizedBox(height: 12),
            // 스테이지 선택
            DropdownButtonFormField<String>(
              value: _selectedStage,
              decoration: InputDecoration(
                labelText: '스테이지',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.map_outlined),
              ),
              items: stageNameList.map((stage) {
                final ct = stageSettings.stageClearTimes[stage];
                final hasConfig = ct != null && ct.isNotEmpty;
                return DropdownMenuItem(
                  value: stage,
                  child: Row(
                    children: [
                      Expanded(child: Text(stage)),
                      if (!hasConfig)
                        Text(
                          '미설정',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() {
                _selectedStage = v;
                _calculate();
              }),
            ),
            const SizedBox(height: 12),
            // 리더 + 옵션
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLeader,
                    decoration: InputDecoration(
                      labelText: '리더',
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: leaderList
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedLeader = v;
                      _calculate();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('골드 핫타임'),
                  selected: _goldHotTime,
                  onSelected: (v) => setState(() {
                    _goldHotTime = v;
                    _calculate();
                  }),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('골드 부스트'),
                  selected: _goldBoost,
                  onSelected: (v) => setState(() {
                    _goldBoost = v;
                    _calculate();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 결과 카드
            if (_loopsNeeded != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '계산 결과',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      _buildResultRow(
                        context,
                        '필요 루프 수',
                        '${_intFormat.format(_loopsNeeded!)}회',
                        icon: Icons.loop_rounded,
                      ),
                      if (_staminaNeeded != null &&
                          _calcTarget == ReverseCalcTarget.gold)
                        _buildResultRow(
                          context,
                          '소모 스태미너',
                          '${_intFormat.format(_staminaNeeded!)}',
                          icon: Icons.bolt_rounded,
                        ),
                      if (_goldPerLoop != null &&
                          _calcTarget == ReverseCalcTarget.stamina)
                        _buildResultRow(
                          context,
                          '예상 획득 골드',
                          '${_intFormat.format(_goldPerLoop!.round())}',
                          icon: Icons.paid_rounded,
                        ),
                      if (_timeNeeded != null)
                        _buildResultRow(
                          context,
                          '예상 소요 시간',
                          _formatTime(_timeNeeded!),
                          icon: Icons.timer_outlined,
                          highlight: true,
                        )
                      else
                        _buildResultRow(
                          context,
                          '예상 소요 시간',
                          '클리어 시간 미설정',
                          icon: Icons.timer_off_outlined,
                        ),
                      if (_calcTarget == ReverseCalcTarget.gold &&
                          _goldPerLoop != null) ...[
                        const Divider(height: 20),
                        _buildResultRow(
                          context,
                          '루프당 골드',
                          '${_intFormat.format(_goldPerLoop!.round())}',
                          icon: Icons.monetization_on_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 스태미너 회복 시간 안내
              if (_staminaNeeded != null &&
                  _calcTarget == ReverseCalcTarget.gold) ...[
                Card(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '스태미너 ${_intFormat.format(_staminaNeeded!)}개 소모 → '
                            '자연 회복 시 약 ${_formatTime(_staminaNeeded! * 5 / 60)} 필요',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else if (_targetController.text.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '스테이지가 설정되지 않았거나 데이터가 없습니다.\n스테이지 설정에서 클리어 시간을 입력해주세요.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 16,
                color: highlight
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? theme.colorScheme.primary : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
