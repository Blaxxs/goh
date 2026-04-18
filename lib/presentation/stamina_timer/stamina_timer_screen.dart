import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/services/settings_service.dart';
import '../../domain/logic/calculator_logic.dart';

class StaminaTimerScreen extends StatefulWidget {
  const StaminaTimerScreen({super.key});

  @override
  State<StaminaTimerScreen> createState() => _StaminaTimerScreenState();
}

class _StaminaTimerScreenState extends State<StaminaTimerScreen> {
  final _currentStaminaController = TextEditingController();
  final _calcLogic = CalculatorLogic();
  final _intFormat = NumberFormat('#,##0');

  int _maxStamina = 0;
  int _currentStamina = 0;
  DateTime? _fullTime;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService.instance.stageSettings;
    _maxStamina = _calcLogic.calculateMaxStamina(
      settings.teamLevel,
      settings.vipLevel,
    );
    _currentStaminaController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _currentStaminaController.removeListener(_onInputChanged);
    _currentStaminaController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    final val = int.tryParse(_currentStaminaController.text.trim()) ?? -1;
    if (val < 0 || val > _maxStamina) {
      setState(() {
        _currentStamina = 0;
        _fullTime = null;
        _remaining = Duration.zero;
      });
      _ticker?.cancel();
      return;
    }
    _recalculate(val);
  }

  void _recalculate(int current) {
    final missing = _maxStamina - current;
    // 스태미너는 5분에 1 회복
    final secondsNeeded = missing * 5 * 60;
    final now = DateTime.now();
    final newFullTime = now.add(Duration(seconds: secondsNeeded));
    setState(() {
      _currentStamina = current;
      _fullTime = newFullTime;
      _remaining = newFullTime.difference(now);
    });
    _ticker?.cancel();
    if (missing > 0) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final diff = _fullTime!.difference(DateTime.now());
        if (diff.isNegative) {
          setState(() => _remaining = Duration.zero);
          _ticker?.cancel();
        } else {
          setState(() => _remaining = diff);
        }
      });
    }
  }

  String _formatRemaining(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h시간 $m분 $s초';
  }

  String _formatTime(DateTime dt) {
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isFull = _maxStamina > 0 && _currentStamina >= _maxStamina;
    final int missing = (_maxStamina - _currentStamina).clamp(0, _maxStamina);
    final double ratio =
        _maxStamina > 0 ? (_currentStamina / _maxStamina).clamp(0.0, 1.0) : 0.0;

    Color progressColor;
    if (ratio >= 0.8) {
      progressColor = Colors.green.shade600;
    } else if (ratio >= 0.4) {
      progressColor = Colors.orange.shade600;
    } else {
      progressColor = theme.colorScheme.error;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('스태미너 타이머')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 최대 스태미너 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최대 스태미너',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      _intFormat.format(_maxStamina),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 현재 스태미너 입력
            TextField(
              controller: _currentStaminaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: '현재 스태미너',
                hintText: '0 ~ ${_intFormat.format(_maxStamina)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.bolt_rounded),
                suffixText: '/ ${_intFormat.format(_maxStamina)}',
              ),
            ),
            const SizedBox(height: 20),
            // 게이지 바
            if (_currentStaminaController.text.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_intFormat.format(_currentStamina)} / ${_intFormat.format(_maxStamina)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${(ratio * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 14,
                  color: progressColor,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 20),
              if (isFull) ...[
                Card(
                  color: Colors.green.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '스태미너가 가득 찼습니다!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_fullTime != null) ...[
                // 남은 시간 카드
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '충전 완료까지',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatRemaining(_remaining),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('부족량',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                )),
                            Text(
                              '${_intFormat.format(missing)} 스태미너',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('완충 예정 시각',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                )),
                            Text(
                              _formatTime(_fullTime!),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 회복 기준 빠른 참조
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('빠른 참조',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        _buildQuickRow(
                            context,
                            '30분 후',
                            '+${_intFormat.format(6)} 스태미너',
                            _currentStamina + 6,
                            _maxStamina),
                        _buildQuickRow(
                            context,
                            '1시간 후',
                            '+${_intFormat.format(12)} 스태미너',
                            _currentStamina + 12,
                            _maxStamina),
                        _buildQuickRow(
                            context,
                            '3시간 후',
                            '+${_intFormat.format(36)} 스태미너',
                            _currentStamina + 36,
                            _maxStamina),
                        _buildQuickRow(
                            context,
                            '6시간 후',
                            '+${_intFormat.format(72)} 스태미너',
                            _currentStamina + 72,
                            _maxStamina),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRow(BuildContext context, String timeLabel, String change,
      int projected, int max) {
    final theme = Theme.of(context);
    final clamped = projected.clamp(0, max);
    final isCapped = projected >= max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(timeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          Expanded(
            child: Text(
              change,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            isCapped
                ? '만충!'
                : '${_intFormat.format(clamped)} / ${_intFormat.format(max)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCapped
                  ? Colors.green.shade600
                  : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
