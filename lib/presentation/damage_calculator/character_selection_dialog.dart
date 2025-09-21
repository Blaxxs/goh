import 'package:flutter/material.dart';
import 'package:goh_calculator/core/constants/damage_calculator_constants.dart';

class CharacterSelectionDialog extends StatelessWidget {
  const CharacterSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final displayCharacters = characters.where((c) => c.name != '선택 안함').toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text("캐릭터 선택", style: Theme.of(context).textTheme.headlineSmall),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: displayCharacters.length,
          itemBuilder: (context, index) {
            final character = displayCharacters[index];
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(character),
              child: Tooltip(
                message: character.name,
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias, // Ensures the image respects the card's rounded corners
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      character.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) => const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: const Text("선택 취소"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}