import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/random_accessory_constants.dart';
import '../../data/models/accessory.dart';

class RandomAccessorySimulatorScreen extends StatefulWidget {
  final Accessory initialAccessory;

  const RandomAccessorySimulatorScreen({
    super.key,
    required this.initialAccessory,
  });

  @override
  State<RandomAccessorySimulatorScreen> createState() =>
      _RandomAccessorySimulatorScreenState();
}

class _RandomAccessorySimulatorScreenState
    extends State<RandomAccessorySimulatorScreen> {
  late Accessory _selectedAccessory;
  bool _useGoldMoru = false;
  bool _isModify = false;
  RandomAccessoryRollResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _selectedAccessory = widget.initialAccessory;
  }

  @override
  Widget build(BuildContext context) {
    final config = RandomAccessoryRepository.configOf(_selectedAccessory.id);
    final cost = _isModify ? config?.modifyCost ?? {} : config?.craftCost ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('랜덤악세 시뮬레이터'),
      ),
      body: config == null
          ? const Center(child: Text('랜덤 악세 설정을 찾을 수 없습니다.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccessoryPicker(context),
                  const SizedBox(height: 10),
                  _buildModeControls(context, config),
                  const SizedBox(height: 10),
                  _buildCostCard(context, cost),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final result = RandomAccessoryRepository.roll(
                          config: config,
                          useGoldMoru: _useGoldMoru,
                        );
                        setState(() {
                          _lastResult = result;
                        });
                      },
                      icon: const Icon(Icons.casino_outlined),
                      label: Text(_isModify ? '개조 결과 보기' : '제작 결과 보기'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultCard(context, config),
                ],
              ),
            ),
    );
  }

  Widget _buildAccessoryPicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '대상 악세사리',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAccessory.id,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: RandomAccessoryRepository.randomAccessories
                  .map(
                    (a) => DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(a.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = RandomAccessoryRepository.randomAccessories
                    .firstWhere((a) => a.id == value);
                setState(() {
                  _selectedAccessory = selected;
                  _lastResult = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeControls(
      BuildContext context, RandomAccessoryConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('시뮬레이션 조건', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('제작')),
                ButtonSegment<bool>(value: true, label: Text('개조')),
              ],
              selected: {_isModify},
              onSelectionChanged: (value) {
                setState(() {
                  _isModify = value.first;
                });
              },
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('은모루')),
                ButtonSegment<bool>(value: true, label: Text('금모루')),
              ],
              selected: {_useGoldMoru},
              onSelectionChanged: (value) {
                setState(() {
                  _useGoldMoru = value.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              '옵션 개수 확률: ${_optionProbText(config.optionCountProbabilities)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              '등급 확률(${_useGoldMoru ? '금모루' : '은모루'}): ${_gradeProbText(_useGoldMoru ? config.goldMoruGradeProbabilities : config.silverMoruGradeProbabilities)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              '옵션 종류는 균등 확률, 상수 계산은 올림 적용',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(BuildContext context, Map<String, int> cost) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('소모 재화', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            if (cost.isEmpty)
              const Text('설정된 소모 재화가 없습니다.')
            else
              ...cost.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      Text(entry.value.toString()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, RandomAccessoryConfig config) {
    if (_lastResult == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('아직 결과가 없습니다. 제작/개조 버튼을 눌러주세요.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CachedNetworkImage(
                    imageUrl: _selectedAccessory.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAccessory.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text('등급: ${_lastResult!.grade} 테두리'),
                      Text('등장 옵션 수: ${_lastResult!.optionCount}개'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ..._lastResult!.options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(option.optionName)),
                    Text(
                      '${option.value}   (${option.minForGrade}~${option.maxForGrade})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '전체 가능한 옵션 종류: ${config.optionRanges.length}개',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _optionProbText(Map<int, double> probs) {
    final items = probs.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return items
        .map((e) => '${e.key}개 ${e.value.toStringAsFixed(0)}%')
        .join(', ');
  }

  String _gradeProbText(Map<String, double> probs) {
    final blue = probs[RandomAccessoryRepository.gradeBlue] ?? 0;
    final green = probs[RandomAccessoryRepository.gradeGreen] ?? 0;
    final yellow = probs[RandomAccessoryRepository.gradeYellow] ?? 0;
    return '파랑 ${blue.toStringAsFixed(0)}%, 초록 ${green.toStringAsFixed(0)}%, 노랑 ${yellow.toStringAsFixed(0)}%';
  }
}
