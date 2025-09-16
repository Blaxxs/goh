import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';

class CharacterSelectionDialog extends StatelessWidget {
  const CharacterSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final displayCharacters = characters.where((c) => c.name != '선택 안함').toList();
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text("캐릭터 선택", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: displayCharacters.length,
              itemBuilder: (context, index) {
                final character = displayCharacters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(character),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Image.asset(
                            character.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => const Icon(Icons.error, size: 60),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              character.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
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
              label: const Text("선택 취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}