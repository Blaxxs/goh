import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';

class CharacterSelectionDialog extends StatelessWidget {
  const CharacterSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final displayCharacters = characters.where((c) => c.name != '선택 안함').toList();
    return Dialog(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("캐릭터 선택", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: displayCharacters.length,
              itemBuilder: (context, index) {
                final character = displayCharacters[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(character),
                  child: GridTile(
                    footer: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        character.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    child: Image.asset(character.imagePath, fit: BoxFit.contain, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text("선택 취소"),
              onPressed: () {
                Navigator.pop(context, characters[0]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
