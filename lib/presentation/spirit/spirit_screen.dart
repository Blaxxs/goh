import 'package:flutter/material.dart';

import '../../core/constants/box_constants.dart';
import '../accessory/accessory_screen.dart';

class SpiritScreen extends StatelessWidget {
  const SpiritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccessoryScreen(
      collectionTitle: '스피릿 도감',
      pickerTitle: '스피릿 선택',
      currentScreen: AppScreen.spirit,
    );
  }
}
