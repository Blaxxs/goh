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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: displayCharacters.length,
            itemBuilder: (context, index) {
              final character = displayCharacters[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(character),
                child: Card(
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        child: Text(
                          character.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            character.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => const Icon(Icons.error, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
