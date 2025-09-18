                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("선택 안함"),
              onPressed: () {
                Navigator.pop(context, {
                  'spirit': spirits[0],
                  'star': 1,
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    final spirit = _detailedSpirit!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _detailedSpirit = null)),
                Expanded(child: Text(spirit.name, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            Image.asset(spirit.imagePath, height: 100, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 100)),
            const SizedBox(height: 16),
            StarSelector(
              initialStar: _selectedStar,
              onChanged: (star) {
                setState(() {
                  _selectedStar = star;
                  _hasChanges = true; // Mark as changed
                  widget.onDamageRecalculated(); // Recalculate after state change
                });
              },
            ),
            const SizedBox(height: 16),
            if (spirit.effects.isNotEmpty)
              Column(
                children: spirit.effects.map((effect) {
                  final value = effect.values[_selectedStar - 1];
                  String text;
                  switch (effect.type) {
                    case SpiritEffectType.skillCoefficient:
                      text = '스킬 계수 +$value%';
                      break;
                    case SpiritEffectType.critDamage:
                      text = '크리티컬 데미지 $value% 증가';
                      break;
                    case SpiritEffectType.baseAttack:
                      text = '기본 공격력 ${value.toInt()} 증가';
                      break;
                    case SpiritEffectType.normalDamage:
                      text = '일반 공격 데미지 $value% 증가';
                      break;
                    case SpiritEffectType.skillDamage:
                      text = '스킬 데미지 $value% 증가';
                      break;
                  }
                  return Text(text);
                }).toList(),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'spirit': _detailedSpirit,
                      'star': _selectedStar,
                    });
                  },
                  child: Text(_hasChanges ? '저장' : '닫기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'spirit': spirits[0],
                      'star': 1,
                    });
                  },
                  child: const Text('초기화'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _detailedSpirit == null ? _buildGridView() : _buildDetailView();
  }
}

class FragmentSelectionDialog extends StatelessWidget {
  const FragmentSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('파편 선택', style: Theme.of(context).textTheme.headlineSmall),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: fragments.length,
                itemBuilder: (context, index) {
                  final fragment = fragments[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(fragment);
                    },
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (fragment.name != '선택 안함')
                            Image.asset(fragment.imagePath, width: 40, height: 40, errorBuilder: (c, o, s) => const Icon(Icons.error))
                          else
                            const Icon(Icons.cancel_outlined, size: 40),
                          Text(fragment.name, textAlign: TextAlign.center),
                        ],
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
